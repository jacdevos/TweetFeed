import TwitterKit
class TweetRelevanceSorter {
    
    static func rankAndFilter(unorderedTweets : [Tweet]) -> [Tweet]{
        return filterOnlyTweetsWithRetweets(sortByRetweets(unorderedTweets))
    }
    
    static func sortByRetweets(tweets : [Tweet]) -> [Tweet]{
        var tweetsToSort = tweets
        tweetsToSort.sortInPlace { (x, y) -> Bool in
            return x.retweetCount > y.retweetCount
        }
        return tweetsToSort
    }
    
    static func filterOnlyTweetsWithRetweets(tweets : [Tweet]) -> [Tweet]{
        var tweetsWithRetweets : [Tweet] = []
        for twt in tweets{
            if (twt.retweetCount > 0){
                tweetsWithRetweets.append(twt)
            }
        }
        return tweetsWithRetweets
    }
    
}