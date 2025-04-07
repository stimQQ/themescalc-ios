import SwiftUI

struct ScientificCalculatorButtonsView: View {
    @ObservedObject var viewModel: CalculatorViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    
    // 计算器按钮布局
    private let typeEButtonSpacing: CGFloat = 3 // 减小TYPE_E按钮水平间距
    private let normalButtonSpacing: CGFloat = 8 // TYPE_F、TYPE_G、TYPE_H、TYPE_I按钮水平间距
    private let verticalSpacing: CGFloat = 5 // normalButton之间的垂直间距
    private let typeEVerticalSpacing: CGFloat = 6 // typeEButton之间的垂直间距，设置为6pt
    private let sectionSpacing: CGFloat = 20 // 区域之间的垂直间距，设置为20pt
    
    private let themeUtils = ThemeUtils.shared
    
    // 状态变量用于跟踪按钮图片
    @State private var buttonImages: [String: UIImage] = [:]
    @State private var buttonPressedImages: [String: UIImage] = [:]
    
    var body: some View {
        GeometryReader { geometry in
            // 调整这里，确保边距准确为20pt
            let screenWidth = UIScreen.main.bounds.width
            let contentWidth = screenWidth - 40 // 左右各20pt边距
            
            // 区域1: TYPE_E按钮 - 每行6个按钮，间距更小
            let availableTypeEWidth = contentWidth - (typeEButtonSpacing * 5) // 5个间距
            let typeEButtonWidth = availableTypeEWidth / 6 // 去掉额外的+0.5，确保精确计算
            
            // 区域2: TYPE_F、G、H、I按钮 - 每行4个按钮，间距8pt
            let availableNormalWidth = contentWidth - (normalButtonSpacing * 3) // 3个间距
            let normalButtonWidth = availableNormalWidth / 4 // 去掉向下取整和减1，确保按钮宽度充分利用空间
            
            // TYPE_I按钮(等号)特殊处理，占据两列宽度+间距
            let equalButtonWidth = (normalButtonWidth * 2) + normalButtonSpacing
            
            // 设置按钮高度，为typeE按钮提供足够的高度显示完整图片
            let typeEButtonHeight: CGFloat = min(typeEButtonWidth * 0.9, 42) // 增加科学计算按钮高度
            let normalButtonHeight: CGFloat = min(normalButtonWidth * 0.8, 55) // 降低标准按钮高度
            
            // 使用ScrollView确保在小屏幕上内容可滚动，避免堆叠
            ScrollView {
                VStack(spacing: sectionSpacing) { // 使用20pt的区域间间距
                    // 使用明确的VStack结构来确保typeE按钮的垂直间距生效
                    scientificButtonsArea(typeEButtonWidth: typeEButtonWidth, typeEButtonHeight: typeEButtonHeight)
                    
                    // 区域2: TYPE_F、G、H、I按钮区域（标准计算器功能）
                    normalButtonsArea(normalButtonWidth: normalButtonWidth, normalButtonHeight: normalButtonHeight, equalButtonWidth: equalButtonWidth)
                }
                .padding(.horizontal, 20) // 明确设置边距为左右各20pt
                .padding(.vertical, 0) // 移除垂直边距
            }
            .frame(width: screenWidth) // 使用整个屏幕宽度
            .onAppear {
                loadAllButtonImages()
            }
            .onChange(of: appViewModel.currentTheme) { oldValue, newValue in
                loadAllButtonImages()
            }
        }
    }
    
    // 科学计算器专用按钮区域
    private func scientificButtonsArea(typeEButtonWidth: CGFloat, typeEButtonHeight: CGFloat) -> some View {
        // 使用明确的VStack和固定的spacing来确保垂直间距正确应用
        VStack(spacing: 0) {
            // 第一行：sin, cos, tan, ln, log, 1/x
            HStack(spacing: typeEButtonSpacing) {
                calculatorButton(.sin) {
                    viewModel.handleScientificFunction("sin")
                }
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                
                calculatorButton(.cos) {
                    viewModel.handleScientificFunction("cos")
                }
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                
                calculatorButton(.tan) {
                    viewModel.handleScientificFunction("tan")
                }
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                
                calculatorButton(.ln) {
                    viewModel.handleScientificFunction("ln")
                }
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                
                calculatorButton(.log) {
                    viewModel.handleScientificFunction("log")
                }
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                
                calculatorButton(.reciprocal) {
                    viewModel.handleScientificFunction("1/x")
                }
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
            }
            
            // 明确设置行间距为6pt
            Spacer().frame(height: typeEVerticalSpacing)
            
            // 第二行：x², x³, x^y, √, ∛, x!
            HStack(spacing: typeEButtonSpacing) {
                CustomThemedButton(
                    buttonType: .power,
                    action: {
                        viewModel.handleScientificFunction("x²")
                    },
                    calculatorMode: .scientific,
                    customText: "x²"
                )
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                
                CustomThemedButton(
                    buttonType: .power,
                    action: {
                        viewModel.handleScientificFunction("x³")
                    },
                    calculatorMode: .scientific,
                    customText: "x³"
                )
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                
                calculatorButton(.power) {
                    viewModel.handleScientificFunction("xʸ")
                }
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                
                calculatorButton(.sqrt) {
                    viewModel.handleScientificFunction("√")
                }
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                
                CustomThemedButton(
                    buttonType: .sqrt,
                    action: {
                        viewModel.handleScientificFunction("∛")
                    },
                    calculatorMode: .scientific,
                    customText: "∛"
                )
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                
                calculatorButton(.factorial) {
                    viewModel.handleScientificFunction("x!")
                }
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
            }
            
            // 明确设置行间距为6pt
            Spacer().frame(height: typeEVerticalSpacing)
            
            // 第三行：e^x, 10^x, π, e, Ans, ()
            HStack(spacing: typeEButtonSpacing) {
                calculatorButton(.exp) {
                    viewModel.handleScientificFunction("eˣ")
                }
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                
                CustomThemedButton(
                    buttonType: .exp,
                    action: {
                        viewModel.handleScientificFunction("10ˣ")
                    },
                    calculatorMode: .scientific,
                    customText: "10ˣ"
                )
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                
                calculatorButton(.pi) {
                    viewModel.handleNumberInput(String(Double.pi))
                }
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                
                calculatorButton(.e) {
                    viewModel.handleNumberInput(String(M_E))
                }
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                
                CustomThemedButton(
                    buttonType: .secondFunction,
                    action: {
                        if let lastResult = viewModel.lastResult {
                            viewModel.displayValue = viewModel.calculatorService.formatNumber(lastResult)
                            viewModel.isStartingNewInput = false
                        }
                    },
                    calculatorMode: .scientific,
                    customText: "Ans"
                )
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                
                CustomThemedButton(
                    buttonType: .leftParenthesis,
                    action: {
                        // 括号功能实现较复杂，暂不实现
                    },
                    calculatorMode: .scientific,
                    customText: "()"
                )
                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
            }
        }
        .padding(.horizontal, 0) // 确保没有额外的水平内边距
    }
    
    // 普通计算器按钮区域
    private func normalButtonsArea(normalButtonWidth: CGFloat, normalButtonHeight: CGFloat, equalButtonWidth: CGFloat) -> some View {
        VStack(spacing: verticalSpacing) {
            // 第四行：AC, ±, %, ÷ (TYPE_F 和 TYPE_G)
            HStack(spacing: normalButtonSpacing) {
                calculatorButton(.clear) {
                    viewModel.handleClear()
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
                
                calculatorButton(.toggleSign) {
                    viewModel.handleToggleSign()
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
                
                calculatorButton(.percentage) {
                    viewModel.handlePercentage()
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
                
                calculatorButton(.divide) {
                    viewModel.handleOperation("÷")
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
            }
            
            // 第五行：7, 8, 9, × (TYPE_H 和 TYPE_G)
            HStack(spacing: normalButtonSpacing) {
                calculatorButton(.seven) {
                    viewModel.handleNumberInput("7")
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
                
                calculatorButton(.eight) {
                    viewModel.handleNumberInput("8")
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
                
                calculatorButton(.nine) {
                    viewModel.handleNumberInput("9")
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
                
                calculatorButton(.multiply) {
                    viewModel.handleOperation("×")
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
            }
            
            // 第六行：4, 5, 6, - (TYPE_H 和 TYPE_G)
            HStack(spacing: normalButtonSpacing) {
                calculatorButton(.four) {
                    viewModel.handleNumberInput("4")
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
                
                calculatorButton(.five) {
                    viewModel.handleNumberInput("5")
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
                
                calculatorButton(.six) {
                    viewModel.handleNumberInput("6")
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
                
                calculatorButton(.subtract) {
                    viewModel.handleOperation("-")
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
            }
            
            // 第七行：1, 2, 3, + (TYPE_H 和 TYPE_G)
            HStack(spacing: normalButtonSpacing) {
                calculatorButton(.one) {
                    viewModel.handleNumberInput("1")
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
                
                calculatorButton(.two) {
                    viewModel.handleNumberInput("2")
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
                
                calculatorButton(.three) {
                    viewModel.handleNumberInput("3")
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
                
                calculatorButton(.add) {
                    viewModel.handleOperation("+")
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
            }
            
            // 第八行：0, ., = (TYPE_H 和 TYPE_I)
            HStack(spacing: normalButtonSpacing) {
                calculatorButton(.zero) {
                    viewModel.handleNumberInput("0")
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
                
                calculatorButton(.decimal) {
                    viewModel.handleNumberInput(".")
                }
                .frame(width: normalButtonWidth, height: normalButtonHeight)
                
                calculatorButton(.equal) {
                    viewModel.handleEqual()
                }
                .frame(width: equalButtonWidth, height: normalButtonHeight)
            }
        }
    }
    
    // 创建计算器按钮
    private func calculatorButton(_ type: ButtonType, action: @escaping () -> Void) -> some View {
        ThemedCalculatorButton(buttonType: type, action: action, calculatorMode: .scientific)
    }
    
    // 获取按钮文本颜色
    private func getButtonTextColor(for buttonType: ButtonType) -> Color {
        if let theme = appViewModel.currentTheme {
            return themeUtils.getButtonForegroundColor(for: buttonType, from: theme, calculatorMode: .scientific)
        }
        return .black // 默认文本颜色
    }
    
    // 预加载所有按钮图片
    private func loadAllButtonImages() {
        guard let theme = appViewModel.currentTheme else { return }
        
        // 清空图片缓存
        buttonImages.removeAll()
        buttonPressedImages.removeAll()
        
        // 预加载所有特殊按钮图片
        let buttonTypes: [ButtonType] = [.power, .sqrt, .exp, .secondFunction, .leftParenthesis]
        
        for buttonType in buttonTypes {
            if let buttonTheme = themeUtils.getButtonTheme(for: buttonType, from: theme, calculatorMode: .scientific) {
                if buttonTheme.useImage {
                    // 加载常规图片
                    if let imageURL = buttonTheme.releasedImage {
                        themeUtils.loadImage(from: imageURL) { image in
                            if let image = image {
                                DispatchQueue.main.async {
                                    self.buttonImages[buttonType.rawValue] = image
                                }
                            }
                        }
                    }
                    
                    // 加载按下状态图片
                    if let pressedImageURL = buttonTheme.pressedImage {
                        themeUtils.loadImage(from: pressedImageURL) { image in
                            if let image = image {
                                DispatchQueue.main.async {
                                    self.buttonPressedImages[buttonType.rawValue] = image
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ScientificCalculatorButtonsView(viewModel: CalculatorViewModel())
        .environmentObject(AppViewModel.shared)
}