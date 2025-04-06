import SwiftUI

/// 自定义主题按钮，与ThemedCalculatorButton类似，但不显示文字
struct CustomThemedButton: View {
    // 环境对象
    @EnvironmentObject private var appViewModel: AppViewModel
    
    // 按钮属性
    let buttonType: ButtonType
    let action: () -> Void
    var calculatorMode: CalculatorMode = .basic
    let customText: String
    
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
                    
                    // 自定义按钮文本
                    Text(customText)
                        .font(.system(size: buttonFontSize))
                        .fontWeight(.medium)
                        .foregroundColor(buttonTextColor)
                        .padding(2) // 减小内边距
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .contentShape(Rectangle())
            }
        }
        .buttonStyle(CalculatorButtonStyle(onPress: { isPressed = true }, onRelease: { isPressed = false }))
        .onAppear(perform: loadImages)
        .onChange(of: appViewModel.currentTheme) { _, _ in
            loadImages()
        }
    }
    
    // 按钮背景
    private var buttonBackground: some View {
        Group {
            if shouldUseImage, let image = isPressed ? pressedImage : buttonImage {
                if isScientificButton {
                    // 科学计算器按钮使用fill模式但保留完整按钮图像
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill) // 填充模式
                            .frame(maxHeight: .infinity) // 确保图片占据整个高度
                            .clipped(antialiased: true) // 裁剪超出部分
                    }
                } else {
                    // 普通按钮使用fit模式
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            } else {
                Rectangle()
                    .fill(buttonBackgroundColor)
            }
        }
    }
    
    // 判断是否为科学计算器按钮
    private var isScientificButton: Bool {
        // 科学计算器模式下的特定按钮
        return calculatorMode == .scientific && (
            buttonType == .power ||
            buttonType == .sqrt ||
            buttonType == .exp ||
            buttonType == .secondFunction ||
            buttonType == .leftParenthesis
        )
    }
    
    // 按钮字体大小
    private var buttonFontSize: CGFloat {
        if let theme = appViewModel.currentTheme,
           let buttonTheme = themeUtils.getButtonTheme(for: buttonType, from: theme, calculatorMode: calculatorMode) {
            return CGFloat(buttonTheme.fontSize)
        }
        return 24
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

// 条件修饰符扩展，用于条件性地应用视图修饰符
extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
} 