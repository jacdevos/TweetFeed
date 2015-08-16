import TwitterKit
typealias TweetsLoaded = (NSError?) -> Void

//This guy is at the centre, coordinating with all the other objects to do the magic
class TweetMediator {
    var tweets: [TWTRTweet] = []
    let alreadyReadTweets : TweetReadingState = TweetReadingState()
    
    func resetToUnreadTweets(loadedTweets : [TWTRTweet]){
        var unreadTweets = loadedTweets.filter(){
            if let tweetID = ($0 as TWTRTweet).tweetID as String! {
                return !self.alreadyReadTweets.alreadyReadTweets.contains(tweetID)
            } else {
                return false
            }
        }
        
        //move active tweets to the top
        for activeTweet in self.alreadyReadTweets.currentlyReadingTweets{
            //unreadTweets.removeObject(activeTweet)//remove from arb position if it is in main list
            for twt in unreadTweets{
                if (twt.tweetID == activeTweet.tweetID){
                    unreadTweets.removeObject(twt)//remove from arb position if it is in main list
                    unreadTweets.insert(activeTweet, atIndex: 0)
                }
            }
            
        }
        
        let oldCount = self.tweets.count
        self.tweets = unreadTweets
    }
    
    func setupTweets(){
        resetToUnreadTweets(TweetRelevanceSorter.relevantTweets(TweetPersistance.getAll()))
    }
    
    func getLatestTweets(callback : TweetsLoaded){
        
        TweetDownloader.downloadHomeTimelineTweets{ dataFromService, error in
            if let err = error{
                callback(error)
            }
            
            if let dataFromSvc = dataFromService{
                TweetPersistance.saveTweetsForData(dataFromSvc)
                //var str = NSString(data: dataFromSvc, encoding: NSUTF8StringEncoding)
                //println(str)
                var tweetsFromPersistance = TweetPersistance.getAll()
                var sorted = TweetRelevanceSorter.relevantTweets(tweetsFromPersistance)
                self.resetToUnreadTweets(sorted)
                callback(nil)
            }
        }
    }
}
