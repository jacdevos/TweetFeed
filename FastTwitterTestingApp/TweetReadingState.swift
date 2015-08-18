import Foundation
import TwitterKit

class TweetReadingState{
    var alreadyReadTweets : Set<String> //the tweets that have crossed the whole screen
    
    var currentlyReadingTweets : Array<TWTRTweet> = []//the tweets that are currently on screen; not persisted in file
    
    init() {
        alreadyReadTweets = []
        let contents = String(contentsOfFile: self.pathForDocumentsFile("readtweetids3.txt"), encoding: NSUTF8StringEncoding, error: nil)
        if let fileContents = contents{
            let lines = fileContents.componentsSeparatedByString("\n") as [NSString]
            for line in lines{
                if (line != ""){
                    alreadyReadTweets.insert(line as String)
                }
            }
        }
    }
    
    func markAsReading(tweet : TWTRTweet){
        currentlyReadingTweets.insert(tweet, atIndex: 0)
       
    }
    
    func markAsRead(tweet : TWTRTweet){
        alreadyReadTweets.insert(tweet.tweetID)
        currentlyReadingTweets.removeObject(tweet)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            if let outputStream = NSOutputStream(toFileAtPath: self.pathForDocumentsFile("readtweetids3.txt"), append: true) {
                outputStream.open()
                outputStream.write(tweet.tweetID + "\n")
                
                outputStream.close()
            } else {
                println("Unable to open file")
            }
        }

    }
    
    func pathForDocumentsFile (fileName : String)  -> String{
        let dirs : [String] = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String])!
        let dir = dirs[0] //documents directory
        let path = dir.stringByAppendingPathComponent(fileName);
        return path
    }
    
    
    
}