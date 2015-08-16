import XCTest
import TwitterKit

class TweetDownloaderTests: XCTestCase {
    
    func testDownloadLastestTweetData(){
        let expectAsync = self.expectationWithDescription("testDownloadLastestTweetData")
        let proxy : TweetDownloader = TweetDownloader()
        var downloadedData :NSData?
        
        TweetDownloader.downloadHomeTimelineTweets { (data, error) -> Void in
            downloadedData = data
            expectAsync.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(60, handler: { (error: NSError?) -> Void in
        })
        
        XCTAssertNotNil(downloadedData, "unable to download latest tweet data")
    }

}
