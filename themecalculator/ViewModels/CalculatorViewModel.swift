import Foundation
import Combine

class CalculatorViewModel: ObservableObject {
    // 服务
    let calculatorService = CalculatorService.shared
    private let themeService = ThemeService.shared
    private let appViewModel = AppViewModel.shared
    
    // 订阅集合
    private var cancellables = Set<AnyCancellable>()
    
    // 计算器状态
    @Published var displayValue: String = "0"
    @Published var inputFormula: String = "" // 实时显示用户输入的公式
    @Published var formulaHistory: String = "" // 显示完整的计算公式历史
    @Published var currentMode: CalculatorMode = .basic
    @Published var isInScientificMode: Bool = false
    @Published var calculationHistory: [CalculationHistoryItem] = []
    
    // 运算相关
    private var firstOperand: Double?
    private var secondOperand: Double?
    private var currentOperation: String?
    @Published var isStartingNewInput: Bool = true
    // 暴露lastResult属性以支持Ans功能
    private(set) var lastResult: Double?
    
    // 科学计算器状态
    @Published var isInRadianMode: Bool = false // 默认使用角度制而非弧度制
    private var memoryValue: Double = 0
    
    init() {
        // 加载计算历史记录
        loadCalculationHistory()
        
        // 订阅主题变化
        appViewModel.$currentTheme
            .sink { [weak self] _ in
                // 主题变化时可能需要更新UI
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 模式切换
    
    // 切换计算器模式
    func switchMode(to mode: CalculatorMode) {
        currentMode = mode
        isInScientificMode = (mode == .scientific)
    }
    
    // MARK: - 基础计算功能
    
    // 处理数字按钮
    func handleNumberInput(_ number: String) {
        if isStartingNewInput {
            displayValue = number
            // 如果是新输入，判断是否已有操作符
            if let firstOperand = firstOperand, let operation = currentOperation {
                // 如果已有操作符，则在公式后添加新输入
                inputFormula = "\(calculatorService.formatNumber(firstOperand)) \(operation) \(number)"
            } else {
                // 否则重置公式
                inputFormula = number
            }
            isStartingNewInput = false
        } else {
            // 如果当前显示为"0"且输入不是小数点，则替换显示内容
            if displayValue == "0" && number != "." {
                displayValue = number
                // 更新输入公式
                if let firstOperand = firstOperand, let operation = currentOperation {
                    inputFormula = "\(calculatorService.formatNumber(firstOperand)) \(operation) \(number)"
                } else {
                    inputFormula = number
                }
            } else {
                // 如果已经包含小数点且输入是小数点，则忽略
                if number == "." && displayValue.contains(".") {
                    return
                }
                
                // 否则追加显示内容
                displayValue += number
                // 更新输入公式
                if let firstOperand = firstOperand, let operation = currentOperation {
                    // 如果有操作符，则更新第二个操作数
                    let parts = inputFormula.components(separatedBy: " ")
                    if parts.count >= 3 {
                        inputFormula = "\(parts[0]) \(parts[1]) \(displayValue)"
                    } else {
                        inputFormula = "\(calculatorService.formatNumber(firstOperand)) \(operation) \(displayValue)"
                    }
                } else {
                    // 否则直接更新公式
                    inputFormula = displayValue
                }
            }
        }
    }
    
    // 处理操作按钮
    func handleOperation(_ operation: String) {
        // 如果已有操作符和两个操作数，先计算结果
        if let firstOp = firstOperand, let op = currentOperation, !isStartingNewInput {
            if let value = Double(displayValue) {
                secondOperand = value
                performCalculation()
                // 更新公式历史(只显示计算公式，不显示结果)
                formulaHistory = "\(calculatorService.formatNumber(firstOp)) \(op) \(calculatorService.formatNumber(value))"
            }
        }
        
        // 保存当前操作
        currentOperation = operation
        
        // 将显示值转换为操作数
        if let value = Double(displayValue) {
            firstOperand = value
        }
        
        // 更新输入公式
        inputFormula = "\(calculatorService.formatNumber(firstOperand ?? 0)) \(operation)"
        
        isStartingNewInput = true
    }
    
    // 处理等号按钮
    func handleEqual() {
        if let firstOp = firstOperand, let currentOp = currentOperation {
            if secondOperand == nil {
                if let value = Double(displayValue) {
                    secondOperand = value
                }
            }
            
            // 在计算前保存完整表达式
            let expression = "\(calculatorService.formatNumber(firstOp)) \(currentOp) \(calculatorService.formatNumber(secondOperand ?? Double(displayValue) ?? 0))"
            
            performCalculation()
            
            // 更新公式历史(只显示计算公式，不显示结果)
            formulaHistory = expression
            
            // 保存计算历史
            calculatorService.saveCalculationHistory(expression: expression, result: displayValue)
            loadCalculationHistory()
            
            // 清空输入公式，因为计算已完成
            inputFormula = ""
            
            // 重置状态，准备新的计算
            self.firstOperand = lastResult
            self.secondOperand = nil
            self.currentOperation = nil
            isStartingNewInput = true
        }
    }
    
    // 执行计算
    private func performCalculation() {
        if let firstOperand = firstOperand, let currentOperation = currentOperation {
            let result: Double
            
            if let secondOperand = secondOperand {
                result = calculatorService.calculateBasic(firstOperand: firstOperand, secondOperand: secondOperand, operation: currentOperation)
            } else if let inputValue = Double(displayValue) {
                result = calculatorService.calculateBasic(firstOperand: firstOperand, secondOperand: inputValue, operation: currentOperation)
            } else {
                result = firstOperand
            }
            
            lastResult = result
            displayValue = calculatorService.formatNumber(result)
        }
    }
    
    // 处理清除按钮
    func handleClear() {
        displayValue = "0"
        inputFormula = ""
        formulaHistory = ""
        firstOperand = nil
        secondOperand = nil
        currentOperation = nil
        isStartingNewInput = true
    }
    
    // 处理正负号切换
    func handleToggleSign() {
        if let value = Double(displayValue) {
            displayValue = calculatorService.formatNumber(-value)
            
            // 更新输入公式
            if let firstOperand = firstOperand, let operation = currentOperation {
                let parts = inputFormula.components(separatedBy: " ")
                if parts.count >= 3 {
                    inputFormula = "\(parts[0]) \(parts[1]) \(displayValue)"
                }
            } else {
                inputFormula = displayValue
            }
        }
    }
    
    // 处理百分比
    func handlePercentage() {
        if let value = Double(displayValue) {
            displayValue = calculatorService.formatNumber(value / 100)
            
            // 更新输入公式
            if let firstOperand = firstOperand, let operation = currentOperation {
                let parts = inputFormula.components(separatedBy: " ")
                if parts.count >= 3 {
                    inputFormula = "\(parts[0]) \(parts[1]) \(displayValue)"
                }
            } else {
                inputFormula = displayValue
            }
        }
    }
    
    // MARK: - 科学计算功能
    
    // 处理科学函数
    func handleScientificFunction(_ function: String) {
        if let value = Double(displayValue) {
            // 三角函数需要考虑角度/弧度模式
            var inputValue = value
            if !isInRadianMode && (function == "sin" || function == "cos" || function == "tan") {
                // 将角度转换为弧度
                inputValue = value * .pi / 180
            }
            
            // 更新公式历史(使用正确的上标符号)
            switch function {
            case "x²":
                formulaHistory = "\(calculatorService.formatNumber(value))²"
            case "x³":
                formulaHistory = "\(calculatorService.formatNumber(value))³"
            case "10ˣ":
                formulaHistory = "10ˣ(\(calculatorService.formatNumber(value)))"
            case "eˣ":
                formulaHistory = "eˣ(\(calculatorService.formatNumber(value)))"
            case "xʸ":
                formulaHistory = "\(calculatorService.formatNumber(value))ʸ"
            case "∛":
                formulaHistory = "∛\(calculatorService.formatNumber(value))"
            default:
                formulaHistory = "\(function)(\(calculatorService.formatNumber(value)))"
            }
            
            let result: Double
            
            // 处理新增的科学计算函数
            switch function {
            case "x²":
                result = pow(inputValue, 2)
            case "x³":
                result = pow(inputValue, 3)
            case "10ˣ":
                result = pow(10, inputValue)
            case "∛":
                result = pow(inputValue, 1/3)
            default:
                result = calculatorService.calculateScientific(value: inputValue, function: function)
            }
            
            displayValue = calculatorService.formatNumber(result)
            inputFormula = ""
            
            lastResult = result
            isStartingNewInput = true
        }
    }
    
    // 切换角度/弧度模式
    func toggleAngleMode() {
        isInRadianMode.toggle()
    }
    
    // 处理内存操作
    func handleMemoryOperation(_ operation: String) {
        switch operation {
        case "mc": // 内存清除
            memoryValue = 0
        case "m+": // 内存加
            if let value = Double(displayValue) {
                memoryValue += value
            }
        case "m-": // 内存减
            if let value = Double(displayValue) {
                memoryValue -= value
            }
        case "mr": // 内存调用
            displayValue = calculatorService.formatNumber(memoryValue)
            isStartingNewInput = true
        default:
            break
        }
    }
    
    // MARK: - 历史记录
    
    // 加载计算历史记录
    func loadCalculationHistory() {
        calculationHistory = calculatorService.loadCalculationHistory()
    }
    
    // 清除历史记录
    func clearHistory() {
        calculatorService.clearCalculationHistory()
        calculationHistory = []
    }
    
    // MARK: - 主题相关
    
    // 播放按钮音效
    func playButtonSound(for buttonType: ButtonType) {
        if let theme = appViewModel.currentTheme {
            let themeButtonType = buttonType.themeButtonType
            if let buttonTheme = theme.buttons.first(where: { $0.type == themeButtonType }) {
                calculatorService.playButtonSound(soundURL: buttonTheme.sound)
            }
        }
    }
} 