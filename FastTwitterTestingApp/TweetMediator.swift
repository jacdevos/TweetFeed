import TwitterKit
typealias TweetsLoaded = (NSError?,_ deletedIndexes: CountableRange<Int>?, _ insertedIndexes: CountableRange<Int>?) -> Void

//This guy is at the centre, coordinating with all the other objects to do download, store, get and rank tweets
class TweetMediator {
    var tweets: [Tweet] = []
    let alreadyReadTweets : TweetReadingState = TweetReadingState()
    
    func downloadNextTweets(){
        //TODO: fromload from last id tweet up to max and save
    }
    
    func getLatestTweets(_ callback : @escaping TweetsLoaded){
        TweetDownloader.downloadHomeTimelineTweets{ dataFromService, error in
            let result : (Data?, NSError?) = (dataFromService as Data?, error)
            
            switch(result){
            case (nil,nil):
                callback(NSError(domain: "TweetMediator", code: 0, userInfo: [NSLocalizedDescriptionKey:"No data from twitter timeline."]),nil,nil)
            case (nil,_):
                callback(error,nil,nil)
            case (_,nil):
                TweetCache.saveTweets(dataFromService!)
                //println( NSString(data: dataFromSvc, encoding: NSUTF8StringEncoding))
                self.resetTweetsBelowActive(callback)
            default:
                callback(NSError(domain: "TweetMediator", code: 0, userInfo: [NSLocalizedDescriptionKey:"Unexpected error"]),nil,nil)
            }
        }
    }
    
    //Remove everything below active tweets, and replace with recalculated, unread items
    //Reason: we don't want to change what the user is seeing on screen, ranking should happen invisibly. 
    //The next item should just magically be the most relevant - user should ALWAYS just have to keep scrolling without missing a beat
    func resetTweetsBelowActive(_ callback : TweetsLoaded){
        let removeRange = removeTweetsAfterActive()
        
        let rankedUnread = calculateRankedUnreadTweets()
        let rankedUnreadAndInactive = alreadyReadTweets.tweetsThatAreNotCurrentlyActive(rankedUnread)
        let addRange = appendTweets(rankedUnreadAndInactive)
        
        callback(nil,removeRange,addRange)
    }
    
    func calculateRankedUnreadTweets()->[Tweet]{
        let loadedTweets = TweetCache.getAll()
        let ranked =  Tweet.rankAndFilter(loadedTweets)
        let rankedUnread = alreadyReadTweets.tweetsThatHaveNotBeenRead(ranked)
        
        return rankedUnread
    }
    
    func appendTweets(_ tweetsToAppend : [Tweet])->CountableRange<Int>?{
        var addRange : CountableRange<Int>? = nil
        if tweetsToAppend.count > 0{
            let addStart = self.tweets.count
            let addEnd = self.tweets.count + tweetsToAppend.count - 1
            addRange  = CountableRange<Int>(addStart...addEnd)
        }
        self.tweets.append(contentsOf: tweetsToAppend)
        return addRange
    }
    
    func removeTweetsAfterActive()->CountableRange<Int>?{
        var removeRange : CountableRange<Int>?  =   nil
        if self.tweets.count > 0{
            let removeStart =  getIndexOfLastActive() + 1
            let removeEnd = self.tweets.count - 1
            removeRange  = CountableRange<Int>(removeStart...removeEnd)
            self.tweets.removeSubrange(removeRange!)
        }
        return removeRange
    }
    func getIndexOfLastActive()->Int{
        let actives = alreadyReadTweets.activeTweets
        var maxActiveIndex = 0
        
        for active in actives{
            let index = self.tweets.index(of: active) ?? 0
            maxActiveIndex = max(index, maxActiveIndex)
        }
        return maxActiveIndex
    }
    
    func loginAsync(_ callback : @escaping TweetsLoaded){
        //use webBased login, so that when tapping on tweet we can open the twitter webview in an already logged in state
        Twitter.sharedInstance().logIn(withMethods: TWTRLoginMethod.webBasedForceLogin) { (session, error) -> Void in
            if let session = session {
                print("signed in as \(session.userName)");
                self.getLatestTweets(callback)
                
            } else {
                print("error: \(error!.localizedDescription)");
                
                //UNABLE TO LOG ON TO TWITTER> MAKE SURE YOU HAVE AN INTERNET CONNECTION AND HAVE SINGED INTO TWITTER IN YOU iPHONE SETTTINGS
            }
        }
    }
}
