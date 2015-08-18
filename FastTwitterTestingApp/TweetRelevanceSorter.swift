import TwitterKit
class TweetRelevanceSorter {
    static func rankAndFilter(unorderedTweets : [TWTRTweet]) -> [TWTRTweet]{
        var unordered = unorderedTweets
        unordered.sort { (x, y) -> Bool in
            return x.retweetCount > y.retweetCount
        }
    
        return filterOnlyTweetsWithRetweets(unordered)
    }
    
    static func filterOnlyTweetsWithRetweets(input : [TWTRTweet]) -> [TWTRTweet]{
        var tweetsWithRetweets : [TWTRTweet] = []
        for twt in input{
            if (twt.retweetCount > 0){
                tweetsWithRetweets.append(twt)
            }
        }
        return tweetsWithRetweets
    }
}