
import UIKit
import TwitterKit

class TweetsTableViewController: UITableViewController, TWTRTweetViewDelegate {
    let serviceProxy : TwitterServiceProxy = TwitterServiceProxy()
    let tweetTableReuseIdentifier = "TweetCell"
        // Hold all the loaded Tweets
    var tweets: [TWTRTweet] = [] {
            didSet {
                tableView.reloadData()
            }
        }
    let tweetIDs = ["616504006790111232","20","510908133917487104"]

    
    func didDownloadLatestTweets(tweetsFromService : [TWTRTweet]?, error : NSError?){
        if let err = error{
            println("Error downloading tweets \(err)")
        }
        
        if let tweets = tweetsFromService{
            self.tweets = tweets
        }
        
    }
    
    override func viewDidLoad() {
        setupTableView()
        serviceProxy.downloadLatestTweets(didDownloadLatestTweets);
    }
    
    func setupTableView(){
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension // Explicitly set on iOS 8 if using automatic row height calculation
        tableView.allowsSelection = false
        tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: tweetTableReuseIdentifier)
        tableView.backgroundColor = UIColor.darkGrayColor()
    }
    
    // MARK: UITableViewDelegate Methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tweet = tweets[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(tweetTableReuseIdentifier, forIndexPath: indexPath) as? TWTRTweetTableViewCell
        
        if let cellChecked = cell{
            cellChecked.configureWithTweet(tweet)
            cellChecked.tweetView.delegate = self
            cellChecked.tweetView.theme = TWTRTweetViewTheme.Dark
            return cellChecked
        }
        return UITableViewCell()
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tweet = tweets[indexPath.row]
        return TWTRTweetTableViewCell.heightForTweet(tweet, width: CGRectGetWidth(self.view.bounds))
    }
}
