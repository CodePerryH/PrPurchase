//
//  AppDelegate.swift
//  PrApplePurchase
//
//  Created by admin on 2022/2/11.
//

import UIKit
import StoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window : UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        ///添加内购代理
        ///如果之前有木有支付完成的订单 app 打开的时候会再次走 paymentQueue 代理
        ///支付完成木有到账的订单并不会在app 打开的时候走这个代理；需要开发者 自己向自己的服务器验证
        PrPay.shared.addObserver()
        
        let nav = UINavigationController(rootViewController: HomeViewController())
        window?.rootViewController  = nav
        window?.makeKeyAndVisible()


        
        return true
    }


}

