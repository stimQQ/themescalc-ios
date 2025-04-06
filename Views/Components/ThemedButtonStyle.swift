import SwiftUI

struct ThemedButtonStyle: ButtonStyle {
    let buttonType: ButtonType
    let themeModel: ThemeModel?
    var calculatorMode: CalculatorMode = .basic
    
    @State private var isPressed = false
    @State private var buttonImage: UIImage?
    @State private var pressedImage: UIImage?
    
    private let themeUtils = ThemeUtils.shared
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Group {
                    if shouldUseImage, let image = isPressed ? pressedImage : buttonImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Rectangle()
                            .fill(buttonBackgroundColor)
                    }
                }
            )
            .foregroundColor(buttonTextColor)
            .onChange(of: configuration.isPressed) { isPressed in
                self.isPressed = isPressed
                if isPressed {
                    // 播放按钮音效
                    if let theme = themeModel,
                       let buttonTheme = themeUtils.getButtonTheme(for: buttonType, from: theme, calculatorMode: calculatorMode) {
                        CalculatorService.shared.playButtonSound(soundURL: buttonTheme.sound)
                    }
                }
            }
            .onAppear(perform: loadImages)
    }
    
    // 按钮文本颜色
    private var buttonTextColor: Color {
        if let theme = themeModel {
            return themeUtils.getButtonForegroundColor(for: buttonType, from: theme, calculatorMode: calculatorMode)
        }
        return .white
    }
    
    // 按钮背景颜色
    private var buttonBackgroundColor: Color {
        if let theme = themeModel {
            return themeUtils.getButtonBackgroundColor(for: buttonType, from: theme, isPressed: isPressed, calculatorMode: calculatorMode)
        }
        return isPressed ? Color.gray.opacity(0.8) : Color.gray
    }
    
    // 是否使用图片
    private var shouldUseImage: Bool {
        if let theme = themeModel,
           let buttonTheme = themeUtils.getButtonTheme(for: buttonType, from: theme, calculatorMode: calculatorMode) {
            return buttonTheme.useImage
        }
        return false
    }
    
    // 加载按钮图片
    private func loadImages() {
        guard let theme = themeModel,
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