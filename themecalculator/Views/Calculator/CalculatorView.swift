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
                        Text(viewModel.inputFormula)
                            .font(.system(size: resultFontSize * 0.7))
                            .foregroundColor(resultTextColor.opacity(0.9))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    
                    // 显示结果
                    Text(viewModel.displayValue)
                        .font(.system(size: resultFontSize))
                        .fontWeight(.medium)
                        .foregroundColor(resultTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: UIScreen.main.bounds.width - 40) // 确保宽度为屏幕宽度减去左右各20pt的边距
        .padding(.vertical, 5)
        .padding(.bottom, viewModel.isInScientificMode ? 20 : 10) // 科学计算器模式使用20pt间距，基础计算器模式使用10pt间距（减半）
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