import TwitterKit
typealias TweetsDownloadedCallback = (NSData?, NSError?) -> Void

class TweetDownloader {
    static func downloadHomeTimelineTweets(callback : TweetsDownloadedCallback){
        //TODO: need to cater for 2 types of calls:
        //the one that gets latest 200
        //the other that gets from the last downloaded ID up to latest or 200 cap
        
        let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count":"200","exclude_replies":"false"]
        var clientError : NSError?
        
        let request = TWTRAPIClient.clientWithCurrentUser().URLRequestWithMethod(
            "GET",
            URL: statusesShowEndpoint,
            parameters: params,
            error: &clientError)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        TWTRAPIClient.clientWithCurrentUser().sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if (connectionError == nil) {
                callback(data,nil)
            }
            else {
                print("Error calling twitter: \(connectionError)")
                callback(nil, connectionError)
            }
        }
    }
}
