
import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var prioritySlider: UISlider!
    @IBOutlet weak var speedSlider: UISlider!
    
    override func viewDidLoad() {
        prioritySlider.value = UserPreferences.instance.priorityBalance
        speedSlider.value = UserPreferences.instance.autoScrollSpeed
    }

    @IBAction func prioritySliderChanged(sender: UISlider) {
        let newPriority = sender.value;
        UserPreferences.instance.priorityBalance = newPriority
    }
    
    @IBAction func speedSlideChanged(sender: UISlider) {
        let newSpeed = sender.value;
        UserPreferences.instance.autoScrollSpeed = newSpeed
    }
}
