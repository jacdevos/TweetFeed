import UIKit

class UserPreferences {

    static let instance = UserPreferences()
    
    private init() {
        NSUserDefaults.standardUserDefaults().registerDefaults(["autoScrollSpeed":0.0,"priorityBalance":0.0])
    }
    
    //-1 slow up tp 1 fast
    var autoScrollSpeed:Float {
        set {
            NSUserDefaults.standardUserDefaults().setFloat(newValue, forKey : "autoScrollSpeed")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return NSUserDefaults.standardUserDefaults().floatForKey("autoScrollSpeed")
        }
    }
    
    //-1 being bias to News up to 1 which biasses people with few followers
    var priorityBalance:Float {
        set {
            NSUserDefaults.standardUserDefaults().setFloat(newValue, forKey : "priorityBalance")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            NSUserDefaults.standardUserDefaults()
            
            
            return NSUserDefaults.standardUserDefaults().floatForKey("priorityBalance")
        }
    }
    
}
