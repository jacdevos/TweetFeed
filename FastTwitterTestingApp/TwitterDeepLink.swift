import UIKit
import TwitterKit

class TwitterDeepLink {
    static func openTweetDeeplink(_ tweet: TWTRTweet!){
        let URL = "https://twitter.com/support/status/\(tweet.tweetID)"
        let URLInApp = "twitter://status?id=\(tweet.tweetID)"
        
        if UIApplication.shared.canOpenURL(Foundation.URL(string: URLInApp)!) {
            UIApplication.shared.openURL(Foundation.URL(string: URLInApp)!)
        } else {
            UIApplication.shared.openURL(Foundation.URL(string: URL)!)
        }
        
        //UIApplication.sharedApplication().openURL(NSURL(string: "twitter://timeline")!)
    }
}
