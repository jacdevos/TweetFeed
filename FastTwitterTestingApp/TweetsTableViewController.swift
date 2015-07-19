
import UIKit
import TwitterKit

class TweetsTableViewController: UITableViewController, TWTRTweetViewDelegate {
    let serviceProxy : TwitterServiceProxy = TwitterServiceProxy()
    let alreadyReadTweets : AlreadyReadTweets = AlreadyReadTweets()
    let tweetTableReuseIdentifier = "TweetCell"
    var tweets: [TWTRTweet] = []
    let tweetIDs = ["616504006790111232","20","510908133917487104"]

    
    override func viewDidLoad() {
        TWTRTweetView.appearance().theme = .Dark
        self.setupTableView()
        var previouslyDownloadedTweets = serviceProxy.tweetsLoadedFromFile( "tweets.twt")
        self.onLoadedTweets(serviceProxy.relevantTweets(previouslyDownloadedTweets),error : nil)
        serviceProxy.downloadLatestTweets(onLoadedTweets);
    }
    
    func setupTableView(){
        tableView.estimatedRowHeight = 150
        tableView.separatorColor = UIColor.grayColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        //tableView.separatorEffect = UIBlurEffect();
        
        tableView.rowHeight = UITableViewAutomaticDimension // Explicitly set on iOS 8 if using automatic row height calculation
        tableView.allowsSelection = false
        tableView.registerClass(TWTRTweetTableViewCell.self, forCellReuseIdentifier: tweetTableReuseIdentifier)
        tableView.backgroundColor = UIColor.darkGrayColor()
    }
    
    
    func onLoadedTweets(tweets : [TWTRTweet]?, error : NSError?){
        if let err = error{
            println("Error downloading tweets \(err)")
        }
        
        
        
        
        if let loadedTweets = tweets{
            
            let unreadTweets = loadedTweets.filter(){
                if let tweetID = ($0 as TWTRTweet).tweetID as String! {
                    return !self.alreadyReadTweets.alreadyReadTweets.contains(tweetID)
                } else {
                    return false
                }
            }
            
            //TODO just append from active one
            let oldCount = self.tweets.count
            self.tweets = unreadTweets
            if (oldCount == 0){
                self.tableView.reloadData()
            }
        }
        
    }

    
    // MARK: UITableViewDelegate Methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println(indexPath.row)
        
        if (indexPath.row > tweets.count - 1){
            return UITableViewCell()
        }
        
        let tweet = tweets[indexPath.row]
        
        self.alreadyReadTweets.markAsRead(tweet)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(tweetTableReuseIdentifier, forIndexPath: indexPath) as? TWTRTweetTableViewCell
        
        if let cellChecked = cell{
            cellChecked.configureWithTweet(tweet)
            cellChecked.tweetView.delegate = self
            cellChecked.separatorInset = UIEdgeInsetsZero
            cellChecked.layoutMargins = UIEdgeInsetsZero
            return cellChecked
        }
        return UITableViewCell()
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row > tweets.count - 1){
            return 1
        }
        let tweet = tweets[indexPath.row]
        return TWTRTweetTableViewCell.heightForTweet(tweet, width: CGRectGetWidth(self.view.bounds))
    }
}
