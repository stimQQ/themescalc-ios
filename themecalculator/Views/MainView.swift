import SwiftUI

struct MainView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var selectedTab: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // 主内容区域 - 使用新的视图切换方式，避免灰色过渡
            ZStack {
                // 始终渲染所有视图，使用opacity控制显示/隐藏
                // 这样可以确保在切换时不会有背景露出
                CalculatorView()
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .zIndex(selectedTab == 0 ? 1 : 0)
                
                ThemeSelectionView()
                    .opacity(selectedTab == 1 ? 1 : 0)
                    .zIndex(selectedTab == 1 ? 1 : 0)
                
                ProfileView()
                    .opacity(selectedTab == 2 ? 1 : 0)
                    .zIndex(selectedTab == 2 ? 1 : 0)
            }
            .animation(.easeOut(duration: 0.15), value: selectedTab) // 使用easeOut，更快的过渡效果
            
            // 底部标签栏
            ThemedTabBar(selectedTab: $selectedTab)
        }
        .onChange(of: selectedTab) { newTab in
            appViewModel.currentTab = newTab
        }
        .onChange(of: appViewModel.currentTab) { newTab in
            selectedTab = newTab
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AppViewModel.shared)
} 