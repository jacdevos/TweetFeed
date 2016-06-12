import UIKit
import CoreData
import Fabric
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
   // var twitterSession: TWTRSession!


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Twitter.sharedInstance().startWithConsumerKey("CUdwBwT5afPSN7QfqAzNvEjtt", consumerSecret: "1wP8OkfpkCPv7w57q6HBYJ8ZhKpIHVna0qI7TlkPc3IbOKsTN6")
        Fabric.with([Twitter.sharedInstance()])
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }



}

