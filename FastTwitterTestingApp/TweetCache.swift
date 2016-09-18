import TwitterKit

//stor the downloaded tweets
class TweetCache {
    static func saveTweets(_ tweetArray : [[AnyHashable: Any]]){
        deleteRepo()//TODO: just delete the items older than a week
        saveTweetsToRepo(tweetArray)
        //TODO newest and oldest saved tweetID
    }
    
    static func clear(){
        deleteRepo();
    }

    static func getAll() -> Set<Tweet>{
        let repository = try! CouchbaseRepository(dbName: "tweets")
        let tweetDictionaries = repository.getAllDocuments()
        return tweetsFromJSONDictionary(tweetDictionaries)
    }
    
    fileprivate static func tweetsFromJSONDictionary(_ JSONDictionary : [NSDictionary])->Set<Tweet>{
        var tweets : Set<Tweet> = []
        for tweetJSONDic in JSONDictionary{
            if let tweet = Tweet(jsonDictionary: tweetJSONDic as! [AnyHashable : Any] as [AnyHashable: Any] as [NSObject : AnyObject]!, priorityBalance : Double(UserPreferences.instance.priorityBalance)){
                tweets.insert(tweet)
            }
        }
        return tweets
    }
    
    fileprivate static func deleteRepo(){
        let repository = try! CouchbaseRepository(dbName: "tweets")
        repository.deleteAll()
    }
    
    fileprivate static func saveTweetsToRepo(_ tweetArray : [[AnyHashable: Any]]){
        let repository = try! CouchbaseRepository(dbName: "tweets")
    
        for tweet in tweetArray{            
            let _ = repository.createDocument(tweet as NSDictionary)
        }
    }

    

}
