import XCTest
import TwitterKit
import FastTwitterTestingApp

class TwitterServiceProxyTests: XCTestCase {
    
    func testDownloadLastestTweetData(){
        let expectAsync = self.expectationWithDescription("testDownloadLastestTweetData")
        let proxy : TwitterServiceProxy = TwitterServiceProxy()
        var downloadedData :NSData?
        
        proxy.downloadLatestTweetData { (data, error) -> Void in
            downloadedData = data
            expectAsync.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(60, handler: { (error: NSError?) -> Void in
        })
        
        XCTAssertNotNil(downloadedData, "unable to download latest tweet data")
    }
    
    func testDownloadLastestTweets(){
        let expectAsync = self.expectationWithDescription("testStatusses")
        let proxy : TwitterServiceProxy = TwitterServiceProxy()
        var downloadedTweets :[TWTRTweet]?
        
        proxy.downloadLatestTweets { (tweets :[TWTRTweet]?, error : NSError?) -> Void in
            downloadedTweets = tweets
            expectAsync.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(60, handler: { (error: NSError?) -> Void in
        })
        
        XCTAssertGreaterThan(downloadedTweets!.count, 0, "No tweets downloaded and serialized")
    }
}
