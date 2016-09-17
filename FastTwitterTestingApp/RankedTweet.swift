import TwitterKit
class Tweet: TWTRTweet {
    var userFollowersCount : Int64 = 0 //default
    var priorityBalance : Double = 0
    init!(jsonDictionary dictionary: [AnyHashable: Any]!, priorityBalance : Double = 0){
        super.init(jsonDictionary: dictionary)
        setUserFollowersCountFromJson(JSONDictionary: dictionary)
        self.priorityBalance = priorityBalance
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required init?(jsonDictionary dictionary: [AnyHashable: Any]) {
       super.init(jsonDictionary: dictionary)
    }

    /*
    required init(jsonDictionary dictionary: [AnyHashable : Any]) {
        fatalError("init(jsonDictionary:) has not been implemented")
    }
    */
    //Used to compare the importance of tweets.
    //the higher, the better the rank
    func rank() -> Double{
        let undecayedRank = Double(self.retweetCount) + Double(self.likeCount)
        return undecayedRank / rankDecayDivisor()
    }
    
    fileprivate func rankDecayDivisor() -> Double{
        let followers = max(userFollowersCount, 1)
        
        //let favoursFriendExponent = 1//sharply favours friends, since the rank linearly reduces as follower increase
        //let favourNewsExponent = 0 //sharply favours news, since user with many followers will not be penalised much
        let defaultExponent = 1/1.5 //nice balance
        
        let exponent = self.priorityBalance < 0
            ? defaultExponent + self.priorityBalance * defaultExponent
            : defaultExponent + self.priorityBalance * (1 - defaultExponent)
        
        return pow(Double(followers),exponent)
        
    }
    
    static func rankAndFilter(_ unorderedTweets : Set<Tweet>) -> [Tweet]{
        return unorderedTweets
            .sorted { $0.rank() > $1.rank() }
            .filter{ $0.rank() != 0 }
    }
    
    func setUserFollowersCountFromJson(JSONDictionary dictionary: [AnyHashable: Any]!){
        if let user : Any = dictionary[AnyHashable("user")]{
            let userItem: [AnyHashable: Any] = user as! [AnyHashable: Any]
            let followersCount : Any = userItem[AnyHashable("followers_count")]
            if let countAsNumber = followersCount as? NSNumber{
                self.userFollowersCount  = countAsNumber.int64Value
            }
        }
    }
    
    
    //customer override of Equatable and Hashable, so that we can use Set and Dictionary effectively
    override var hashValue: Int {
        return self.tweetID.hashValue
    }
    override var hash: Int {
        return self.hashValue
    }
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? Tweet {
            return self.tweetID == object.tweetID
        } else {
            return false
        }
    }
}
func == (lhs: Tweet, rhs: Tweet) -> Bool {
    return (lhs.tweetID == rhs.tweetID)
}
