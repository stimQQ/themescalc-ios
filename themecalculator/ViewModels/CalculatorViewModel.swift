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
            // 检查是否在括号内有未完成的操作
            if displayValue.contains("(") && !displayValue.hasSuffix(")") {
                // 如果在括号内有操作符，保留括号和操作符，只替换最新的数字部分
                let parts = displayValue.components(separatedBy: " ")
                if parts.count >= 3 && ["+", "-", "×", "÷"].contains(parts[parts.count - 2]) {
                    // 保留前面的内容，包括操作符
                    let prefix = parts.dropLast().joined(separator: " ")
                    displayValue = "\(prefix) \(number)"
                    
                    // 同样更新输入公式
                    if !inputFormula.isEmpty {
                        // 尝试找到操作符的位置
                        if let lastOperatorRange = inputFormula.range(of: " \(parts[parts.count - 2]) ", options: .backwards) {
                            let prefixFormula = inputFormula[..<lastOperatorRange.upperBound]
                            inputFormula = "\(prefixFormula)\(number)"
                        } else {
                            // 如果找不到操作符，追加到当前公式
                            inputFormula += number
                        }
                    } else {
                        inputFormula = displayValue
                    }
                } else {
                    // 如果没有操作符，但有未闭合的括号，追加数字
                    displayValue = number
                    
                    // 如果括号在开头，保留它
                    if inputFormula.hasPrefix("(") {
                        inputFormula = "(\(number)"
                    } else {
                        inputFormula = number
                    }
                }
            } else {
                // 常规新输入处理
                displayValue = number
                
                // 如果是新输入，判断是否已有操作符
                if let firstOperand = firstOperand, let operation = currentOperation {
                    // 如果已有操作符，则在公式后添加新输入
                    inputFormula = "\(calculatorService.formatNumber(firstOperand)) \(operation) \(number)"
                } else {
                    // 否则重置公式
                    inputFormula = number
                }
            }
            isStartingNewInput = false
        } else {
            // 如果当前显示为"0"且输入不是小数点，则替换显示内容
            if displayValue == "0" && number != "." {
                displayValue = number
                
                // 更新输入公式
                if inputFormula == "0" {
                    inputFormula = number
                } else if let firstOperand = firstOperand, let operation = currentOperation {
                    // 如果有前置操作，保留操作符
                    inputFormula = "\(calculatorService.formatNumber(firstOperand)) \(operation) \(number)"
                } else {
                    // 检查是否有未闭合的括号
                    let openBrackets = inputFormula.filter { $0 == "(" }.count
                    let closeBrackets = inputFormula.filter { $0 == ")" }.count
                    
                    if openBrackets > closeBrackets {
                        // 如果有未闭合的括号，替换最后一个数字
                        if let range = inputFormula.range(of: "0", options: .backwards) {
                            inputFormula.replaceSubrange(range, with: number)
                        } else {
                            inputFormula += number
                        }
                    } else {
                        inputFormula = number
                    }
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
                        if parts[2].isEmpty {
                            // 如果第二个操作数为空，直接设置
                            inputFormula = "\(parts[0]) \(parts[1]) \(number)"
                        } else {
                            // 否则追加到第二个操作数
                            inputFormula = "\(parts[0]) \(parts[1]) \(parts[2])\(number)"
                        }
                    } else {
                        inputFormula = "\(calculatorService.formatNumber(firstOperand)) \(operation) \(displayValue)"
                    }
                } else {
                    // 检查括号情况
                    if displayValue.contains("(") && !inputFormula.isEmpty {
                        // 如果有括号且公式不为空，更新公式的最后部分
                        if let lastChar = inputFormula.last, lastChar.isNumber || lastChar == "." {
                            // 如果最后一个字符是数字或小数点，追加数字
                            inputFormula += number
                        } else if inputFormula.hasSuffix(" ") {
                            // 如果以空格结尾，追加数字
                            inputFormula += number
                        } else {
                            // 其他情况，尝试拼接输入到当前公式
                            inputFormula += number
                        }
                    } else {
                        // 否则直接更新公式
                        inputFormula = displayValue
                    }
                }
            }
        }
    }
    
    // 处理操作按钮
    func handleOperation(_ operation: String) {
        // 检查括号情况
        var openBrackets = 0
        
        for char in displayValue {
            if char == "(" {
                openBrackets += 1
            } else if char == ")" {
                openBrackets -= 1
            }
        }
        
        // 如果在括号内（有未闭合的左括号），直接将操作符追加到显示值和输入公式中
        if openBrackets > 0 {
            displayValue += " \(operation) "
            
            // 只要追加操作符到现有公式，不替换任何内容
            if inputFormula.isEmpty {
                inputFormula = displayValue
            } else {
                // 检查inputFormula是否已包含当前显示值
                // 如果不包含，则直接追加到inputFormula
                if !inputFormula.contains(displayValue.dropLast(operation.count + 2)) {
                    inputFormula += " \(operation) "
                } else {
                    // 否则，只追加操作符
                    inputFormula += " \(operation) "
                }
            }
            
            // 标记为开始新输入，但不清除现有内容
            isStartingNewInput = true
            return
        }
        
        // 以下是原来的逻辑，处理非括号内的操作
        // 如果已有操作符和两个操作数，先计算结果
        if let firstOp = firstOperand, let op = currentOperation, !isStartingNewInput {
            if let value = Double(displayValue) {
                secondOperand = value
                performCalculation()
                // 更新公式历史(只显示计算公式，不显示结果)
                formulaHistory = "\(calculatorService.formatNumber(firstOp)) \(op) \(calculatorService.formatNumber(value))"
            }
        } else if displayValue.contains("(") && displayValue.contains(")") {
            // 如果显示值包含括号表达式，尝试保留它而不是替换
            if let value = evaluateExpressionWithBrackets(displayValue) {
                firstOperand = value
            } else if let value = Double(displayValue.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")) {
                // 如果无法计算括号表达式，尝试去除括号并转换为数值
                firstOperand = value
            }
        } else if let value = Double(displayValue) {
            // 如果显示值是数字，直接作为第一操作数
            firstOperand = value
        }
        
        // 保存当前操作
        currentOperation = operation
        
        // 更新输入公式
        if let firstOp = firstOperand {
            inputFormula = "\(calculatorService.formatNumber(firstOp)) \(operation)"
        } else {
            inputFormula = "0 \(operation)"
        }
        
        isStartingNewInput = true
    }
    
    // 处理等号按钮
    func handleEqual() {
        // 在计算前修复表达式格式
        fixExpressionFormat()
        
        // 检查是否有括号表达式需要先计算
        if displayValue.contains("(") && displayValue.contains(")") || inputFormula.contains("(") && inputFormula.contains(")") {
            // 尝试计算复杂的括号表达式
            let expressionToEvaluate = inputFormula.isEmpty ? displayValue : inputFormula
            
            // 首先尝试计算内部括号表达式
            if let result = evaluateComplexExpression(expressionToEvaluate) {
                // 保存计算前的表达式用于历史记录
                formulaHistory = expressionToEvaluate
                
                // 更新结果
                displayValue = calculatorService.formatNumber(result)
                lastResult = result
                firstOperand = result
                secondOperand = nil
                currentOperation = nil
                
                // 保存计算历史
                calculatorService.saveCalculationHistory(expression: expressionToEvaluate, result: displayValue)
                loadCalculationHistory()
                
                // 清空输入公式，因为计算已完成
                inputFormula = ""
                isStartingNewInput = true
                return
            }
        }
        
        // 常规等号处理逻辑
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
            
            // 更新显示值和状态
            displayValue = calculatorService.formatNumber(result)
            lastResult = result
            
            // 设置为可继续计算的状态
            // 如果之前有未完成的操作，保持该操作
            if firstOperand != nil && currentOperation != nil {
                // 如果有未完成的基本操作，则把科学计算结果作为第二个操作数
                secondOperand = result
            } else {
                // 否则将结果设为第一个操作数，准备进行后续计算
                firstOperand = result
                // 清空当前操作以便输入新的操作
                currentOperation = nil
            }
            
            // 允许用户基于此结果继续科学计算或基本操作
            isStartingNewInput = true
            
            // 保留输入公式，以便继续计算
            if inputFormula.isEmpty {
                inputFormula = displayValue
            } else if !isStartingNewInput {
                // 在已有公式的情况下，更新右侧操作数
                let parts = inputFormula.components(separatedBy: " ")
                if parts.count >= 3 && currentOperation != nil {
                    inputFormula = "\(parts[0]) \(parts[1]) \(displayValue)"
                }
            }
        }
    }
    
    // 切换角度/弧度模式
    func toggleAngleMode() {
        isInRadianMode.toggle()
    }
    
    // 处理括号按钮
    func handleParenthesis() {
        // 统计显示值和输入公式中的括号数量
        var openBracketsInDisplay = 0
        for char in displayValue {
            if char == "(" {
                openBracketsInDisplay += 1
            } else if char == ")" {
                openBracketsInDisplay -= 1
            }
        }
        
        var openBracketsInFormula = 0
        for char in inputFormula {
            if char == "(" {
                openBracketsInFormula += 1
            } else if char == ")" {
                openBracketsInFormula -= 1
            }
        }
        
        // 如果有未闭合的括号，添加右括号
        if openBracketsInDisplay > 0 || openBracketsInFormula > 0 {
            // 添加右括号
            displayValue += ")"
            inputFormula += ")"
            
            // 判断是否需要计算括号表达式
            // 如果右括号闭合了一个完整表达式，尝试计算
            if displayValue.contains("(") && displayValue.hasSuffix(")") && openBracketsInDisplay == 1 {
                if let result = evaluateExpressionWithBrackets(displayValue) {
                    // 将结果设置为第一个操作数，以便继续计算
                    firstOperand = result
                    lastResult = result
                    
                    // 更新显示值为计算结果，但保留公式用于历史记录
                    displayValue = calculatorService.formatNumber(result)
                    
                    // 如果这是一个完整的括号表达式计算，标记为开始新输入
                    isStartingNewInput = true
                }
            }
        } else {
            // 没有未闭合的括号，添加左括号
            
            // 判断是否需要添加乘号（当前值不为0，且最后字符是数字或右括号）
            if displayValue != "0" && !isStartingNewInput {
                if let lastChar = displayValue.last, 
                   (lastChar.isNumber || lastChar == ")" || lastChar == "π" || lastChar == "e") {
                    // 需要添加乘号
                    displayValue += " × ("
                    inputFormula += " × ("
                } else {
                    // 直接添加左括号
                    displayValue += "("
                    inputFormula += "("
                }
            } else {
                // 清除当前显示，开始新的括号输入
                displayValue = "("
                
                // 如果有前置操作数和运算符，保留它们
                if let firstOp = firstOperand, let operation = currentOperation {
                    inputFormula = "\(calculatorService.formatNumber(firstOp)) \(operation) ("
                } else {
                    inputFormula = "("
                }
            }
            
            // 标记为非新输入状态，以便继续输入
            isStartingNewInput = false
        }
    }
    
    // 尝试计算包含括号的表达式
    private func evaluateExpressionWithBrackets(_ expression: String) -> Double? {
        // 简单括号表达式求值，暂时支持简单的括号表达式
        // 实际应用中，应该使用更复杂的表达式解析器
        
        // 这个是一个简化版本，只处理单层括号
        if let leftBracketIndex = expression.firstIndex(of: "("),
           let rightBracketIndex = expression.lastIndex(of: ")"),
           leftBracketIndex < rightBracketIndex {
            
            let startIndex = expression.index(after: leftBracketIndex)
            let innerExpression = String(expression[startIndex..<rightBracketIndex])
            
            // 尝试解析内部表达式
            if let innerResult = evaluateSimpleExpression(innerExpression) {
                return innerResult
            }
        }
        
        return nil
    }
    
    // 简单表达式求值
    private func evaluateSimpleExpression(_ expression: String) -> Double? {
        // 非常简化的表达式求值
        // 实际应用应使用专业的表达式解析库
        
        // 检查加法
        if let components = expression.components(separatedBy: "+").map({ $0.trimmingCharacters(in: .whitespaces) }) as? [String], components.count == 2 {
            if let left = Double(components[0]), let right = Double(components[1]) {
                return left + right
            }
        }
        
        // 检查减法
        if let components = expression.components(separatedBy: "-").map({ $0.trimmingCharacters(in: .whitespaces) }) as? [String], components.count == 2 {
            if let left = Double(components[0]), let right = Double(components[1]) {
                return left - right
            }
        }
        
        // 检查乘法
        if let components = expression.components(separatedBy: "×").map({ $0.trimmingCharacters(in: .whitespaces) }) as? [String], components.count == 2 {
            if let left = Double(components[0]), let right = Double(components[1]) {
                return left * right
            }
        }
        
        // 检查除法
        if let components = expression.components(separatedBy: "÷").map({ $0.trimmingCharacters(in: .whitespaces) }) as? [String], components.count == 2 {
            if let left = Double(components[0]), let right = Double(components[1]), right != 0 {
                return left / right
            }
        }
        
        // 如果是单一数字，直接返回
        return Double(expression)
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
    
    // MARK: - 表达式验证
    
    // 验证表达式语法的正确性，主要检查括号平衡和基本运算符规则
    func validateExpression(_ expression: String) -> Bool {
        var openBrackets = 0
        var lastChar: Character? = nil
        let operators: [Character] = ["+", "-", "×", "÷"]
        
        for char in expression {
            // 检查括号平衡
            if char == "(" {
                openBrackets += 1
            } else if char == ")" {
                openBrackets -= 1
                // 如果右括号多于左括号，表达式无效
                if openBrackets < 0 {
                    return false
                }
            }
            
            // 运算符规则检查
            if let last = lastChar {
                // 检查两个运算符是否相邻（除了负号可以跟在其他运算符后面）
                if operators.contains(char) && operators.contains(last) && !(char == "-" && operators.contains(last)) {
                    return false
                }
                
                // 右括号后不能直接跟数字，左括号前不能直接跟数字（应该有运算符）
                if last == ")" && char.isNumber {
                    return false
                }
                
                if char == "(" && last.isNumber {
                    return false
                }
            }
            
            lastChar = char
        }
        
        // 最终括号应该平衡
        return openBrackets == 0
    }
    
    // 检查表达式格式并在有问题时提供修复
    func fixExpressionFormat() {
        // 统计左右括号数量
        var openBrackets = 0
        
        for char in inputFormula {
            if char == "(" {
                openBrackets += 1
            } else if char == ")" {
                openBrackets -= 1
            }
        }
        
        // 如果右括号多于左括号，移除多余的右括号
        if openBrackets < 0 {
            var newFormula = ""
            var tmpOpenBrackets = 0
            
            for char in inputFormula {
                if char == "(" {
                    tmpOpenBrackets += 1
                    newFormula.append(char)
                } else if char == ")" {
                    if tmpOpenBrackets > 0 {
                        tmpOpenBrackets -= 1
                        newFormula.append(char)
                    }
                    // 忽略多余的右括号
                } else {
                    newFormula.append(char)
                }
            }
            
            inputFormula = newFormula
        }
        
        // 如果左括号多于右括号，在末尾添加缺少的右括号
        if openBrackets > 0 {
            for _ in 0..<openBrackets {
                inputFormula.append(")")
            }
        }
    }
    
    // 增强的表达式计算功能，支持复杂的括号表达式
    private func evaluateComplexExpression(_ expression: String) -> Double? {
        // 去掉表达式中的空白字符
        var sanitizedExpression = expression.replacingOccurrences(of: " ", with: "")
        
        // 首先计算所有括号内的表达式
        while sanitizedExpression.contains("(") && sanitizedExpression.contains(")") {
            // 找到最内层的括号
            if let rightBracketIndex = sanitizedExpression.firstIndex(of: ")") {
                // 向左查找匹配的左括号
                var leftBracketIndex: String.Index?
                var openCount = 0
                
                // 从右括号向左查找匹配的左括号
                for i in stride(from: sanitizedExpression.distance(from: sanitizedExpression.startIndex, to: rightBracketIndex) - 1, through: 0, by: -1) {
                    let charIndex = sanitizedExpression.index(sanitizedExpression.startIndex, offsetBy: i)
                    let char = sanitizedExpression[charIndex]
                    
                    if char == ")" {
                        openCount += 1
                    } else if char == "(" {
                        if openCount == 0 {
                            leftBracketIndex = charIndex
                            break
                        } else {
                            openCount -= 1
                        }
                    }
                }
                
                // 如果找到了匹配的左括号
                if let leftIndex = leftBracketIndex {
                    // 提取括号内的表达式
                    let start = sanitizedExpression.index(after: leftIndex)
                    let innerExpression = String(sanitizedExpression[start..<rightBracketIndex])
                    
                    // 计算括号内的表达式
                    if let result = evaluateSimpleArithmeticExpression(innerExpression) {
                        // 替换括号及其内容为计算结果
                        let rangeToReplace = leftIndex..<sanitizedExpression.index(after: rightBracketIndex)
                        sanitizedExpression.replaceSubrange(rangeToReplace, with: calculatorService.formatNumber(result))
                    } else {
                        // 如果无法计算，则去掉括号
                        let leftRange = leftIndex..<sanitizedExpression.index(after: leftIndex)
                        sanitizedExpression.replaceSubrange(leftRange, with: "")
                        
                        // 更新右括号索引（因为左括号被移除，右括号索引减1）
                        let newRightIndex = sanitizedExpression.index(rightBracketIndex, offsetBy: -1)
                        let rightRange = newRightIndex..<sanitizedExpression.index(after: newRightIndex)
                        sanitizedExpression.replaceSubrange(rightRange, with: "")
                    }
                } else {
                    // 如果没有找到匹配的左括号，移除这个右括号
                    sanitizedExpression.remove(at: rightBracketIndex)
                }
            } else {
                // 没有右括号，退出循环
                break
            }
        }
        
        // 最后计算整个表达式
        return evaluateSimpleArithmeticExpression(sanitizedExpression)
    }
    
    // 计算简单的算术表达式（支持 +, -, ×, ÷）
    private func evaluateSimpleArithmeticExpression(_ expression: String) -> Double? {
        // 先查找乘除法
        let mulDivPattern = "([\\d.]+)([×÷])([\\d.]+)"
        let mulDivRegex = try? NSRegularExpression(pattern: mulDivPattern, options: [])
        
        var workingExpression = expression
        
        // 处理乘除法
        while let match = mulDivRegex?.firstMatch(in: workingExpression, options: [], range: NSRange(workingExpression.startIndex..., in: workingExpression)) {
            if let operandRange1 = Range(match.range(at: 1), in: workingExpression),
               let operatorRange = Range(match.range(at: 2), in: workingExpression),
               let operandRange2 = Range(match.range(at: 3), in: workingExpression) {
                
                let operand1 = Double(workingExpression[operandRange1]) ?? 0
                let operand2 = Double(workingExpression[operandRange2]) ?? 0
                let operatorSymbol = workingExpression[operatorRange]
                
                let result: Double
                
                if operatorSymbol == "×" {
                    result = operand1 * operand2
                } else { // ÷
                    if operand2 == 0 {
                        return nil // 除以零错误
                    }
                    result = operand1 / operand2
                }
                
                // 替换整个表达式部分为结果
                let rangeToReplace = operandRange1.lowerBound..<operandRange2.upperBound
                workingExpression.replaceSubrange(rangeToReplace, with: calculatorService.formatNumber(result))
            } else {
                break
            }
        }
        
        // 处理加减法
        let addSubPattern = "([\\d.]+)([+\\-])([\\d.]+)"
        let addSubRegex = try? NSRegularExpression(pattern: addSubPattern, options: [])
        
        // 处理加减法
        while let match = addSubRegex?.firstMatch(in: workingExpression, options: [], range: NSRange(workingExpression.startIndex..., in: workingExpression)) {
            if let operandRange1 = Range(match.range(at: 1), in: workingExpression),
               let operatorRange = Range(match.range(at: 2), in: workingExpression),
               let operandRange2 = Range(match.range(at: 3), in: workingExpression) {
                
                let operand1 = Double(workingExpression[operandRange1]) ?? 0
                let operand2 = Double(workingExpression[operandRange2]) ?? 0
                let operatorSymbol = workingExpression[operatorRange]
                
                let result: Double
                
                if operatorSymbol == "+" {
                    result = operand1 + operand2
                } else { // -
                    result = operand1 - operand2
                }
                
                // 替换整个表达式部分为结果
                let rangeToReplace = operandRange1.lowerBound..<operandRange2.upperBound
                workingExpression.replaceSubrange(rangeToReplace, with: calculatorService.formatNumber(result))
            } else {
                break
            }
        }
        
        // 最终结果应该只是一个数字
        return Double(workingExpression)
    }
} 