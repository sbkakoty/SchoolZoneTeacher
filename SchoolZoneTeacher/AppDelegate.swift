//
//  AppDelegate.swift
//  SchoolZoneTeacher
//
//  Created by Apple on 12/12/18.
//  Copyright © 2018 ClearWin Technologies. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import Alamofire
import Siren
import SCLAlertView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var slideImagesCopy = [UIImage]()
    var slidesCopy = [Slide]()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        let siren = Siren.shared
        siren.rulesManager = RulesManager(globalRules: .critical)
        siren.wail()
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        AppLoadingStatus.appLoadingStatus.status = "Fresh"
        
        //RunLoop.current.run(until: NSDate(timeIntervalSinceNow:0) as Date)
        
        if #available(iOS 13.0, *) {
            let sharedApplication = UIApplication.shared
            let statusBar = UIView(frame: (sharedApplication.delegate?.window??.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.backgroundColor = colorWithHexString(hex: "#00CCFF")
            sharedApplication.delegate?.window??.addSubview(statusBar)

        } else {
            
            if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                statusBar.backgroundColor = colorWithHexString(hex: "#00CCFF")
            }
        }
        
        let navigationBarAppearace = UINavigationBar.appearance()
        
        let navigationFont = UIFont(name: "HelveticaNeue", size: getTitleFontSize())
        navigationBarAppearace.barTintColor = colorWithHexString(hex: "#00CCFF")
        
        navigationBarAppearace.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: navigationFont!
        ]
        
        navigationBarAppearace.shadowImage = UIImage()
        navigationBarAppearace.setBackgroundImage(UIImage(), for: .default)
        
        return true
    }
    
    func checkAppUpdates()
    {
        let siren = Siren.shared
        siren.apiManager = APIManager(countryCode: "IN")
        siren.rulesManager = RulesManager(globalRules: .critical)
        siren.wail()
    }
    
    @objc func languageWillChange(notification:NSNotification){
        let targetLang = notification.object as! String
        UserDefaults.standard.set(targetLang, forKey: "selectedLanguage")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "en"), object: targetLang)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        //print("applicationWillResignActive")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //print("applicationDidEnterBackground")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        //print("applicationWillEnterForeground")
        
        checkAppUpdates()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //print("applicationDidBecomeActive")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //print("applicationWillTerminate")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print full message.
        //print(userInfo)
        
        /*let appearance = SCLAlertView.SCLAppearance(
         kTitleFont: UIFont(name: "HelveticaNeue", size: 16)!,
         kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
         kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!
         )
         
         if let aps = userInfo["aps"] as? NSDictionary {
         if let alert = aps["alert"] as? NSDictionary {
         
         if let title = alert["title"] as? NSString {
         if let body = alert["body"] as? NSString {
         //Do stuff
         
         let bodyContents = body.components(separatedBy: ":")
         let alertView = SCLAlertView(appearance: appearance)
         alertView.showSuccess(title as String, subTitle: (bodyContents[1].trimmingCharacters(in: .whitespacesAndNewlines)) as String, closeButtonTitle: "OK")
         }
         }
         }
         }*/
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    /*func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
        //display notification
        
        print(remoteMessage.appData)
    }*/
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        if let refreshedToken = Messaging.messaging().fcmToken {
            print("Device token: \(refreshedToken)")
            setDeviceToken(deviceToken: refreshedToken)
        }
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else {
                print("Remote instance ID token: \(token!)")
                setDeviceToken(deviceToken: token!)
            }
        }
        
        let savedUUID:NSString = KeychainService.loadUUID()!
        //print(savedUUID)
        
        if(savedUUID == "0")
        {
            let uuidString = UIDevice.current.identifierForVendor!.uuidString
            
            KeychainService.saveUUID(token: uuidString as NSString)
        }
        //setUUID(UUID: uuidString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("i am not available in simulator \(error)")
    }
}



// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}
