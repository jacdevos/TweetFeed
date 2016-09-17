import UIKit


class AutoScroller : NSObject{
    private static let defaultScrollSpeed : Float = 0.014 //>0.01 is fast, 0.05 very slow
    
    var isScrollVisible = true{
        didSet {
            autoScrollAfterInterval()
        }
    }
    
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
        if !isAutoScrolling || !isScrollVisible{
            return
        }
        NSTimer.scheduledTimerWithTimeInterval(Double(scrollSpeed()), target: self, selector:#selector(AutoScroller.scrollByOnePointOnTimer), userInfo: nil, repeats: false)
    }
    
    func scrollSpeed() -> Float{
        let scrollSpeedUserAdjustment
            = UserPreferences.instance.autoScrollSpeed > 0
                ? -UserPreferences.instance.autoScrollSpeed * 0.01
                : -UserPreferences.instance.autoScrollSpeed * 0.02
        
        return AutoScroller.defaultScrollSpeed + scrollSpeedUserAdjustment
    }
}
