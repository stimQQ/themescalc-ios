import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ThemedBackgroundView {
            VStack(spacing: 30) {
                Spacer()
                
                // 应用Logo
                Image(systemName: "function")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)
                
                Text("主题计算器")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("使用Apple ID登录或选择访客模式")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                // 登录按钮
                VStack(spacing: 20) {
                    // Apple登录按钮
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: configureAppleRequest,
                        onCompletion: handleAppleSignIn
                    )
                    .frame(height: 50)
                    .padding(.horizontal)
                    
                    // 访客登录按钮
                    Button(action: {
                        appViewModel.loginAsGuest()
                    }) {
                        Text("访客模式")
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(colorScheme == .dark ? Color.white : Color.black, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    // 配置Apple登录请求
    private func configureAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
    
    // 处理Apple登录结果
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                // 处理成功登录
                _ = UserService.shared.signInWithApple(credential: appleIDCredential)
                    .sink(
                        receiveCompletion: { completion in
                            // 处理错误
                            if case .failure(let error) = completion {
                                print("Apple登录失败: \(error)")
                                
                                // 失败时使用访客模式
                                appViewModel.loginAsGuest()
                            }
                        },
                        receiveValue: { _ in
                            // 登录成功
                            appViewModel.completeOnboarding()
                        }
                    )
            }
        case .failure(let error):
            print("Apple登录失败: \(error.localizedDescription)")
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppViewModel.shared)
} 