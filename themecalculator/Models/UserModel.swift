import Foundation

// 用户模型
struct UserModel: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String?
    let language: String
    
    // 订阅信息可以根据实际需求扩展
    var isSubscribed: Bool = false
    var subscriptionExpiryDate: Date?
}

// 认证响应
struct AuthResponse: Codable {
    let token: String
    let user: UserModel
}

// 登录请求
struct LoginRequest: Codable {
    let username: String
    let password: String
}

enum UserType {
    case guest
    case authenticated
}

// 用户语言设置
enum AppLanguage: String, CaseIterable, Identifiable {
    case chinese = "zh"
    case english = "en"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .chinese:
            return "中文"
        case .english:
            return "English"
        }
    }
} 