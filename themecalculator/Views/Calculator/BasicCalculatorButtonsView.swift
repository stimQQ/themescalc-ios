import SwiftUI

struct BasicCalculatorButtonsView: View {
    @ObservedObject var viewModel: CalculatorViewModel
    
    // 计算器按钮布局
    private let buttonSpacing: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            let totalWidth = UIScreen.main.bounds.width - 40 // 确保与计算结果区域宽度一致
            let buttonWidth = (totalWidth - buttonSpacing * 3) / 4
            let equalButtonWidth = buttonWidth * 2 + buttonSpacing
            
            VStack(spacing: buttonSpacing) {
                // 第一行：AC, +/-, %, ÷
                HStack(spacing: buttonSpacing) {
                    calculatorButton(.clear) {
                        viewModel.handleClear()
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                    
                    calculatorButton(.toggleSign) {
                        viewModel.handleToggleSign()
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                    
                    calculatorButton(.percentage) {
                        viewModel.handlePercentage()
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                    
                    calculatorButton(.divide) {
                        viewModel.handleOperation("÷")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                }
                
                // 第二行：7, 8, 9, ×
                HStack(spacing: buttonSpacing) {
                    calculatorButton(.seven) {
                        viewModel.handleNumberInput("7")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                    
                    calculatorButton(.eight) {
                        viewModel.handleNumberInput("8")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                    
                    calculatorButton(.nine) {
                        viewModel.handleNumberInput("9")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                    
                    calculatorButton(.multiply) {
                        viewModel.handleOperation("×")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                }
                
                // 第三行：4, 5, 6, -
                HStack(spacing: buttonSpacing) {
                    calculatorButton(.four) {
                        viewModel.handleNumberInput("4")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                    
                    calculatorButton(.five) {
                        viewModel.handleNumberInput("5")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                    
                    calculatorButton(.six) {
                        viewModel.handleNumberInput("6")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                    
                    calculatorButton(.subtract) {
                        viewModel.handleOperation("-")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                }
                
                // 第四行：1, 2, 3, +
                HStack(spacing: buttonSpacing) {
                    calculatorButton(.one) {
                        viewModel.handleNumberInput("1")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                    
                    calculatorButton(.two) {
                        viewModel.handleNumberInput("2")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                    
                    calculatorButton(.three) {
                        viewModel.handleNumberInput("3")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                    
                    calculatorButton(.add) {
                        viewModel.handleOperation("+")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                }
                
                // 第五行：0, ., =
                HStack(spacing: buttonSpacing) {
                    calculatorButton(.zero) {
                        viewModel.handleNumberInput("0")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                    
                    calculatorButton(.decimal) {
                        viewModel.handleNumberInput(".")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                    
                    calculatorButton(.equal) {
                        viewModel.handleEqual()
                    }
                    .frame(width: equalButtonWidth, height: buttonWidth)
                }
            }
            .frame(width: totalWidth)
            .padding(.horizontal, 20) // 添加水平内边距
            .padding(.top, 10)
        }
    }
    
    // 创建计算器按钮
    private func calculatorButton(_ type: ButtonType, action: @escaping () -> Void) -> some View {
        ThemedCalculatorButton(buttonType: type, action: action, calculatorMode: .basic)
    }
}

#Preview {
    BasicCalculatorButtonsView(viewModel: CalculatorViewModel())
        .environmentObject(AppViewModel.shared)
} 