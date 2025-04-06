import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    // 服务
    private let userService = UserService.shared
    private let calculatorService = CalculatorService.shared
    private let appViewModel = AppViewModel.shared
    
    // 用户信息
    @Published var username: String = ""
    @Published var email: String?
    @Published var isSubscribed: Bool = false
    @Published var subscriptionExpiryDate: Date?
    @Published var calculationHistory: [CalculationHistoryItem] = []
    
    // 订阅集合
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 订阅用户信息变化
        appViewModel.$currentUser
            .sink { [weak self] user in
                if let user = user {
                    self?.username = user.username
                    self?.email = user.email
                    self?.isSubscribed = user.isSubscribed
                    self?.subscriptionExpiryDate = user.subscriptionExpiryDate
                }
            }
            .store(in: &cancellables)
        
        // 加载计算历史
        loadCalculationHistory()
    }
    
    // 加载计算历史
    func loadCalculationHistory() {
        calculationHistory = calculatorService.loadCalculationHistory()
    }
    
    // 清除计算历史
    func clearCalculationHistory() {
        calculatorService.clearCalculationHistory()
        calculationHistory = []
    }
    
    // 登出
    func signOut() {
        userService.signOut()
    }
    
    // 分享应用
    func shareApp() {
        // 在实际应用中，这里可能会弹出系统分享表单
        // 实际实现需要使用UIActivityViewController
    }
    
    // 订阅管理
    func manageSubscription() {
        // 在实际应用中，这里可能会跳转到App Store或自定义订阅页面
    }
    
    // 格式化订阅到期日期
    func formatExpiryDate() -> String {
        guard let date = subscriptionExpiryDate else {
            return "未订阅"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
} 