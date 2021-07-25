//
//  AppDelegate.swift
//  AmakknCustmerSupport
//
//  Created by Peeyush Shrivastava on 12/10/20.
//

import UIKit
import Firebase
import AWSCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.EUCentral1,
                                                                identityPoolId:"eu-central-1:14032726-16fe-4208-b032-5a1585ad6e53")
        let configuration = AWSServiceConfiguration(region:.EUCentral1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        AppNetworkManager.shared.getBadge()

        FirebaseApp.configure()

        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
    
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound],
                                           categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()

        Messaging.messaging().token { token, error in
          if let token = token {
            AppUserDefaults.manager.pushFCMToken = token
          }
        }

        AppNetworkManager.shared.getDomain()
        SocketIOManager.sharedInstance.establishConnection()

        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        guard AppSession.manager.validSession else { return }

        SocketIOManager.sharedInstance.establishConnection()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        guard AppSession.manager.validSession else { return }

        SocketIOManager.sharedInstance.closeConnection()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        guard AppSession.manager.validSession else { return }

        SocketIOManager.sharedInstance.establishConnection()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        guard AppSession.manager.validSession else { return }

        SocketIOManager.sharedInstance.closeConnection()
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NotificationHandler.manager.manageNotification(for: notification)

        completionHandler( [.banner, .sound] )
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationHandler.manager.handleNotification(for: response)

        completionHandler()
    }
}
