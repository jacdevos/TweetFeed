import TwitterKit

//stor the downloaded tweets
class TweetCache {
    static func saveTweets(_ tweetData : Data){
        deleteRepo()//TODO: just delete the items older than a week
        saveTweetsToRepo(tweetData)
        //TODO newest and oldest saved tweetID
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
    
    fileprivate static func saveTweetsToRepo(_ tweetData : Data){
        let repository = try! CouchbaseRepository(dbName: "tweets")
        let nsarray = getJSONTweetArrayFromData(tweetData)
        for tweetJSON in nsarray{
            let tweetJSONDic : [AnyHashable: Any]! = tweetJSON as! [AnyHashable: Any]
            let _ = repository.createDocument(tweetJSONDic as NSDictionary)
        }
    }

    fileprivate static func getJSONTweetArrayFromData(_ data: Data) -> NSArray {
        var jsonError : NSError?
        var json : Any
        do {
            json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as! NSArray
        } catch let error as NSError {
            jsonError = error
            print(jsonError)
        } catch{
            print("Unknown error serializing JSON")
        }
        return NSArray()
    }
    

}
