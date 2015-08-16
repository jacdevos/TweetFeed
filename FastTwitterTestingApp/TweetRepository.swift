import TwitterKit
typealias TweetsLoaded = ([TWTRTweet]?, NSError?) -> Void

class TweetRepository {
    
    static func getLatestTweets(callback : TweetsLoaded){
        
        TweetDownloader.downloadLatestTweetData{ dataFromService, error in
            //todo handle error
            if let dataFromSvc = dataFromService{
                self.creatDownloadedFile(dataFromSvc, fileName: "tweets.twt")
                //var str = NSString(data: dataFromSvc, encoding: NSUTF8StringEncoding)
                //println(str)
                var sorted = TweetRelevanceSorter.relevantTweets(self.tweetsLoadedFromFile( "tweets.twt"))
                callback(sorted,nil)
            }
        }
    }
    
    static func creatDownloadedFile (data : NSData, fileName : String){
        data.writeToFile(self.pathForCacheFile(fileName), atomically: true)
    }
    
    static func tweetsLoadedFromFile (fileName : String) -> [TWTRTweet]{
        let data = NSData(contentsOfFile: self.pathForCacheFile(fileName))
        if data == nil{
            return []
        }
        
        return self.deserializeTweetsFromData(data!)
    }
    
    static func pathForCacheFile (fileName : String)  -> String{
        let dirs : [String] = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String])!
        let dir = dirs[0] //documents directory
        let path = dir.stringByAppendingPathComponent(fileName);
        return path
    }
    
    static func deserializeTweetsFromData(data: NSData) -> [TWTRTweet] {
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
}