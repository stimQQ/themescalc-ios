import SwiftUI

struct MainView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var selectedTab: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // 主内容区域
            ZStack {
                // 计算器视图
                if selectedTab == 0 {
                    CalculatorView()
                        .zIndex(selectedTab == 0 ? 1 : 0)
                        .transition(.opacity)
                }
                
                // 主题选择视图
                if selectedTab == 1 {
                    ThemeSelectionView()
                        .zIndex(selectedTab == 1 ? 1 : 0)
                        .transition(.opacity)
                }
                
                // 个人中心视图
                if selectedTab == 2 {
                    ProfileView()
                        .zIndex(selectedTab == 2 ? 1 : 0)
                        .transition(.opacity)
                }
            }
            
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