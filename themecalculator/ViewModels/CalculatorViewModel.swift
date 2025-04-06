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
    @Published var isInRadianMode: Bool = true
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
            isStartingNewInput = false
        } else {
            // 如果当前显示为"0"且输入不是小数点，则替换显示内容
            if displayValue == "0" && number != "." {
                displayValue = number
            } else {
                // 如果已经包含小数点且输入是小数点，则忽略
                if number == "." && displayValue.contains(".") {
                    return
                }
                
                // 否则追加显示内容
                displayValue += number
            }
        }
    }
    
    // 处理操作按钮
    func handleOperation(_ operation: String) {
        // 保存当前操作
        currentOperation = operation
        
        // 将显示值转换为操作数
        if let value = Double(displayValue) {
            if firstOperand == nil {
                firstOperand = value
            } else {
                secondOperand = value
                performCalculation()
            }
        }
        
        isStartingNewInput = true
    }
    
    // 处理等号按钮
    func handleEqual() {
        if let firstOperand = firstOperand, let currentOperation = currentOperation {
            if secondOperand == nil {
                if let value = Double(displayValue) {
                    secondOperand = value
                }
            }
            
            performCalculation()
            
            // 保存计算历史
            let expression = "\(calculatorService.formatNumber(firstOperand)) \(currentOperation) \(calculatorService.formatNumber(secondOperand ?? 0))"
            calculatorService.saveCalculationHistory(expression: expression, result: displayValue)
            loadCalculationHistory()
            
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
        firstOperand = nil
        secondOperand = nil
        currentOperation = nil
        isStartingNewInput = true
    }
    
    // 处理正负号切换
    func handleToggleSign() {
        if let value = Double(displayValue) {
            displayValue = calculatorService.formatNumber(-value)
        }
    }
    
    // 处理百分比
    func handlePercentage() {
        if let value = Double(displayValue) {
            displayValue = calculatorService.formatNumber(value / 100)
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