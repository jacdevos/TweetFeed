import TwitterKit
typealias TweetsDownloadedCallback = ([[AnyHashable: Any]]?, NSError?) -> Void

class TweetDownloader {
    static let countPerCall = 200
    static let totalNumberOfCalls = 3
    
    static func downloadHomeTimelineTweets(_ callback : @escaping TweetsDownloadedCallback){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        downloadHomeTimelineRecursively(callCount :1, max_id : Int64.max, previousTweets : [[AnyHashable: Any]](), callback)
    }
    
    static func downloadHomeTimelineRecursively(callCount : Int, max_id : Int64, previousTweets : [[AnyHashable: Any]],_ callback : @escaping TweetsDownloadedCallback){
        let request = buildTwitterRequest(max_id : max_id)
        TWTRAPIClient.withCurrentUser().sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            print("Called \(request)  and returned error \(connectionError) and data size \(data?.description)")
                
                
            if (connectionError == nil && data != nil) {
                let tweetArrayFromService = getJSONTweetArrayFromData(data!)
                let newFullTweetArray : [[AnyHashable: Any]] = previousTweets + tweetArrayFromService
                
                if (callCount < totalNumberOfCalls){
                    
                    downloadHomeTimelineRecursively(callCount: callCount + 1, max_id: getLowestTweetId(tweets: tweetArrayFromService), previousTweets: newFullTweetArray, callback)
                }else{
                    callback(newFullTweetArray as [[AnyHashable: Any]]?,nil)
                }
                
            }
            else {
                print("Error calling twitter: \(connectionError)")
                callback(nil, connectionError as NSError?)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    static func buildTwitterRequest(max_id : Int64)->URLRequest{
        let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        var params = ["count":"\(countPerCall)","exclude_replies":"false"]
        if (max_id  != Int64.max){
            params["max_id"] = "\(max_id)"
        }
        var clientError : NSError?
        
        return TWTRAPIClient.withCurrentUser().urlRequest(
            withMethod: "GET",
            url: statusesShowEndpoint,
            parameters: params,
            error: &clientError)
    }
    
    
    fileprivate static func getLowestTweetId(tweets: [[AnyHashable: Any]]) -> Int64 {
        
        let minOrNul = tweets.min { (a, b) -> Bool in
            
            let id_a = (a["id"] as! NSNumber).int64Value
            let id_b = (b["id"]as! NSNumber).int64Value
            return id_a < id_b
        }
        
        
        if let min = minOrNul{
            let min_id = (min["id"] as! NSNumber).int64Value
            return min_id
        }else{
            return Int64.max
        }
    }
    
    fileprivate static func getJSONTweetArrayFromData(_ data: Data) -> [[AnyHashable: Any]] {
        var jsonError : NSError?
        var json : Any
        do {
            json = try JSONSerialization.jsonObject(with: data, options: [])
            let nsArray = json as! NSArray
            let array = nsArray as! [[AnyHashable: Any]]
            return array
        } catch let error as NSError {
            jsonError = error
            print(jsonError)
        } catch{
            print("Unknown error serializing JSON")
        }
        return [[AnyHashable: Any]]()
    }
    
}
