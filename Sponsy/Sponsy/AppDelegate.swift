//
//  AppDelegate.swift
//  Sponsy
//
//  Created by Admin on 21.09.17.
//  Copyright © 2017 Vano Production. All rights reserved.
//

import UIKit
import UserNotifications
import Kingfisher
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate{
    
    let REGULAR_FEELINGS_UPDATE_TASK_PERIOD:CFTimeInterval = 40.0
    
    var window: UIWindow?
   // var bottom_menu:BottomMenu!
    var hint_view:HintView!
    var now_updaing_feelings = false
    var location_manager:CLLocationManager!
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print(UIFont.fontNames(forFamilyName: "Aquatico"))
        if #available(iOS 10.0, *) {
            let un_center = UNUserNotificationCenter.current()
            un_center.delegate = self
        } else {
            // Fallback on earlier versions
        }
        location_manager = CLLocationManager()
        location_manager.delegate = self
        print("Ssdfsdfsd")

       // NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.didPressOpenMenu(_:)), name: NSNotification.Name(rawValue: "notification_menu_pressed"), object: nil)
    //    NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.showHint(_:)), name: Notification.Name.init("notification_show_hint"), object: nil)
    //    NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.showBoldPopup(_:)), name: NSNotification.Name(rawValue: "notification_bold_popup"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.obtainInitialData(_:)), name: NSNotification.Name(rawValue: "notification_initial_request"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.updateLocation(sender:)), name: NSNotification.Name(rawValue: "notification_update_location"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.showHint(_:)), name: Notification.Name.init("notification_show_hint"), object: nil)
      //  NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.shareOwnTopic(_:)), name: NSNotification.Name(rawValue: "notification_share_own_topic"), object: nil)
      //  let _ = Timer.scheduledTimer(timeInterval: REGULAR_FEELINGS_UPDATE_TASK_PERIOD, target: self, selector: #selector(AppDelegate.updateFeelings(_:)), userInfo: nil, repeats: true)
        
        General.events_images_cache = ImageCache(name: "events_cache")
        General.events_images_cache.maxMemoryCost = UInt(30 * 1000 * 1000)
        General.events_images_cache.maxDiskCacheSize = UInt(30 * 1000 * 1000)
        General.events_images_cache.maxCachePeriodInSecond = TimeInterval(1 * 7 * 24 * 60 * 60)
        //General.topics_images_cache.clearDiskCache()
        General.sponsors_images_cache = ImageCache(name: "sponsors_cache")
        General.sponsors_images_cache.maxMemoryCost = UInt(20 * 1000 * 1000)
        General.sponsors_images_cache.maxDiskCacheSize = UInt(15 * 1000 * 1000)
        General.sponsors_images_cache.maxCachePeriodInSecond = TimeInterval(2 * 24 * 60 * 60)
        //General.profiles_images_cache.clearDiskCache()
        
        // NSUserDefaults().setObject(arch_t, forKey: "topics_favorite_ids")
        //NSUserDefaults().setObject(arch_op, forKey: "liked_opinions_ids")
        //NSUserDefaults().setObject(arch_us, forKey: "users_favorite_ids")
        //let arch_prof = NSKeyedArchiver.archivedData(withRootObject: my_default_profile)
        //NSUserDefaults().setObject(arch_prof, forKey: "my_own_profile")
        //UserDefaults().set(false, forKey: "tutorial_passed_0")
        //UserDefaults().set(false, forKey: "tutorial_passed_1")
        //UserDefaults().set(false, forKey: "tutorial_passed_2")
        //UserDefaults().set(false, forKey: "tutorial_passed_3")
        //UserDefaults().set(false, forKey: "tutorial_passed_4")
        //UserDefaults().set(false, forKey: "tutorial_passed_5")
        //UserDefaults().set(false, forKey: "personal_discussion_disabled")
        //UserDefaults().set(Date.init(timeInterval: -300000, since: Date()), forKey: "last_rate_proposal_date")
        let events_data_all:[SponsyEvent] = []
        let sponsors_data_all:[SponsySponsor] = []
        let arch_events_all = NSKeyedArchiver.archivedData(withRootObject: NSArray(array: events_data_all))
        let arch_sponsors_all = NSKeyedArchiver.archivedData(withRootObject: sponsors_data_all)
        UserDefaults.standard.register(defaults: ["tutorial_sponsor_passed":false,"tutorial_event_passed":false,"tutorial_votes_passed":false,"rules_accepted":false,"total_sessions":0,"challenge_notifications_disabled" : false, "events_all":arch_events_all,"sponsors_all":arch_sponsors_all])
        // tut 1 - detail vc first , tut 2 - detail vc second , tut 3 - profile, tut 4 - create new topic, tut 5 - discussion about user
        //UserDefaults().set([1,2,3,4], forKey: "topics_ads_types_allowed")
        // UserDefaults.standard.set(arch_t opics_trending, forKey: "topics_trending")
        //UserDefaults.standard.set(arch_topics_latest, forKey: "topics_latest")
        //UserDefaults.standard.set(arch_opinions_trending, forKey: "opinions_trending")
        //UserDefaults.standard.set(arch_opinions_latest, forKey: "opinions_latest")
  
        General.events_all = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.data(forKey: "events_all")!) as! [AnyObject]).map({$0 as! HailyInjectable})

        General.sponsors_all = (NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.data(forKey: "sponsors_all")!) as! [AnyObject]).map({$0 as! HailyInjectable})
        /*
        let trending_topics_last_value = UserDefaults().double(forKey: "topics_trending_last_value")
        let trending_opinions_last_value = UserDefaults().double(forKey: "opinions_trending_last_value")
        if trending_topics_last_value != nil || trending_opinions_last_value != nil {
            General.trendingLastValues = [String:Double]()
            if trending_topics_last_value != nil {
                General.trendingLastValues!["topics"] = trending_topics_last_value
            }
            if trending_opinions_last_value != nil {
                General.trendingLastValues!["opinions"] = trending_opinions_last_value
            }
        }
 */

        if let myProfileId = UserDefaults().object(forKey: "my_profile_id") as? Int {
            General.myProfileId = myProfileId
        }
        
        let session_data_config = URLSessionConfiguration.ephemeral
        let session_images_search_config = URLSessionConfiguration.ephemeral
        General.session_data = URLSession(configuration: session_data_config)
        General.authorized = UserDefaults().string(forKey: "auth_token") != nil

        UserDefaults().set(UserDefaults().integer(forKey: "total_sessions") + 1, forKey: "total_sessions")
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            General.current_location_array = [currentLocation.coordinate.longitude,currentLocation.coordinate.latitude]
            print("having location array")
            print(General.current_location_array!)
        }
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.locationServicesEnabled() {
                location_manager.startUpdatingLocation()
            }
        }
    }
    
    func application(_ application: UIApplication, didChangeStatusBarFrame oldStatusBarFrame: CGRect) {
        let delta_y = oldStatusBarFrame.height - application.statusBarFrame.height
        NotificationCenter.default.post(name: Notification.Name.init("status_changed"), object: nil, userInfo: ["deltaY":delta_y])
    }
    
    func updateLocation(sender:Notification) {
        if General.current_location_array != nil {
            return
        }
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            location_manager.requestWhenInUseAuthorization()
        case .denied , .restricted:
            print("location can not be determined due to app's restrictions!")
        default:
            if CLLocationManager.locationServicesEnabled() {
                location_manager.startUpdatingLocation()
            }
            else {
                print("Location error: location services are disabled!")
            }
        }
    }
    
    func showHint(_ sender:Notification) {
        let hintText = sender.userInfo!["hintText"] as? String
        let transparentHole = sender.userInfo!["transparentHole"] as? CGRect
        if hint_view == nil {
            hint_view = HintView(frame: window!.bounds)
            window!.addSubview(hint_view)
        }
        let handler_here = sender.userInfo!["hintTappedHandler"] as? (() -> Void)
        hint_view.setHintWithText(hintText: hintText, transparentHole ?? CGRect.zero, handler_here)
    }
    
    
    func obtainInitialData(_ sender:Notification) {
        let full_request = sender.userInfo!["fullRequest"] as! Bool
        let initial_tasks = HailyTaskBuilder(session: General.session_data, anonymous: false, degradePossible: true)
        let events_all_task = HailyReceiveTask(dataOrigin: HailyDataOrigin.event, dataType: HailyDataType.all)
        let events_own_task = HailyReceiveTask(dataOrigin: HailyDataOrigin.event, dataType: HailyDataType.own)
        let sponsors_all_task = HailyReceiveTask(dataOrigin: HailyDataOrigin.sponsor, dataType: HailyDataType.all)
        let sponsors_own_task = HailyReceiveTask(dataOrigin: HailyDataOrigin.sponsor, dataType: HailyDataType.own)
        let sync_task = HailySyncTask()
        initial_tasks.addTasks(full_request ? [events_all_task,events_own_task,sponsors_all_task,sponsors_own_task,sync_task] : [events_own_task,sponsors_own_task, sync_task])
        initial_tasks.sendTasksWithCompletionHandler({
            (parsedResponse:[HailyParsedResponse]?, error:Error?) in
            print("received initial response")
            if let _error = error {
                print("Having error \(_error)")
                DispatchQueue.main.async(execute: {
                  //  if let profileRefreshedCompletionHandler = sender.userInfo!["profileRefreshedCompletionHandler"] as? ((Bool) -> Void) {
                   //     profileRefreshedCompletionHandler(false)
                  //  }
                    NotificationCenter.default.post(kHailyDataRetrievalErrorSliderNotification)
                })
            }
            else if let responses = parsedResponse {
                //now should do wahever we need to handle requests - put new opinions, etc
                var responses_data_ends:[String:Bool] = [String:Bool]()
                for parsedResponse in responses {
                    switch parsedResponse.task {
                    case is HailyReceiveTask:
                        let receive_task = parsedResponse.task as! HailyReceiveTask
                        if receive_task.dataOrigin == HailyDataOrigin.sponsor && receive_task.dataType == HailyDataType.all {
                            if let sponsors = parsedResponse.sponsors {
                                if sponsors.count > 0 {
                                    General.sponsors_all = parsedResponse.sponsors!
                                    responses_data_ends["sponsors_all"] = parsedResponse.dataEnd
                                }
                            }
                        }
                        else if receive_task.dataOrigin == HailyDataOrigin.event && receive_task.dataType == HailyDataType.all {
                            if let events = parsedResponse.events {
                                if events.count > 0 {
                                    General.events_all = parsedResponse.events!
                                    responses_data_ends["events_all"] = parsedResponse.dataEnd
                                }
                            }
                        }
                        else if receive_task.dataOrigin == HailyDataOrigin.sponsor && receive_task.dataType == HailyDataType.own {
                            if let sponsors = parsedResponse.sponsors {
                                if sponsors.count > 0 {
                                    General.sponsors_favorite = parsedResponse.sponsors!
                                    responses_data_ends["sponsors_favorite"] = parsedResponse.dataEnd
                                }
                            }
                            
                        }
                        else if receive_task.dataOrigin == HailyDataOrigin.event && receive_task.dataType == HailyDataType.own {
                            if let events = parsedResponse.events {
                                if events.count > 0 {
                                    General.events_favorite = parsedResponse.events!
                                    responses_data_ends["events_favorite"] = parsedResponse.dataEnd
                                }
                            }
                        }
                    case is HailySyncTask:
                        DispatchQueue.main.async(execute: {
                            self.handleSyncResponse(parsedResponse)
                        })
                    default:
                        continue
                    }
                }
                if full_request {
                    General.dataEndsStates = responses_data_ends
                }
            }
          //  if full_request {
                DispatchQueue.main.async(execute: {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "notification_main_content_updated"), object: nil)
                })
          //  }
        })
    }
    
    func handleSyncResponse(_ syncTaskResponse:HailyParsedResponse) {
        var should_repeat_explore_sync = false
        var having_feelings_update = false
        if let newMessagesArrived = syncTaskResponse.newMessagesArrived {
            if newMessagesArrived {
                let new_alert = UIAlertController.init(title: "You have new incoming requests", message: "Check them is Requests tab", preferredStyle: .alert)
                new_alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                window?.rootViewController?.present(new_alert, animated: true, completion: nil)
            }
        }
        if let _error = syncTaskResponse.error {
            print("Error while syncing : \(_error)")
        }
        if let message = syncTaskResponse.message {
            let new_alert = UIAlertController.init(title: "Personal Message", message: message, preferredStyle: .alert)
            new_alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
            window?.rootViewController?.present(new_alert, animated: true, completion: nil)
        }
        if should_repeat_explore_sync {
            Timer.scheduledTimer(timeInterval: 35.0, target: self, selector: #selector(AppDelegate.repeatExploreSync(_:)), userInfo: nil, repeats: false)
        }
    }
    
    func repeatExploreSync(_ sender:Timer) {
        let explore_task_builder = HailyTaskBuilder(session: General.session_data, anonymous: true, degradePossible: true)
        let explore_sync_task = HailySyncTask()
        explore_task_builder.addTasks([explore_sync_task])
        explore_task_builder.sendTasksWithCompletionHandler({
            (parsedResponse:[HailyParsedResponse]?, error:Error?) in
            if let _error = error {
                print("Having error when repeating explore sync")
                print(_error)
            }
            if let responsesParsed = parsedResponse {
                if responsesParsed.count == 1 {
                    self.handleSyncResponse(responsesParsed[0])
                }
            }
        })
    }
    /*
    func checkFavorites(_ data:[HailyInjectable]) {
        for element in data {
            switch element.type {
            case .topic:
                (element as! HailyTopic).fav = General.topicIsFavorite((element as! HailyTopic).topic_id)
                if (element as! HailyTopic).related_topics != nil {
                    for relatedElement in (element as! HailyTopic).related_topics {
                        relatedElement.fav = General.topicIsFavorite((element as! HailyTopic).topic_id)
                    }
                }
            case .opinion:
                break
            default:
                continue
            }
        }
    }
    
    func didPressOpenMenu(_ sender:Notification) {
        let menuType = sender.userInfo!["menuType"] as! String == "opinion" ? BottomMenuType.opinionMenu : sender.userInfo!["menuType"] as! String == "topic" ? BottomMenuType.topicMenu : BottomMenuType.imagePickerMenu
        var origin_id = -1
        if menuType != BottomMenuType.imagePickerMenu {
            origin_id = menuType == BottomMenuType.topicMenu ? (sender.userInfo!["topicData"] as! HailyTopic).topic_id : -1
        }
        if bottom_menu == nil {
            bottom_menu = BottomMenu(frame: CGRect(x: 0, y: 0, width: window!.bounds.width, height: window!.bounds.height), menuType: menuType, originId : origin_id)
            bottom_menu.addTarget(self, action: #selector(AppDelegate.menuItemPressed(_:)), for: .valueChanged)
            window!.addSubview(bottom_menu)
        }
        bottom_menu.setMenuType(menuType, withOriginId: origin_id)
        if menuType == BottomMenuType.opinionMenu {

        }
        else if menuType == BottomMenuType.topicMenu {
            bottom_menu.originData = sender.userInfo!["topicData"] as! HailyTopic
            bottom_menu.topicMenuButtonView = sender.userInfo!["topicMenuButtonView"] as! UIView
        }
        bottom_menu.setMenuShown(true)
    }
    
    func showHint(_ sender:Notification) {
        let hintText = sender.userInfo!["hintText"] as? String
        let transparentHole = sender.userInfo!["transparentHole"] as? CGRect
        if hint_view == nil {
            hint_view = HintView(frame: window!.bounds)
            window!.addSubview(hint_view)
        }
        let handler_here = sender.userInfo!["hintTappedHandler"] as? (() -> Void)
        hint_view.setHintWithText(hintText: hintText, transparentHole ?? CGRect.zero, handler_here)
    }
    
    func showBoldPopup(_ sender:Notification) {
        let popup_vc = sender.userInfo!["popup"] as! BoldPopupController
        popup_vc.view.frame = window!.bounds
        window!.addSubview(popup_vc.view)
        popup_vc.setPopupShown(true)
    }
    
    func shareOwnTopic(_ sender: Notification) {
        shareTopicWithTopicData(sender.userInfo!["topicData"] as! HailyTopic, topicMenuButtonView: sender.userInfo!["shareButtonView"] as! UIView)
    }
    
    func menuItemPressed(_ sender:BottomMenu) {
        let task_builder = HailyTaskBuilder(session: General.session_data, anonymous: false, degradePossible: false)
        switch sender.selected_action {
        case .addFavorites:
            if !General.authorized {
                NotificationCenter.default.post(kHailyUnauthorizedSliderNotification)
                break
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "notification_topic_favorite"), object: nil, userInfo: ["topicId":sender.origin_id,"favorite":!General.topicIsFavorite(sender.origin_id)])
            var event_params:[AnyHashable:Any] = ["topicId":sender.origin_id,"favoriteState":!General.topicIsFavorite(sender.origin_id)]
            if let topic_data = sender.originData as? HailyTopic {
                if let loveScore = topic_data.love_index {
                    event_params["loveScore"] = loveScore
                }
                if let categoryId = topic_data.categoryId {
                    event_params["categoryId"] = categoryId
                }
            }
        case .opinionReport:
            if !General.authorized {
                NotificationCenter.default.post(kHailyUnauthorizedSliderNotification)
                break
            }
            let report_opinion_task = HailyPersonalTask(personalType: HailyPersonalType.reportOpinion)
            report_opinion_task.reportEntityId = sender.origin_id
            task_builder.addTasks([report_opinion_task])
            var event_params:[AnyHashable:Any] = ["opinionId":sender.origin_id]

        case .opinionShare:
        break
        case .topicReport:
            if !General.authorized {
                NotificationCenter.default.post(kHailyUnauthorizedSliderNotification)
                break
            }
            let report_opinion_task = HailyPersonalTask(personalType: HailyPersonalType.reportTopic)
            report_opinion_task.reportEntityId = sender.origin_id
            task_builder.addTasks([report_opinion_task])
            var event_params:[AnyHashable:Any] = ["topicId":sender.origin_id]
            if let topic_data = sender.originData as? HailyTopic {
                if let loveScore = topic_data.love_index {
                    event_params["loveScore"] = loveScore
                }
                if let categoryId = topic_data.categoryId {
                    event_params["categoryId"] = categoryId
                }
            }
        case .topicShare:
            shareTopicWithTopicData(sender.originData as! HailyTopic, topicMenuButtonView: sender.topicMenuButtonView!)
        default:
            print("action is undefined")
        }
        if sender.selected_action == MenuAction.topicReport || sender.selected_action == MenuAction.opinionReport {
            task_builder.sendTasksWithCompletionHandler({
                (parsedResponse:[HailyParsedResponse]?,error:Error?) in
                if let responses = parsedResponse {
                    if responses.count == 1 {
                        if let result = responses[0].result {
                            if result == HailyResponseResult.ok {
                                print("reported succesfully")
                            }
                        }
                    }
                }
            })
            print("sending report task")
        }
    }
    
    
    func shareTopicWithImage(image:UIImage,shareText:String, topicTitle:String, menuButtonView:UIView) {
        let topic_view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let title_label = UILabel(frame: CGRect.init(x: 0, y: 0, width: 440.0, height: 1000.0))
        title_label.text = topicTitle.uppercased()
        title_label.textColor = UIColor.white
        title_label.numberOfLines = 0
        title_label.textAlignment = .center
        title_label.font = UIFont.init(name: "ProximaNova-Bold", size: getOverlayFontSizeForTitleLabel(title_label, maxHeight: 400.0, maxFontSize: 70.0))!
        let final_text_size = title_label.textRect(forBounds: CGRect.init(x: 0, y: 0, width: 440.0, height: 1000.0), limitedToNumberOfLines: 0)
        title_label.frame = CGRect.init(x: 30.0, y: 0.5 * topic_view.bounds.height - 0.5 * final_text_size.height, width: 440.0, height: final_text_size.height)
        let topic_image_view = UIImageView.init(frame: topic_view.bounds)
        topic_image_view.image = image
        topic_view.addSubview(topic_image_view)
        topic_view.addSubview(title_label)
        UIGraphicsBeginImageContextWithOptions(topic_view.frame.size, false, 0.0)
        topic_view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let final_img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let activity_vc = UIActivityViewController(activityItems: [shareText,final_img!], applicationActivities: nil)
        let excl = [UIActivityType.addToReadingList,UIActivityType.airDrop,UIActivityType.assignToContact,UIActivityType.copyToPasteboard]
        activity_vc.excludedActivityTypes = excl
        let root_vc = UIApplication.shared.keyWindow?.rootViewController
        if let baseVc = root_vc {
            baseVc.present(activity_vc, animated: true, completion: nil)
            if UIDevice().userInterfaceIdiom != .phone {
                activity_vc.popoverPresentationController?.sourceView = UIApplication.shared.keyWindow
                activity_vc.popoverPresentationController?.sourceRect = menuButtonView.convert(menuButtonView.bounds, to: UIApplication.shared.keyWindow!)
                activity_vc.popoverPresentationController?.permittedArrowDirections = [.any]
            }
        }
    }
    */
    func getOverlayFontSizeForTitleLabel(_ titleLabel:UILabel, maxHeight:CGFloat, maxFontSize:CGFloat) -> CGFloat {
        let test_label = titleLabel
        var resultingFontSize:CGFloat = maxFontSize
        for final_font_size in stride(from: maxFontSize, through: 1.0, by: -1.0) {
            test_label.font = UIFont(name: "ProximaNova-Bold", size: final_font_size)!
            let test_size = test_label.textRect(forBounds: test_label.bounds, limitedToNumberOfLines: 0)
            if test_size.height <= maxHeight {
                resultingFontSize = final_font_size
                break
            }
        }
        return resultingFontSize
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        //
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        //should archive latest and trending topics & opinions so that not to face with empty screen next time app is loaded
        //the notification is sent
    }
    
    
}

