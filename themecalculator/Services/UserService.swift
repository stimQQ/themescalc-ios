import Foundation
import Combine
import AuthenticationServices

// 空响应结构体，用于处理不需要返回数据的API响应
struct EmptyResponse: Codable { }

class UserService {
    static let shared = UserService()
    
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // 用户信息
    @Published var currentUser: UserModel?
    @Published var isLoggedIn = false
    @Published var userType: UserType = .guest
    
    // 认证信息
    private var authToken: String?
    
    private init() {
        // 尝试从UserDefaults恢复用户会话
        loadUserSession()
    }
    
    // 使用Apple ID登录
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) -> AnyPublisher<UserModel, NetworkError> {
        // 在实际应用中，可能需要额外处理Apple的认证响应
        guard let identityTokenData = credential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
        }
        
        // 调用后端API验证Apple ID
        struct AppleAuthRequest: Codable {
            let identityToken: String
        }
        
        return networkService.post(endpoint: "auth/apple", body: AppleAuthRequest(identityToken: identityToken))
            .map { (response: AuthResponse) -> UserModel in
                self.authToken = response.token
                self.currentUser = response.user
                self.isLoggedIn = true
                self.userType = .authenticated
                
                // 保存会话信息
                self.saveUserSession(user: response.user, token: response.token)
                
                return response.user
            }
            .eraseToAnyPublisher()
    }
    
    // 访客登录
    func signInAsGuest() {
        let guestUser = UserModel(id: -1, username: "Guest", email: nil, language: AppLanguage.chinese.rawValue)
        currentUser = guestUser
        isLoggedIn = true
        userType = .guest
        
        // 保存访客会话
        saveUserSession(user: guestUser, token: nil)
    }
    
    // 登出
    func signOut() {
        currentUser = nil
        authToken = nil
        isLoggedIn = false
        userType = .guest
        
        // 清除会话信息
        UserDefaults.standard.removeObject(forKey: "user")
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
    
    // 设置用户语言
    func setUserLanguage(language: AppLanguage) {
        guard let user = currentUser else { return }
        
        // 更新内存中的用户语言
        let updatedUser = UserModel(
            id: user.id,
            username: user.username,
            email: user.email,
            language: language.rawValue,
            isSubscribed: user.isSubscribed,
            subscriptionExpiryDate: user.subscriptionExpiryDate
        )
        
        self.currentUser = updatedUser
        
        // 保存更新后的用户信息
        if let userData = try? JSONEncoder().encode(updatedUser) {
            UserDefaults.standard.set(userData, forKey: "user")
        }
        
        // 如果是已认证用户，还需要调用API更新语言偏好
        if userType == .authenticated, let token = authToken {
            struct UpdateLanguageRequest: Codable {
                let language: String
            }
            
            let _ = networkService.post(endpoint: "auth/languages", body: UpdateLanguageRequest(language: language.rawValue))
                .sink(
                    receiveCompletion: { (completion: Subscribers.Completion<NetworkError>) in },
                    receiveValue: { (response: EmptyResponse) in }
                )
                .store(in: &cancellables)
        }
    }
    
    // 保存用户会话到UserDefaults
    private func saveUserSession(user: UserModel, token: String?) {
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "user")
        }
        
        if let token = token {
            UserDefaults.standard.set(token, forKey: "authToken")
        }
    }
    
    // 从UserDefaults加载用户会话
    private func loadUserSession() {
        // 尝试加载用户数据
        if let userData = UserDefaults.standard.data(forKey: "user"),
           let user = try? JSONDecoder().decode(UserModel.self, from: userData) {
            currentUser = user
            isLoggedIn = true
            
            // 加载认证令牌
            if let token = UserDefaults.standard.string(forKey: "authToken") {
                authToken = token
                userType = .authenticated
            } else {
                userType = .guest
            }
        }
    }
} 