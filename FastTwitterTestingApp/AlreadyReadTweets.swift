import Foundation
import TwitterKit
extension NSOutputStream {
    
    /// Write String to outputStream
    ///
    /// :param: string                The string to write.
    /// :param: encoding              The NSStringEncoding to use when writing the string. This will default to UTF8.
    /// :param: allowLossyConversion  Whether to permit lossy conversion when writing the string.
    ///
    /// :returns:                     Return total number of bytes written upon success. Return -1 upon failure.
    
    func write(string: String, encoding: NSStringEncoding = NSUTF8StringEncoding, allowLossyConversion: Bool = true) -> Int {
        if let data = string.dataUsingEncoding(encoding, allowLossyConversion: allowLossyConversion) {
            var bytes = UnsafePointer<UInt8>(data.bytes)
            var bytesRemaining = data.length
            var totalBytesWritten = 0
            
            while bytesRemaining > 0 {
                let bytesWritten = self.write(bytes, maxLength: bytesRemaining)
                if bytesWritten < 0 {
                    return -1
                }
                
                bytesRemaining -= bytesWritten
                bytes += bytesWritten
                totalBytesWritten += bytesWritten
            }
            
            return totalBytesWritten
        }
        
        return -1
    }
    
}

class AlreadyReadTweets{
    var alreadyReadTweets : Set<String>
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
        
        //println(alreadyReadTweets)
    }
    
    func markAsRead(tweet : TWTRTweet){
        alreadyReadTweets.insert(tweet.tweetID)
        
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