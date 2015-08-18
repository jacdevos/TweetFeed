import TwitterKit
class TweetRelevanceSorter {
    
    static func rankAndFilter(unorderedTweets : [TWTRTweet]) -> [TWTRTweet]{
        return filterOnlyTweetsWithRetweets(sortByRetweets(unorderedTweets))
    }
    
    static func sortByRetweets(tweets : [TWTRTweet]) -> [TWTRTweet]{
        var tweetsToSort = tweets
        tweetsToSort.sort { (x, y) -> Bool in
            return x.retweetCount > y.retweetCount
        }
        return tweetsToSort
    }
    
    static func filterOnlyTweetsWithRetweets(tweets : [TWTRTweet]) -> [TWTRTweet]{
        var tweetsWithRetweets : [TWTRTweet] = []
        for twt in tweets{
            if (twt.retweetCount > 0){
                tweetsWithRetweets.append(twt)
            }
        }
        return tweetsWithRetweets
    }
    
}