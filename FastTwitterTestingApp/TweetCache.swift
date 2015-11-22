import TwitterKit

class TweetCache {
    static func saveTweets(tweetData : NSData){
        deleteRepo()
        saveTweetsToRepo(tweetData)
    }

    static func getAll() -> Set<Tweet>{
        let repository = try! CouchbaseRepository(dbName: "tweets")
        let tweetDictionaries = repository.getAllDocuments()
        return tweetsFromJSONDictionary(tweetDictionaries)
    }
    
    private static func tweetsFromJSONDictionary(JSONDictionary : [NSDictionary])->Set<Tweet>{
        var tweets : Set<Tweet> = []
        for tweetJSONDic in JSONDictionary{
            if let tweet = Tweet(JSONDictionary: tweetJSONDic as [NSObject : AnyObject], priorityBalance : Double(UserPreferences.instance.priorityBalance)){
                tweets.insert(tweet)
            }
        }
        return tweets
    }
    
    private static func deleteRepo(){
        let repository = try! CouchbaseRepository(dbName: "tweets")
        repository.deleteAll()
    }
    
    private static func saveTweetsToRepo(tweetData : NSData){
        let repository = try! CouchbaseRepository(dbName: "tweets")
        let nsarray = getJSONTweetArrayFromData(tweetData)
        for tweetJSON in nsarray{
            let tweetJSONDic : [NSObject : AnyObject]! = tweetJSON as! [NSObject : AnyObject]
            repository.createDocument(tweetJSONDic)
        }
    }

    private static func getJSONTweetArrayFromData(data: NSData) -> NSArray {
        var jsonError : NSError?
        var json : AnyObject? = nil
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data, options: [])
        } catch let error as NSError {
            jsonError = error
            print(jsonError)
        } catch{
            print("Unknown error serializing JSON")
        }
        return json as! NSArray
    }
    

}