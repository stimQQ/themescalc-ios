//
//  themecalculatorApp.swift
//  themecalculator
//
//  Created by 钧玮 on 2025/4/6.
//

import SwiftUI
import SwiftData

@main
struct themecalculatorApp: App {
    // 使用AppViewModel作为全局状态管理
    @StateObject private var appViewModel = AppViewModel.shared
    
    // 注册AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            contentView
                .environmentObject(appViewModel)
                .onAppear {
                    // 设置方向锁定为竖屏
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                    
                    // 禁用iPad多任务
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        UIApplication.shared.connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .forEach { windowScene in
                                windowScene.sizeRestrictions?.minimumSize = CGSize(width: 375, height: 667)
                                windowScene.sizeRestrictions?.maximumSize = CGSize(width: 375, height: 667)
                            }
                    }
                }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if appViewModel.hasCompletedOnboarding {
            // 已完成引导，显示主视图
            MainView()
        } else if appViewModel.isLoggedIn {
            // 已登录未选择语言，显示语言选择
            LanguageSelectionView()
        } else {
            // 未登录，显示登录页面
            LoginView()
        }
    }
}

// 禁用iPad支持和横屏旋转
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}
