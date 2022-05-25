//
//  AppDelegate.swift
//  Hype
//
//  Created by Harrison Kleiman on 5/25/22.
//

import UIKit
import UserNotifications
import CloudKit

@UIApplicationMain

    class AppDelegate: UIResponder, UIApplicationDelegate {

        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            
            // MARK: - Day 2 Changes
            // Add everything on this file
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (userDidAllow, error) in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
                
                if userDidAllow == true {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
            return true
        }
        
        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            HypeController.shared.subscribeForRemoteNotifications { (error) in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
        
        func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
        
        func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            HypeController.shared.fetchAllHypes { (success) in
            }
        }
        
        func applicationDidBecomeActive(_ application: UIApplication) {
            application.applicationIconBadgeNumber = 0
        }
    }
