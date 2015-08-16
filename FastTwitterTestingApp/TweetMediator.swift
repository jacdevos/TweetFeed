import TwitterKit
class TweetMediator {
    static func getPreviouslyDownloadedTweets() -> [TWTRTweet]{
        return TweetPersistance.getAll()
    }
    
    static func getLatestTweets(callback : TweetsLoaded){
        
        TweetDownloader.downloadHomeTimelineTweets{ dataFromService, error in
            if let err = error{
                callback(nil,error)
            }
            
            if let dataFromSvc = dataFromService{
                TweetPersistance.saveTweetsForData(dataFromSvc)
                //var str = NSString(data: dataFromSvc, encoding: NSUTF8StringEncoding)
                //println(str)
                var tweetsFromPersistance = TweetPersistance.getAll()
                var sorted = TweetRelevanceSorter.relevantTweets(tweetsFromPersistance)
                callback(sorted,nil)
            }
        }
    }
}
