import XCTest
import TwitterKit
class TweetRelevanceSorterTests: XCTestCase {
    
    func testRankedListShouldIncludeRankedTweets() {
        let tweets : [Tweet] = [createTweet("1", retweets: 1)]
        XCTAssertTrue(tweets[0].rank() > 0)
        let sorted = Tweet.rankAndFilter(tweets)
        XCTAssertEqual(sorted.count, 1)
    }
    
    func testRankedListShouldExclude0RankedTweets() {
        let tweets : [Tweet] = [createTweet("1", retweets: 0)]
        XCTAssertTrue(tweets[0].rank() == 0)
        let sorted = Tweet.rankAndFilter(tweets)
        XCTAssertEqual(sorted.count, 0)
    }
    
    func testRankedListShouldSortFromHighestToLowestRank() {
        let tweets : [Tweet] =
            [createTweet("1", retweets: 1),createTweet("2", retweets: 3),createTweet("3", retweets: 2)]
        var sorted = Tweet.rankAndFilter(tweets)
        XCTAssertEqual(sorted.count, 3)
        XCTAssertEqual(sorted[0].tweetID, "2")
        XCTAssertEqual(sorted[1].tweetID, "3")
        XCTAssertEqual(sorted[2].tweetID, "1")
        
    }
    
    func testSortTheMoreFollowersLowerSoThatFamousPeopleDontAlwaysGetOnTop() {
        XCTAssertGreaterThan(createTweet("1", retweets: 100,followersCount: 1).rank(),createTweet("2", retweets: 100,followersCount: 1000).rank())
        XCTAssertGreaterThan(createTweet("1", retweets: 100,followersCount: 100).rank(),createTweet("2", retweets: 100,followersCount: 1000000).rank())
    }
    
    func createTweet(id : String, retweets : Int, followersCount : Int = 0) -> Tweet{
        return Tweet(JSONDictionary: ["retweet_count":retweets,"id_str":id, "user":["followers_count":100]])
    }
}
