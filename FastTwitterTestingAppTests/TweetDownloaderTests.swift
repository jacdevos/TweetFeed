import XCTest
import TwitterKit

class TweetDownloaderTests: XCTestCase {
    
    func testDownloadLastestTweetData(){
        let expectAsync = self.expectation(description: "testDownloadLastestTweetData")
        var downloadedData :Data?
        
        TweetDownloader.downloadHomeTimelineTweets { (data, error) -> Void in
            downloadedData = data as Data?
            expectAsync.fulfill()
        }
        
        self.waitForExpectations(timeout: 60, handler: { XCWaitCompletionHandler in
        })
        
        XCTAssertNotNil(downloadedData, "unable to download latest tweet data")
    }

}
