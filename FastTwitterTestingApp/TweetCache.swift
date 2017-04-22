import TwitterKit

//Cache the downloaded tweets. Store both in mem for immediate loading and on disc for startup
class TweetCache {
    static var inMemoryTweets = Set<Tweet>()
    
    static func saveTweets(_ tweetArray : [[AnyHashable: Any]]){
        clearTweetsInMem()
        saveTweetsInMem(tweetArray)
        
        clearTweetsOnDisk()//TODO: just delete the items older than a week
        saveTweetsToDisk(tweetArray)
        //TODO newest and oldest saved tweetID
    }
    
    static func clear(){
        clearTweetsInMem();
        clearTweetsOnDisk();
    }

    static func getAll() -> Set<Tweet>{
        if inMemoryTweets.count > 0{
            return inMemoryTweets
        }
        
        let repository = try! CouchbaseRepository(dbName: "tweets")
        let tweetDictionaries = repository.getAllDocuments()
        return tweetsFromJSONDictionary(tweetDictionaries as? [[AnyHashable: Any]] ?? [[:]])
    }
    
    fileprivate static func clearTweetsInMem(){
        inMemoryTweets.removeAll()
    }
    
    fileprivate static func saveTweetsInMem(_ tweetArray : [[AnyHashable: Any]]){
        tweetsFromJSONDictionary(tweetArray).forEach { (tweet) in
            inMemoryTweets.insert(tweet)
        }
    }
    
    fileprivate static func tweetsFromJSONDictionary(_ JSONDictionary : [[AnyHashable : Any]])->Set<Tweet>{
        var tweets : Set<Tweet> = []
        for tweetJSONDic in JSONDictionary{
            if let tweet = Tweet(jsonDictionary: tweetJSONDic as [AnyHashable: Any] as [NSObject : AnyObject]!, priorityBalance : Double(UserPreferences.instance.priorityBalance)){
                tweets.insert(tweet)
            }
        }
        return tweets
    }
    
    fileprivate static func clearTweetsOnDisk(){
        let repository = try! CouchbaseRepository(dbName: "tweets")
        repository.deleteAll()
    }
    
    fileprivate static func saveTweetsToDisk(_ tweetArray : [[AnyHashable: Any]]){
        let repository = try! CouchbaseRepository(dbName: "tweets")
    
        for tweet in tweetArray{            
            let _ = repository.createDocument(tweet as NSDictionary)
        }
    }

    

}
