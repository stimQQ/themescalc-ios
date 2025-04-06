import SwiftUI

struct ThemedTabBar: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Binding var selectedTab: Int
    
    private let themeUtils = ThemeUtils.shared
    
    @State private var homeSelectedImage: UIImage?
    @State private var homeUnselectedImage: UIImage?
    @State private var themeSelectedImage: UIImage?
    @State private var themeUnselectedImage: UIImage?
    @State private var profileSelectedImage: UIImage?
    @State private var profileUnselectedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 0) {
                // 计算器标签
                tabButton(
                    selectedImage: homeSelectedImage,
                    unselectedImage: homeUnselectedImage,
                    title: "计算器",
                    tab: 0
                )
                
                // 主题标签
                tabButton(
                    selectedImage: themeSelectedImage,
                    unselectedImage: themeUnselectedImage,
                    title: "主题",
                    tab: 1
                )
                
                // 个人中心标签
                tabButton(
                    selectedImage: profileSelectedImage,
                    unselectedImage: profileUnselectedImage,
                    title: "我的",
                    tab: 2
                )
            }
            .frame(height: 50)
            .background(tabBarBackground)
        }
        .onAppear(perform: loadTabBarImages)
        .onChange(of: appViewModel.currentTheme) { _ in
            loadTabBarImages()
        }
    }
    
    private func tabButton(selectedImage: UIImage?, unselectedImage: UIImage?, title: String, tab: Int) -> some View {
        Button(action: {
            withAnimation {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                // 图标
                if let theme = appViewModel.currentTheme, theme.tabbarUseImage {
                    // 使用图片
                    Group {
                        if selectedTab == tab, let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 24)
                        } else if let image = unselectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 24)
                        } else {
                            // 回退到系统图标
                            fallbackTabIcon(for: tab, isSelected: selectedTab == tab)
                                .frame(height: 24)
                        }
                    }
                } else {
                    // 使用系统图标
                    fallbackTabIcon(for: tab, isSelected: selectedTab == tab)
                        .frame(height: 24)
                }
                
                // 标题
                Text(title)
                    .font(.system(size: tabFontSize))
                    .foregroundColor(tabTextColor(isSelected: selectedTab == tab))
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // 标签栏背景
    private var tabBarBackground: some View {
        Group {
            if let theme = appViewModel.currentTheme {
                if theme.tabbarUseImage, let backgroundImageURL = theme.tabbarBackgroundImage {
                    AsyncImage(url: URL(string: backgroundImageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        case .failure, .empty, _:
                            tabBarBackgroundColor(theme: theme)
                        }
                    }
                } else {
                    tabBarBackgroundColor(theme: theme)
                }
            } else {
                Color(.systemBackground)
            }
        }
    }
    
    // 标签栏背景颜色
    private func tabBarBackgroundColor(theme: ThemeModel) -> some View {
        themeUtils.color(from: theme.tabbarBackgroundColor, defaultColor: Color(.systemBackground))
            .opacity(theme.tabbarBackgroundOpacity)
    }
    
    // 标签文字颜色
    private func tabTextColor(isSelected: Bool) -> Color {
        if let theme = appViewModel.currentTheme {
            if isSelected {
                return themeUtils.color(
                    from: theme.tabbarSelectedFontColor,
                    defaultColor: .accentColor
                )
            } else {
                return themeUtils.color(
                    from: theme.tabbarUnselectedFontColor,
                    defaultColor: .gray
                )
            }
        }
        return isSelected ? .accentColor : .gray
    }
    
    // 标签字体大小
    private var tabFontSize: CGFloat {
        if let theme = appViewModel.currentTheme {
            return CGFloat(theme.tabbarFontSize)
        }
        return 12
    }
    
    // 加载TabBar图片
    private func loadTabBarImages() {
        guard let theme = appViewModel.currentTheme else { return }
        
        // 加载主页图标
        themeUtils.loadImage(from: theme.tabbarIcons.home.selected) { image in
            homeSelectedImage = image
        }
        
        themeUtils.loadImage(from: theme.tabbarIcons.home.unselected) { image in
            homeUnselectedImage = image
        }
        
        // 加载主题图标
        themeUtils.loadImage(from: theme.tabbarIcons.theme.selected) { image in
            themeSelectedImage = image
        }
        
        themeUtils.loadImage(from: theme.tabbarIcons.theme.unselected) { image in
            themeUnselectedImage = image
        }
        
        // 加载个人中心图标
        themeUtils.loadImage(from: theme.tabbarIcons.profile.selected) { image in
            profileSelectedImage = image
        }
        
        themeUtils.loadImage(from: theme.tabbarIcons.profile.unselected) { image in
            profileUnselectedImage = image
        }
    }
    
    // 回退使用系统图标
    private func fallbackTabIcon(for tab: Int, isSelected: Bool) -> some View {
        Group {
            switch tab {
            case 0:
                Image(systemName: "calculator")
                    .font(.system(size: 20))
            case 1:
                Image(systemName: "paintpalette")
                    .font(.system(size: 20))
            case 2:
                Image(systemName: "person")
                    .font(.system(size: 20))
            default:
                Image(systemName: "circle")
                    .font(.system(size: 20))
            }
        }
        .foregroundColor(tabTextColor(isSelected: isSelected))
    }
}

#Preview {
    ThemedTabBar(selectedTab: .constant(0))
        .environmentObject(AppViewModel.shared)
        .previewLayout(.sizeThatFits)
} 