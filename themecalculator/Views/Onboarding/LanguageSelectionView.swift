import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        ThemedBackgroundView {
            VStack(spacing: 30) {
                Spacer()
                
                Text("选择语言")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("请选择您偏好的语言")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // 语言选择列表
                VStack(spacing: 16) {
                    ForEach(AppLanguage.allCases) { language in
                        Button(action: {
                            appViewModel.setLanguage(language)
                            appViewModel.completeOnboarding()
                        }) {
                            HStack {
                                Text(language.displayName)
                                    .font(.headline)
                                
                                Spacer()
                                
                                if appViewModel.selectedLanguage == language {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.secondarySystemBackground))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 跳过按钮
                Button(action: {
                    appViewModel.completeOnboarding()
                }) {
                    Text("跳过")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(.bottom)
            }
            .padding()
        }
    }
}

#Preview {
    LanguageSelectionView()
        .environmentObject(AppViewModel.shared)
} 