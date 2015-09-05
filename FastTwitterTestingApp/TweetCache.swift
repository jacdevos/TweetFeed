import TwitterKit

class TweetCache {
    static func saveTweetsForData(tweetData : NSData){
        creatDownloadedFile(tweetData, fileName: "tweets.twt")
    }
    
    static func getAll() -> [Tweet]{
        return tweetsLoadedFromFile( "tweets.twt")
    }
    
    private static func creatDownloadedFile (data : NSData, fileName : String){
        data.writeToFile(self.pathForCacheFile(fileName), atomically: true)
    }
    
    private static func tweetsLoadedFromFile (fileName : String) -> [Tweet]{
        let data = NSData(contentsOfFile: self.pathForCacheFile(fileName))
        if data == nil{
            return []
        }
        return self.deserializeTweetsFromData(data!)
    }
    
    private static func pathForCacheFile (fileName : String)  -> String{
        let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
        let dir = dirs[0] //documents directory
        
        let url = NSURL(fileURLWithPath: dir, isDirectory: true).URLByAppendingPathComponent(fileName);
        return url.path!
    }
    
    private static func deserializeTweetsFromData(data: NSData) -> [Tweet] {
        var jsonError : NSError?
        var json : AnyObject? = nil
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data,
                options: [])
        } catch let error as NSError {
            jsonError = error
            print(jsonError)
            json = nil
        }
        
        let nsarray : NSArray = json as! NSArray
        
        var tweets : [Tweet] = []
        for tweetJSON in nsarray{
            let tweetJSONDic : [NSObject : AnyObject]! = tweetJSON as! [NSObject : AnyObject]

            if let tweet = Tweet(JSONDictionary: tweetJSONDic){
                tweets.append(tweet)
            }
        }
        
        return tweets
    }
}