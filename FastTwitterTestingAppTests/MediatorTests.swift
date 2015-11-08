import XCTest

class MediatorTests: XCTestCase {
    func testDownloadLastestTweets(){
        let expectAsync = self.expectationWithDescription("testStatusses")
        //let proxy : TweetDownloader = TweetDownloader()
        let mediator = TweetMediator()
        
        mediator.getLatestTweets { (error, deletedIndexes, insertedIndexes) -> Void in
             expectAsync.fulfill()
        }
        self.waitForExpectationsWithTimeout(60, handler: { (error: NSError?) -> Void in })
        
        XCTAssertGreaterThan(mediator.tweets.count, 0, "No tweets downloaded and serialized")
    }
}

