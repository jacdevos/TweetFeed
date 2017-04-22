
import UIKit
import TwitterKit

class TweetsTableViewController: UITableViewController, TWTRTweetViewDelegate, UIPopoverPresentationControllerDelegate {
     let settingsButton = UIButton(type: UIButtonType.roundedRect)
    let mediator = TweetMediator()
    let tweetTableReuseIdentifier = "TweetCell"
    var tempLoadedCells : [TweetTableViewCell] = []
    let autoScrollerButton = UIButton(type: UIButtonType.roundedRect)
    var autoScroller : AutoScroller?
    @IBOutlet weak var autoScrollBarButton: UIBarButtonItem!
    var ffdBarButton : UIBarButtonItem? = nil
    var pauseBarButton : UIBarButtonItem? = nil
    let webViewControllerForTweets = UIViewController()
    let webViewForTweets : UIWebView
    var delegateForProgressForTweets  : WebViewDelegateForProgress

    required init?(coder aDecoder: NSCoder) {
        self.webViewForTweets = UIWebView(frame: self.webViewControllerForTweets.view.bounds)
        delegateForProgressForTweets = WebViewDelegateForProgress()
        super.init(coder: aDecoder)
        self.webViewControllerForTweets.view = self.webViewForTweets
    }
    
    override func viewDidLoad() {
        TWTRTweetView.appearance().theme = .light
        self.setupAutoScroll()
        self.setupTableView()
        NotificationCenter.default.addObserver(self,selector: #selector(TweetsTableViewController.onApplicationDidBecomeActive(_:)),name: NSNotification.Name.UIApplicationDidBecomeActive,object: nil)
        self.webViewForTweets.loadRequest(URLRequest(url: URL(string: "https://mobile.twitter.com/home")!))
        self.mediator.getLatestTweets(self.onLoadedTweets)
        addFloatingButtons()
    }
    
    @objc func onApplicationDidBecomeActive(_ notification: Notification){
        mediator.getLatestTweets(onLoadedTweets)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTweets()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        autoScroller!.isScrollVisible = false
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        stickFloatingButtonToScroll(scrollView, floating: self.autoScrollerButton)
        stickFloatingButtonToScroll(scrollView, floating: self.settingsButton)
    }
}

//Integration with Twitter logic extention
extension TweetsTableViewController{
    
    func refreshTweets(){
        if (!mediator.isLoggedIn()){
            mediator.clearTweets()
            self.tableView.reloadData()
            mediator.getLatestTweets(onLoadedTweets)
        }else{
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.mediator.resetTweetsBelowActive(self.onLoadedTweets)
            }
        }
        autoScroller!.isScrollVisible = true
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

    }
    
    func handleAuthorisationError(_ error : NSError){
        if error.localizedDescription.range(of: "401") != nil || error.localizedDescription.range(of: "403") != nil{
            self.mediator.loginAsync(self.onLoadedTweets)
        }
    }
    
}

//UITableViewDelegate Methods extention
extension TweetsTableViewController{
    func setupTableView(){
        tableView.estimatedRowHeight = 150
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.allowsSelection = true
        tableView.rowHeight = UITableViewAutomaticDimension // Explicitly set on iOS 8 if using automatic row height calculation
        tableView.allowsSelection = false
        tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: tweetTableReuseIdentifier)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mediator.viewableTweets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if ((indexPath as NSIndexPath).row > mediator.viewableTweets.count - 1){
            return UITableViewCell()
        }
        
        let tweet = mediator.viewableTweets[(indexPath as NSIndexPath).row]
        
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
        cell.layoutMargins = UIEdgeInsets.zero

    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let tweetCell = cell as? TweetTableViewCell{
            self.tempLoadedCells.append(tweetCell)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((indexPath as NSIndexPath).row > mediator.viewableTweets.count - 1){
            return 1
        }
        let tweet = mediator.viewableTweets[(indexPath as NSIndexPath).row]
        return TweetTableViewCell.height(for: tweet, style: TWTRTweetViewStyle.compact, width: self.view.bounds.width, showingActions: true)
    }
}

//TWTRTweetViewDelegate Methods extention
extension TweetsTableViewController{
    func tweetView(_ tweetView: TWTRTweetView, didTap url: URL) {
        UIApplication.shared.openURL(url)
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
}

//Autoscroll interaction extention
extension TweetsTableViewController{
    func setupAutoScroll(){
        autoScroller = AutoScroller(tableView: tableView!, onAutoScrollingToggled: self.setAutoScrollBarButtonImage)
        ffdBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fastForward, target: self, action: #selector(TweetsTableViewController.autoScroll(_:)))
        pauseBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.pause, target: self, action:  #selector(TweetsTableViewController.autoScroll(_:)))
    }
    
    func autoScrollerButtonClicked() {
        autoScroller!.toggleAutoScroll()
    }
    
    func setAutoScrollBarButtonImage(){
        navigationItem.rightBarButtonItems =  autoScroller!.isAutoScrolling ? [pauseBarButton!] : [ffdBarButton!]
        
        if autoScroller!.isAutoScrolling {
            autoScrollerButton.setImage(UIImage(named: "pausecircle"), for: .normal)
        }else{
            autoScrollerButton.setImage(UIImage(named: "down"), for: .normal)
        }
    }
    
    @IBAction func autoScroll(_ sender: AnyObject) {
        autoScroller!.toggleAutoScroll()
    }
    
}

//Preferences interaction extention
extension TweetsTableViewController{

    @IBAction func openPreferences(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "preferences", sender: self)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "preferences" {
            let popoverViewController = segue.destination as! SettingsTableViewController;
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
            popoverViewController.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 300)
            popoverViewController.onDismiss = handlePopoverDismiss
            popoverViewController.refreshTweets = refreshTweets
            
            let popoverPresentationController = popoverViewController.popoverPresentationController! as UIPopoverPresentationController
            popoverPresentationController.delegate = self
            popoverPresentationController.sourceView = self.settingsButton
            popoverPresentationController.sourceRect = CGRect(x: 32, y: -5, width: 1, height: 1);
            popoverPresentationController.permittedArrowDirections = .down
            
            
            let dimView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.contentSize.height) )
            dimView.backgroundColor = .black
            dimView.alpha = 0.5
            dimView.tag = 1234
            dimView.isUserInteractionEnabled = false
            tableView.addSubview(dimView)
        }
    }
    
    func handlePopoverDismiss(){
        for subView in view.subviews {
            if subView.tag == 1234 {
                subView.removeFromSuperview()
            }
        }
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController){
        handlePopoverDismiss()
    }
}

//FloatingButtons extention
extension TweetsTableViewController{
    
    func addFloatingButtons(){
        autoScrollerButton.addTarget(self, action:#selector(self.autoScrollerButtonClicked), for: .touchUpInside)
        autoScrollerButton.setImage(UIImage(named: "down"), for: .normal)
        autoScrollerButton.frame = CGRect(x: self.view.frame.size.width - 55 - 5, y: self.view.frame.size.height - 55 - 5, width: 55, height: 55)
        autoScrollerButton.layer.shadowColor = UIColor.black.cgColor
        autoScrollerButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        autoScrollerButton.layer.shadowRadius = 1
        autoScrollerButton.layer.shadowOpacity = 0.7
        autoScrollerButton.layer.masksToBounds = false
        self.view.addSubview(autoScrollerButton)
        
        settingsButton.addTarget(self, action:#selector(self.openPreferences), for: .touchUpInside)
        settingsButton.setImage(UIImage(named: "SettingsIcon"), for: .normal)
        settingsButton.frame = CGRect(x: 5, y: self.view.frame.size.height - 55 - 5, width: 50, height: 50)
        settingsButton.layer.shadowColor = UIColor.black.cgColor
        settingsButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        settingsButton.layer.shadowRadius = 1
        settingsButton.layer.shadowOpacity = 0.7
        settingsButton.layer.masksToBounds = false
        self.view.addSubview(settingsButton)
    }
    
    func stickFloatingButtonToScroll(_ scrollView: UIScrollView, floating: UIView) {
        let y = scrollView.contentOffset.y + self.tableView.frame.size.height - floating.frame.size.height - 5
        let newFrame = CGRect(x: floating.frame.origin.x, y: y, width: floating.frame.size.width, height: floating.frame.size.height)
        floating.frame = newFrame
        self.view.bringSubview(toFront: floating)
    }
}
