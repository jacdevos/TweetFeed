import UIKit
import TwitterKit

//extends TWTRTweetTableViewCell to allow access to state
class TweetTableViewCell: TWTRTweetTableViewCell {
    var tweet : TWTRTweet? = nil
    

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //self.tweetView.style =  TWTRTweetViewStyle.Regular
        self.tweetView.showActionButtons = true
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func configureWithTweet(tweet: TWTRTweet!){
        super.configureWithTweet(tweet)
        self.tweet = tweet
    }
}
