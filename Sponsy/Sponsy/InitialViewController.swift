//
//  ViewController.swift
//  Sponsy
//
//  Created by Ivan Komar on 8/23/18.
//  Copyright © 2018 Ivan Komar. All rights reserved.
//

import UIKit
import WebKit
import SystemConfiguration

class InitialViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet var shadow_bg: UIView!
    @IBOutlet var proceed_button: UIButton!
    @IBOutlet var proceed_button_new: UIButton!
    @IBOutlet var motto_label: UILabel!
    @IBOutlet var notification_label: UILabel!
    @IBOutlet var gradient_view: UIView!
    @IBOutlet var notification_view: UIView!
    @IBOutlet var shadow_new_center_x: NSLayoutConstraint!
    @IBOutlet var shadow_new_center_y: NSLayoutConstraint!
    @IBOutlet var gradient_new_bottom: NSLayoutConstraint!
    @IBOutlet var notification_new_appears: NSLayoutConstraint!
    
    var webView: WKWebView!
    var loading_timer: Timer!
    var gradient_layer: CAGradientLayer!
    
    let ANIMATE_STEP_1: TimeInterval = 0.7
    let ANIMATE_STEP_2: TimeInterval = 0.3
    let ANIMATE_SHOWING_WEBVIEW: TimeInterval = 0.35
    let ANIMATE_SHOWING_NOTIFICATION: TimeInterval = 0.25
    let ANIMATE_SHOWING_NOTIFICATION_DELAY: TimeInterval = 2.25
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearCache()
        let web_config = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRect.zero, configuration: web_config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.alpha = 0.0
        webView.isUserInteractionEnabled = true
        view.addSubview(webView)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func clearCache() {
        if #available(iOS 9.0, *)
        {
            let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
            let date = NSDate(timeIntervalSince1970: 0)
            
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
        }
        else
        {
            var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
            libraryPath += "/Cookies"
            
            do {
                try FileManager.default.removeItem(atPath: libraryPath)
            } catch {
                print("error")
            }
            URLCache.shared.removeAllCachedResponses()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gradient_layer = CAGradientLayer()
        gradient_layer.colors = [UIColor.init(red: 237/255, green: 15/255, blue: 15/255, alpha: 1.0).cgColor, UIColor.init(red: 173/255, green: 13/255, blue: 13/255, alpha: 1.0).cgColor]
        gradient_layer.startPoint = CGPoint(x: 0.05, y: 0.95)
        gradient_layer.endPoint = CGPoint(x: 0.85, y: 0.10)
        gradient_layer.frame = gradient_view.bounds
        gradient_layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        gradient_view.layer.insertSublayer(gradient_layer, at: 0)
        gradient_view.layoutSubviews()
        view.addSubview(gradient_view)
        notification_view.layer.cornerRadius = 10.0
        shadow_bg.layer.masksToBounds = false
        self.shadow_bg.layer.shadowPath = UIBezierPath(rect: self.shadow_bg.bounds.insetBy(dx: -6, dy: -6)).cgPath
        self.shadow_bg.layer.shadowColor = UIColor.black.cgColor
        self.shadow_bg.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.shadow_bg.layer.shadowOpacity = 0.0
        shadow_bg.layer.cornerRadius = 10.0
        shadow_bg.layer.zPosition = 14
        shadow_bg.layoutSubviews()
        gradient_view.layer.zPosition = 10
        proceed_button.layer.cornerRadius = 9.0
        proceed_button_new.layer.cornerRadius = 9.0
        motto_label.layoutIfNeeded()
        let shadow_anim = CABasicAnimation(keyPath: "shadowOpacity")
        shadow_anim.fromValue = Float(0.0)
        shadow_anim.toValue = Float(0.3)
        shadow_anim.duration = ANIMATE_STEP_1
        shadow_anim.fillMode = kCAFillModeForwards
        shadow_anim.isRemovedOnCompletion = false
        notification_view.layer.zPosition = 101
        shadow_bg.layer.add(shadow_anim, forKey: "shadowOpacity")
        UIView.animate(withDuration: self.ANIMATE_STEP_1, animations: {
            self.shadow_new_center_x.priority = UILayoutPriority.init(999)
            self.shadow_new_center_y.priority = UILayoutPriority.init(999)
            self.gradient_new_bottom.priority = UILayoutPriority.init(999)
            self.view.layoutIfNeeded()
            self.view.layoutSubviews()
            self.gradient_view.layoutSubviews()
            self.gradient_layer.layoutIfNeeded()
            let grad_frame_anim = CABasicAnimation(keyPath: "bounds")
            grad_frame_anim.fromValue = NSValue(cgRect: self.gradient_layer.bounds)
            grad_frame_anim.toValue = NSValue(cgRect: self.gradient_view.bounds)
            grad_frame_anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            grad_frame_anim.duration = self.ANIMATE_STEP_1
            grad_frame_anim.fillMode = kCAFillModeForwards
            grad_frame_anim.isRemovedOnCompletion = false
            self.gradient_layer.add(grad_frame_anim, forKey: "bounds")
            self.gradient_layer.frame = self.gradient_view.bounds
        }, completion: {(fin:Bool) in
            UIView.animate(withDuration: self.ANIMATE_STEP_2, animations: {
                self.motto_label.alpha = 1.0
                self.proceed_button.alpha = 1.0
                UIView.animate(withDuration: 0.45, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
                    self.proceed_button_new.transform = CGAffineTransform.init(scaleX: 1.15, y: 1.15)
                }, completion: nil)
            })
        })
        let sponsy_mvp_url = URL(string: "http://mvp.sponsy.org")!
        let sponsy_mvp_request = URLRequest(url: sponsy_mvp_url)
        webView.load(sponsy_mvp_request)
        var topSafeArea: CGFloat
        var bottomSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            topSafeArea = view.safeAreaInsets.top
            bottomSafeArea = view.safeAreaInsets.bottom
        } else {
            topSafeArea = topLayoutGuide.length
            bottomSafeArea = bottomLayoutGuide.length
        }
        webView.frame = CGRect(x: 0, y: topSafeArea, width: view.bounds.width, height: view.bounds.height - topSafeArea - bottomSafeArea)
        print(webView.frame)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func proceedButtonTouchedDown(sender: UIButton) {
        sender.alpha = 0.8
    }
    
    @IBAction func proceedButtonTouchedUp(sender: UIButton) {
        sender.alpha = 1.0
    }
    
    @IBAction func proceedButtonOld(sender: UIButton) {
        present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "head_navigation_controller"), animated: true, completion: nil)
        self.proceed_button_new.layer.removeAllAnimations()
    }
    
    @IBAction func proceedButton(sender: UIButton) {
        self.proceed_button_new.layer.removeAllAnimations()
        sender.alpha = 1.0
        let grad_frame_anim = CABasicAnimation(keyPath: "bounds")
        grad_frame_anim.fromValue = NSValue(cgRect: self.gradient_layer.bounds)
        grad_frame_anim.toValue = NSValue(cgRect: self.gradient_view.bounds)
        grad_frame_anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        grad_frame_anim.duration = self.ANIMATE_SHOWING_WEBVIEW
        grad_frame_anim.fillMode = kCAFillModeForwards
        grad_frame_anim.isRemovedOnCompletion = false
        self.gradient_layer.add(grad_frame_anim, forKey: "bounds")
        UIView.animate(withDuration: ANIMATE_SHOWING_WEBVIEW, animations: {
            self.shadow_bg.alpha = 0.0
            self.motto_label.alpha = 0.0
            self.gradient_new_bottom.priority = UILayoutPriority.init(998)
            self.view.layoutSubviews()
            self.view.layoutIfNeeded()
            self.webView.alpha = 1.0
            self.webView.layer.zPosition = 100
            self.view.bringSubview(toFront: self.webView)
            
        }, completion: {(fin:Bool) in
            print("Progress = \(self.webView.estimatedProgress)")
            if !Reachability.isConnectedToNetwork() {
                let alert_load = UIAlertController(title: "Troubles loading the web app", message: "Check your Internet connection and press 'Continue'", preferredStyle: UIAlertControllerStyle.alert)
                alert_load.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: {(act:UIAlertAction) in
                    self.loading_timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.checkLoading), userInfo: nil, repeats: true)
                    alert_load.dismiss(animated: true, completion: nil)
                }))
                self.present(alert_load, animated: true, completion: nil)
            }
            else if self.webView.estimatedProgress < 0.70 {
                print("showing progress")
                self.notification_label.text = "Please wait; \(Int(self.webView.estimatedProgress * 100))% loaded"
                UIView.animate(withDuration: self.ANIMATE_SHOWING_NOTIFICATION, animations: {
                    self.notification_new_appears.priority = UILayoutPriority.init(999)
                    self.view.layoutIfNeeded()
                    self.view.layoutSubviews()
                })
                UIView.animate(withDuration: self.ANIMATE_SHOWING_NOTIFICATION, delay: self.ANIMATE_SHOWING_NOTIFICATION + self.ANIMATE_SHOWING_NOTIFICATION_DELAY, options: .curveEaseInOut, animations: {
                    self.notification_new_appears.priority = UILayoutPriority.init(997)
                    self.view.layoutIfNeeded()
                    self.view.layoutSubviews()
                }, completion: nil)
            }
        })
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    @objc func checkLoading(sender: Timer!) {
        let sponsy_mvp_url = URL(string: "http://mvp.sponsy.org")!
        let sponsy_mvp_request = URLRequest(url: sponsy_mvp_url)
        self.webView.load(sponsy_mvp_request)
        print(webView.isLoading)
        if Reachability.isConnectedToNetwork() {
            loading_timer.invalidate()
            self.notification_label.text = "Please wait; \(Int(self.webView.estimatedProgress * 100))% loaded"
            UIView.animate(withDuration: self.ANIMATE_SHOWING_NOTIFICATION, animations: {
                self.notification_new_appears.priority = UILayoutPriority.init(999)
                self.view.layoutIfNeeded()
                self.view.layoutSubviews()
            })
            UIView.animate(withDuration: self.ANIMATE_SHOWING_NOTIFICATION, delay: self.ANIMATE_SHOWING_NOTIFICATION + self.ANIMATE_SHOWING_NOTIFICATION_DELAY, options: .curveEaseInOut, animations: {
                self.notification_new_appears.priority = UILayoutPriority.init(997)
                self.view.layoutIfNeeded()
                self.view.layoutSubviews()
            }, completion: nil)
        }
    }
    
    
}

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
}

