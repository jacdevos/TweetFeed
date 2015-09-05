import UIKit

class UserPreferences : NSObject {

    static let instance = UserPreferences()
    
    override init() {
        NSUserDefaults.standardUserDefaults().registerDefaults(["autoScrollSpeed":0.0,"priorityBalance":0.0])
    }
    
    //-1 slow up tp 1 fast
    var autoScrollSpeed:Float {
        set {
            if (newValue > 1 || newValue < -1){
                return;
            }
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
            if (newValue > 1 || newValue < -1){
                return;
            }
            NSUserDefaults.standardUserDefaults().setFloat(newValue, forKey : "priorityBalance")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return NSUserDefaults.standardUserDefaults().floatForKey("priorityBalance")
        }
    }
    
}
