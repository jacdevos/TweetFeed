import XCTest
import TwitterKit

class TweetDownloaderTests: XCTestCase {
    
    func testDownloadLastestTweetData(){
        let expectAsync = self.expectation(description: "testDownloadLastestTweetData")
        var downloadedData :NSArray?
        
        TweetDownloader.downloadHomeTimelineTweets { (tweetArray, error) -> Void in
            downloadedData = tweetArray as NSArray?
            expectAsync.fulfill()
        }
        
        self.waitForExpectations(timeout: 60, handler: { XCWaitCompletionHandler in
        })
        
        XCTAssertNotNil(downloadedData, "unable to download latest tweet data")
    }

}
