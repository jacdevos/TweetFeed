import TwitterKit
typealias TwitterServiceResponse = ([TWTRTweet]?, NSError?) -> Void
class TwitterServiceProxy {
   var tweets: [TWTRTweet] = []
    
    func downloadLatestTweets(callback : TwitterServiceResponse){
        var tweetsWithRetweets : [TWTRTweet] = []
        
        let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count":"200","exclude_replies":"true"]
        var clientError : NSError?
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod(
            "GET", URL: statusesShowEndpoint, parameters: params,
            error: &clientError)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        var json : AnyObject? = nil
        Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {
            (response, data, connectionError) -> Void in
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if (connectionError == nil) {
                var jsonError : NSError?
                json = NSJSONSerialization.JSONObjectWithData(data!,
                    options: nil,
                    error: &jsonError)
                
                let nsarray : NSArray = json as! NSArray
                
                let tweetsUntypedArray = TWTRTweet.tweetsWithJSONArray(Array(nsarray))
                var tweets : [TWTRTweet] = []
                for twt in tweetsUntypedArray{
                    tweets.append(twt as! TWTRTweet)
                }
                
                
                tweets.sort { (x, y) -> Bool in
                    
                    return x.retweetCount > y.retweetCount
                }
                
                
                for twt in tweets{
                    //must have at least 2 retweets
                    if (twt.retweetCount > 1){
                        tweetsWithRetweets.append(twt)
                    }
                    println(twt.retweetCount)
                }
                
                self.tweets = tweetsWithRetweets
                callback(self.tweets,nil)
                
            }
            else {
                println("Error calling twitter: \(connectionError)")
                callback(nil, connectionError)
            }
        }
    }
}
