import UIKit
import TwitterKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var prioritySlider: UISlider!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var signoutButton: UIButton!
    var onDismiss : () -> () = {};
    var refreshTweets : () -> () = {};
    
    override func viewDidLoad() {
        prioritySlider.value = UserPreferences.instance.priorityBalance
        speedSlider.value = UserPreferences.instance.autoScrollSpeed
        let userID = getLoggedOnUser()
        userNameLabel.text = ""//userID
        signoutButton.setTitle(userID == "" ? "Sign in" : "Sign out", for: .normal)
    }

    @IBAction func prioritySliderChanged(_ sender: UISlider) {
        let newPriority = sender.value;
        UserPreferences.instance.priorityBalance = newPriority
        self.refreshTweets()
    }
    
    @IBAction func speedSlideChanged(_ sender: UISlider) {
        let newSpeed = sender.value;
        UserPreferences.instance.autoScrollSpeed = newSpeed
    }
    
    @IBAction func signOutAndClose(_ sender: Any) {
        let store = Twitter.sharedInstance().sessionStore
        let sessions = store.existingUserSessions()
        print("Twitter sessions: \(sessions)")
        for session in sessions{
            let userID = (session as! TWTRAuthSession).userID
            store.logOutUserID(userID)
        }
 
        dismiss(animated: true) {
            self.onDismiss()
            self.refreshTweets()
        }
    }
    
    func getLoggedOnUser() -> String{
        let store = Twitter.sharedInstance().sessionStore
        let sessions = store.existingUserSessions()
        print("Twitter sessions: \(sessions)")
        for session in sessions{
            let userID = (session as! TWTRAuthSession).userID
            return userID
        }
        return "";
    }
}
