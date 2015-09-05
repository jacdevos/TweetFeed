import TwitterKit
class Tweet: TWTRTweet {
    var userFollowersCount : Int64 = 0 //default
    override init!(JSONDictionary dictionary: [NSObject : AnyObject]!){
        super.init(JSONDictionary: dictionary)
        setUserFollowersCountFromJson(JSONDictionary: dictionary)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //Used to compare the importance of tweets.
    //the higher, the better the rank
    func rank() -> Double{
        if (self.retweetCount == 0){
            return 0;
        }
        
        return Double(self.retweetCount)
    }
    
    static func rankAndFilter(unorderedTweets : [Tweet]) -> [Tweet]{
        return unorderedTweets
            .sort { $0.rank() > $1.rank() }
            .filter{ $0.rank() != 0 }
    }
    
    func setUserFollowersCountFromJson(JSONDictionary dictionary: [NSObject : AnyObject]!){
        if let user = dictionary["user"]{
            if let followersCount : AnyObject = user["followers_count"]!{
                if let countAsNumber = followersCount as? NSNumber{
                    self.userFollowersCount  = countAsNumber.longLongValue
                }
            }
        }
    }
}
