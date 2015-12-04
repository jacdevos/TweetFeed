import TwitterKit
typealias TweetsLoaded = (NSError?,deletedIndexes: Range<Int>?, insertedIndexes: Range<Int>?) -> Void

//This guy is at the centre, coordinating with all the other objects to do download, store, get and rank tweets
class TweetMediator {
    var tweets: [Tweet] = []
    let alreadyReadTweets : TweetReadingState = TweetReadingState()
    
    func downloadNextTweets(){
        //TODO: fromload from last id tweet up to max and save
    }
    
    func getLatestTweets(callback : TweetsLoaded){
        TweetDownloader.downloadHomeTimelineTweets{ dataFromService, error in
            let result : (NSData?, NSError?) = (dataFromService, error)
            
            switch(result){
            case (nil,nil):
                callback(NSError(domain: "TweetMediator", code: 0, userInfo: [NSLocalizedDescriptionKey:"No data from twitter timeline."]),deletedIndexes: nil,insertedIndexes: nil)
            case (nil,_):
                callback(error,deletedIndexes: nil,insertedIndexes: nil)
            case (_,nil):
                TweetCache.saveTweets(dataFromService!)
                //println( NSString(data: dataFromSvc, encoding: NSUTF8StringEncoding))
                self.resetTweetsBelowActive(callback)
            default:
                callback(NSError(domain: "TweetMediator", code: 0, userInfo: [NSLocalizedDescriptionKey:"Unexpected error"]),deletedIndexes: nil,insertedIndexes: nil)
            }
        }
    }
    
    //Remove everything below active tweets, and replace with recalculated, unread items
    //Reason: we don't want to change what the user is seeing on screen, ranking should happen invisibly. 
    //The next item should just magically be the most relevant - user should ALWAYS just have to keep scrolling without missing a beat
    func resetTweetsBelowActive(callback : TweetsLoaded){
        let removeRange = removeTweetsAfterActive()
        
        let rankedUnread = calculateRankedUnreadTweets()
        let rankedUnreadAndInactive = alreadyReadTweets.tweetsThatAreNotCurrentlyActive(rankedUnread)
        let addRange = appendTweets(rankedUnreadAndInactive)
        
        callback(nil,deletedIndexes: removeRange,insertedIndexes: addRange)
    }
    
    func calculateRankedUnreadTweets()->[Tweet]{
        let loadedTweets = TweetCache.getAll()
        let ranked =  Tweet.rankAndFilter(loadedTweets)
        let rankedUnread = alreadyReadTweets.tweetsThatHaveNotBeenRead(ranked)
        
        return rankedUnread
    }
    
    func appendTweets(tweetsToAppend : [Tweet])->Range<Int>?{
        var addRange : Range<Int>? = nil
        if tweetsToAppend.count > 0{
            let addStart = self.tweets.count
            let addEnd = self.tweets.count + tweetsToAppend.count - 1
            addRange  = addStart...addEnd
        }
        self.tweets.appendContentsOf(tweetsToAppend)
        return addRange
    }
    
    func removeTweetsAfterActive()->Range<Int>?{
        var removeRange : Range<Int>?  =   nil
        if self.tweets.count > 0{
            let removeStart =  getIndexOfLastActive() + 1
            let removeEnd = self.tweets.count - 1
            removeRange  = removeStart...removeEnd
            self.tweets.removeRange(removeRange!)
        }
        return removeRange
    }
    func getIndexOfLastActive()->Int{
        let actives = alreadyReadTweets.activeTweets
        var maxActiveIndex = 0
        
        for active in actives{
            let index = self.tweets.indexOf(active) ?? 0
            maxActiveIndex = max(index, maxActiveIndex)
        }
        return maxActiveIndex
    }
}
