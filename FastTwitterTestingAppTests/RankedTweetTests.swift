import XCTest
import TwitterKit
class TweetRelevanceSorterTests: XCTestCase {
    /*
    func testRankShouldIncreaseWithMoreRetweets() {
        XCTAssertGreaterThan(createTweet(retweets: 100).rank(),
            createTweet(retweets: 1).rank())
        XCTAssertGreaterThan(createTweet(retweets: 100).rank(),
            createTweet(retweets: 0).rank())
        XCTAssertLessThan(createTweet(retweets: 1).rank(),
            createTweet(retweets: 100).rank())
    }
    
    func testRankShouldIncreaseWithMoreFavourites() {
        XCTAssertGreaterThan(createTweet(favourites: 100).rank(),
            createTweet(favourites: 1).rank())
        XCTAssertGreaterThan(createTweet(favourites: 100).rank(),
            createTweet(favourites: 0).rank())
        XCTAssertLessThan(createTweet(favourites: 1).rank(),
            createTweet(favourites: 100).rank())
    }
    
    func testRankShouldLowerWithMoreFollowers() {
        XCTAssertGreaterThan(createTweet(retweets: 100,followersCount: 1).rank(),
            createTweet(retweets: 100,followersCount: 1000).rank())
        XCTAssertGreaterThan(createTweet(retweets: 100,followersCount: 100).rank(),
            createTweet(retweets: 100,followersCount: 1000000).rank())
        XCTAssertGreaterThan(createTweet(retweets: 100,followersCount: 0).rank(),
            createTweet(retweets: 100,followersCount: 1000).rank())
    }
    
    func testRankShouldNotLowerWithMoreFollowersIfNewsIsPrioritised() {
        let priorityToNews : Double = -1 // -1 does not penalise many followers at all
        XCTAssertEqual(createTweet(retweets: 100,followersCount: 1,priority:priorityToNews).rank(),
            createTweet(retweets: 100,followersCount: 1000,priority : priorityToNews).rank())
        XCTAssertEqual(createTweet(retweets: 100,followersCount: 100, priority:priorityToNews).rank(),
            createTweet(retweets: 100,followersCount: 1000000,priority : priorityToNews).rank())
        XCTAssertEqual(createTweet(retweets: 100,followersCount: 0,priority:priorityToNews).rank(),
            createTweet(retweets: 100,followersCount: 1000,priority : priorityToNews).rank())
    }
    
    func testRankShouldLowerWithMoreFollowersIfFriendsIsPrioritised() {
        let priorityToFriends : Double = 1 // -1 does not penalise many followers at all
        XCTAssertGreaterThan(createTweet(retweets: 100,followersCount: 1,priority:priorityToFriends).rank(),
            createTweet(retweets: 100,followersCount: 1000,priority : priorityToFriends).rank())
        XCTAssertGreaterThan(createTweet(retweets: 100,followersCount: 100, priority:priorityToFriends).rank(),
            createTweet(retweets: 100,followersCount: 1000000,priority : priorityToFriends).rank())
        XCTAssertGreaterThan(createTweet(retweets: 100,followersCount: 0,priority:priorityToFriends).rank(),
            createTweet(retweets: 100,followersCount: 1000,priority : priorityToFriends).rank())
    }
    
    func testRankedListShouldIncludeRankedTweets() {
        let tweets : [Tweet] = [createTweet("1", retweets: 1)]
        XCTAssertTrue(tweets[0].rank() > 0)
        let sorted = Tweet.rankAndFilter(Set(tweets))
        XCTAssertEqual(sorted.count, 1)
    }
    
    func testRankedListShouldExclude0RankedTweets() {
        let tweets : [Tweet] = [createTweet("1", retweets: 0)]
        XCTAssertTrue(tweets[0].rank() == 0)
        let sorted = Tweet.rankAndFilter(Set(tweets))
        XCTAssertEqual(sorted.count, 0)
    }
    
    func testRankedListShouldSortFromHighestToLowestRank() {
        let tweets : [Tweet] =
        [createTweet("1", retweets: 1),createTweet("2", retweets: 3),createTweet("3", retweets: 2)]
        var sorted = Tweet.rankAndFilter(Set(tweets))
        XCTAssertEqual(sorted.count, 3)
        XCTAssertEqual(sorted[0].tweetID, "2")
        XCTAssertEqual(sorted[1].tweetID, "3")
        XCTAssertEqual(sorted[2].tweetID, "1")
    }
 
 */
    /*
    func testShouldExtractUserFollowersCountAsProperty() {
        XCTAssertEqual(3, Tweet(JsonDictionary: ["retweet_count":1,"id_str":2, "user":["followers_count":3]]).userFollowersCount)
    }
    
    func createTweet(_ id : String = "1", retweets : Int = 0, favourites : Int = 0, followersCount : Int = 0, priority : Double = 0) -> Tweet{
        return Tweet(JsonDictionary: ["retweet_count" as NSObject:retweets as AnyObject, "favorite_count" as NSObject:favourites as AnyObject,"id_str" as NSObject:id as AnyObject, "user" as NSObject:["followers_count":followersCount]],priorityBalance : priority)
    }
 */
}
