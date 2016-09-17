
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
    let webViewControllerForTweets = UIViewController()
    let webViewForTweets : UIWebView
    let webViewControllerForWebLinks = UIViewController()
    //let webViewForWebLinks : UIWebView
    var delegateForProgressForTweets  : WebViewDelegateForProgress
    var delegateForProgressForWebLinks  : WebViewDelegateForProgress
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        //self.webViewForWebLinks = UIWebView(frame: self.webViewControllerForWebLinks.view.bounds)
        self.webViewForTweets = UIWebView(frame: self.webViewControllerForTweets.view.bounds)
        delegateForProgressForTweets = WebViewDelegateForProgress()
        delegateForProgressForWebLinks = WebViewDelegateForProgress()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        //self.webViewForWebLinks.delegate = self
        //self.webViewForTweets.delegate = self
        //self.webViewControllerForWebLinks.view = self.webViewForWebLinks
        self.webViewControllerForTweets.view = self.webViewForTweets
    }

    required init?(coder aDecoder: NSCoder) {
        //self.webViewForWebLinks = UIWebView(frame: self.webViewControllerForWebLinks.view.bounds)
        self.webViewForTweets = UIWebView(frame: self.webViewControllerForTweets.view.bounds)
        delegateForProgressForWebLinks = WebViewDelegateForProgress()
        delegateForProgressForTweets = WebViewDelegateForProgress()
        super.init(coder: aDecoder)
        //self.webViewForWebLinks.delegate = self
        self.webViewControllerForTweets.view = self.webViewForTweets
    }
    
    override func viewDidLoad() {
        TWTRTweetView.appearance().theme = .light
        self.setupAutoScroll()
        self.setupTableView()
        //self.mediator.getLatestTweets(self.onLoadedTweets)
        
        NotificationCenter.default.addObserver(self,selector: #selector(TweetsTableViewController.onApplicationDidBecomeActive(_:)),name: NSNotification.Name.UIApplicationDidBecomeActive,object: nil)
        
        loginAsync()
        
        self.webViewForTweets.loadRequest(URLRequest(url: URL(string: "https://mobile.twitter.com/home")!))

    }
    
    func loginAsync(){
        Twitter.sharedInstance().logIn(withMethods: TWTRLoginMethod.webBased) { (session, error) -> Void in
            if let session = session {
                print("signed in as \(session.userName)");
                
                self.mediator.getLatestTweets(self.onLoadedTweets)
                
            } else {
                print("error: \(error!.localizedDescription)");
                
                //UNABLE TO LOG ON TO TWITTER> MAKE SURE YOU HAVE AN INTERNET CONNECTION AND HAVE SINGED INTO TWITTER IN YOU iPHONE SETTTINGS
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.webViewForWebLinks.frame = self.webViewController.view.bounds
        mediator.resetTweetsBelowActive(onLoadedTweets)
        autoScroller!.isScrollVisible = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        autoScroller!.isScrollVisible = false
    }
    
    @objc func onApplicationDidBecomeActive(_ notification: Notification){
        mediator.getLatestTweets(onLoadedTweets)
    }
    
    func setupAutoScroll(){
        autoScroller = AutoScroller(tableView: tableView!, onAutoScrollingToggled: self.setAutoScrollBarButtonImage)
        ffdBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fastForward, target: self, action: #selector(TweetsTableViewController.autoScroll(_:)))
        pauseBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.pause, target: self, action:  #selector(TweetsTableViewController.autoScroll(_:)))
    }

    func setupTableView(){
        tableView.estimatedRowHeight = 150
        //tableView.separatorColor = UIColor.grayColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tableView.separatorInset = UIEdgeInsets.zero

        //if #available(iOS 8.0, *) {
            tableView.layoutMargins = UIEdgeInsets.zero
        //}
        tableView.allowsSelection = true
        tableView.rowHeight = UITableViewAutomaticDimension // Explicitly set on iOS 8 if using automatic row height calculation
        tableView.allowsSelection = false
        tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: tweetTableReuseIdentifier)
        //tableView.backgroundColor = UIColor.darkGrayColor()
    }
    
    func onLoadedTweets(_ error : NSError?, deletedIndexes: CountableRange<Int>?, insertedIndexes: CountableRange<Int>?){
        if let err = error{
            print("Error downloading tweets \(err)")
            handleAuthorisationError(err)
            return;
        }
        self.tableView.beginUpdates()

        if let deleted = deletedIndexes{
            self.tableView.deleteRows(at: Array(deleted).map{IndexPath(row: $0, section: 0)}, with: .none)
        }
        if let inserted = insertedIndexes{
            self.tableView.insertRows(at: Array(inserted).map{IndexPath(row: $0, section: 0)}, with: .none)
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
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: false)
    }
    
    func handleAuthorisationError(_ error : NSError){
        if error.localizedDescription.range(of: "401") != nil{
            //TODO how do I logout with the new SDK
            //OLD one was: Twitter.sharedInstance().logOut()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: UITableViewDelegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mediator.tweets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if ((indexPath as NSIndexPath).row > mediator.tweets.count - 1){
            return UITableViewCell()
        }
        
        let tweet = mediator.tweets[(indexPath as NSIndexPath).row]
        
        mediator.alreadyReadTweets.markAsReading(tweet)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tweetTableReuseIdentifier, for: indexPath) as? TweetTableViewCell
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
    
    func configureCell(_ cell : TweetTableViewCell, tweet : Tweet){
        cell.configWithTweet(tweet)
        cell.tweetView.delegate = self
        cell.separatorInset = UIEdgeInsets.zero

            //if #available(iOS 8.0, *) {
                cell.layoutMargins = UIEdgeInsets.zero
            //}
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let tweetCell = cell as? TweetTableViewCell{
            self.tempLoadedCells.append(tweetCell)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((indexPath as NSIndexPath).row > mediator.tweets.count - 1){
            return 1
        }
        let tweet = mediator.tweets[(indexPath as NSIndexPath).row]
        return TweetTableViewCell.height(for: tweet, style: TWTRTweetViewStyle.compact, width: self.view.bounds.width, showingActions: true)
    }
    

    func tweetView(_ tweetView: TWTRTweetView, didTap url: URL) {

        
        let webViewForWebLinks = UIWebView(frame: self.webViewControllerForWebLinks.view.bounds)
        webViewForWebLinks.loadRequest(URLRequest(url: url))
        webViewControllerForWebLinks.view = webViewForWebLinks
        webViewControllerForWebLinks.navigationItem.title = url.host
        
        self.navigationController!.pushViewController(self.webViewControllerForWebLinks, animated: true)
        
        let progressView = WebViewProgressView(webView: webViewForWebLinks)
        delegateForProgressForWebLinks = WebViewDelegateForProgress()
        delegateForProgressForWebLinks.viewController = self.webViewControllerForWebLinks
        webViewForWebLinks.delegate = delegateForProgressForWebLinks
        delegateForProgressForWebLinks.progressView = progressView
        webViewForWebLinks.addSubview(progressView)
        
    }
    
    
    func tweetView(_ tweetView: TWTRTweetView, shouldDisplay controller: TWTRTweetDetailViewController) -> Bool {
        let tweetURL = controller.tweet.permalink
        
        webViewForTweets.loadRequest(URLRequest(url: tweetURL))
        self.webViewControllerForTweets.navigationItem.title = "Tweet"
        self.navigationController!.pushViewController(self.webViewControllerForTweets, animated: true)
        
        let progressView = WebViewProgressView(webView: webViewForTweets)
        delegateForProgressForTweets = WebViewDelegateForProgress()
        webViewForTweets.delegate = delegateForProgressForTweets
        delegateForProgressForTweets.progressView = progressView
        webViewForTweets.addSubview(progressView)
        
        return false;
    }
    


    func setAutoScrollBarButtonImage(){
        navigationItem.rightBarButtonItems =  autoScroller!.isAutoScrolling ? [pauseBarButton!] : [ffdBarButton!]
    }
    
    @IBAction func autoScroll(_ sender: AnyObject) {
        autoScroller!.toggleAutoScroll()
    }
    
    @IBAction func openPreferences(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "preferences", sender: self)
    }
}
