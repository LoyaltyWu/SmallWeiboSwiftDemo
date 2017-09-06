//
//  AppDelegate.swift
//  BikeMapMVCDemo
//
//  Created by LoyaltyWu on 17/8/11.
//  Copyright © 2017年 LoyaltyWu. All rights reserved.
//

import UIKit
import CoreData

//enum ViewPagerComponent: Int {
//    case WeiboSDKResponseStatusCodeSuccess
//    case ViewPagerTabsView
//    case ViewPagerContent
//};


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,WeiboSDKDelegate {
    var wbToken:String!
    var wbCurrentUserID:String!
    var wbRefreshToken:String!
    var vc:ViewController!
    /**
     收到一个来自微博客户端程序的响应
     
     收到微博的响应后，第三方应用可以通过响应类型、响应的数据和 WBBaseResponse.userInfo 中的数据完成自己的功能
     @param response 具体的响应对象
     */
    public func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        // <#code#>
        print(response.description)
        if response is WBSendMessageToWeiboResponse {// response.isKind(of: WBSendMessageToWeiboResponse.self){
            let title:String = NSLocalizedString("发送结果", comment: "comment")
            let message:String = String.init(format: "%@: %d\n%@: %@\n%@: %@", locale: nil,  NSLocalizedString("响应状态", comment: ""), (response.statusCode as! Int), NSLocalizedString("响应UserInfro", comment: ""), response.userInfo, NSLocalizedString("原请求UserInfo数据", comment: ""), response.requestUserInfo)
            // NSString.localizedStringWithFormat("%@: %d\n%@: %@\n%@: %@", NSLocalizedString("响应状态", comment: ""), (response.statusCode as! Int), NSLocalizedString("响应UserInfro", comment: ""), response.userInfo, NSLocalizedString("原请求UserInfo数据", comment: ""), response.requestUserInfo) as String
            let alert:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
            let send:WBSendMessageToWeiboResponse = WBSendMessageToWeiboResponse()
            let actoken: String = send.authResponse.accessToken
            if actoken != nil{
                self.wbToken = actoken
            }
            let userID:String = send.authResponse.userID
            if userID != nil{
                print("userID is \(userID)")
                self.wbCurrentUserID = userID
            }
            alert.show(vc, sender: nil)
            
        }
        else if (response is WBAuthorizeResponse){
            let title:String = NSLocalizedString("认证结果", comment: "")
//            // print("\(response.statusCode.rawValue)")
//            let responseStatusCode = response.statusCode as! String
            var _statusCode: Int
            switch (response.statusCode){
            case.success:
                _statusCode = 0 // 成功
            case.userCancel:
                _statusCode = -1 // 用户取消发送
            case.sentFail:
                _statusCode = -2 // 发送失败
            case.authDeny:
                _statusCode = -3 // 授权失败
            case.userCancelInstall:
                _statusCode = -4 // 用户取消
            case.payFail:
                _statusCode = -5 // 支付失败
            case.shareInSDKFailed:
                _statusCode = -8 // 分享失败
            case.unsupport:
                _statusCode = -99 // 不支持
            case.unknown:
                _statusCode = -100
        
            default:
                _statusCode = -999
            }
            let caoniStatus = _statusCode
            let anotherResponse:WBAuthorizeResponse = (response as! WBAuthorizeResponse)
            let usssID:String = (response as! WBAuthorizeResponse).userID
            let acT:String = anotherResponse.accessToken
            let userInfo:[AnyHashable : Any]! = response.userInfo
            let userRequestResponse:[AnyHashable : Any]! = response.requestUserInfo
            
            let message:String = String(format: "%@: %d\nresponse.userId: %@\nresponse.accessToken: %@\n%@: %@\n%@: %@", locale: nil,
                                        "响应状态",
                                        _statusCode,
                                        usssID,
                                        acT,
                                        "响应状态Info",
                                        response.userInfo,
                                        "原请求UserInfo数据",
                                        response.requestUserInfo)
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            let noAction = UIAlertAction(title: "返回继续编辑", style: .default, handler: { (action:UIAlertAction) in
                self.vc.presentedViewController?.dismiss(animated: true, completion: nil)
                // do nothing
            })
            alert.addAction(noAction)
            self.wbToken = (response as! WBAuthorizeResponse).accessToken
            self.wbCurrentUserID = (response as! WBAuthorizeResponse).userID
            self.wbRefreshToken = (response as! WBAuthorizeResponse).refreshToken
            alert.show(vc, sender: nil)
            vc.present(alert, animated: true, completion: nil)
        }
    }
    /**
     收到一个来自微博客户端程序的请求
     
     收到微博的请求后，第三方应用应该按照请求类型进行处理，处理完后必须通过 [WeiboSDK sendResponse:] 将结果回传给微博
     @param request 具体的请求对象
     */
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        // <#code#>
    }
//    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
//        //
//    }
    // 这tm不是tm的被删掉了吗？。。。wc。。。你tm好意思.....
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print("url is \(url.absoluteString)")
        return WeiboSDK.handleOpen(url, delegate: self)
    }
    // 这tm不是tm的被删掉了吗？。。。wc。。。你tm好意思.....
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        print("url is \(url.absoluteString)")
        return WeiboSDK.handleOpen(url, delegate: self)
    }
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return WeiboSDK.handleOpen(url, delegate: self)
    }
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp(kAppKey)
        // Override point for customization after application launch.
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "BikeMapMVCDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if #available(iOS 10.0, *) {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        } else {
            // Fallback on earlier versions
        }

    }

}

