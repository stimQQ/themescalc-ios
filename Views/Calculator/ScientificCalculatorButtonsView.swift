import SwiftUI

struct ScientificCalculatorButtonsView: View {
    @ObservedObject var viewModel: CalculatorViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    
    // 计算器按钮布局 - 参考BasicCalculatorButtonsView的简洁布局方式
    private let buttonSpacing: CGFloat = 10 // 统一的按钮间距
    private let verticalSpacing: CGFloat = 10 // 垂直间距
    
    var body: some View {
        GeometryReader { geometry in
            let totalWidth = UIScreen.main.bounds.width - 40 // 确保与计算结果区域宽度一致
            
            // 科学计算器按钮区域（TYPE_E）- 每行6个按钮
            let typeEButtonWidth = (totalWidth - buttonSpacing * 5) / 6
            let typeEButtonHeight = min(typeEButtonWidth * 0.9, 40) // 控制最大高度
            
            // 标准计算器按钮区域 - 每行4个按钮
            let normalButtonWidth = (totalWidth - buttonSpacing * 3) / 4
            let normalButtonHeight = min(normalButtonWidth * 0.9, 60) // 控制最大高度
            
            // 等号按钮特殊处理
            let equalButtonWidth = normalButtonWidth * 2 + buttonSpacing
            
            ScrollView {
                VStack(spacing: verticalSpacing) {
                    // 科学计算器按钮区域
                    VStack(spacing: verticalSpacing) {
                        // 第一行：sin, cos, tan, ln, log, 1/x (TYPE_E)
                        HStack(spacing: buttonSpacing) {
                            ForEach(["sin", "cos", "tan", "ln", "log", "1/x"], id: \.self) { funcName in
                                scientificFunctionButton(funcName)
                                    .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            }
                        }
                        
                        // 第二行：x², x³, x^y, √, ∛, x! (TYPE_E)
                        HStack(spacing: buttonSpacing) {
                            ThemedCalculatorButton(
                                buttonType: .power, 
                                action: { viewModel.handleScientificFunction("x²") },
                                calculatorMode: .scientific, 
                                customText: "x²"
                            )
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            
                            ThemedCalculatorButton(
                                buttonType: .power, 
                                action: { viewModel.handleScientificFunction("x³") },
                                calculatorMode: .scientific, 
                                customText: "x³"
                            )
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            
                            ThemedCalculatorButton(
                                buttonType: .power, 
                                action: { viewModel.handleScientificFunction("x^y") },
                                calculatorMode: .scientific, 
                                customText: "x^y"
                            )
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            
                            calculatorButton(.squareRoot) {
                                viewModel.handleScientificFunction("√")
                            }
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            
                            ThemedCalculatorButton(
                                buttonType: .squareRoot, 
                                action: { viewModel.handleScientificFunction("∛") },
                                calculatorMode: .scientific, 
                                customText: "∛"
                            )
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            
                            calculatorButton(.factorial) {
                                viewModel.handleScientificFunction("x!")
                            }
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                        }
                        
                        // 第三行：e^x, 10^x, π, e, Ans, () (TYPE_E)
                        HStack(spacing: buttonSpacing) {
                            calculatorButton(.exp) {
                                viewModel.handleScientificFunction("eˣ")
                            }
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            
                            ThemedCalculatorButton(
                                buttonType: .exp, 
                                action: { viewModel.handleScientificFunction("10ˣ") },
                                calculatorMode: .scientific, 
                                customText: "10^x"
                            )
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            
                            calculatorButton(.pi) {
                                viewModel.handleConstant("π")
                            }
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            
                            calculatorButton(.e) {
                                viewModel.handleConstant("e")
                            }
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            
                            calculatorButton(.ans) {
                                viewModel.handleAns()
                            }
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                            
                            ThemedCalculatorButton(
                                buttonType: .parentheses, 
                                action: { /* 括号功能 */ },
                                calculatorMode: .scientific, 
                                customText: "()"
                            )
                            .frame(width: typeEButtonWidth, height: typeEButtonHeight)
                        }
                    }
                    
                    // 标准计算器按钮区域
                    VStack(spacing: verticalSpacing) {
                        // 第四行：AC, ±, %, ÷ (TYPE_F 和 TYPE_G)
                        HStack(spacing: buttonSpacing) {
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
                        HStack(spacing: buttonSpacing) {
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
                        HStack(spacing: buttonSpacing) {
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
                        HStack(spacing: buttonSpacing) {
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
                        HStack(spacing: buttonSpacing) {
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
                .frame(width: totalWidth) // 严格控制总宽度
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
    }
    
    // 创建科学计算器功能按钮
    @ViewBuilder
    private func scientificFunctionButton(_ funcName: String) -> some View {
        switch funcName {
        case "sin":
            calculatorButton(.sin) { viewModel.handleScientificFunction("sin") }
        case "cos":
            calculatorButton(.cos) { viewModel.handleScientificFunction("cos") }
        case "tan":
            calculatorButton(.tan) { viewModel.handleScientificFunction("tan") }
        case "ln":
            calculatorButton(.ln) { viewModel.handleScientificFunction("ln") }
        case "log":
            calculatorButton(.log) { viewModel.handleScientificFunction("log") }
        case "1/x":
            calculatorButton(.reciprocal) { viewModel.handleScientificFunction("1/x") }
        default:
            calculatorButton(.sin) { viewModel.handleScientificFunction(funcName) }
        }
    }
    
    // 创建计算器按钮
    @ViewBuilder
    private func calculatorButton(_ buttonType: ButtonType, action: @escaping () -> Void) -> some View {
        ThemedCalculatorButton(buttonType: buttonType, action: action, calculatorMode: .scientific)
    }
} 