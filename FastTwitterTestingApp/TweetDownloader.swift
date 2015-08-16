import TwitterKit
typealias TwitterServiceResponse = ([TWTRTweet]?, NSError?) -> Void
typealias TwitterServiceDataResponse = (NSData?, NSError?) -> Void

//TODO split this class into its various responsibilities
class TwitterServiceProxy {
    var tweets: [TWTRTweet] = []
    

    
    func deserializeTweetsFromData(data: NSData) -> [TWTRTweet] {
        var jsonError : NSError?
        var json : AnyObject? = nil
        json = NSJSONSerialization.JSONObjectWithData(data,
            options: nil,
            error: &jsonError)
        
        let nsarray : NSArray = json as! NSArray
        
        var tweets : [TWTRTweet] = []
        for tweetJSON in nsarray{
            let tweetJSONDic : [NSObject : AnyObject]! = tweetJSON as! [NSObject : AnyObject]
            let tweet = TWTRTweet(JSONDictionary: tweetJSONDic)
            
            if let nonOptionalTweet = tweet{
                tweets.append(nonOptionalTweet)
            }
        }

        return tweets
    }
    
    func downloadLatestTweetData(callback : TwitterServiceDataResponse){
        let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count":"200","exclude_replies":"false","include_entities":"false"]
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

        self.downloadLatestTweetData{ dataFromService, error in
            //todo handle error
            if let dataFromSvc = dataFromService{
                self.creatDownloadedFile(dataFromSvc, fileName: "tweets.twt")
                var str = NSString(data: dataFromSvc, encoding: NSUTF8StringEncoding)
                println(str)
                var sorted = TweetRelevanceSorter.relevantTweets(self.tweetsLoadedFromFile( "tweets.twt"))
                callback(sorted,nil)
            }
        }
    }
    
    func creatDownloadedFile (data : NSData, fileName : String){
       data.writeToFile(self.pathForCacheFile(fileName), atomically: true)
    }
    
    func tweetsLoadedFromFile (fileName : String) -> [TWTRTweet]{
        let data = NSData(contentsOfFile: self.pathForCacheFile(fileName))
        if data == nil{
            return []
        }
        
        return self.deserializeTweetsFromData(data!)
    }
    
    func pathForCacheFile (fileName : String)  -> String{
        let dirs : [String] = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String])!
        let dir = dirs[0] //documents directory
        let path = dir.stringByAppendingPathComponent(fileName);
        return path
    }
}
