import TwitterKit
typealias TweetsLoaded = (NSError?) -> Void

//This guy is at the centre, coordinating with all the other objects to do download, store, get and rank tweets
class TweetMediator {
    var tweets: [Tweet] = []
    let alreadyReadTweets : TweetReadingState = TweetReadingState()

    //Set up tweets list with active tweets at the top.
    //Reason: so that we get the feeling of continuation when restarting app
    func setupTweets(){
        let rankedUnread = calculateRankedUnreadTweets()
        self.tweets = alreadyReadTweets.moveActiveTweetsToTop(rankedUnread)
    }
    
    //Remove everything below active tweets, and replace with recalculated, unread items
    //Reason: we don't want to change what the user is seeing on screen, ranking should happen invisibly. 
    //The next item should just magically be the most relevant - user should ALWAYS just have to keep scrolling without missing a beat
    func resetTweetsBelowActive(){
        self.tweets.removeRange(Range<Int>(start: getIndexOfLastActive(), end: self.tweets.count - 1))
        let rankedUnread = calculateRankedUnreadTweets()
        self.tweets.appendContentsOf(rankedUnread)
    }
    
    func calculateRankedUnreadTweets()->[Tweet]{
        let loadedTweets = TweetCache.getAll()
        let ranked =  Tweet.rankAndFilter(loadedTweets)
        let rankedUnread = alreadyReadTweets.removeTweetsThatHaveBeenRead(ranked)
        return rankedUnread
    }
    
    func getIndexOfLastActive()->Int{
        let actives = alreadyReadTweets.currentlyReadingTweets
        var maxActiveIndex = 0
        
        for active in actives{
            let index = self.tweets.indexOf(active) ?? 0
            maxActiveIndex = max(index, maxActiveIndex)
        }
        return maxActiveIndex
    }

    func getLatestTweets(callback : TweetsLoaded){
        TweetDownloader.downloadHomeTimelineTweets{ dataFromService, error in
            if let _ = error{
                callback(error)
            }
            
            if let dataFromSvc = dataFromService{
                TweetCache.saveTweets(dataFromSvc)
                //println( NSString(data: dataFromSvc, encoding: NSUTF8StringEncoding))
                self.resetTweetsBelowActive()
                callback(nil)
            }else{
                callback(NSError(domain: "TweetMediator", code: 0, userInfo: [NSLocalizedDescriptionKey:"No data from twitter timeline."]))
            }
        }
    }
}
