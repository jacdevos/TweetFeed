import TwitterKit
typealias TweetsDownloadedCallback = (NSArray?, NSError?) -> Void

class TweetDownloader {
    static let countPerCall = 200
    static let numberOfCalls = 3
    
    static func downloadHomeTimelineTweets(_ callback : @escaping TweetsDownloadedCallback){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        TWTRAPIClient.withCurrentUser().sendTwitterRequest(buildTwitterRequest()) { (response, data, connectionError) -> Void in

            if (connectionError == nil && data != nil) {
                let tweetArray = getJSONTweetArrayFromData(data!)
                callback(tweetArray,nil)
            }
            else {
                print("Error calling twitter: \(connectionError)")
                callback(nil, connectionError as NSError?)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    static func buildTwitterRequest()->URLRequest{
        let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count":"\(countPerCall)","exclude_replies":"false"]
        var clientError : NSError?
        
        return TWTRAPIClient.withCurrentUser().urlRequest(
            withMethod: "GET",
            url: statusesShowEndpoint,
            parameters: params,
            error: &clientError)
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
