import TwitterKit
class Tweet: TWTRTweet {
    var userFollowersCountInt : Int64 = 1 //default
    override init!(JSONDictionary dictionary: [NSObject : AnyObject]!){
        super.init(JSONDictionary: dictionary)
        setUserFollowersCountFromJson(JSONDictionary: dictionary)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUserFollowersCountFromJson(JSONDictionary dictionary: [NSObject : AnyObject]!){
        if let user = dictionary["user"]{
            if let followersCount : AnyObject = user["followers_count"]!{
                if let countAsNumber = followersCount as? NSNumber{
                    userFollowersCountInt  = countAsNumber.longLongValue
                }
            }
        }
    }
}
