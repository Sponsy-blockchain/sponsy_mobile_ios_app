//
//  ViewController.swift
//  Haily
//
//  Created by Admin on 11.11.16.
//  Copyright © 2016 Vanoproduction. All rights reserved.
//

import UIKit
import Foundation
import Kingfisher

class HeadViewController: UIViewController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    let NAVIGATION_BAR_COLOR_NORMAL:UIColor = UIColor(red: 200/255, green: 59/255, blue: 51/255, alpha: 1.0)
    let NAVIGATION_BAR_COLOR_LOGIN_PENDING:UIColor = UIColor(red: 255/255, green: 102/255, blue: 102/255, alpha: 1.0)
    let BOTTOM_BAR_HEIGHT:CGFloat = 50
    var settings_bar_button:UIBarButtonItem?
    var votes_update_bar_button:UIBarButtonItem?
    var CHILD_CONTENT_FRAME:CGRect!
    let TABS_SWITCH_ANIMATION_DURATION:CFTimeInterval = 0.15
    let CHALLENGE_BUTTON_TWITCH_VALUE:CGFloat = 10
    
    var view_appeared = false
    var should_show_challenge = false
    var current_shown_tab_vc:Int = 0
    var anim_controller:DetailTopicAnimationController = DetailTopicAnimationController()
    var bottom_bar:BottomTabBar!
    var tabs_content_vc:[ChildTabViewController?] = [nil,nil,nil,nil]
    //var bottom_menu:BottomMenu!

    override func viewDidLoad() {
        super.viewDidLoad()
        settings_bar_button = UIBarButtonItem(image: UIImage(named: "settings_icon")!, style: .plain, target: self, action: #selector(HeadViewController.settingsPressed(_:)))
        votes_update_bar_button = UIBarButtonItem(image: UIImage(named: "votes_update_icon")!, style: .plain, target: self, action: #selector(HeadViewController.votesUpdatePressed))
        NotificationCenter.default.addObserver(self, selector: #selector(HeadViewController.openEvent(_:)), name: NSNotification.Name(rawValue: "notification_open_event"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HeadViewController.openSponsor(_:)), name: NSNotification.Name(rawValue: "notification_open_sponsor"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HeadViewController.openLister(_:)), name: NSNotification.Name(rawValue: "notification_open_lister"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HeadViewController.showTroublesSlider(_:)), name: NSNotification.Name(rawValue: "notification_show_troubles_slider"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HeadViewController.presentLoginScreen(_:)), name: Notification.Name.init("notification_show_login"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HeadViewController.statusBarChanged), name: Notification.Name.init("status_changed"), object: nil)
        navigationController!.delegate = self
        navigationController!.navigationBar.barStyle = UIBarStyle.black
        navigationController!.navigationBar.tintColor = UIColor.white
        navigationController!.navigationBar.barTintColor = NAVIGATION_BAR_COLOR_NORMAL
        navigationController!.navigationBar.isTranslucent = false
        navigationController!.navigationBar.backgroundColor = NAVIGATION_BAR_COLOR_NORMAL
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController!.navigationBar.shadowImage = UIImage()
        navigationController!.interactivePopGestureRecognizer?.delegate = self
        navigationItem.title = "Sponsess"
        anim_controller.navController = self.navigationController!
        bottom_bar = BottomTabBar(frame: CGRect(x: 0, y: view.bounds.height - BOTTOM_BAR_HEIGHT - navigationController!.navigationBar.frame.maxY, width: view.bounds.width, height: BOTTOM_BAR_HEIGHT))
        bottom_bar.addTarget(self, action: #selector(HeadViewController.tabChanged(_:)), for: .valueChanged)
        view.addSubview(bottom_bar)
        tabs_content_vc[0] = storyboard!.instantiateViewController(withIdentifier: "topics_opinions_explorer_vc") as! ChildTabViewController
        tabs_content_vc[0]!.paradigm_type = "events"
        CHILD_CONTENT_FRAME = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - bottom_bar.bounds.height)
        tabs_content_vc[0]?.view.frame = CHILD_CONTENT_FRAME
       // tabs_content_vc[0]?.view.layer.borderWidth = 2.0
        addChildViewController(tabs_content_vc[0]!)
        view.addSubview(tabs_content_vc[0]!.view)
        tabs_content_vc[0]!.didMove(toParentViewController: self)
        tabs_content_vc[0]!.view.setNeedsDisplay()
        tabs_content_vc[0]!.prepareContent()
        tabs_content_vc[1] = storyboard!.instantiateViewController(withIdentifier: "topics_opinions_explorer_vc") as! ChildTabViewController
        tabs_content_vc[1]!.paradigm_type = "sponsors"
        tabs_content_vc[1]?.view.frame = CHILD_CONTENT_FRAME
        tabs_content_vc[1]?.view.isHidden = true
        tabs_content_vc[1]?.view.alpha = 0.0
        addChildViewController(tabs_content_vc[1]!)
        view.addSubview(tabs_content_vc[1]!.view)
        tabs_content_vc[1]!.didMove(toParentViewController: self)
        tabs_content_vc[1]!.view.setNeedsDisplay()
        tabs_content_vc[1]!.prepareContent()
        tabs_content_vc[2] = storyboard!.instantiateViewController(withIdentifier: "explore_vc") as! ChildTabViewController
        tabs_content_vc[2]?.view.frame = CHILD_CONTENT_FRAME
        tabs_content_vc[2]?.view.isHidden = true
        tabs_content_vc[2]?.view.alpha = 0.0
        addChildViewController(tabs_content_vc[2]!)
        view.addSubview(tabs_content_vc[2]!.view)
        tabs_content_vc[2]!.didMove(toParentViewController: self)
        tabs_content_vc[2]!.view.setNeedsDisplay()
        tabs_content_vc[3] = storyboard!.instantiateViewController(withIdentifier: "requests_vc") as! ChildTabViewController
       tabs_content_vc[3]?.view.frame = CHILD_CONTENT_FRAME
       tabs_content_vc[3]?.view.isHidden = true
        tabs_content_vc[3]?.view.alpha = 0.0
        addChildViewController(tabs_content_vc[3]!)
        view.addSubview(tabs_content_vc[3]!.view)
        tabs_content_vc[3]!.didMove(toParentViewController: self)
        tabs_content_vc[3]!.view.setNeedsDisplay()
        view.bringSubview(toFront: bottom_bar)
        //should initiate initial data loading
        NotificationCenter.default.post(name: Notification.Name.init(rawValue: "notification_initial_request"), object: nil, userInfo: ["fullRequest":true])
        
      //  let _ = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "demoTroubles:", userInfo: true, repeats: false)
      //  let _ = NSTimer.scheduledTimerWithTimeInterval(11.0, target: self, selector: "demoTroubles:", userInfo: false, repeats: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view_appeared = true
    }
    
    func statusBarChanged(sender: Notification) {
        let delta_y = sender.userInfo!["deltaY"] as! CGFloat
        UIView.animate(withDuration: 0.5, animations: {
            self.bottom_bar.center.y += delta_y
            for tabVc in self.tabs_content_vc {
                if let _tab_vc = tabVc {
                    let initial_frame = _tab_vc.view.frame
                    _tab_vc.view.frame = CGRect(x: initial_frame.minX, y: initial_frame.minY, width: initial_frame.width, height: initial_frame.height + delta_y)
                }
            }
        })
    }
    
    func votesUpdatePressed(sender:UIBarButtonItem) {
        NotificationCenter.default.post(name: Notification.Name.init("notification_update_votings"), object: nil, userInfo: nil)
    }
    
    func showTroublesSlider(_ sender:Notification) {
        let info = sender.userInfo!
        setTroublesShown(info["shown"] as! Bool, withType: TroubleTopSliderType(rawValue: info["slider_type"] as! Int)!, withText: info["slider_text"] as! String, withColor: TroubleTopSliderColor(rawValue: info["slider_color"] as! Int)!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("head vc appeared")
       // NSNotificationCenter.defaultCenter().addObserver(self, selector: "openTopic:", name: "notification_open_topic", object: nil)
    }
    

    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        print("asking for RECOGNIZER pop gesture vc")
        print("stack now is \(navigationController?.viewControllers)")
        return navigationController?.viewControllers.count ?? 0 > 1
    }
    
    func setTroublesShown(_ shown:Bool, withType:TroubleTopSliderType, withText:String, withColor:TroubleTopSliderColor) {
        if shown == General.troubles_internet && withType == TroubleTopSliderType.constant {
            return
        }
        if withType == TroubleTopSliderType.constant {
            General.troubles_internet = shown
        }
        if let visible_vc = navigationController?.visibleViewController {
            if shown {
                let troubles_slider = TroubleTopSlider(width: visible_vc.view.bounds.width, sliderType: withType, sliderText: withText, sliderColor: withColor)
                visible_vc.view.addSubview(troubles_slider)
                troubles_slider.setSliderShown(true, animated: true)
            }
            else {
                for view in visible_vc.view.subviews {
                    if view.isKind(of: TroubleTopSlider.self) {
                        if (view as! TroubleTopSlider).slider_type == TroubleTopSliderType.constant {
                            (view as! TroubleTopSlider).setSliderShown(false, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    //only adding troubles with internet slider here
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        print("will show vc \(viewController)")
        var trouble_present = false
        var trouble_view:TroubleTopSlider? = nil
        for view in viewController.view.subviews {
            if view.isKind(of: TroubleTopSlider.self) {
                if (view as! TroubleTopSlider).slider_type == TroubleTopSliderType.constant {
                    trouble_present = true
                    trouble_view = view as! TroubleTopSlider
                }
            }
        }
        if General.troubles_internet && !trouble_present {
            let trouble_slider = TroubleTopSlider(width: viewController.view.bounds.width, sliderType: TroubleTopSliderType.constant, sliderText: "Troubles with internet!", sliderColor: TroubleTopSliderColor.red)
            viewController.view.addSubview(trouble_slider)
            trouble_slider.setSliderShown(true, animated: false)
        }
        if !General.troubles_internet && trouble_present {
            trouble_view!.setSliderShown(false, animated: false)
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        print("calling animation controller with FROM = \(fromVC)")
        print("calling animation controller with TO = \(toVC)")
        print("having stack")
        print(navigationController.viewControllers)
        //navigationController.interactivePopGestureRecognizer?.delegate = self
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        print("Asking for interactive controller ")
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        print("did show vc \(viewController)")
    }
    
    func openTopic(_ sender:Notification) {
        
        
    }
    
    func openLister(_ sender:Notification) {
        let lister_vc = storyboard!.instantiateViewController(withIdentifier: "topics_opinions_lister_vc") as! TopicsOpinionsLister
        let user_info = sender.userInfo!
        lister_vc.prepareListerWithTitle(user_info["title"] as! String, paradigm: user_info["paradigm"] as! LoadableParadigm, emptyText: "Nothing to show here", addButtonRequired: false, topicsStyle: nil)
        navigationController!.pushViewController(lister_vc, animated: true)
    }
    
    
    func presentLoginScreen(_ sender:Notification) {
        let login_vc = self.storyboard!.instantiateViewController(withIdentifier: "login_vc") as! LoginViewController
        present(login_vc, animated: true, completion: nil)
    }
    
    

    func setNavigationItemTitleWithSelectedTab(_ tab:Int) {
        var navigation_title = ""
        switch tab {
        case 0:
            navigation_title = "Sponsees"
        case 1:
            navigation_title = "Sponsors"
        case 2:
            navigation_title = "Voting"
        case 3:
            navigation_title = "Requests"
        default:
            break
        }
        navigationItem.title = navigation_title
    }
    
    func tabChanged(_ sender:BottomTabBar) {
        setNavigationItemTitleWithSelectedTab(sender.selected_tab - 1)
        if sender.selected_tab == 4 {
            showProfileBarButtons()
        }
        if sender.selected_tab == 3 {
            showVotesBarButton(true)
            NotificationCenter.default.post(name: Notification.Name.init("notification_votes_tutorial"), object: nil, userInfo: nil)
        }
        if sender.selected_tab != 4 && sender.selected_tab != 3 {
            hideProfileBarButton()
        }
        let new_shown_tab_vc = sender.selected_tab - 1
        tabs_content_vc[new_shown_tab_vc]!.view.isHidden = false
        UIView.animate(withDuration: TABS_SWITCH_ANIMATION_DURATION, animations: {
            self.tabs_content_vc[self.current_shown_tab_vc]!.view.alpha = 0.0
            self.tabs_content_vc[new_shown_tab_vc]!.view.alpha = 1.0
            }, completion: {
                (fin:Bool) in
                self.tabs_content_vc[self.current_shown_tab_vc]!.view.isHidden = true
                self.current_shown_tab_vc = new_shown_tab_vc
        })
    }
    
    func showVotesBarButton(_ show:Bool) {
        navigationItem.setRightBarButton(show ? votes_update_bar_button : nil, animated: false)
    }
    
    func showProfileBarButtons() {
        navigationItem.setRightBarButton(settings_bar_button, animated: false)
        
    }
    
    func hideProfileBarButton() {
        navigationItem.setRightBarButton(nil, animated: false)
    }
    
        
    func settingsPressed(_ sender:UIBarButtonItem) {
        let settings_vc = self.storyboard!.instantiateViewController(withIdentifier: "settings_vc")
        present(settings_vc, animated: true, completion: nil)
    }
    
    func openEvent(_ sender:Notification) {
        var event_id:Int = -1
        var event_title = ""
        let event_vc = self.storyboard!.instantiateViewController(withIdentifier: "event_detail_vc") as! DetailedEventViewController
        let userInfo = sender.userInfo!
        switch userInfo["origin"] as! String {
        case "event":
            let event_data = userInfo["eventData"] as! SponsyEvent
            event_id = event_data.event_id
            event_title = event_data.title
        case "voting":
            let voting_data = userInfo["votingData"] as! SponsyVote
            event_id = voting_data.event_id
            event_title = voting_data.event_title
        case "request":
            let request_data = userInfo["requestData"] as! SponsyRequest
            event_id = request_data.party_id
            event_title = request_data.title
        default:
            break
        }
        event_vc.prepareWith(eventId: event_id, eventTitle: event_title)
        navigationController!.pushViewController(event_vc, animated: true)
    }
    
    func openSponsor(_ sender:Notification) {
        var sponsor_id:Int = -1
        var sponsor_title = ""
        let userInfo = sender.userInfo!
        let sponsor_vc = self.storyboard!.instantiateViewController(withIdentifier: "sponsor_detail_vc") as! DetailedSponsorViewController
        switch userInfo["origin"] as! String {
        case "sponsor":
            let sponsor_data = userInfo["sponsorData"] as! SponsySponsor
            sponsor_id = sponsor_data.sponsor_id
            sponsor_title = sponsor_data.title
        case "voting":
            let voting_data = userInfo["votingData"] as! SponsyVote
            sponsor_id = voting_data.sponsor_id
            sponsor_title = voting_data.sponsor_title
        case "request":
            let request_data = userInfo["requestData"] as! SponsyRequest
            sponsor_id = request_data.party_id
            sponsor_title = request_data.title
        default:
            break
        }
        sponsor_vc.prepareWith(sponsorId: sponsor_id, sponsorTitle: sponsor_title)
        print("prepared sponsor with sponsor id \(sponsor_id)")
        navigationController!.pushViewController(sponsor_vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

