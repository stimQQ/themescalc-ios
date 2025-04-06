import Foundation
import Combine

class ThemeViewModel: ObservableObject {
    // 服务
    private let themeService = ThemeService.shared
    private let appViewModel = AppViewModel.shared
    
    // 主题列表
    @Published var freeThemes: [ThemeListItem] = []
    @Published var paidThemes: [ThemeListItem] = []
    @Published var currentPage: Int = 1
    @Published var hasMorePages: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // 当前选中的主题
    @Published var selectedThemeId: Int = 1
    
    // 当前分类标签索引（0：免费，1：付费）
    @Published var currentTabIndex: Int = 0
    
    // 订阅状态
    var isSubscribed: Bool {
        return appViewModel.currentUser?.isSubscribed ?? false
    }
    
    // 订阅集合
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 加载主题列表
        loadThemes()
        
        // 监听当前主题变化
        appViewModel.$currentTheme
            .compactMap { $0 }
            .sink { [weak self] theme in
                self?.selectedThemeId = theme.id
            }
            .store(in: &cancellables)
    }
    
    // 加载主题列表
    func loadThemes(page: Int = 1, perPage: Int = 20) {
        isLoading = true
        errorMessage = nil
        
        // 加载免费主题
        themeService.getThemeList(page: page, perPage: perPage, isPaid: false)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = "加载免费主题失败: \(error.localizedDescription)"
                    }
                    self?.isLoading = false
                },
                receiveValue: { [weak self] response in
                    if page == 1 {
                        self?.freeThemes = response.items
                    } else {
                        self?.freeThemes.append(contentsOf: response.items)
                    }
                    self?.hasMorePages = response.currentPage < response.pages
                    self?.currentPage = response.currentPage
                }
            )
            .store(in: &cancellables)
        
        // 加载付费主题
        themeService.getThemeList(page: page, perPage: perPage, isPaid: true)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = "加载付费主题失败: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] response in
                    if page == 1 {
                        self?.paidThemes = response.items
                    } else {
                        self?.paidThemes.append(contentsOf: response.items)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // 加载更多主题
    func loadMoreThemes() {
        if !isLoading && hasMorePages {
            loadThemes(page: currentPage + 1)
        }
    }
    
    // 刷新主题列表
    func refreshThemes() {
        loadThemes(page: 1)
    }
    
    // 选择主题
    func selectTheme(id: Int) {
        selectedThemeId = id
        appViewModel.loadTheme(id: id)
    }
    
    // 检查主题是否已选中
    func isThemeSelected(id: Int) -> Bool {
        return selectedThemeId == id
    }
} 