import TwitterKit
class Tweet: TWTRTweet {

    override init!(JSONDictionary dictionary: [NSObject : AnyObject]!){
        super.init(JSONDictionary: dictionary)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
