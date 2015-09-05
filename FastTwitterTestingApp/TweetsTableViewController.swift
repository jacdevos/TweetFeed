
import UIKit
import TwitterKit

class TweetsTableViewController: UITableViewController, TWTRTweetViewDelegate {
    let mediator = TweetMediator()
    let tweetTableReuseIdentifier = "TweetCell"
    var tempLoadedCells : [TweetTableViewCell] = []
    var autoScroller : AutoScroller?
    @IBOutlet weak var autoScrollBarButton: UIBarButtonItem!
    var ffdBarButton : UIBarButtonItem? = nil
    var pauseBarButton : UIBarButtonItem? = nil
    
    override func viewDidLoad() {
        TWTRTweetView.appearance().theme = .Dark
        self.setupAutoScroll()
        self.setupTableView()
        mediator.getLatestTweets(onLoadedTweets)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: "onApplicationDidBecomeActive:",name: UIApplicationDidBecomeActiveNotification,object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mediator.setupTweets()
        autoScroller!.isScrollVisible = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        autoScroller!.isScrollVisible = false
    }
    
    @objc func onApplicationDidBecomeActive(notification: NSNotification){
        mediator.getLatestTweets(onLoadedTweets)
    }
    
    func setupAutoScroll(){
        autoScroller = AutoScroller(tableView: tableView!, onAutoScrollingToggled: self.setAutoScrollBarButtonImage)
        ffdBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FastForward, target: self, action: "autoScroll:")
        pauseBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Pause, target: self, action:  "autoScroll:")
    }

    func setupTableView(){
        tableView.estimatedRowHeight = 150
        tableView.separatorColor = UIColor.grayColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableView.separatorInset = UIEdgeInsetsZero

        if #available(iOS 8.0, *) {
            tableView.layoutMargins = UIEdgeInsetsZero
        }
        tableView.allowsSelection = true
        tableView.rowHeight = UITableViewAutomaticDimension // Explicitly set on iOS 8 if using automatic row height calculation
        tableView.allowsSelection = false
        tableView.registerClass(TweetTableViewCell.self, forCellReuseIdentifier: tweetTableReuseIdentifier)
        tableView.backgroundColor = UIColor.darkGrayColor()
    }
    
    func onLoadedTweets(error : NSError?){
        if let err = error{
            print("Error downloading tweets \(err)")
            handleAuthorisationError(err)
            return;
        }
        cleanOldreuseCellsSoThatTheyDontAffectMarkAsReadLogic()
        self.tableView.reloadData()
        if self.mediator.tweets.count > 0{
            scrollToTopRow()
        }
    }
    
    func cleanOldreuseCellsSoThatTheyDontAffectMarkAsReadLogic(){
        for tweetCell in self.tempLoadedCells{
            tweetCell.tweet = nil
            //println("position \(tweetCell.frame.origin.y)")
        }
    }
    
    func scrollToTopRow(){
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
    }
    
    func handleAuthorisationError(error : NSError){
        if error.localizedDescription.rangeOfString("401") != nil{
            Twitter.sharedInstance().logOut()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: UITableViewDelegate Methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mediator.tweets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row > mediator.tweets.count - 1){
            return UITableViewCell()
        }
        
        let tweet = mediator.tweets[indexPath.row]
        
        mediator.alreadyReadTweets.markAsReading(tweet)
        
        let cell = tableView.dequeueReusableCellWithIdentifier(tweetTableReuseIdentifier, forIndexPath: indexPath) as? TweetTableViewCell
        let tweetFromReusedCell = cell?.tweet
        
        if let unloadedTweet = tweetFromReusedCell{
            mediator.alreadyReadTweets.markAsRead(unloadedTweet)
        }
        
        if let cellChecked = cell{
            configureCell(cellChecked, tweet : tweet)
            return cellChecked
        }
        return UITableViewCell()
    }
    
    func configureCell(cell : TweetTableViewCell, tweet : Tweet){
        cell.configWithTweet(tweet)
        cell.tweetView.delegate = self
        cell.separatorInset = UIEdgeInsetsZero

            if #available(iOS 8.0, *) {
                cell.layoutMargins = UIEdgeInsetsZero
            }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let tweetCell = cell as? TweetTableViewCell{
            self.tempLoadedCells.append(tweetCell)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row > mediator.tweets.count - 1){
            return 1
        }
        let tweet = mediator.tweets[indexPath.row]
        return TweetTableViewCell.heightForTweet(tweet, width: CGRectGetWidth(self.view.bounds), showingActions: true)
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
    
    @IBAction func openPreferences(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("preferences", sender: self)
    }
}
