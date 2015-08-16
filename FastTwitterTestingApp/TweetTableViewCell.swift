import UIKit
import TwitterKit

//extends TWTRTweetTableViewCell to allow access to state
class TweetTableViewCell: TWTRTweetTableViewCell {
    var tweet : TWTRTweet? = nil

    override func configureWithTweet(tweet: TWTRTweet!){
        super.configureWithTweet(tweet)
        self.tweet = tweet
    }
}
