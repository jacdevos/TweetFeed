import XCTest

class MediatorTests: XCTestCase {
    func testDownloadLastestTweets(){
        let expectAsync = self.expectation(description: "testStatusses")
        //let proxy : TweetDownloader = TweetDownloader()
        let mediator = TweetMediator()
        
        mediator.getLatestTweets { (error, deletedIndexes, insertedIndexes) -> Void in
             expectAsync.fulfill()
        }
        self.waitForExpectations(timeout: 60, handler: { XCWaitCompletionHandler in })
        
        XCTAssertGreaterThan(mediator.tweets.count, 0, "No tweets downloaded and serialized")
    }
}

