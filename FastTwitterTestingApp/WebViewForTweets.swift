//
//  WebViewDelegate.swift
//  SpeedTweetRead
//
//  Created by jacdevos on 2016/06/12.
//  Copyright © 2016 nReality. All rights reserved.
//

import UIKit

class WebViewDelegateForProgress: NSObject, UIWebViewDelegate{
    var progressView : WebViewProgressView?
    var viewController : UIViewController?
    
    func webViewDidStartLoad(webView_Pages: UIWebView) {
        // webViewProgressView.hidden = false;
    }
    
    internal func webViewDidFinishLoad(webView: UIWebView){
        if let vc = viewController{
            vc.navigationItem.title = webView.request?.URL?.host
        }
    
        if let pv = progressView{
            pv.removeFromSuperview()
        }
    }
}

class WebViewProgressView: UIView {
    
    
    init(webView : UIView){
        super.init(frame : CGRect(x: webView.frame.width/2 - 40, y: webView.frame.height/2 - 40, width: 80, height: 80))
        // Box config:
        self.removeFromSuperview()
        self.backgroundColor = UIColor.blackColor()
        self.alpha = 0.7
        self.layer.cornerRadius = 10
        
        
        // Text config:
        let textLabel = UILabel(frame: CGRect(x: 0, y: 50, width: 80, height: 30))
        textLabel.textColor = UIColor.whiteColor()
        textLabel.textAlignment = .Center
        textLabel.font = UIFont(name: textLabel.font.fontName, size: 13)
        textLabel.text = "Loading..."
        
        // Spin config:
        
        let webViewActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        webViewActivityIndicatorView.frame = CGRect(x: 20, y: 12, width: 40, height: 40)
        webViewActivityIndicatorView.hidesWhenStopped = true
        webViewActivityIndicatorView.startAnimating()
        
        
        // Activate:
        self.addSubview(webViewActivityIndicatorView)
        self.addSubview(textLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
