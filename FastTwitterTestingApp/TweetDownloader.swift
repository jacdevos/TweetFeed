import TwitterKit
typealias TweetsDownloadedCallback = (NSData?, NSError?) -> Void

class TweetDownloader {
    static func downloadHomeTimelineTweets(callback : TweetsDownloadedCallback){
        let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count":"200","exclude_replies":"false","include_entities":"false"]
        var clientError : NSError?
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod(
            "GET", URL: statusesShowEndpoint, parameters: params,
            error: &clientError)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        Twitter.sharedInstance().APIClient.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if (connectionError == nil) {
                callback(data,nil)
            }
            else {
                println("Error calling twitter: \(connectionError)")
                callback(nil, connectionError)
            }
        }
    }

}
