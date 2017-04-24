import UIKit
import TwitterKit

//extends TWTRTweetTableViewCell to allow access to state
class TweetTableViewCell: TWTRTweetTableViewCell {
    var tweet : Tweet? = nil
    

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //self.tweetView.style =  TWTRTweetViewStyle.Regular
        self.tweetView
        self.tweetView.showActionButtons = true //for some reason I have to set on init, else get funny sizing behaviour
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func configure(with tweet: (TWTRTweet!)){
        super.configure(with: tweet)
        self.tweet = tweet as! Tweet?
    }
    
    func configWithTweet(_ tweet: Tweet!){
        super.configure(with: tweet)
        self.tweet = tweet
    }
}
