import SwiftUI

// 自定义带缓存的异步图片组件
struct CachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    
    init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    var body: some View {
        if let urlString = url?.absoluteString {
            CachedAsyncImageInternal(
                urlString: urlString,
                scale: scale,
                transaction: transaction,
                content: content
            )
        } else {
            content(.empty)
        }
    }
}

// 内部组件，负责实际的缓存和图片加载逻辑
private struct CachedAsyncImageInternal<Content: View>: View {
    @State private var phase: AsyncImagePhase = .empty
    
    private let urlString: String
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    private let themeUtils = ThemeUtils.shared
    
    init(
        urlString: String,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.urlString = urlString
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    var body: some View {
        content(phase)
            .onAppear {
                loadImage()
            }
    }
    
    private func loadImage() {
        themeUtils.loadImage(from: urlString) { image in
            if let image = image {
                phase = .success(Image(uiImage: image))
            } else {
                phase = .failure(NSError(domain: "CachedAsyncImage", code: -1, userInfo: nil))
            }
        }
    }
}

struct CalculatorView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = CalculatorViewModel()
    
    private let themeUtils = ThemeUtils.shared
    
    var body: some View {
        ThemedBackgroundView {
            VStack(spacing: 0) {
                // 模式切换按钮
                calculatorModeToggle
                
                // 结果显示区域
                resultDisplayView
                
                // 按钮区域
                if viewModel.isInScientificMode {
                    ScientificCalculatorButtonsView(viewModel: viewModel)
                } else {
                    BasicCalculatorButtonsView(viewModel: viewModel)
                }
            }
            .padding(.bottom, 10)
        }
    }
    
    // 计算器模式切换按钮
    private var calculatorModeToggle: some View {
        HStack {
            ForEach(CalculatorMode.allCases) { mode in
                Button(action: {
                    viewModel.switchMode(to: mode)
                }) {
                    Text(mode.displayName)
                        .font(.headline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundColor(modeToggleTextColor(for: mode))
                        .background(
                            modeToggleBackground(for: mode)
                        )
                        .cornerRadius(20)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 5)
    }
    
    // 结果显示区域
    private var resultDisplayView: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .trailing) {
                // 结果背景
                resultBackground
                
                // 结果内容
                VStack(alignment: .trailing, spacing: 4) {
                    // 公式历史记录
                    if !viewModel.formulaHistory.isEmpty {
                        Text(viewModel.formulaHistory)
                            .font(.system(size: resultFontSize * 0.5))
                            .foregroundColor(resultTextColor.opacity(0.7))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    
                    // 当前输入公式
                    if !viewModel.inputFormula.isEmpty {
                        FormattedFormulaText(formula: viewModel.inputFormula, 
                                             textColor: resultTextColor.opacity(0.9),
                                             fontSize: resultFontSize * 0.7,
                                             primaryThemeColor: primaryThemeColor)
                    }
                    
                    // 显示结果
                    Text(viewModel.displayValue)
                        .font(.system(size: resultFontSize))
                        .fontWeight(.medium)
                        .foregroundColor(resultTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                        .allowsTightening(true)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: UIScreen.main.bounds.width - 40) // 确保宽度为屏幕宽度减去左右各20pt的边距
        .padding(.vertical, 5)
        .padding(.bottom, viewModel.isInScientificMode ? 10 : 10) // 将科学计算器模式的间距从20pt减小为10pt
    }
    
    // 获取当前主题的主要颜色（用于括号高亮）
    private var primaryThemeColor: Color {
        if let theme = appViewModel.currentTheme {
            return themeUtils.color(from: theme.topButtonSelectedColor, defaultColor: .blue)
        }
        return .blue // 默认颜色
    }
    
    // 结果背景
    private var resultBackground: some View {
        Group {
            if let theme = appViewModel.currentTheme,
               theme.resultUseImage,
               let imageUrlString = theme.resultBackgroundImage {
                // 使用自定义缓存图片组件替代AsyncImage
                CachedAsyncImage(url: URL(string: imageUrlString)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .clipped()
                    case .failure, .empty, _:
                        resultBackgroundColor
                    }
                }
            } else {
                resultBackgroundColor
            }
        }
        .cornerRadius(20)
    }
    
    // 结果背景颜色
    private var resultBackgroundColor: some View {
        if let theme = appViewModel.currentTheme {
            themeUtils.color(from: theme.resultBackgroundColor, defaultColor: Color(.secondarySystemBackground))
        } else {
            Color(.secondarySystemBackground)
        }
    }
    
    // 结果文本颜色
    private var resultTextColor: Color {
        if let theme = appViewModel.currentTheme {
            return themeUtils.color(from: theme.resultFontColor, defaultColor: .primary)
        }
        return .primary
    }
    
    // 结果字体大小
    private var resultFontSize: CGFloat {
        if let theme = appViewModel.currentTheme {
            return CGFloat(theme.resultFontSize)
        }
        return 40
    }
    
    // 模式切换按钮文本颜色
    private func modeToggleTextColor(for mode: CalculatorMode) -> Color {
        if let theme = appViewModel.currentTheme {
            if viewModel.currentMode == mode {
                return themeUtils.color(from: theme.topButtonSelectedFontColor, defaultColor: .white)
            } else {
                return themeUtils.color(from: theme.topButtonUnselectedFontColor, defaultColor: .blue)
            }
        }
        return viewModel.currentMode == mode ? .white : .blue
    }
    
    // 模式切换按钮背景
    private func modeToggleBackground(for mode: CalculatorMode) -> some View {
        Group {
            if let theme = appViewModel.currentTheme {
                if theme.topButtonUseImage, 
                   let imageUrl = viewModel.currentMode == mode ? theme.topButtonSelectedImage : theme.topButtonUnselectedImage {
                    // 同样为模式切换按钮也使用缓存图片
                    CachedAsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        case .failure, .empty, _:
                            modeToggleBackgroundColor(for: mode)
                        }
                    }
                } else {
                    modeToggleBackgroundColor(for: mode)
                }
            } else {
                modeToggleBackgroundColor(for: mode)
            }
        }
    }
    
    // 模式切换按钮背景颜色
    private func modeToggleBackgroundColor(for mode: CalculatorMode) -> some View {
        if let theme = appViewModel.currentTheme {
            if viewModel.currentMode == mode {
                return themeUtils.color(from: theme.topButtonSelectedColor, defaultColor: .blue)
            } else {
                return themeUtils.color(from: theme.topButtonUnselectedColor, defaultColor: Color(.secondarySystemBackground))
            }
        }
        return viewModel.currentMode == mode ? Color.blue : Color(.secondarySystemBackground)
    }
}

#Preview {
    CalculatorView()
        .environmentObject(AppViewModel.shared)
}

// 自定义视图：带括号高亮的公式文本
struct FormattedFormulaText: View {
    let formula: String
    let textColor: Color
    let fontSize: CGFloat
    let primaryThemeColor: Color
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(getFormattedSegments(), id: \.id) { segment in
                Text(segment.text)
                    .foregroundColor(textColor) // 所有文本使用相同颜色，不再使用高亮色
                    .font(.system(size: fontSize))
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    
    // 获取分段后的公式文本，保持分段结构但不再使用颜色区分
    private func getFormattedSegments() -> [FormulaSegment] {
        var segments: [FormulaSegment] = []
        var currentText = ""
        var bracketDepth = 0
        
        // 遍历公式字符串
        for (index, char) in formula.enumerated() {
            if char == "(" {
                // 如果之前有文本，先添加为一个段
                if !currentText.isEmpty {
                    segments.append(FormulaSegment(text: currentText, isHighlighted: false, bracketLevel: bracketDepth))
                    currentText = ""
                }
                
                // 左括号单独作为一个段
                bracketDepth += 1
                segments.append(FormulaSegment(text: String(char), isHighlighted: false, bracketLevel: bracketDepth - 1))
                
                continue
            } else if char == ")" {
                // 如果之前有文本，先添加为一个段
                if !currentText.isEmpty {
                    segments.append(FormulaSegment(text: currentText, isHighlighted: false, bracketLevel: bracketDepth))
                    currentText = ""
                }
                
                // 右括号单独作为一个段
                bracketDepth = max(0, bracketDepth - 1)
                segments.append(FormulaSegment(text: String(char), isHighlighted: false, bracketLevel: bracketDepth))
                
                continue
            }
            
            // 累积其他字符
            currentText += String(char)
        }
        
        // 添加最后剩余的文本
        if !currentText.isEmpty {
            segments.append(FormulaSegment(text: currentText, isHighlighted: false, bracketLevel: bracketDepth))
        }
        
        return segments
    }
    
    // 原来用于根据段类型获取颜色的方法，现在简化为始终返回textColor
    private func getColorForSegment(_ segment: FormulaSegment) -> Color {
        return textColor
    }
}

// 公式段数据模型
struct FormulaSegment: Identifiable {
    let id = UUID()
    let text: String
    let isHighlighted: Bool
    let bracketLevel: Int
} 