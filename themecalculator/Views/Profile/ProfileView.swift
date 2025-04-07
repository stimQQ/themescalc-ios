import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = ProfileViewModel()
    
    private let themeUtils = ThemeUtils.shared
    
    var body: some View {
        ThemedBackgroundView {
            ScrollView {
                VStack(spacing: 20) {
                    // 用户信息卡片
                    userProfileCard
                    
                    // 订阅推广区域
                    if !viewModel.isSubscribed {
                        subscriptionPromotionCard
                    }
                    
                    // 功能列表
                    functionList
                    
                    // 计算历史记录
                    calculationHistorySection
                    
                    // 关于和法律信息
                    aboutSection
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.loadCalculationHistory()
        }
    }
    
    // 用户信息卡片
    private var userProfileCard: some View {
        HStack(spacing: 16) {
            // 用户信息（左侧）
            VStack(alignment: .leading, spacing: 8) {
                // 用户名
                Text(viewModel.username)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                // 邮箱（如果有）
                if let email = viewModel.email {
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // 订阅状态
                if viewModel.isSubscribed {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(primaryThemeColor)
                        
                        Text("已订阅 - 到期日: \(viewModel.formatExpiryDate())")
                            .font(.subheadline)
                            .foregroundColor(primaryThemeColor)
                    }
                    .padding(.top, 4)
                }
            }
            
            Spacer()
            
            // 用户头像（右侧）
            Image(systemName: "person.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(primaryThemeColor)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground).opacity(0.7))
        )
    }
    
    // 新增：订阅推广卡片
    private var subscriptionPromotionCard: some View {
        VStack(spacing: 16) {
            // 标题
            Text("解锁完整计算体验")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 推广内容
            VStack(alignment: .leading, spacing: 12) {
                promotionFeature(icon: "paintpalette.fill", text: "解锁所有精美主题，让计算更有趣")
                promotionFeature(icon: "clock.fill", text: "无限历史记录，随时查看过往计算")
                promotionFeature(icon: "function", text: "高级计算功能，满足专业需求")
                promotionFeature(icon: "icloud.fill", text: "多设备同步，随时随地使用")
            }
            
            // 立即订阅按钮
            Button(action: {
                // 跳转到订阅页面
            }) {
                HStack {
                    Text("立即订阅 每月仅需 ¥18")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(primaryThemeColor)
                .cornerRadius(30)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground).opacity(0.7))
                .shadow(color: primaryThemeColor.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
    
    // 推广功能项
    private func promotionFeature(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(primaryThemeColor)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
    
    // 功能列表
    private var functionList: some View {
        VStack(spacing: 0) {
            // 标题
            Text("功能选项")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
            
            // 设置列表
            VStack(spacing: 0) {
                // 分享应用
                profileListItem(icon: "square.and.arrow.up", title: "分享应用") {
                    viewModel.shareApp()
                }
                
                Divider()
                
                // 语言设置
                profileListItem(icon: "globe", title: "语言设置") {
                    // 弹出语言选择
                    appViewModel.switchTab(to: 0)
                }
                
                Divider()
                
                // 订阅管理
                profileListItem(icon: "creditcard", title: "订阅管理") {
                    viewModel.manageSubscription()
                }
                
                Divider()
                
                // 清空计算历史
                profileListItem(icon: "trash", title: "清空计算历史") {
                    viewModel.clearCalculationHistory()
                }
                
                Divider()
                
                // 登出
                profileListItem(icon: "arrow.right.square", title: "退出登录") {
                    viewModel.signOut()
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground).opacity(0.7))
            )
        }
    }
    
    // 计算历史记录部分
    private var calculationHistorySection: some View {
        VStack(spacing: 8) {
            // 标题
            Text("计算历史")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
            
            // 历史记录列表
            if viewModel.calculationHistory.isEmpty {
                Text("暂无计算历史")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground).opacity(0.7))
                    )
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.calculationHistory.prefix(5)) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.expression)
                                .font(.subheadline)
                            
                            HStack {
                                Text("= \(item.result)")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text(formattedDate(item.timestamp))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        
                        if item.id != viewModel.calculationHistory.prefix(5).last?.id {
                            Divider()
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground).opacity(0.7))
                )
            }
        }
    }
    
    // 关于和法律信息
    private var aboutSection: some View {
        VStack(spacing: 0) {
            // 标题
            Text("关于")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
            
            // 关于和法律信息列表
            VStack(spacing: 0) {
                // 关于我们
                profileListItem(icon: "info.circle", title: "关于我们") {
                    // 显示关于我们
                }
                
                Divider()
                
                // 联系我们
                profileListItem(icon: "envelope", title: "联系我们") {
                    // 显示联系方式
                }
                
                Divider()
                
                // 隐私政策
                profileListItem(icon: "lock.shield", title: "隐私政策") {
                    // 显示隐私政策
                }
                
                Divider()
                
                // 用户协议
                profileListItem(icon: "doc.text", title: "用户协议") {
                    // 显示用户协议
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground).opacity(0.7))
            )
        }
    }
    
    // 个人中心列表项
    private func profileListItem(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .frame(width: 26, height: 26)
                    .foregroundColor(primaryThemeColor)
                
                Text(title)
                    .font(.body)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
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
    
    // 格式化日期
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppViewModel.shared)
} 