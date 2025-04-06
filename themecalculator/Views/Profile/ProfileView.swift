import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        ThemedBackgroundView {
            ScrollView {
                VStack(spacing: 20) {
                    // 用户信息卡片
                    userProfileCard
                    
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
        VStack(spacing: 12) {
            // 用户头像
            Image(systemName: "person.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue)
            
            // 用户名
            Text(viewModel.username)
                .font(.title)
                .fontWeight(.bold)
            
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
                        .foregroundColor(.green)
                    
                    Text("已订阅 - 到期日: \(viewModel.formatExpiryDate())")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                .padding(.top, 4)
            } else {
                Button(action: {
                    // 跳转到订阅页面
                }) {
                    Text("立即订阅解锁所有主题")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
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
                    .fill(Color(.secondarySystemBackground))
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
                            .fill(Color(.secondarySystemBackground))
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
                        .fill(Color(.secondarySystemBackground))
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
                    .fill(Color(.secondarySystemBackground))
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
                    .foregroundColor(.blue)
                
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