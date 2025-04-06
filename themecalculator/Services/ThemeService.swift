import Foundation
import Combine

class ThemeService {
    static let shared = ThemeService()
    
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // 获取主题列表
    func getThemeList(page: Int = 1, perPage: Int = 20, search: String? = nil, isPaid: Bool? = nil) -> AnyPublisher<ThemeListResponse, NetworkError> {
        var queryParams: [String: String] = [
            "page": "\(page)",
            "per_page": "\(perPage)"
        ]
        
        if let search = search {
            queryParams["search"] = search
        }
        
        if let isPaid = isPaid {
            queryParams["is_paid"] = isPaid ? "true" : "false"
        }
        
        return networkService.get(endpoint: "skin", queryParams: queryParams)
    }
    
    // 获取主题详情
    func getThemeDetail(themeId: Int) -> AnyPublisher<ThemeModel, NetworkError> {
        return networkService.get(endpoint: "skin/\(themeId)")
    }
    
    // 从本地缓存加载主题
    func loadThemeFromCache(themeId: Int) -> ThemeModel? {
        guard let data = UserDefaults.standard.data(forKey: "theme_\(themeId)") else {
            return nil
        }
        
        do {
            let theme = try JSONDecoder().decode(ThemeModel.self, from: data)
            return theme
        } catch {
            print("Failed to decode theme from cache: \(error)")
            return nil
        }
    }
    
    // 保存主题到本地缓存
    func saveThemeToCache(theme: ThemeModel) {
        do {
            let data = try JSONEncoder().encode(theme)
            UserDefaults.standard.set(data, forKey: "theme_\(theme.id)")
        } catch {
            print("Failed to encode theme for cache: \(error)")
        }
    }
    
    // 获取或加载主题（先尝试从缓存加载，如果没有则从网络获取并缓存）
    func getOrLoadTheme(themeId: Int) -> AnyPublisher<ThemeModel, NetworkError> {
        if let cachedTheme = loadThemeFromCache(themeId: themeId) {
            return Just(cachedTheme)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } else {
            return getThemeDetail(themeId: themeId)
                .handleEvents(receiveOutput: { [weak self] theme in
                    self?.saveThemeToCache(theme: theme)
                })
                .eraseToAnyPublisher()
        }
    }
} 