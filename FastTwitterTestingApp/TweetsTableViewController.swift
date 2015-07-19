
import UIKit
import TwitterKit

class TweetsTableViewController: UITableViewController, TWTRTweetViewDelegate {
    let serviceProxy : TwitterServiceProxy = TwitterServiceProxy()
    let alreadyReadTweets : AlreadyReadTweets = AlreadyReadTweets()
    let tweetTableReuseIdentifier = "TweetCell"
    var tweets: [TWTRTweet] = []
    var isAutoScrolling = false {
        didSet {
            self.setAutoScrollBarButtonImage()
        }
    }

    @IBOutlet weak var autoScrollBarButton: UIBarButtonItem!
    var ffdBarButton : UIBarButtonItem? = nil
    var pauseBarButton : UIBarButtonItem? = nil
    
    func setupTweets(){
        var previouslyDownloadedTweets = serviceProxy.tweetsLoadedFromFile( "tweets.twt")
        self.onLoadedTweets(serviceProxy.relevantTweets(previouslyDownloadedTweets),error : nil)

    }
    
    override func viewDidLoad() {
        TWTRTweetView.appearance().theme = .Dark
        self.setupTableView()
        self.setupTweets()
        
        ffdBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FastForward, target: self, action: "autoScroll:")
        pauseBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Pause, target: self, action:  "autoScroll:")
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "onApplicationDidBecomeActive:",
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)

    }
    

    func scrollByOnePointOnTimer() {
        tableView.setContentOffset(CGPoint(
            x:tableView.contentOffset.x,
            y: tableView.contentOffset.y + 1),//add one point, more than than makes it appear to jump
            animated: false)//need to switch animation off for smooth scrolling
        
        if isAutoScrolling{
            self.autoScrollAfterInterval()
            
            if tableView.contentOffset.y > tableView.contentSize.height - 500{
                isAutoScrolling = false
            }
        }
    
    }
    
    @objc func onApplicationDidBecomeActive(notification: NSNotification){
        serviceProxy.downloadLatestTweets(onLoadedTweets)
        
        if tweets.count > 0{
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        }
    }
    
    func setAutoScrollBarButtonImage(){
        navigationItem.rightBarButtonItems = isAutoScrolling ? [pauseBarButton!] : [ffdBarButton!]
    }
  
    @IBAction func autoScroll(sender: AnyObject) {
        isAutoScrolling = !isAutoScrolling
        
        self.autoScrollAfterInterval()
    }
    
    func autoScrollAfterInterval(){
        if !isAutoScrolling{
            return
        }
        
         NSTimer.scheduledTimerWithTimeInterval(0.011, target: self, selector: "scrollByOnePointOnTimer", userInfo: nil, repeats: false)
    }
    
    func setupTableView(){
        tableView.estimatedRowHeight = 150
        tableView.separatorColor = UIColor.grayColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        
        tableView.allowsSelection = true
        
        
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
            self.tableView.reloadData()
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
    
    func tweetView(tweetView: TWTRTweetView!, didSelectTweet tweet: TWTRTweet!){
        isAutoScrolling = false
        setAutoScrollBarButtonImage()
        
        
        let URL = "https://twitter.com/support/status/\(tweet.tweetID)"
        let URLInApp = "twitter://status?id=\(tweet.tweetID)"
        
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: URLInApp)!) {
            UIApplication.sharedApplication().openURL(NSURL(string: URLInApp)!)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: URL)!)
        }
        
        UIApplication.sharedApplication().openURL(NSURL(string: "twitter://timeline")!)
    }

}
