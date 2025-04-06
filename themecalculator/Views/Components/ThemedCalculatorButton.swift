import SwiftUI

struct ThemedCalculatorButton: View {
    // 环境对象
    @EnvironmentObject private var appViewModel: AppViewModel
    
    // 按钮属性
    let buttonType: ButtonType
    let action: () -> Void
    var calculatorMode: CalculatorMode = .basic
    
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
                    Text(buttonType.rawValue)
                        .font(.system(size: buttonFontSize))
                        .fontWeight(.medium)
                        .foregroundColor(buttonTextColor)
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
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(buttonBackgroundColor)
            }
        }
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

// 自定义按钮样式，处理按下和释放状态
struct CalculatorButtonStyle: ButtonStyle {
    let onPress: () -> Void
    let onRelease: () -> Void
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed {
                    onPress()
                } else {
                    onRelease()
                }
            }
    }
}

#Preview {
    ThemedCalculatorButton(buttonType: .one) {
        print("Button pressed")
    }
    .frame(width: 80, height: 80)
    .environmentObject(AppViewModel.shared)
} 