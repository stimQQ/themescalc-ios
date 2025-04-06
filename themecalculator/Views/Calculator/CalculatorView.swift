import SwiftUI

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
            ZStack {
                // 结果背景
                resultBackground
                
                // 结果文本
                Text(viewModel.displayValue)
                    .font(.system(size: resultFontSize))
                    .fontWeight(.medium)
                    .foregroundColor(resultTextColor)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: UIScreen.main.bounds.width - 40) // 确保宽度为屏幕宽度减去左右各20pt的边距
        .padding(.vertical, 5)
    }
    
    // 结果背景
    private var resultBackground: some View {
        Group {
            if let theme = appViewModel.currentTheme,
               theme.resultUseImage,
               let imageUrlString = theme.resultBackgroundImage {
                AsyncImage(url: URL(string: imageUrlString)) { phase in
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
                    AsyncImage(url: URL(string: imageUrl)) { phase in
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