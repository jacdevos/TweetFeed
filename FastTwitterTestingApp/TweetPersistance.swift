import TwitterKit

class TweetPersistance {
    static func saveTweetsForData(tweetData : NSData){
        creatDownloadedFile(tweetData, fileName: "tweets.twt")
    }
    
    static func getAll() -> [TWTRTweet]{
        return tweetsLoadedFromFile( "tweets.twt")
    }
    
    private static func creatDownloadedFile (data : NSData, fileName : String){
        data.writeToFile(self.pathForCacheFile(fileName), atomically: true)
    }
    
    private static func tweetsLoadedFromFile (fileName : String) -> [TWTRTweet]{
        let data = NSData(contentsOfFile: self.pathForCacheFile(fileName))
        if data == nil{
            return []
        }
        return self.deserializeTweetsFromData(data!)
    }
    
    private static func pathForCacheFile (fileName : String)  -> String{
        let dirs : [String] = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String])!
        let dir = dirs[0] //documents directory
        let path = dir.stringByAppendingPathComponent(fileName);
        return path
    }
    
    private static func deserializeTweetsFromData(data: NSData) -> [TWTRTweet] {
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
            let userFollowersCount  = tweetJSONDic["user"]!["followers_count"]!! as! NSNumber
            let userFollowersCountInt : Int64 = userFollowersCount.longLongValue

            if let nonOptionalTweet = tweet{
                tweets.append(nonOptionalTweet)
            }
        }
        
        return tweets
    }
}