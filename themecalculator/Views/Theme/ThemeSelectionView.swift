import SwiftUI

struct ThemeSelectionView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = ThemeViewModel()
    @State private var showingSubscriptionSheet = false
    @State private var selectedThemeForDetail: ThemeListItem? = nil
    
    private let themeUtils = ThemeUtils.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // 主题背景
                if let theme = appViewModel.currentTheme {
                    if theme.hasGlobalBackgroundImage, let imageUrlString = theme.globalBackgroundImage, !imageUrlString.isEmpty {
                        CachedAsyncImage(url: URL(string: imageUrlString)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .edgesIgnoringSafeArea(.all)
                            case .failure:
                                themeUtils.color(from: theme.globalBackgroundColor, defaultColor: Color(.systemBackground))
                                    .edgesIgnoringSafeArea(.all)
                            case .empty:
                                themeUtils.color(from: theme.globalBackgroundColor, defaultColor: Color(.systemBackground))
                                    .edgesIgnoringSafeArea(.all)
                            @unknown default:
                                themeUtils.color(from: theme.globalBackgroundColor, defaultColor: Color(.systemBackground))
                                    .edgesIgnoringSafeArea(.all)
                            }
                        }
                    } else {
                        themeUtils.color(from: theme.globalBackgroundColor, defaultColor: Color(.systemBackground))
                            .edgesIgnoringSafeArea(.all)
                    }
                } else {
                    Color(.systemBackground)
                        .edgesIgnoringSafeArea(.all)
                }
                
                // 内容
                VStack(spacing: 0) {
                    // 顶部标题
                    Text("主题")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    // 主题列表
                    ScrollView {
                        VStack(spacing: 20) {
                            // 免费主题区域
                            VStack(alignment: .leading, spacing: 12) {
                                Text("免费主题")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                ThemeGrid(themes: viewModel.freeThemes, viewModel: viewModel, onThemeSelected: { theme in
                                    selectedThemeForDetail = theme
                                })
                            }
                            
                            // 订阅引导卡片
                            if !viewModel.isSubscribed {
                                subscriptionCard
                                    .padding(.vertical, 12)
                            }
                            
                            // 付费主题区域
                            VStack(alignment: .leading, spacing: 12) {
                                Text("付费主题")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                ThemeGrid(themes: viewModel.paidThemes, viewModel: viewModel, onThemeSelected: { theme in
                                    selectedThemeForDetail = theme
                                })
                            }
                        }
                        .padding(.top, 8)
                    }
                    
                    // 加载中指示器
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                    
                    // 错误消息
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .background(Color.clear) // 确保内容的背景是透明的
                .navigationBarHidden(true)
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedThemeForDetail != nil },
                set: { if !$0 { selectedThemeForDetail = nil } }
            )) {
                if let theme = selectedThemeForDetail {
                    ThemeDetailView(theme: theme, viewModel: viewModel)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // 使用StackNavigationViewStyle避免iPad上的分屏布局
        .onAppear {
            viewModel.refreshThemes()
        }
        .sheet(isPresented: $showingSubscriptionSheet) {
            SubscriptionView()
                .environmentObject(appViewModel)
        }
    }
    
    // 订阅卡片
    private var subscriptionCard: some View {
        VStack(spacing: 16) {
            Text("解锁所有主题")
                .font(.title)
                .fontWeight(.bold)
            
            Text("订阅后可使用所有付费主题，无限制更换皮肤")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showingSubscriptionSheet = true
            }) {
                Text("立即订阅")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(primaryThemeColor)
                    .cornerRadius(30) // 使用全圆角
            }
            .padding(.horizontal, 32)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.7))
        )
        .padding(.horizontal)
    }
    
    // 获取当前主题的主要颜色（使用主题顶部按钮选中颜色）
    private var primaryThemeColor: Color {
        if let theme = appViewModel.currentTheme {
            return themeUtils.color(from: theme.topButtonSelectedColor, defaultColor: Color.blue)
        }
        return Color.blue // 默认颜色
    }
}

// 主题网格视图
struct ThemeGrid: View {
    let themes: [ThemeListItem]
    @ObservedObject var viewModel: ThemeViewModel
    @EnvironmentObject private var appViewModel: AppViewModel
    var onThemeSelected: (ThemeListItem) -> Void
    
    private let themeUtils = ThemeUtils.shared
    
    // 修改为固定的3列布局
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(themes) { theme in
                ThemeGridItem(theme: theme, isSelected: viewModel.isThemeSelected(id: theme.id)) {
                    onThemeSelected(theme)
                }
            }
        }
        .padding(.horizontal)
    }
}

// 主题网格项
struct ThemeGridItem: View {
    let theme: ThemeListItem
    let isSelected: Bool
    let onSelect: () -> Void
    
    @EnvironmentObject private var appViewModel: AppViewModel
    private let themeUtils = ThemeUtils.shared
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                // 主题预览图，设置宽高比为9:16
                GeometryReader { geo in
                    CachedAsyncImage(url: URL(string: theme.detailImage)) { phase in
                        switch phase {
                        case .success(let image):
                            ZStack(alignment: .topTrailing) {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geo.size.width, height: geo.size.width * 16/9)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isSelected ? primaryThemeColor : Color.clear, lineWidth: 3)
                                    )
                                    .clipped()
                                
                                // 主题标签（付费/免费）
                                Text(theme.isPaid ? "付费" : "免费")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(theme.isPaid ? primaryThemeColor : Color.green)
                                    .cornerRadius(4)
                                    .padding(6)
                            }
                        case .failure:
                            ZStack(alignment: .topTrailing) {
                                Color.gray
                                    .frame(width: geo.size.width, height: geo.size.width * 16/9)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isSelected ? primaryThemeColor : Color.clear, lineWidth: 3)
                                    )
                                
                                // 主题标签（付费/免费）
                                Text(theme.isPaid ? "付费" : "免费")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(theme.isPaid ? primaryThemeColor : Color.green)
                                    .cornerRadius(4)
                                    .padding(6)
                            }
                        case .empty:
                            ProgressView()
                                .frame(width: geo.size.width, height: geo.size.width * 16/9)
                        @unknown default:
                            Color.gray
                                .frame(width: geo.size.width, height: geo.size.width * 16/9)
                                .cornerRadius(12)
                        }
                    }
                }
                .aspectRatio(9/16, contentMode: .fit) // 设置容器的宽高比为9:16
                
                // 主题名称
                Text(theme.name)
                    .font(.headline)
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 获取当前主题的主要颜色（使用主题顶部按钮选中颜色）
    private var primaryThemeColor: Color {
        if let theme = appViewModel.currentTheme {
            return themeUtils.color(from: theme.topButtonSelectedColor, defaultColor: Color.blue)
        }
        return Color.blue // 默认颜色
    }
}

// 主题详情页面
struct ThemeDetailView: View {
    let theme: ThemeListItem
    @ObservedObject var viewModel: ThemeViewModel
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.presentationMode) var presentationMode
    
    private let themeUtils = ThemeUtils.shared
    
    var body: some View {
        ZStack {
            // 主题背景
            if let currentTheme = appViewModel.currentTheme {
                if currentTheme.hasGlobalBackgroundImage, let imageUrlString = currentTheme.globalBackgroundImage, !imageUrlString.isEmpty {
                    CachedAsyncImage(url: URL(string: imageUrlString)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .edgesIgnoringSafeArea(.all)
                        case .failure:
                            themeUtils.color(from: currentTheme.globalBackgroundColor, defaultColor: Color(.systemBackground))
                                .edgesIgnoringSafeArea(.all)
                        case .empty:
                            themeUtils.color(from: currentTheme.globalBackgroundColor, defaultColor: Color(.systemBackground))
                                .edgesIgnoringSafeArea(.all)
                        @unknown default:
                            themeUtils.color(from: currentTheme.globalBackgroundColor, defaultColor: Color(.systemBackground))
                                .edgesIgnoringSafeArea(.all)
                        }
                    }
                } else {
                    themeUtils.color(from: currentTheme.globalBackgroundColor, defaultColor: Color(.systemBackground))
                        .edgesIgnoringSafeArea(.all)
                }
            } else {
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)
            }
            
            // 内容
            ScrollView {
                VStack(spacing: 20) {
                    // 主题图片
                    CachedAsyncImage(url: URL(string: theme.detailImage)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        case .failure:
                            Text("加载图片失败")
                                .foregroundColor(.red)
                                .padding(50)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        case .empty:
                            ProgressView()
                                .padding(100)
                                .frame(maxWidth: .infinity)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal)
                    
                    // 主题详情信息
                    VStack(alignment: .leading, spacing: 16) {
                        // 主题名称
                        Text(theme.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        // 主题类型和版本
                        HStack {
                            Label(
                                theme.isPaid ? "付费主题" : "免费主题",
                                systemImage: theme.isPaid ? "lock.fill" : "checkmark.circle.fill"
                            )
                            .foregroundColor(theme.isPaid ? primaryThemeColor : .green)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        theme.isPaid 
                                        ? primaryThemeColor.opacity(0.1) 
                                        : Color.green.opacity(0.1)
                                    )
                            )
                            
                            Spacer()
                            
                            Text("版本: \(theme.version)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // 主题发布时间
                        HStack {
                            Text("发布时间")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(formatDate(theme.createTime))
                                .font(.subheadline)
                        }
                        
                        // 主题更新时间（如果有）
                        if let updateTime = theme.updateTime {
                            HStack {
                                Text("更新时间")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(formatDate(updateTime))
                                    .font(.subheadline)
                            }
                        }
                        
                        Divider()
                        
                        // 应用按钮
                        Button(action: {
                            viewModel.selectTheme(id: theme.id)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text(viewModel.isThemeSelected(id: theme.id) ? "已应用" : "应用主题")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    viewModel.isThemeSelected(id: theme.id)
                                    ? Color.gray
                                    : primaryThemeColor
                                )
                                .cornerRadius(30)
                        }
                        .disabled(viewModel.isThemeSelected(id: theme.id))
                        .opacity(viewModel.isThemeSelected(id: theme.id) ? 0.7 : 1)
                        .padding(.vertical, 8)
                        
                        // 如果是付费主题并且用户未订阅，显示订阅提示
                        if theme.isPaid && !viewModel.isSubscribed {
                            Text("需要订阅才能使用此主题")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground).opacity(0.7))
                    )
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationBarTitle("主题详情", displayMode: .inline)
        }
    }
    
    // 格式化日期
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
    
    // 获取当前主题的主要颜色
    private var primaryThemeColor: Color {
        if let theme = appViewModel.currentTheme {
            return themeUtils.color(from: theme.topButtonSelectedColor, defaultColor: Color.blue)
        }
        return Color.blue // 默认颜色
    }
}

// 订阅页面
struct SubscriptionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appViewModel: AppViewModel
    
    private let themeUtils = ThemeUtils.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 标题
                    Text("选择您的订阅计划")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // 订阅卡片
                    VStack(spacing: 16) {
                        // 月度订阅
                        subscriptionOption(
                            title: "月度订阅",
                            price: "¥18.00/月",
                            features: ["使用所有付费主题", "优先获取新主题", "支持在多台设备上使用"],
                            action: { subscribeToPlan(plan: "monthly") }
                        )
                        
                        // 年度订阅
                        subscriptionOption(
                            title: "年度订阅",
                            price: "¥128.00/年",
                            description: "每月仅需¥10.67，比月度订阅节省40%",
                            features: ["使用所有付费主题", "优先获取新主题", "支持在多台设备上使用", "免费获取新增高级功能"],
                            isRecommended: true,
                            action: { subscribeToPlan(plan: "yearly") }
                        )
                        
                        // 永久订阅
                        subscriptionOption(
                            title: "永久会员",
                            price: "¥298.00",
                            features: ["永久使用所有付费主题", "无需担心续费问题", "所有高级功能永久解锁"],
                            action: { subscribeToPlan(plan: "lifetime") }
                        )
                    }
                    .padding()
                    
                    // 恢复购买按钮
                    Button(action: {
                        // 恢复购买逻辑
                    }) {
                        Text("恢复购买")
                            .foregroundColor(primaryThemeColor)
                    }
                    .padding(.bottom)
                    
                    // 隐私和条款链接
                    HStack(spacing: 8) {
                        Text("订阅即表示您同意我们的")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            // 显示服务条款
                        }) {
                            Text("服务条款")
                                .font(.caption)
                                .foregroundColor(primaryThemeColor)
                        }
                        
                        Text("和")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            // 显示隐私政策
                        }) {
                            Text("隐私政策")
                                .font(.caption)
                                .foregroundColor(primaryThemeColor)
                        }
                    }
                    .padding(.bottom)
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("关闭") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // 订阅选项卡
    private func subscriptionOption(
        title: String,
        price: String,
        description: String? = nil,
        features: [String],
        isRecommended: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 12) {
            // 推荐标签
            if isRecommended {
                Text("推荐")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(primaryThemeColor)
                    .cornerRadius(12)
                    .padding(.top, -12)
            }
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(price)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(primaryThemeColor)
            
            if let description = description {
                Text(description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // 功能列表
            VStack(alignment: .leading, spacing: 8) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text(feature)
                            .font(.subheadline)
                    }
                }
            }
            .padding(.vertical, 4)
            
            // 选择按钮
            Button(action: action) {
                Text("选择")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(primaryThemeColor)
                    .cornerRadius(30) // 使用全圆角
            }
            .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(primaryThemeColor.opacity(0.1))
                .shadow(color: isRecommended ? primaryThemeColor.opacity(0.2) : Color.gray.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isRecommended ? primaryThemeColor : Color.clear, lineWidth: isRecommended ? 2 : 0)
        )
    }
    
    // 获取当前主题的主要颜色（使用主题顶部按钮选中颜色）
    private var primaryThemeColor: Color {
        if let theme = appViewModel.currentTheme {
            return themeUtils.color(from: theme.topButtonSelectedColor, defaultColor: Color.blue)
        }
        return Color.blue // 默认颜色
    }
    
    // 订阅计划逻辑
    private func subscribeToPlan(plan: String) {
        print("订阅计划: \(plan)")
        // 这里实现实际的订阅逻辑
    }
}

#Preview {
    ThemeSelectionView()
        .environmentObject(AppViewModel.shared)
} 