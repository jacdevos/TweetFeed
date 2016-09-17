import UIKit
import TwitterKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let logInButton = TWTRLogInButton { (session, error) -> Void in
            if let session = session {
                print("signed in as \(session.userName)");
                //let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                //appDelegate.twitterSession = session
                self.performSegue(withIdentifier: "login", sender: self)
            } else {
                print("error: \(error!.localizedDescription)");
                
                //UNABLE TO LOG ON TO TWITTER> MAKE SURE YOU HAVE AN INTERNET CONNECTION AND HAVE SINGED INTO TWITTER IN YOU iPHONE SETTTINGS
            }
        }

        logInButton.center = self.view.center
        
        self.view.addSubview(logInButton)
        logInButton.sendActions(for: UIControlEvents.touchUpInside)

        self.setNeedsStatusBarAppearanceUpdate()


    }
    


    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

