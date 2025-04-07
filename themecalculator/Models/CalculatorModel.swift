import Foundation

// 计算器模式
enum CalculatorMode: String, CaseIterable, Identifiable {
    case basic = "basic"
    case scientific = "scientific"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .basic:
            return "基础"
        case .scientific:
            return "科学"
        }
    }
}

// 计算按钮类型
enum ButtonType: String {
    // 基础计算器按钮类型
    case clear = "AC"            // 清除
    case toggleSign = "+/-"      // 正负号
    case percentage = "%"        // 百分比
    case divide = "÷"            // 除法
    case multiply = "×"          // 乘法
    case subtract = "-"          // 减法
    case add = "+"               // 加法
    case equal = "="             // 等于
    case decimal = "."           // 小数点
    
    // 数字按钮 0-9
    case zero = "0"
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    
    // 科学计算器按钮类型
    case secondFunction = "2nd"   // 第二功能
    case leftParenthesis = "("    // 左括号
    case rightParenthesis = ")"   // 右括号
    case memory = "mc"           // 内存清除
    case memoryPlus = "m+"       // 内存加
    case memoryMinus = "m-"      // 内存减
    case memoryRecall = "mr"     // 内存调用
    case sin = "sin"             // 正弦
    case cos = "cos"             // 余弦
    case tan = "tan"             // 正切
    case log = "log"             // 对数
    case ln = "ln"               // 自然对数
    case power = "xʸ"            // 幂
    case sqrt = "√"              // 平方根
    case exp = "eˣ"              // e的幂
    case pi = "π"                // 圆周率
    case e = "e"                 // 自然常数
    case reciprocal = "1/x"      // 倒数
    case factorial = "x!"        // 阶乘
    case rad = "Rad"             // 弧度
    case deg = "Deg"             // 角度
    
    // 主题按钮映射
    func themeButtonType(for calculatorMode: CalculatorMode) -> String {
        switch calculatorMode {
        case .basic:
            // 基础计算器按钮类型映射
            switch self {
            case .clear, .toggleSign, .percentage:
                return "TYPE_A"  // 功能按钮
            case .divide, .multiply, .subtract, .add:
                return "TYPE_B"  // 运算符按钮
            case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .decimal:
                return "TYPE_C"  // 数字按钮和小数点
            case .equal:
                return "TYPE_D"  // 等于按钮
            default:
                return "TYPE_A"  // 其他按钮默认为TYPE_A
            }
            
        case .scientific:
            // 科学计算器按钮类型映射
            switch self {
            case .clear, .toggleSign, .percentage:
                return "TYPE_F"  // 功能按钮
            case .divide, .multiply, .subtract, .add:
                return "TYPE_G"  // 运算符按钮
            case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .decimal:
                return "TYPE_H"  // 数字按钮和小数点
            case .equal:
                return "TYPE_I"  // 等于按钮
            case .sin, .cos, .tan, .log, .ln, .reciprocal,
                 .power, .sqrt, .exp, .pi, .e, .factorial,
                 .secondFunction, .leftParenthesis, .rightParenthesis:
                return "TYPE_E"  // 科学计算器特殊函数按钮
            case .memory, .memoryPlus, .memoryMinus, .memoryRecall:
                return "TYPE_F"  // 内存功能按钮
            case .rad, .deg:
                return "TYPE_I"  // 角度/弧度切换按钮
            }
        }
    }
    
    // 兼容现有代码的映射方法
    var themeButtonType: String {
        // 默认使用基础计算器的映射
        return themeButtonType(for: .basic)
    }
}

// 计算历史记录项
struct CalculationHistoryItem: Identifiable, Codable {
    let id = UUID()
    let expression: String
    let result: String
    let timestamp: Date
    
    // 添加CodingKeys以允许UUID的编码解码
    enum CodingKeys: String, CodingKey {
        case id
        case expression
        case result
        case timestamp
    }
    
    // 自定义编码方法
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(expression, forKey: .expression)
        try container.encode(result, forKey: .result)
        try container.encode(timestamp, forKey: .timestamp)
    }
    
    // 自定义解码方法
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let _ = try container.decode(String.self, forKey: .id)
        
        let expression = try container.decode(String.self, forKey: .expression)
        let result = try container.decode(String.self, forKey: .result)
        let timestamp = try container.decode(Date.self, forKey: .timestamp)
        
        self.init(expression: expression, result: result, timestamp: timestamp)
    }
    
    init(expression: String, result: String, timestamp: Date) {
        self.expression = expression
        self.result = result
        self.timestamp = timestamp
    }
} 