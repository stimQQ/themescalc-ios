import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    // 单例
    static let shared = AppViewModel()
    
    // 服务
    private let userService = UserService.shared
    private let themeService = ThemeService.shared
    
    // 订阅集合
    private var cancellables = Set<AnyCancellable>()
    
    // 应用状态
    @Published var isLoggedIn: Bool = false
    @Published var userType: UserType = .guest
    @Published var currentUser: UserModel?
    @Published var selectedLanguage: AppLanguage = .chinese
    
    // 主题相关
    @Published var currentTheme: ThemeModel?
    @Published var isLoadingTheme: Bool = false
    @Published var themeError: String?
    
    // 应用初始化状态
    @Published var hasCompletedOnboarding: Bool = false
    @Published var currentTab: Int = 0 // 0: 计算, 1: 主题, 2: 个人中心
    
    private init() {
        // 订阅用户服务状态变化
        userService.$isLoggedIn
            .assign(to: &$isLoggedIn)
        
        userService.$userType
            .assign(to: &$userType)
        
        userService.$currentUser
            .sink { [weak self] user in
                self?.currentUser = user
                if let languageCode = user?.language, let language = AppLanguage(rawValue: languageCode) {
                    self?.selectedLanguage = language
                }
            }
            .store(in: &cancellables)
        
        // 从UserDefaults加载应用状态
        loadAppState()
        
        // 加载默认主题
        loadDefaultTheme()
    }
    
    // MARK: - 主题相关方法
    
    // 加载默认主题（ID为1）
    func loadDefaultTheme() {
        loadTheme(id: 1)
    }
    
    // 加载指定主题
    func loadTheme(id: Int) {
        isLoadingTheme = true
        themeError = nil
        
        themeService.getOrLoadTheme(themeId: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoadingTheme = false
                    if case .failure(let error) = completion {
                        self?.themeError = "加载主题失败: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] theme in
                    self?.currentTheme = theme
                    self?.saveCurrentThemeId(id: theme.id)
                }
            )
            .store(in: &cancellables)
    }
    
    // 保存当前主题ID
    private func saveCurrentThemeId(id: Int) {
        UserDefaults.standard.set(id, forKey: "currentThemeId")
    }
    
    // MARK: - 用户相关方法
    
    // 访客登录
    func loginAsGuest() {
        userService.signInAsGuest()
        hasCompletedOnboarding = true
        saveAppState()
    }
    
    // 设置语言
    func setLanguage(_ language: AppLanguage) {
        selectedLanguage = language
        if let user = currentUser {
            userService.setUserLanguage(language: language)
        }
        saveAppState()
    }
    
    // 完成引导
    func completeOnboarding() {
        hasCompletedOnboarding = true
        saveAppState()
    }
    
    // 切换标签页
    func switchTab(to index: Int) {
        currentTab = index
    }
    
    // MARK: - 应用状态持久化
    
    // 保存应用状态
    private func saveAppState() {
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")
    }
    
    // 加载应用状态
    private func loadAppState() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if let languageCode = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = AppLanguage(rawValue: languageCode) {
            selectedLanguage = language
        }
        
        if let themeId = UserDefaults.standard.object(forKey: "currentThemeId") as? Int {
            loadTheme(id: themeId)
        }
    }
} 