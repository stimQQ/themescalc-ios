import SwiftUI

struct ThemeSelectionView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = ThemeViewModel()
    
    var body: some View {
        ThemedBackgroundView {
            VStack(spacing: 0) {
                // 顶部标题
                Text("主题")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                // 分段控制器
                Picker("Theme Type", selection: $viewModel.currentTabIndex) {
                    Text("免费").tag(0)
                    Text("付费").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // 主题列表
                ScrollView {
                    if viewModel.currentTabIndex == 0 {
                        // 免费主题
                        ThemeGrid(themes: viewModel.freeThemes, viewModel: viewModel)
                    } else {
                        // 付费主题
                        VStack(spacing: 16) {
                            // 订阅卡片
                            if !viewModel.isSubscribed {
                                subscriptionCard
                            }
                            
                            // 付费主题列表
                            ThemeGrid(themes: viewModel.paidThemes, viewModel: viewModel)
                        }
                    }
                }
                .padding(.top)
                
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
        }
        .onAppear {
            viewModel.refreshThemes()
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
                // 跳转到订阅页面或弹出订阅选项
            }) {
                Text("立即订阅")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 32)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
    }
}

// 主题网格视图
struct ThemeGrid: View {
    let themes: [ThemeListItem]
    @ObservedObject var viewModel: ThemeViewModel
    
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
                    viewModel.selectTheme(id: theme.id)
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
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                // 主题预览图，设置宽高比为9:16
                GeometryReader { geo in
                    CachedAsyncImage(url: URL(string: theme.detailImage)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geo.size.width, height: geo.size.width * 16/9)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                                )
                                .clipped()
                        case .failure:
                            Color.gray
                                .frame(width: geo.size.width, height: geo.size.width * 16/9)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                                )
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
                
                // 付费标志
                if theme.isPaid {
                    Label("付费", systemImage: "cart")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ThemeSelectionView()
        .environmentObject(AppViewModel.shared)
} 