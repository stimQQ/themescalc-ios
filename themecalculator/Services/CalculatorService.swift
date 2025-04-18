import Foundation
import AVFoundation

class CalculatorService {
    static let shared = CalculatorService()
    
    // 音频播放器用于按钮音效
    private var audioPlayers: [URL: AVAudioPlayer] = [:]
    
    private init() {
        // 初始化音频会话
        setupAudioSession()
    }
    
    // 设置音频会话
    private func setupAudioSession() {
        do {
            // 修改音频会话类别为playback，以确保在静音状态下也能播放
            // 添加.mixWithOthers选项，使音效可以和其他音频混合播放
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers, .duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // 播放按钮音效
    func playButtonSound(soundURL: String?) {
        guard let soundURLString = soundURL,
              let url = URL(string: soundURLString) else {
            return
        }
        
        // 确保音频会话是激活的
        do {
            if !AVAudioSession.sharedInstance().isOtherAudioPlaying {
                try AVAudioSession.sharedInstance().setActive(true)
            }
        } catch {
            print("Failed to activate audio session: \(error)")
        }
        
        // 检查是否已经缓存了这个URL的音频播放器
        if let player = audioPlayers[url] {
            // 确保每次播放从头开始，避免播放器已到结尾的问题
            player.currentTime = 0
            player.play()
            return
        }
        
        // 否则创建新的音频播放器
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Failed to download sound file: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let player = try AVAudioPlayer(data: data)
                // 设置播放器属性
                player.volume = 1.0
                player.numberOfLoops = 0
                
                self?.audioPlayers[url] = player
                player.prepareToPlay()
                
                // 在主线程播放音频，避免线程安全问题
                DispatchQueue.main.async {
                    player.play()
                }
            } catch {
                print("Failed to create audio player: \(error)")
            }
        }.resume()
    }
    
    // 基本计算逻辑（模拟iOS计算器行为）
    func calculateBasic(firstOperand: Double, secondOperand: Double?, operation: String?) -> Double {
        guard let secondOperand = secondOperand, let operation = operation else {
            return firstOperand
        }
        
        switch operation {
        case "+":
            return firstOperand + secondOperand
        case "-":
            return firstOperand - secondOperand
        case "×":
            return firstOperand * secondOperand
        case "÷":
            return secondOperand != 0 ? firstOperand / secondOperand : Double.nan
        case "%":
            return firstOperand / 100
        default:
            return firstOperand
        }
    }
    
    // 科学计算功能
    func calculateScientific(value: Double, function: String) -> Double {
        switch function {
        case "sin":
            return sin(value)
        case "cos":
            return cos(value)
        case "tan":
            return tan(value)
        case "log":
            return log10(value)
        case "ln":
            return log(value)
        case "√":
            return sqrt(value)
        case "xʸ":
            // 需要两个参数，这里简化处理
            return pow(value, 2)
        case "x!":
            return factorial(value)
        case "1/x":
            return 1 / value
        case "eˣ":
            return exp(value)
        default:
            return value
        }
    }
    
    // 阶乘计算（仅支持整数）
    private func factorial(_ n: Double) -> Double {
        guard n >= 0 else { return Double.nan }
        guard n.truncatingRemainder(dividingBy: 1) == 0 else { return Double.nan }
        
        let nInt = Int(n)
        if nInt == 0 || nInt == 1 {
            return 1
        }
        
        var result: Double = 1
        for i in 2...nInt {
            result *= Double(i)
        }
        
        return result
    }
    
    // 格式化数字显示（模拟iOS计算器显示规则）
    func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 15 // 增加小数位数精度从10位提高到15位
        formatter.numberStyle = .decimal
        
        // 处理特殊情况
        if number.isNaN {
            return "错误"
        } else if number.isInfinite {
            return number > 0 ? "∞" : "-∞"
        }
        
        // 检查数字是否非常大或非常小，使用科学计数法
        let absNumber = abs(number)
        if absNumber > 0 && (absNumber < 0.0000001 || absNumber > 10000000000.0) {
            // 使用科学计数法
            let scientificFormatter = NumberFormatter()
            scientificFormatter.numberStyle = .scientific
            scientificFormatter.maximumFractionDigits = 10
            scientificFormatter.exponentSymbol = "e" // 使用小写e作为指数符号
            return scientificFormatter.string(from: NSNumber(value: number)) ?? "\(number)"
        } else {
            // 常规格式
            return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
        }
    }
    
    // 保存计算历史记录
    func saveCalculationHistory(expression: String, result: String) {
        let historyItem = CalculationHistoryItem(
            expression: expression,
            result: result,
            timestamp: Date()
        )
        
        var history = loadCalculationHistory()
        history.insert(historyItem, at: 0)
        
        // 限制历史记录数量
        if history.count > 100 {
            history = Array(history.prefix(100))
        }
        
        saveCalculationHistory(history: history)
    }
    
    // 加载计算历史记录
    func loadCalculationHistory() -> [CalculationHistoryItem] {
        guard let data = UserDefaults.standard.data(forKey: "calculationHistory") else {
            return []
        }
        
        do {
            let history = try JSONDecoder().decode([CalculationHistoryItem].self, from: data)
            return history
        } catch {
            print("Failed to decode calculation history: \(error)")
            return []
        }
    }
    
    // 保存计算历史记录到UserDefaults
    private func saveCalculationHistory(history: [CalculationHistoryItem]) {
        do {
            let data = try JSONEncoder().encode(history)
            UserDefaults.standard.set(data, forKey: "calculationHistory")
        } catch {
            print("Failed to encode calculation history: \(error)")
        }
    }
    
    // 清除计算历史记录
    func clearCalculationHistory() {
        UserDefaults.standard.removeObject(forKey: "calculationHistory")
    }
} 