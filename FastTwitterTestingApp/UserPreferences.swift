import UIKit

class UserPreferences : NSObject {

    static let instance = UserPreferences()
    
    override init() {
        UserDefaults.standard.register(defaults: ["autoScrollSpeed":0.0,"priorityBalance":0.0])
    }
    
    //-1 slow up tp 1 fast
    var autoScrollSpeed:Float {
        set {
            if (newValue > 1 || newValue < -1){
                return;
            }
            UserDefaults.standard.set(newValue, forKey : "autoScrollSpeed")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.float(forKey: "autoScrollSpeed")
        }
    }
    
    //-1 being bias to News up to 1 which biasses people with few followers
    var priorityBalance:Float {
        set {
            if (newValue > 1 || newValue < -1){
                return;
            }
            UserDefaults.standard.set(newValue, forKey : "priorityBalance")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.float(forKey: "priorityBalance")
        }
    }
    
}
