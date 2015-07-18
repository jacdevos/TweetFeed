import UIKit
import TwitterKit

class TweetsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let session = appDelegate.twitterSession

        Twitter.sharedInstance().APIClient.loadTweetWithID("616504006790111232") { (tweet: TWTRTweet?, error: NSError?) in
            var tweetView = TWTRTweetView(tweet: tweet, style: TWTRTweetViewStyle.Compact)
            self.view.addSubview(tweetView)
        }
        

    }



}
