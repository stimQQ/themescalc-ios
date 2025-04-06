import SwiftUI

struct ThemedCalculatorButton: View {
    // 环境对象
    @EnvironmentObject private var appViewModel: AppViewModel
    
    // 按钮属性
    let buttonType: ButtonType
    let action: () -> Void
    var calculatorMode: CalculatorMode = .basic
    
    // 自定义文本（可选）
    var customText: String? = nil
    
    // 状态变量
    @State private var isPressed = false
    @State private var buttonImage: UIImage?
    @State private var pressedImage: UIImage?
    
    // 主题工具
    private let themeUtils = ThemeUtils.shared
    
    var body: some View {
        Button(action: {
            action()
            
            // 播放按钮音效
            if let theme = appViewModel.currentTheme,
               let buttonTheme = themeUtils.getButtonTheme(for: buttonType, from: theme, calculatorMode: calculatorMode) {
                CalculatorService.shared.playButtonSound(soundURL: buttonTheme.sound)
            }
        }) {
            GeometryReader { geo in
                ZStack {
                    // 按钮背景
                    buttonBackground
                    
                    // 按钮文本
                    Text(customText ?? buttonType.rawValue)
                        .font(.system(size: adjustedFontSize))
                        .fontWeight(.medium)
                        .foregroundColor(buttonTextColor)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .allowsTightening(true) // 允许字符间距压缩
                        .fixedSize(horizontal: false, vertical: true) // 允许水平方向缩放
                        .padding(.horizontal, 2) // 添加少量水平内边距，避免文字紧贴边缘
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .contentShape(Rectangle())
            }
        }
        .buttonStyle(CalculatorButtonStyle(onPress: { isPressed = true }, onRelease: { isPressed = false }))
        .onAppear(perform: loadImages)
        .onChange(of: appViewModel.currentTheme) { _ in
            loadImages()
        }
    }
    
    // 按钮背景
    private var buttonBackground: some View {
        Group {
            if shouldUseImage, let image = isPressed ? pressedImage : buttonImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipped() // 确保图片不会溢出按钮边界
            } else {
                Rectangle()
                    .fill(buttonBackgroundColor)
            }
        }
    }
    
    // 调整后的按钮字体大小
    private var adjustedFontSize: CGFloat {
        let baseFontSize = buttonFontSize
        
        // 为特定按钮设置更小的字体
        if calculatorMode == .scientific {
            if let text = customText {
                // 自定义文本的科学计算器按钮
                switch text.count {
                case 0...1: // 单字符按钮
                    return baseFontSize * 0.9
                case 2: // 双字符按钮，如"x²"
                    return baseFontSize * 0.8
                case 3: // 三字符按钮，如"10^x"
                    return baseFontSize * 0.7
                default: // 四个或更多字符
                    return baseFontSize * 0.6
                }
            } else {
                // 根据按钮类型调整字体大小
                switch buttonType {
                case .sin, .cos, .tan, .log, .ln:
                    return baseFontSize * 0.9
                default:
                    return baseFontSize
                }
            }
        }
        
        return baseFontSize
    }
    
    // 按钮字体大小
    private var buttonFontSize: CGFloat {
        if let theme = appViewModel.currentTheme,
           let buttonTheme = themeUtils.getButtonTheme(for: buttonType, from: theme, calculatorMode: calculatorMode) {
            return CGFloat(buttonTheme.fontSize)
        }
        
        // 默认字体大小
        if calculatorMode == .scientific {
            return 16 // 科学计算器默认较小字体
        }
        return 24 // 基础计算器默认字体
    }
    
    // 按钮文本颜色
    private var buttonTextColor: Color {
        if let theme = appViewModel.currentTheme {
            return themeUtils.getButtonForegroundColor(for: buttonType, from: theme, calculatorMode: calculatorMode)
        }
        return .white
    }
    
    // 按钮背景颜色
    private var buttonBackgroundColor: Color {
        if let theme = appViewModel.currentTheme {
            return themeUtils.getButtonBackgroundColor(for: buttonType, from: theme, isPressed: isPressed, calculatorMode: calculatorMode)
        }
        return isPressed ? Color.gray.opacity(0.8) : Color.gray
    }
    
    // 是否使用图片
    private var shouldUseImage: Bool {
        if let theme = appViewModel.currentTheme,
           let buttonTheme = themeUtils.getButtonTheme(for: buttonType, from: theme, calculatorMode: calculatorMode) {
            return buttonTheme.useImage
        }
        return false
    }
    
    // 加载按钮图片
    private func loadImages() {
        guard let theme = appViewModel.currentTheme,
              let buttonTheme = themeUtils.getButtonTheme(for: buttonType, from: theme, calculatorMode: calculatorMode),
              buttonTheme.useImage else {
            buttonImage = nil
            pressedImage = nil
            return
        }
        
        // 加载常规状态图片
        if let imageURL = buttonTheme.releasedImage {
            themeUtils.loadImage(from: imageURL) { image in
                buttonImage = image
            }
        }
        
        // 加载按下状态图片
        if let pressedImageURL = buttonTheme.pressedImage {
            themeUtils.loadImage(from: pressedImageURL) { image in
                pressedImage = image
            }
        }
    }
} 