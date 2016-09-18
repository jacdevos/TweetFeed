import TwitterKit
typealias TweetsDownloadedCallback = (NSArray?, NSError?) -> Void

class TweetDownloader {
    static func downloadHomeTimelineTweets(_ callback : @escaping TweetsDownloadedCallback){
        //TODO: need to cater for 2 types of calls:
        //the one that gets latest 200
        //the other that gets from the last downloaded ID up to latest or 200 cap
        
        let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count":"200","exclude_replies":"false"]
        var clientError : NSError?
        
        let request = TWTRAPIClient.withCurrentUser().urlRequest(
            withMethod: "GET",
            url: statusesShowEndpoint,
            parameters: params,
            error: &clientError)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        TWTRAPIClient.withCurrentUser().sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if (connectionError == nil && data != nil) {
                let tweetArray = getJSONTweetArrayFromData(data!)
                callback(tweetArray,nil)
            }
            else {
                print("Error calling twitter: \(connectionError)")
                callback(nil, connectionError as NSError?)
            }
        }
    }
    
    
    fileprivate static func getJSONTweetArrayFromData(_ data: Data) -> NSArray {
        var jsonError : NSError?
        var json : Any
        do {
            json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as! NSArray
        } catch let error as NSError {
            jsonError = error
            print(jsonError)
        } catch{
            print("Unknown error serializing JSON")
        }
        return NSArray()
    }
    
}
