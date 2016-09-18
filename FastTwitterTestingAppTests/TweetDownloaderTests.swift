import XCTest
import TwitterKit

class TweetDownloaderTests: XCTestCase {
    
    func testDownloadLastestTweetData(){
        let expectAsync = self.expectation(description: "testDownloadLastestTweetData")
        var downloadedTweetArray :[[AnyHashable: Any]]?
        
        TweetDownloader.downloadHomeTimelineTweets { (tweetArray, error) -> Void in
            if (tweetArray != nil){
                downloadedTweetArray = tweetArray! as [[AnyHashable: Any]]
            }
            expectAsync.fulfill()
        }
        
        self.waitForExpectations(timeout: 60, handler: { XCWaitCompletionHandler in
        })
        
        XCTAssertNotNil(downloadedTweetArray, "unable to download latest tweet data")
        if (downloadedTweetArray != nil){
            XCTAssertGreaterThan((downloadedTweetArray?.count)!, 500, "expected at least 500 tweets but got \(downloadedTweetArray?.count)")
        }
    }

}
