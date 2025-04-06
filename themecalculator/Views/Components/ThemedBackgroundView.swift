import SwiftUI

struct ThemedBackgroundView<Content: View>: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // 背景层
            backgroundView
            
            // 内容层
            content
        }
    }
    
    private var backgroundView: some View {
        GeometryReader { geometry in
            Group {
                if let theme = appViewModel.currentTheme {
                    if theme.hasGlobalBackgroundImage, let imageUrlString = theme.globalBackgroundImage {
                        AsyncImage(url: URL(string: imageUrlString)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                fallbackBackgroundColor(theme: theme)
                            case .empty:
                                fallbackBackgroundColor(theme: theme)
                            @unknown default:
                                fallbackBackgroundColor(theme: theme)
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    } else {
                        fallbackBackgroundColor(theme: theme)
                    }
                } else {
                    // 默认背景色
                    Color(.systemBackground)
                }
            }
            .ignoresSafeArea()
        }
    }
    
    private func fallbackBackgroundColor(theme: ThemeModel) -> some View {
        ThemeUtils.shared.color(from: theme.globalBackgroundColor, defaultColor: Color(.systemBackground))
            .ignoresSafeArea()
    }
}

#Preview {
    ThemedBackgroundView {
        Text("主题背景视图测试")
            .foregroundColor(.white)
    }
    .environmentObject(AppViewModel.shared)
} 