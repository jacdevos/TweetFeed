import UIKit
import CoreData
import Fabric
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
   // var twitterSession: TWTRSession!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Twitter.sharedInstance().start(withConsumerKey: "CUdwBwT5afPSN7QfqAzNvEjtt", consumerSecret: "1wP8OkfpkCPv7w57q6HBYJ8ZhKpIHVna0qI7TlkPc3IbOKsTN6")
        Fabric.with([Twitter.sharedInstance()])
        return true
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        print("")
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if Twitter.sharedInstance().application(app, open:url, options: options) {
            return true
        }
        
        // If you handle other (non Twitter Kit) URLs elsewhere in your app, return true. Otherwise
        return false
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }



}

