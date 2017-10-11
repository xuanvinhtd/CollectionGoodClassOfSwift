//
//  AppDelegate.swift
//  eMartMall
//
//  Created by Hanbiro on 6/10/17.
//  Copyright © 2017 hanbiro. All rights reserved.
//

import UIKit
import DropDown
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let mainVC = EMHelper.shareInstance.getViewController(storyboardType: .HomeStoryboard, name: String.className(EMMainViewController.self), bundle: Bundle.main) as! EMMainViewController
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        URLProtocol.registerClass(EMUrlProtocol.self)
        
        DropDown.startListeningToKeyboard()
        //Thread.sleep(forTimeInterval: 0.3)
        EMHelper.shareInstance.startNetworkReachabilityObserver()
        self.createSlideMenu()
        registerForPushNotifications()
        self.getAllLanguage()
        
        if launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] != nil {
            print("Info Push : \(String(describing: launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification]))")
            EMHelper.shareInstance.isShowPushNotification = true
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:EMNotification.ClickedNotificationButton.rawValue), object: nil)
            }
        }
        return true
    }
    
    func sendEnablePushNotificationApi(_ token:String) {
        EMGlobal.apiManager.request(method: .post, url: .SubcriblePush, params: ["device_id": EMHelper.shareInstance.getDeviceID(),"device_type": EMGlobal.deviceType, "reg_id": token], parser: { (json) in
            print("On push: \(String(describing: json))")
            if let dict = json as? Dictionary<String, Any> {
                if let valueStr = dict["success"] as? String, valueStr == "true" {
                    UserDefaults.standard.set(true, forKey: UserDefaultKeyOf.statePushSetting.rawValue)
                    UserDefaults.standard.set(true, forKey: UserDefaultKeyOf.onlyOnceSendEnablePush.rawValue)
                    print("On push: SUCCESS")
                } else {
                    print("On push: FAIL")
                }
            } else {
                print("On push: FAIL")
            }
        })
    }

    func getCurrentLanguage() {
        EMGlobal.apiManager.request(method: .get, url: .GetCurrentLanguage, params: nil) { (data) in
            if let json = data as? Dictionary<String, String> {
                print("current language: \(json)")
                if let langID = json["language_id"] {
                    Localize.languages.forEach({ (item) in
                        if langID == item["language_id"] {
                           Localize.setCurrentLanguageByAPI(WithCode: item["code"]!, isReload: false)
                        }
                    })
                }
            }
        }
    }
    
    func getAllLanguage() {
        EMGlobal.apiManager.request(method: .get, url: .GetAllLanguage, params: nil) { (data) in
            if let json = data as? Dictionary<String, Any> {
                print("All current languages: \(json)")
                if !json.isEmpty {
                    if let languageArray = json["languages"] as? [Dictionary<String, String>] {
                        Localize.languages = languageArray
                        self.getCurrentLanguage()
                    }
                }
            }
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.sync {
               UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        EMHelper.shareInstance.keepString(keyword: "push_token", data: token)
        print("Device Token: \(token)")
        
        if let _ = UserDefaults.standard.object(forKey: UserDefaultKeyOf.onlyOnceSendEnablePush.rawValue) as? Bool {
        } else {
            self.sendEnablePushNotificationApi(token)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Info Push : \(userInfo)")
        if application.applicationState != .active {
            EMHelper.shareInstance.isShowPushNotification = true
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:EMNotification.ClickedNotificationButton.rawValue), object: nil)
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
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
        application.applicationIconBadgeNumber = 0
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
//MARK: - Slide Menu
    fileprivate func createSlideMenu() {
        let navigationController = EMHelper.shareInstance.getViewController(storyboardType: .HomeStoryboard, name: String.className(EMNavigationController.self), bundle: Bundle.main) as! UINavigationController
        
        let tabVC = EMHelper.shareInstance.getViewController(storyboardType: .TabbarStoryboard, name: String.className(EMTabBarController.self), bundle: Bundle.main) as! EMTabBarController
        navigationController.setViewControllers([tabVC], animated: false)
        
        mainVC.rootViewController = navigationController
        self.window?.backgroundColor = .white
        self.window?.rootViewController = mainVC
        self.window?.makeKeyAndVisible()
    }
}

