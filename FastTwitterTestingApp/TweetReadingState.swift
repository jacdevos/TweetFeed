import Foundation
import TwitterKit

//TODO: need to use the Tweet repository instead of a seperate file
class TweetReadingState{
    fileprivate var alreadyReadTweets : Set<String> //the tweets that have crossed the whole screen
    fileprivate let filename = "readtweetids8.txt";
    var activeTweets : Array<Tweet> = []//the tweets that are currently on screen; not persisted in file
    
    init() {
        alreadyReadTweets = []
        let contents = try? String(contentsOfFile: self.pathForDocumentsFile(filename), encoding: String.Encoding.utf8)
        if let fileContents = contents{
            let lines = fileContents.components(separatedBy: "\n") as [NSString]
            for line in lines{
                if (line != ""){
                    alreadyReadTweets.insert(line as String)
                }
            }
        }
    }
    
    func markAsReading(_ tweet : Tweet){
        activeTweets.insert(tweet, at: 0)
    }
    
    func markAsRead(_ tweet : Tweet){
        alreadyReadTweets.insert(tweet.tweetID)
        activeTweets.removeObject(tweet)
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            
            if let outputStream = OutputStream(toFileAtPath: self.pathForDocumentsFile(self.filename), append: true) {
                outputStream.open()
                outputStream.write(tweet.tweetID + "\n")
                
                outputStream.close()
            } else {
                print("Unable to open file")
            }
        }
    }
    
    func tweetsThatHaveNotBeenRead(_ tweets : [Tweet]) -> [Tweet]{
        return tweets.filter(){
            if let tweetID = ($0 as Tweet).tweetID as String! {
                return !self.alreadyReadTweets.contains(tweetID)
            } else {
                return false
            }
        }
    }
    
    func tweetsThatAreNotCurrentlyActive(_ tweets : [Tweet]) -> [Tweet]{
        let unreadTweets = tweets.filter(){!self.activeTweets.contains($0)}
        return unreadTweets
    }
    
    func tweetsWithActiveTweetsAtTheTop(_ tweets : [Tweet]) -> [Tweet]{
        var tweetsSortedByIsActive = tweets
        
        for activeTweet in self.activeTweets{
            //unreadTweets.removeObject(activeTweet)//remove from arb position if it is in main list
            for twt in tweetsSortedByIsActive{
                if (twt.tweetID == activeTweet.tweetID){
                    tweetsSortedByIsActive.removeObject(twt)//remove from arb position if it is in main list
                    tweetsSortedByIsActive.insert(activeTweet, at: 0)
                }
            }
        }
        return tweetsSortedByIsActive
    }
    
    func pathForDocumentsFile (_ fileName : String)  -> String{
        let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        let dir = dirs[0] //documents directory
        
        let url = URL(fileURLWithPath: dir, isDirectory: true).appendingPathComponent(fileName);
        return url.path
    }
}
