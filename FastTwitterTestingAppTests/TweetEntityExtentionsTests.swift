import XCTest

class TweetEntityExtentionsTests: XCTestCase {

    func testShouldExtractUserFollowersCountAsProperty() {
        XCTAssertEqual(3, Tweet(JSONDictionary: ["retweet_count":1,"id_str":2, "user":["followers_count":3]]).userFollowersCount)
        
    }
}
