import TwitterKit
class TweetRelevanceSorter {
    static func relevantTweets(unorderedTweets : [TWTRTweet]) -> [TWTRTweet]{
        var unordered = unorderedTweets
        unordered.sort { (x, y) -> Bool in
            return x.retweetCount > y.retweetCount
        }
        
        var tweetsWithRetweets : [TWTRTweet] = []
        for twt in unordered{
            //must have at least 2 retweets
            if (twt.retweetCount > 1){
                tweetsWithRetweets.append(twt)
            }
        }
        return tweetsWithRetweets
    }
}