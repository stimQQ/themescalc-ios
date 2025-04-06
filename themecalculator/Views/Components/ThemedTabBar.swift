import SwiftUI

struct ThemedTabBar: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Binding var selectedTab: Int
    
    private let themeUtils = ThemeUtils.shared
    
    // 图标图片状态
    @State private var homeSelectedImage: UIImage?
    @State private var homeUnselectedImage: UIImage?
    @State private var themeSelectedImage: UIImage?
    @State private var themeUnselectedImage: UIImage?
    @State private var profileSelectedImage: UIImage?
    @State private var profileUnselectedImage: UIImage?
    @State private var voiceSelectedImage: UIImage?
    @State private var voiceUnselectedImage: UIImage?
    @State private var cameraSelectedImage: UIImage?
    @State private var cameraUnselectedImage: UIImage?
    
    // 背景图片状态
    @State private var backgroundImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 0) {
                // 计算器标签 (home)
                tabButton(
                    selectedImage: homeSelectedImage,
                    unselectedImage: homeUnselectedImage,
                    title: "计算器",
                    iconName: "calculator",
                    tab: 0
                )
                
                // 主题标签 (theme)
                tabButton(
                    selectedImage: themeSelectedImage,
                    unselectedImage: themeUnselectedImage,
                    title: "主题",
                    iconName: "paintpalette",
                    tab: 1
                )
                
                // 个人中心标签 (profile)
                tabButton(
                    selectedImage: profileSelectedImage,
                    unselectedImage: profileUnselectedImage,
                    title: "我的",
                    iconName: "person",
                    tab: 2
                )
            }
            .frame(height: 50)
            .background(tabBarBackground)
        }
        .onAppear(perform: loadTabBarAssets)
        .onChange(of: appViewModel.currentTheme) { _ in
            loadTabBarAssets()
        }
    }
    
    private func tabButton(selectedImage: UIImage?, unselectedImage: UIImage?, title: String, iconName: String, tab: Int) -> some View {
        Button(action: {
            withAnimation {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                // 图标
                Group {
                    if selectedTab == tab, let image = selectedImage {
                        // 使用选中状态的自定义图片
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 24)
                    } else if let image = unselectedImage {
                        // 使用未选中状态的自定义图片
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 24)
                    } else {
                        // 回退到系统图标
                        Image(systemName: iconName)
                            .font(.system(size: 20))
                            .foregroundColor(tabTextColor(isSelected: selectedTab == tab))
                            .frame(height: 24)
                    }
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
                if theme.tabbarUseImage, let image = backgroundImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
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
    
    // 加载TabBar资源（图标和背景）
    private func loadTabBarAssets() {
        guard let theme = appViewModel.currentTheme else { return }
        
        // 加载背景图片
        if let backgroundImageURL = theme.tabbarBackgroundImage {
            themeUtils.loadImage(from: backgroundImageURL) { image in
                backgroundImage = image
            }
        } else {
            backgroundImage = nil
        }
        
        print("开始加载TabBar图标...")
        
        // 加载主页(home)图标
        themeUtils.loadImage(from: theme.tabbarIcons.home.selected) { image in
            print("Home selected icon loaded: \(image != nil)")
            homeSelectedImage = image
        }
        
        themeUtils.loadImage(from: theme.tabbarIcons.home.unselected) { image in
            print("Home unselected icon loaded: \(image != nil)")
            homeUnselectedImage = image
        }
        
        // 加载主题(theme)图标
        themeUtils.loadImage(from: theme.tabbarIcons.theme.selected) { image in
            print("Theme selected icon loaded: \(image != nil)")
            themeSelectedImage = image
        }
        
        themeUtils.loadImage(from: theme.tabbarIcons.theme.unselected) { image in
            print("Theme unselected icon loaded: \(image != nil)")
            themeUnselectedImage = image
        }
        
        // 加载个人中心(profile)图标
        themeUtils.loadImage(from: theme.tabbarIcons.profile.selected) { image in
            print("Profile selected icon loaded: \(image != nil)")
            profileSelectedImage = image
        }
        
        themeUtils.loadImage(from: theme.tabbarIcons.profile.unselected) { image in
            print("Profile unselected icon loaded: \(image != nil)")
            profileUnselectedImage = image
        }
        
        // 加载语音(voice)图标（备用）
        themeUtils.loadImage(from: theme.tabbarIcons.voice?.selected) { image in
            voiceSelectedImage = image
        }
        
        themeUtils.loadImage(from: theme.tabbarIcons.voice?.unselected) { image in
            voiceUnselectedImage = image
        }
        
        // 加载相机(camera)图标（备用）
        themeUtils.loadImage(from: theme.tabbarIcons.camera?.selected) { image in
            cameraSelectedImage = image
        }
        
        themeUtils.loadImage(from: theme.tabbarIcons.camera?.unselected) { image in
            cameraUnselectedImage = image
        }
    }
}

#Preview {
    ThemedTabBar(selectedTab: .constant(0))
        .environmentObject(AppViewModel.shared)
        .previewLayout(.sizeThatFits)
} 