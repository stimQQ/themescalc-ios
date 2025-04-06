import Foundation

// 主题模型
struct ThemeModel: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let version: String
    let isPaid: Bool
    let createTime: String
    let updateTime: String?
    let detailImage: String
    let previewImage: String
    let globalBackgroundColor: String
    let globalBackgroundImage: String?
    let hasGlobalBackgroundImage: Bool
    let resultBackgroundColor: String
    let resultBackgroundImage: String?
    let resultUseImage: Bool
    let resultFontColor: String
    let resultFontSize: Int
    let topButtonSelectedColor: String
    let topButtonSelectedFontColor: String
    let topButtonSelectedImage: String?
    let topButtonUnselectedColor: String
    let topButtonUnselectedFontColor: String
    let topButtonUnselectedImage: String?
    let topButtonUseImage: Bool
    let customTabbar: Bool
    let tabbarBackgroundColor: String
    let tabbarBackgroundImage: String?
    let tabbarBackgroundOpacity: Double
    let tabbarFontColor: String?
    let tabbarFontSize: Int
    let tabbarSelectedFontColor: String
    let tabbarUnselectedFontColor: String
    let tabbarUseImage: Bool
    let tabbarIcons: TabbarIcons
    let buttons: [ButtonTheme]
    let useSystemFont: Bool
    
    // 实现Equatable协议
    static func == (lhs: ThemeModel, rhs: ThemeModel) -> Bool {
        return lhs.id == rhs.id && lhs.version == rhs.version
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case version
        case isPaid = "is_paid"
        case createTime = "create_time"
        case updateTime = "update_time"
        case detailImage = "detail_image"
        case previewImage = "preview_image"
        case globalBackgroundColor = "global_background_color"
        case globalBackgroundImage = "global_background_image"
        case hasGlobalBackgroundImage = "has_global_background_image"
        case resultBackgroundColor = "result_background_color"
        case resultBackgroundImage = "result_background_image"
        case resultUseImage = "result_use_image"
        case resultFontColor = "result_font_color"
        case resultFontSize = "result_font_size"
        case topButtonSelectedColor = "top_button_selected_color"
        case topButtonSelectedFontColor = "top_button_selected_font_color"
        case topButtonSelectedImage = "top_button_selected_image"
        case topButtonUnselectedColor = "top_button_unselected_color"
        case topButtonUnselectedFontColor = "top_button_unselected_font_color"
        case topButtonUnselectedImage = "top_button_unselected_image"
        case topButtonUseImage = "top_button_use_image"
        case customTabbar = "custom_tabbar"
        case tabbarBackgroundColor = "tabbar_background_color"
        case tabbarBackgroundImage = "tabbar_background_image"
        case tabbarBackgroundOpacity = "tabbar_background_opacity"
        case tabbarFontColor = "tabbar_font_color"
        case tabbarFontSize = "tabbar_font_size"
        case tabbarSelectedFontColor = "tabbar_selected_font_color"
        case tabbarUnselectedFontColor = "tabbar_unselected_font_color"
        case tabbarUseImage = "tabbar_use_image"
        case tabbarIcons = "tabbar_icons"
        case buttons
        case useSystemFont = "use_system_font"
    }
}

// TabBar图标
struct TabbarIcons: Codable, Equatable {
    let home: TabbarIconPair
    let theme: TabbarIconPair
    let profile: TabbarIconPair
    let camera: TabbarIconPair?
    let voice: TabbarIconPair?
}

// TabBar图标对（选中和未选中状态）
struct TabbarIconPair: Codable, Equatable {
    let selected: String
    let unselected: String
}

// 按钮主题
struct ButtonTheme: Codable, Identifiable, Equatable {
    let id: Int
    let type: String
    let fontColor: String
    let fontSize: Int
    let pressedColor: String?
    let pressedImage: String?
    let releasedColor: String?
    let releasedImage: String?
    let colorOpacity: Double
    let sound: String?
    let useImage: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case fontColor = "font_color"
        case fontSize = "font_size"
        case pressedColor = "pressed_color"
        case pressedImage = "pressed_image"
        case releasedColor = "released_color"
        case releasedImage = "released_image"
        case colorOpacity = "color_opacity"
        case sound
        case useImage = "use_image"
    }
}

// 主题列表响应
struct ThemeListResponse: Codable {
    let items: [ThemeListItem]
    let total: Int
    let pages: Int
    let currentPage: Int
    let perPage: Int
    
    enum CodingKeys: String, CodingKey {
        case items
        case total
        case pages
        case currentPage = "current_page"
        case perPage = "per_page"
    }
}

// 主题列表项
struct ThemeListItem: Codable, Identifiable {
    let id: Int
    let name: String
    let version: String
    let isPaid: Bool
    let createTime: String
    let updateTime: String?
    let detailImage: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case version
        case isPaid = "is_paid"
        case createTime = "create_time"
        case updateTime = "update_time"
        case detailImage = "detail_image"
    }
} 