import TwitterKit
typealias TwitterServiceResponse = ([TWTRTweet]?, NSError?) -> Void
typealias TwitterServiceDataResponse = (NSData?, NSError?) -> Void
class TwitterServiceProxy {
    var tweets: [TWTRTweet] = []
    
    func relevantTweets(unorderedTweets : [TWTRTweet]) -> [TWTRTweet]{
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
            println(twt.retweetCount)
        }
        return tweetsWithRetweets
    }
    
    func deserializeTweetsFromData(data: NSData) -> [TWTRTweet] {
        var jsonError : NSError?
        var json : AnyObject? = nil
        json = NSJSONSerialization.JSONObjectWithData(data,
            options: nil,
            error: &jsonError)
        
        let nsarray : NSArray = json as! NSArray
        
        let tweetsUntypedArray = TWTRTweet.tweetsWithJSONArray(Array(nsarray))
        var tweets : [TWTRTweet] = []
        for twt in tweetsUntypedArray{
            tweets.append(twt as! TWTRTweet)
        }
        return tweets
    }
    
    func downloadLatestTweetData(callback : TwitterServiceDataResponse){
        let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count":"200","exclude_replies":"true"]
        var clientError : NSError?
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod(
            "GET", URL: statusesShowEndpoint, parameters: params,
            error: &clientError)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        Twitter.sharedInstance().APIClient.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if (connectionError == nil) {
                callback(data,nil)
            }
            else {
                println("Error calling twitter: \(connectionError)")
                callback(nil, connectionError)
            }
        }
    }
    
    func downloadLatestTweets(callback : TwitterServiceResponse){
        
        self.downloadLatestTweetData{ data, error in
            //todo handle error
            let tweetsFromData = self.deserializeTweetsFromData(data!)
            callback(self.relevantTweets(tweetsFromData),nil)
        }
    }
}
