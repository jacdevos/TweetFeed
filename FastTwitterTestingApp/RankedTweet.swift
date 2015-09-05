import TwitterKit
class Tweet: TWTRTweet {
    var userFollowersCount : Int64 = 0 //default
    var priorityBalance : Double = 0
    init!(JSONDictionary dictionary: [NSObject : AnyObject]!, priorityBalance : Double = 0){
        super.init(JSONDictionary: dictionary)
        setUserFollowersCountFromJson(JSONDictionary: dictionary)
        self.priorityBalance = priorityBalance
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Used to compare the importance of tweets.
    //the higher, the better the rank
    func rank() -> Double{
        let undecayedRank = Double(self.retweetCount) + Double(self.favoriteCount)
        return undecayedRank / rankDecayDivisor()
    }
    
    private func rankDecayDivisor() -> Double{
        let followers = max(userFollowersCount, 1)
        
        //let favoursFriendExponent = 1//sharply favours friends, since the rank linearly reduces as follower increase
        //let favourNewsExponent = 0 //sharply favours news, since user with many followers will not be penalised much
        let defaultExponent = 1/1.5 //nice balance
        
        let exponent = self.priorityBalance < 0
            ? defaultExponent + self.priorityBalance * defaultExponent
            : defaultExponent + self.priorityBalance * (1 - defaultExponent)
        
        return pow(Double(followers),exponent)
        
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
