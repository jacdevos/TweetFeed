import UIKit
import TwitterKit

class TwitterDeepLink {
    static func openTweetDeeplink(tweet: TWTRTweet!){
        let URL = "https://twitter.com/support/status/\(tweet.tweetID)"
        let URLInApp = "twitter://status?id=\(tweet.tweetID)"
        
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: URLInApp)!) {
            UIApplication.sharedApplication().openURL(NSURL(string: URLInApp)!)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: URL)!)
        }
        
        //UIApplication.sharedApplication().openURL(NSURL(string: "twitter://timeline")!)
    }
}
