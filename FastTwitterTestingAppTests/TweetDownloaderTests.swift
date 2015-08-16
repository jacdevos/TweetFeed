import XCTest
import TwitterKit

class TweetDownloaderTests: XCTestCase {
    
    func testDownloadLastestTweetData(){
        let expectAsync = self.expectationWithDescription("testDownloadLastestTweetData")
        let proxy : TweetDownloader = TweetDownloader()
        var downloadedData :NSData?
        
        TweetDownloader.downloadLatestTweetData { (data, error) -> Void in
            downloadedData = data
            expectAsync.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(60, handler: { (error: NSError?) -> Void in
        })
        
        XCTAssertNotNil(downloadedData, "unable to download latest tweet data")
    }
    
    func testDownloadLastestTweets(){
        let expectAsync = self.expectationWithDescription("testStatusses")
        let proxy : TweetDownloader = TweetDownloader()
        var downloadedTweets :[TWTRTweet]?
        
        TweetRepository.getLatestTweets { (tweets :[TWTRTweet]?, error : NSError?) -> Void in
            downloadedTweets = tweets
            expectAsync.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(60, handler: { (error: NSError?) -> Void in
        })
        
        XCTAssertGreaterThan(downloadedTweets!.count, 0, "No tweets downloaded and serialized")
    }
}
