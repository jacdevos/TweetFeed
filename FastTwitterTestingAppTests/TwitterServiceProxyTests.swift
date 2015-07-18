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
    
   /*
    func testGetTweet() {
    let expectAsync = self.expectationWithDescription("testGetTweet")
    var twt : TWTRTweet? = nil
    Twitter.sharedInstance().APIClient.loadTweetWithID("616504006790111232") { (tweet: TWTRTweet?, error: NSError?) in
    twt = tweet
    expectAsync.fulfill()
    }
    XCTAssertNotNil(twt, "unable to get tweet from api. make sure you have a twitter session")
    }
    func testStatus(){
        let expectAsync = self.expectationWithDescription("testStatus")
        
        let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/show.json"
        let params = ["id": "20"]
        var clientError : NSError?
        
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod(
            "GET", URL: statusesShowEndpoint, parameters: params,
            error: &clientError)
        
        var json : AnyObject? = nil
        Twitter.sharedInstance().APIClient.sendTwitterRequest(request) {
            (response, data, connectionError) -> Void in
            if (connectionError == nil) {
                var jsonError : NSError?
                json = NSJSONSerialization.JSONObjectWithData(data!,
                    options: nil,
                    error: &jsonError)
                
            }
            else {
                println("Error: \(connectionError)")
            }
            expectAsync.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(60, handler: { (error: NSError?) -> Void in
        })
        
        XCTAssertNotNil(json, "unable to get json from api")
        
        
    }
    */
}
