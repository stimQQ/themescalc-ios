import SwiftUI

struct ScientificCalculatorButtonsView: View {
    @ObservedObject var viewModel: CalculatorViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    
    // 计算器按钮布局
    private let typeEButtonSpacing: CGFloat = 8 // 增加TYPE_E按钮间距，避免堆叠
    private let normalButtonSpacing: CGFloat = 10 // TYPE_F、TYPE_G、TYPE_H、TYPE_I按钮间距
    private let verticalSpacing: CGFloat = 10 // 区域间和行间的垂直间距
    
    var body: some View {
        GeometryReader { geometry in
            // 调整这里，确保边距准确为20pt
            let screenWidth = UIScreen.main.bounds.width
            let contentWidth = screenWidth - 40 // 左右各20pt边距
            
            // 区域1: TYPE_E按钮 - 每行6个按钮，间距8pt
            let availableTypeEWidth = contentWidth - (typeEButtonSpacing * 5) // 5个间距
            let typeEButtonWidth = availableTypeEWidth / 6 // 6个按钮
            
            // 区域2: TYPE_F、G、H、I按钮 - 每行4个按钮，间距10pt
            let availableNormalWidth = contentWidth - (normalButtonSpacing * 3) // 3个间距
            let normalButtonWidth = availableNormalWidth / 4 // 4个按钮
            
            // TYPE_I按钮(等号)特殊处理，占据两列宽度+间距
            let equalButtonWidth = (normalButtonWidth * 2) + normalButtonSpacing
            
            // 设置按钮高度，确保不会太高导致按钮堆叠
            let typeEButtonHeight: CGFloat = min(typeEButtonWidth, 45) // 降低最大高度限制
            let normalButtonHeight: CGFloat = min(normalButtonWidth, 70) // 降低最大高度限制
            
            // 使用ScrollView确保在小屏幕上内容可滚动，避免堆叠
            ScrollView {
                VStack(spacing: verticalSpacing) {
                    // 区域1: TYPE_E按钮区域（科学计算器特殊函数）
                    VStack(spacing: verticalSpacing) {
                        // 第一行：sin, cos, tan, ln, log, 1/x (TYPE_E)
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
                        
                        // 第二行：x², x³, x^y, √, ∛, x! (TYPE_E)
                        HStack(spacing: typeEButtonSpacing) {
                            // 修复文字堆叠问题，使用更合适的字体大小
                            Group {
                                ThemedCalculatorButton(buttonType: .power, action: {
                                    viewModel.handleScientificFunction("x²")
                                }, calculatorMode: .scientific)
                                .overlay(
                                    Text("x²")
                                        .font(.system(size: 17, weight: .medium)) // 减小字体大小
                                        .foregroundColor(.black) // 确保文字可见
                                )
                                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            }
                            
                            Group {
                                ThemedCalculatorButton(buttonType: .power, action: {
                                    viewModel.handleScientificFunction("x³")
                                }, calculatorMode: .scientific)
                                .overlay(
                                    Text("x³")
                                        .font(.system(size: 17, weight: .medium)) // 减小字体大小
                                        .foregroundColor(.black) // 确保文字可见
                                )
                                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            }
                            
                            calculatorButton(.power) {
                                viewModel.handleScientificFunction("xʸ")
                            }
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            
                            calculatorButton(.sqrt) {
                                viewModel.handleScientificFunction("√")
                            }
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            
                            Group {
                                ThemedCalculatorButton(buttonType: .sqrt, action: {
                                    viewModel.handleScientificFunction("∛")
                                }, calculatorMode: .scientific)
                                .overlay(
                                    Text("∛")
                                        .font(.system(size: 17, weight: .medium)) // 减小字体大小
                                        .foregroundColor(.black) // 确保文字可见
                                )
                                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            }
                            
                            calculatorButton(.factorial) {
                                viewModel.handleScientificFunction("x!")
                            }
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                        }
                        
                        // 第三行：e^x, 10^x, π, e, Ans, () (TYPE_E)
                        HStack(spacing: typeEButtonSpacing) {
                            calculatorButton(.exp) {
                                viewModel.handleScientificFunction("eˣ")
                            }
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            
                            Group {
                                ThemedCalculatorButton(buttonType: .exp, action: {
                                    viewModel.handleScientificFunction("10ˣ")
                                }, calculatorMode: .scientific)
                                .overlay(
                                    Text("10^x")
                                        .font(.system(size: 16, weight: .medium)) // 减小字体大小
                                        .foregroundColor(.black) // 确保文字可见
                                )
                                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            }
                            
                            calculatorButton(.pi) {
                                viewModel.handleNumberInput(String(Double.pi))
                            }
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            
                            calculatorButton(.e) {
                                viewModel.handleNumberInput(String(M_E))
                            }
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            
                            Group {
                                ThemedCalculatorButton(buttonType: .secondFunction, action: {
                                    // 实现Ans功能，可以调用上一次计算结果
                                    if let lastResult = viewModel.lastResult {
                                        viewModel.displayValue = viewModel.calculatorService.formatNumber(lastResult)
                                        viewModel.isStartingNewInput = false
                                    }
                                }, calculatorMode: .scientific)
                                .overlay(
                                    Text("Ans")
                                        .font(.system(size: 16, weight: .medium)) // 减小字体大小
                                        .foregroundColor(.black) // 确保文字可见
                                )
                                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            }
                            
                            Group {
                                ThemedCalculatorButton(buttonType: .leftParenthesis, action: {
                                    // 括号功能实现较复杂，暂不实现
                                }, calculatorMode: .scientific)
                                .overlay(
                                    Text("()")
                                        .font(.system(size: 17, weight: .medium)) // 减小字体大小
                                        .foregroundColor(.black) // 确保文字可见
                                )
                                .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            }
                        }
                    }
                    
                    // 区域2: TYPE_F、G、H、I按钮区域（标准计算器功能）
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
                .padding(.horizontal, 20) // 明确设置边距为左右各20pt
            }
            .frame(width: screenWidth) // 使用整个屏幕宽度
        }
    }
    
    // 创建计算器按钮
    private func calculatorButton(_ type: ButtonType, action: @escaping () -> Void) -> some View {
        ThemedCalculatorButton(buttonType: type, action: action, calculatorMode: .scientific)
    }
}

#Preview {
    ScientificCalculatorButtonsView(viewModel: CalculatorViewModel())
        .environmentObject(AppViewModel.shared)
        .previewLayout(.sizeThatFits)
}