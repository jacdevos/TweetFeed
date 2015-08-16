import UIKit


class AutoScroller : NSObject{
    var isAutoScrolling = false {
        didSet {
            //TODO event self.setAutoScrollBarButtonImage()
            self.onAutoScrollingToggledCallback()
        }
    }
    
    let tableView : UITableView
    let onAutoScrollingToggledCallback : () -> Void
    
    init(tableView :UITableView, onAutoScrollingToggled: () -> Void ){
        self.tableView = tableView
        self.onAutoScrollingToggledCallback = onAutoScrollingToggled
    }
    
    func scrollByOnePointOnTimer() {
        self.tableView.setContentOffset(CGPoint(
            x:self.tableView.contentOffset.x,
            y: self.tableView.contentOffset.y + 1),//add one point, more than than makes it appear to jump
            animated: false)//need to switch animation off for smooth scrolling
        
        if isAutoScrolling{
            self.autoScrollAfterInterval()
            
            if self.tableView.contentOffset.y > self.tableView.contentSize.height - 500{
                isAutoScrolling = false
            }
        }
    }

    
    func toggleAutoScroll() {
        isAutoScrolling = !isAutoScrolling
        
        self.autoScrollAfterInterval()
    }
    
    func autoScrollAfterInterval(){
        if !isAutoScrolling{
            return
        }
        
        var scrollSpeed = 0.014 //>0.01 is fast, 0.05 very slow

        NSTimer.scheduledTimerWithTimeInterval(scrollSpeed, target: self, selector:"scrollByOnePointOnTimer", userInfo: nil, repeats: false)
    }
}