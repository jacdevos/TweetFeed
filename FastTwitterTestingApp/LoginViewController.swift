import UIKit
import TwitterKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let logInButton = TWTRLogInButton(logInCompletion: {
            (session: TWTRSession!, error: NSError!) in
            
            if (session != nil) {
                println("signed in as \(session.userName)");
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.twitterSession = session
                self.performSegueWithIdentifier("login", sender: self)
            } else {
                println("error: \(error.localizedDescription)");
            }
        })
        logInButton.center = self.view.center
        
        self.view.addSubview(logInButton)
        logInButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

