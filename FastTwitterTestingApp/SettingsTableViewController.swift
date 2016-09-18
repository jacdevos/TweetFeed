
import UIKit
import TwitterKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var prioritySlider: UISlider!
    @IBOutlet weak var speedSlider: UISlider!
    
    override func viewDidLoad() {
        prioritySlider.value = UserPreferences.instance.priorityBalance
        speedSlider.value = UserPreferences.instance.autoScrollSpeed
    }

    @IBAction func prioritySliderChanged(_ sender: UISlider) {
        let newPriority = sender.value;
        UserPreferences.instance.priorityBalance = newPriority
    }
    
    @IBAction func speedSlideChanged(_ sender: UISlider) {
        let newSpeed = sender.value;
        UserPreferences.instance.autoScrollSpeed = newSpeed
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        let store = Twitter.sharedInstance().sessionStore
        let sessions = store.existingUserSessions()
        for session in sessions{
            let userID = (session as! TWTRAuthSession).userID
            store.logOutUserID(userID)
        }
        print("Twitter sessions: \(sessions)")
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}
