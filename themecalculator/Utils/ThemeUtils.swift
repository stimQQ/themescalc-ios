import SwiftUI
import Combine

class ThemeUtils {
    static let shared = ThemeUtils()
    
    // 图片缓存
    private var imageCache: [String: UIImage] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // 解析十六进制颜色
    func color(from hexString: String?, defaultColor: Color = .gray) -> Color {
        guard let hexString = hexString, hexString != "null" else {
            return defaultColor
        }
        
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return defaultColor
        }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        return Color(red: r, green: g, blue: b)
    }
    
    // 加载网络图片
    func loadImage(from urlString: String?, completion: @escaping (UIImage?) -> Void) {
        guard let urlString = urlString, urlString != "null", !urlString.isEmpty else {
            completion(nil)
            return
        }
        
        // 检查缓存
        if let cachedImage = imageCache[urlString] {
            completion(cachedImage)
            return
        }
        
        // 从网络加载图片
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                if let image = image {
                    self?.imageCache[urlString] = image
                }
                completion(image)
            }
            .store(in: &cancellables)
    }
    
    // 清除图片缓存
    func clearImageCache() {
        imageCache.removeAll()
    }
    
    // 获取按钮的主题配置
    func getButtonTheme(for buttonType: ButtonType, from theme: ThemeModel, calculatorMode: CalculatorMode = .basic) -> ButtonTheme? {
        let themeButtonType = buttonType.themeButtonType(for: calculatorMode)
        return theme.buttons.first { $0.type == themeButtonType }
    }
    
    // 获取按钮的前景色（文字颜色）
    func getButtonForegroundColor(for buttonType: ButtonType, from theme: ThemeModel, calculatorMode: CalculatorMode = .basic) -> Color {
        guard let buttonTheme = getButtonTheme(for: buttonType, from: theme, calculatorMode: calculatorMode) else {
            return .white
        }
        
        return color(from: buttonTheme.fontColor, defaultColor: .white)
    }
    
    // 获取按钮的背景色
    func getButtonBackgroundColor(for buttonType: ButtonType, from theme: ThemeModel, isPressed: Bool, calculatorMode: CalculatorMode = .basic) -> Color {
        guard let buttonTheme = getButtonTheme(for: buttonType, from: theme, calculatorMode: calculatorMode) else {
            return .gray
        }
        
        let colorHex = isPressed ? buttonTheme.pressedColor : buttonTheme.releasedColor
        return color(from: colorHex, defaultColor: isPressed ? .gray.opacity(0.8) : .gray)
    }
    
    // 获取按钮的字体大小
    func getButtonFontSize(for buttonType: ButtonType, from theme: ThemeModel, calculatorMode: CalculatorMode = .basic) -> CGFloat {
        guard let buttonTheme = getButtonTheme(for: buttonType, from: theme, calculatorMode: calculatorMode) else {
            return 24
        }
        
        return CGFloat(buttonTheme.fontSize)
    }
} 