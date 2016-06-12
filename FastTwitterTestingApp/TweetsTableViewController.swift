
import UIKit
import TwitterKit

class TweetsTableViewController: UITableViewController, TWTRTweetViewDelegate, UIWebViewDelegate {
    let mediator = TweetMediator()
    let tweetTableReuseIdentifier = "TweetCell"
    var tempLoadedCells : [TweetTableViewCell] = []
    var autoScroller : AutoScroller?
    @IBOutlet weak var autoScrollBarButton: UIBarButtonItem!
    var ffdBarButton : UIBarButtonItem? = nil
    var pauseBarButton : UIBarButtonItem? = nil
    let webViewControllerForTweets = UIViewController()
    let webViewForTweets : UIWebView
    let webViewControllerForWebLinks = UIViewController()
    let webViewForWebLinks : UIWebView
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        self.webViewForWebLinks = UIWebView(frame: self.webViewControllerForWebLinks.view.bounds)
        self.webViewForTweets = UIWebView(frame: self.webViewControllerForTweets.view.bounds)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.webViewForWebLinks.delegate = self
        self.webViewControllerForWebLinks.view = self.webViewForWebLinks
        self.webViewControllerForTweets.view = self.webViewForTweets
    }

    required init?(coder aDecoder: NSCoder) {
        self.webViewForWebLinks = UIWebView(frame: self.webViewControllerForWebLinks.view.bounds)
        self.webViewForTweets = UIWebView(frame: self.webViewControllerForTweets.view.bounds)
        super.init(coder: aDecoder)
        self.webViewForWebLinks.delegate = self
        self.webViewControllerForTweets.view = self.webViewForTweets
    }
    
    override func viewDidLoad() {
        TWTRTweetView.appearance().theme = .Dark
        self.setupAutoScroll()
        self.setupTableView()
       self.mediator.getLatestTweets(self.onLoadedTweets)
        
        NSNotificationCenter.defaultCenter().addObserver(self,selector: "onApplicationDidBecomeActive:",name: UIApplicationDidBecomeActiveNotification,object: nil)
        
        /*

            Twitter.sharedInstance().logInWithMethods(TWTRLoginMethod.WebBased) { (session, error) -> Void in
                if let session = session {
                    print("signed in as \(session.userName)");
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.twitterSession = session
                    
                    
                } else {
                    print("error: \(error!.localizedDescription)");
                    
                    //UNABLE TO LOG ON TO TWITTER> MAKE SURE YOU HAVE AN INTERNET CONNECTION AND HAVE SINGED INTO TWITTER IN YOU iPHONE SETTTINGS
                }
            }

*/
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.webViewForWebLinks.frame = self.webViewController.view.bounds
        mediator.resetTweetsBelowActive(onLoadedTweets)
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

        //if #available(iOS 8.0, *) {
            tableView.layoutMargins = UIEdgeInsetsZero
        //}
        tableView.allowsSelection = true
        tableView.rowHeight = UITableViewAutomaticDimension // Explicitly set on iOS 8 if using automatic row height calculation
        tableView.allowsSelection = false
        tableView.registerClass(TweetTableViewCell.self, forCellReuseIdentifier: tweetTableReuseIdentifier)
        tableView.backgroundColor = UIColor.darkGrayColor()
    }
    
    func onLoadedTweets(error : NSError?, deletedIndexes: Range<Int>?, insertedIndexes: Range<Int>?){
        if let err = error{
            print("Error downloading tweets \(err)")
            handleAuthorisationError(err)
            return;
        }
        self.tableView.beginUpdates()

        if let deleted = deletedIndexes{
            self.tableView.deleteRowsAtIndexPaths(Array(deleted).map{NSIndexPath(forRow: $0, inSection: 0)}, withRowAnimation: .None)
        }
        if let inserted = insertedIndexes{
            self.tableView.insertRowsAtIndexPaths(Array(inserted).map{NSIndexPath(forRow: $0, inSection: 0)}, withRowAnimation: .None)
        }
        
        self.tableView.endUpdates()
        //ADD NEW UNREAD RANK BELOW
    }
    
    func reloadTweets(){
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
            //TODO how do I logout with the new SDK
            //OLD one was: Twitter.sharedInstance().logOut()
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

            //if #available(iOS 8.0, *) {
                cell.layoutMargins = UIEdgeInsetsZero
            //}
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
        return TweetTableViewCell.heightForTweet(tweet, style: TWTRTweetViewStyle.Compact, width: CGRectGetWidth(self.view.bounds), showingActions: true)
    }
    
    /* obsolete
    
    func tweetView(tweetView: TWTRTweetView!, didSelectTweet tweet: TWTRTweet!){
        TwitterDeepLink.openTweetDeeplink(tweet)
    }
*/

    func tweetView(tweetView: TWTRTweetView, didTapURL url: NSURL) {

        self.webViewForWebLinks.loadRequest(NSURLRequest(URL: url))
        self.webViewControllerForWebLinks.view = self.webViewForWebLinks
        self.webViewControllerForWebLinks.navigationItem.title = url.host
        
        self.navigationController!.pushViewController(self.webViewControllerForWebLinks, animated: true)
    }
    
    internal func webViewDidFinishLoad(webView: UIWebView){
        self.webViewControllerForWebLinks.navigationItem.title = webView.request?.URL?.host
    }
    
    func tweetView(tweetView: TWTRTweetView, shouldDisplayDetailViewController controller: TWTRTweetDetailViewController) -> Bool {
        let tweetURL = controller.tweet.permalink
        
        webViewForTweets.loadRequest(NSURLRequest(URL: tweetURL))
        self.webViewControllerForTweets.navigationItem.title = "Tweet"
        self.navigationController!.pushViewController(self.webViewControllerForTweets, animated: true)
        return false;
    }
    
    /*
    //show detail using their controller
    func tweetView(tweetView: TWTRTweetView, shouldDisplayDetailViewController controller: TWTRTweetDetailViewController) -> Bool {
        self.showViewController(controller, sender:self)
        return false;
    }
*/

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
