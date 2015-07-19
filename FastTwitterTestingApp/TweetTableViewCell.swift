import UIKit
import TwitterKit

class TweetTableViewCell: TWTRTweetTableViewCell {
    var tweet : TWTRTweet? = nil

    override func configureWithTweet(tweet: TWTRTweet!){
        super.configureWithTweet(tweet)
        self.tweet = tweet
    }
}
