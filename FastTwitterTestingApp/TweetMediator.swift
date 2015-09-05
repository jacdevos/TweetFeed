import TwitterKit
typealias TweetsLoaded = (NSError?) -> Void

//This guy is at the centre, coordinating with all the other objects to do download, store, get and rank tweets
class TweetMediator {
    var tweets: [Tweet] = []
    let alreadyReadTweets : TweetReadingState = TweetReadingState()
    
    func setupTweets(){
        let loadedTweets = TweetCache.getAll()
        let ranked =  Tweet.rankAndFilter(loadedTweets)
        let rankedUnread = alreadyReadTweets.removeTweetsThatHaveBeenRead(ranked)
        self.tweets = alreadyReadTweets.moveActiveTweetsToTop(rankedUnread)
    }
    
    func getLatestTweets(callback : TweetsLoaded){
        TweetDownloader.downloadHomeTimelineTweets{ dataFromService, error in
            if let _ = error{
                callback(error)
            }
            
            if let dataFromSvc = dataFromService{
                TweetCache.saveTweetsForData(dataFromSvc)
                //println( NSString(data: dataFromSvc, encoding: NSUTF8StringEncoding))
                self.setupTweets()
                callback(nil)
            }
        }
    }
}
