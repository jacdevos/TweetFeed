import Foundation
import TwitterKit

//TODO: need to use the Tweet repository instead of a seperate file
class TweetReadingState{
    private var alreadyReadTweets : Set<String> //the tweets that have crossed the whole screen
    private let filename = "readtweetids8.txt";
    var activeTweets : Array<Tweet> = []//the tweets that are currently on screen; not persisted in file
    
    init() {
        alreadyReadTweets = []
        let contents = try? String(contentsOfFile: self.pathForDocumentsFile(filename), encoding: NSUTF8StringEncoding)
        if let fileContents = contents{
            let lines = fileContents.componentsSeparatedByString("\n") as [NSString]
            for line in lines{
                if (line != ""){
                    alreadyReadTweets.insert(line as String)
                }
            }
        }
    }
    
    func markAsReading(tweet : Tweet){
        activeTweets.insert(tweet, atIndex: 0)
    }
    
    func markAsRead(tweet : Tweet){
        alreadyReadTweets.insert(tweet.tweetID)
        activeTweets.removeObject(tweet)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            if let outputStream = NSOutputStream(toFileAtPath: self.pathForDocumentsFile(self.filename), append: true) {
                outputStream.open()
                outputStream.write(tweet.tweetID + "\n")
                
                outputStream.close()
            } else {
                print("Unable to open file")
            }
        }
    }
    
    func tweetsThatHaveNotBeenRead(tweets : [Tweet]) -> [Tweet]{
        return tweets.filter(){
            if let tweetID = ($0 as Tweet).tweetID as String! {
                return !self.alreadyReadTweets.contains(tweetID)
            } else {
                return false
            }
        }
    }
    
    func tweetsThatAreNotCurrentlyActive(tweets : [Tweet]) -> [Tweet]{
        let unreadTweets = tweets.filter(){!self.activeTweets.contains($0)}
        return unreadTweets
    }
    
    func tweetsWithActiveTweetsAtTheTop(tweets : [Tweet]) -> [Tweet]{
        var tweetsSortedByIsActive = tweets
        
        for activeTweet in self.activeTweets{
            //unreadTweets.removeObject(activeTweet)//remove from arb position if it is in main list
            for twt in tweetsSortedByIsActive{
                if (twt.tweetID == activeTweet.tweetID){
                    tweetsSortedByIsActive.removeObject(twt)//remove from arb position if it is in main list
                    tweetsSortedByIsActive.insert(activeTweet, atIndex: 0)
                }
            }
        }
        return tweetsSortedByIsActive
    }
    
    func pathForDocumentsFile (fileName : String)  -> String{
        let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
        let dir = dirs[0] //documents directory
        
        let url = NSURL(fileURLWithPath: dir, isDirectory: true).URLByAppendingPathComponent(fileName);
        return url.path!
    }
}