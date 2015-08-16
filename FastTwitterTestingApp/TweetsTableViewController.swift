
import UIKit
import TwitterKit

class TweetsTableViewController: UITableViewController, TWTRTweetViewDelegate {
    let iOS7 = floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_7_1)

    let alreadyReadTweets : TweetReadingState = TweetReadingState()
    let tweetTableReuseIdentifier = "TweetCell"
    var tweets: [TWTRTweet] = []
    var tempLoadedCells : [TweetTableViewCell] = []
    var autoScroller : AutoScroller?

    @IBOutlet weak var autoScrollBarButton: UIBarButtonItem!
    var ffdBarButton : UIBarButtonItem? = nil
    var pauseBarButton : UIBarButtonItem? = nil
    
    func setupTweets(){
        var previouslyDownloadedTweets = TweetMediator.getPreviouslyDownloadedTweets()
        self.onLoadedTweets(TweetRelevanceSorter.relevantTweets(previouslyDownloadedTweets),error : nil)
        TweetMediator.getLatestTweets(onLoadedTweets)
    }
    
    override func viewDidLoad() {
        TWTRTweetView.appearance().theme = .Dark
        
        autoScroller = AutoScroller(tableView: tableView!, onAutoScrollingToggled: self.setAutoScrollBarButtonImage)
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
    
    @objc func onApplicationDidBecomeActive(notification: NSNotification){
        TweetMediator.getLatestTweets(onLoadedTweets)
    }
    
    
    func setupTableView(){
        tableView.estimatedRowHeight = 150
        tableView.separatorColor = UIColor.grayColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableView.separatorInset = UIEdgeInsetsZero
        
        if !iOS7{
          tableView.layoutMargins = UIEdgeInsetsZero
        }
        tableView.allowsSelection = true
        
        tableView.rowHeight = UITableViewAutomaticDimension // Explicitly set on iOS 8 if using automatic row height calculation
        tableView.allowsSelection = false
        tableView.registerClass(TweetTableViewCell.self, forCellReuseIdentifier: tweetTableReuseIdentifier)
        tableView.backgroundColor = UIColor.darkGrayColor()
    }
    
    func onLoadedTweets(tweets : [TWTRTweet]?, error : NSError?){
        if let err = error{
            println("Error downloading tweets \(err)")

            if err.localizedDescription.rangeOfString("401") != nil{
                //unauthorised
                 Twitter.sharedInstance().logOut()
                self.dismissViewControllerAnimated(true, completion: nil)
                    
            }

        }
        
        
        //clear old cell data, so old data does not affect the markAsRead logic
        for tweetCell in self.tempLoadedCells{
            tweetCell.tweet = nil
            //println("position \(tweetCell.frame.origin.y)")
        }

        if let loadedTweets = tweets{
            
            var unreadTweets = loadedTweets.filter(){
                if let tweetID = ($0 as TWTRTweet).tweetID as String! {
                    return !self.alreadyReadTweets.alreadyReadTweets.contains(tweetID)
                } else {
                    return false
                }
            }
            
            //move active tweets to the top
            for activeTweet in self.alreadyReadTweets.currentlyReadingTweets{
                //unreadTweets.removeObject(activeTweet)//remove from arb position if it is in main list
                for twt in unreadTweets{
                    if (twt.tweetID == activeTweet.tweetID){
                        unreadTweets.removeObject(twt)//remove from arb position if it is in main list
                        unreadTweets.insert(activeTweet, atIndex: 0)
                    }
                }
                
            }
            
            let oldCount = self.tweets.count
            self.tweets = unreadTweets
            self.tableView.reloadData()
            
            if self.tweets.count > 0{
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
            }
        }
    }

    
    // MARK: UITableViewDelegate Methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row > tweets.count - 1){
            return UITableViewCell()
        }
        
        let tweet = tweets[indexPath.row]
        
        self.alreadyReadTweets.markAsReading(tweet)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(tweetTableReuseIdentifier, forIndexPath: indexPath) as? TweetTableViewCell
        let tweetFromReusedCell = cell?.tweet
        
        if let unloadedTweet = tweetFromReusedCell{
            self.alreadyReadTweets.markAsRead(unloadedTweet)
        }
        
        if let cellChecked = cell{
            
            cellChecked.configureWithTweet(tweet)
            cellChecked.tweetView.delegate = self
            cellChecked.separatorInset = UIEdgeInsetsZero
            if !iOS7{
                cellChecked.layoutMargins = UIEdgeInsetsZero
            }
            return cellChecked
        }
        return UITableViewCell()
        
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let tweetCell = cell as? TweetTableViewCell{
            self.tempLoadedCells.append(tweetCell)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row > tweets.count - 1){
            return 1
        }
        let tweet = tweets[indexPath.row]
        return TweetTableViewCell.heightForTweet(tweet, width: CGRectGetWidth(self.view.bounds), showingActions: true)
        //return TweetTableViewCell.heightForTweet(tweet, width: CGRectGetWidth(self.view.bounds) - 20)
        
    }
    
    func tweetView(tweetView: TWTRTweetView!, didSelectTweet tweet: TWTRTweet!){
        TwitterDeepLink.openTweetDeeplink(tweet)
    }


    
    func setAutoScrollBarButtonImage(){
        navigationItem.rightBarButtonItems =  autoScroller!.isAutoScrolling ? [pauseBarButton!] : [ffdBarButton!]
        
    }
    
    @IBAction func autoScroll(sender: AnyObject) {
        autoScroller!.toggleAutoScroll()
        
    }


}
