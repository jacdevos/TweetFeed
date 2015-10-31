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
    
    func resetTweetsBelowActive(){
        //get index of last active item
        let actives = alreadyReadTweets.currentlyReadingTweets
        var maxActiveIndex = 0
        for active in actives{
            let index = self.tweets.indexOf(active) ?? 0
            maxActiveIndex = max(index, maxActiveIndex)
        }
        
        
        //remove everything after that
        let loadedTweets = TweetCache.getAll()
        let ranked =  Tweet.rankAndFilter(loadedTweets)
        let rankedUnread = alreadyReadTweets.removeTweetsThatHaveBeenRead(ranked)
        self.tweets.appendContentsOf(rankedUnread)
    }
    
    func getLatestTweets(callback : TweetsLoaded){
        TweetDownloader.downloadHomeTimelineTweets{ dataFromService, error in
            if let _ = error{
                callback(error)
            }
            
            if let dataFromSvc = dataFromService{
                TweetCache.saveTweets(dataFromSvc)
                //println( NSString(data: dataFromSvc, encoding: NSUTF8StringEncoding))
                
                //do this in background?
                self.setupTweets()
                //TODO self.resetTweetsBelowActive()
                callback(nil)
            }
        }
    }
}
