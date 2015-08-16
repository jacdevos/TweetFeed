import TwitterKit
class TweetMediator {
    static func getPreviouslyDownloadedTweets() -> [TWTRTweet]{
        return TweetRepository.getTweets()
    }
    
    
    static func getLatestTweets(callback : TweetsLoaded){
        
        TweetDownloader.downloadLatestTweetData{ dataFromService, error in
            //todo handle error
            if let dataFromSvc = dataFromService{
                TweetRepository.persistTweetsForData(dataFromSvc)
                //var str = NSString(data: dataFromSvc, encoding: NSUTF8StringEncoding)
                //println(str)
                var sorted = TweetRelevanceSorter.relevantTweets(TweetRepository.getTweets())
                callback(sorted,nil)
            }
        }
    }
}
