import XCTest
import TwitterKit
class TweetRelevanceSorterTests: XCTestCase {
    
    func testIncludeIfTweetHasRetweets() {
        let tweets : [Tweet] = [createTweet("1", retweets: 1)]
        let sorted = TweetRelevanceSorter.rankAndFilter(tweets)
        XCTAssertEqual(sorted.count, 1)
    }
    
    func testExcludeIfTweetHas0Retweets() {
        let tweets : [Tweet] = [createTweet("1", retweets: 0)]
        let sorted = TweetRelevanceSorter.rankAndFilter(tweets)
        XCTAssertEqual(sorted.count, 0)
    }
    
    func testSortByRetweets() {
        let tweets : [Tweet] =
            [createTweet("1", retweets: 1),createTweet("3", retweets: 3),createTweet("2", retweets: 2)]
        var sorted = TweetRelevanceSorter.rankAndFilter(tweets)
        XCTAssertEqual(sorted.count, 3)
        XCTAssertEqual(sorted[0].tweetID, "3")
        XCTAssertEqual(sorted[1].tweetID, "2")
        XCTAssertEqual(sorted[2].tweetID, "1")
        
    }
    
    func createTweet(id : String, retweets : Int, followersCount : Int = 10) -> Tweet{
        return Tweet(JSONDictionary: ["retweet_count":retweets,"id_str":id, "user":["followers_count":100]])
    }
}
