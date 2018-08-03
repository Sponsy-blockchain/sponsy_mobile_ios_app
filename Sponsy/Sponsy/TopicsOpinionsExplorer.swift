//
//  TopicsOpinionsExplorer.swift
//  Haily
//
//  Created by Admin on 12.11.16.
//  Copyright © 2016 Vanoproduction. All rights reserved.
//

import UIKit

class TopicsOpinionsExplorer: ChildTabViewController, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate {
    
    let ADD_TOPIC_BUTTON_MARGIN_RIGHT:CGFloat = 9
    let ADD_TOPIC_BUTTON_MARGIN_BOTTOM:CGFloat = 9
    let ADD_TOPIC_BUTTON_WIDTH:CGFloat = 60
    let PAGE_SWITCHER_HEIGHT:CGFloat = 38
    let PAGE_TRANSITION_DURATION:CFTimeInterval = 0.35
    let PAN_TRANSLATION_CONSIDERED_COMPLETED:CGFloat = 0.25
    let PAN_TRANSLATION_REQUIRED_COMPLETED:CGFloat = 0.6
    let EMPTY_ICON_HEIGHT:CGFloat = 65
    let EMPTY_LABEL_COLOR = UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 1.0)
    let EMPTY_LABEL_TEXT_SIZE:CGFloat = 18
    let EMPTY_LABEL_SPACING_TOP:CGFloat = 8
    let EMPTY_LABEL_WIDTH_RELATIVE:CGFloat = 0.89 // to whole view width
    let BG_OPACITY:CGFloat = 0.5
    let OPINIONS_INSET:CGFloat = 13
    let LOADER_SIZE:CGFloat = 40
    
    var upper_page_switcher:UpperPageSwitcher!
    var page_switcher_gesture_recognizer:UIPanGestureRecognizer!
    var selected_page:Int = 1
    var pages:[UIView] = []
    var topics_table:TopicsTable!
    var topics_table_own:TopicsTable!
    var sample_opinions_data:[HailyInjectable] = []
    var bg_view:UIImageView!
    var layed_out = false
    var should_stop_loader = false
    var should_show_related_topics:Int? = nil
    var loader_view:LoaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bg_view = UIImageView(image: UIImage(named: "bg_neutral")!)
        bg_view.alpha = BG_OPACITY
        //view.addSubview(bg_view)
        view.backgroundColor = UIColor(patternImage: UIImage.init(named: "bg_art")!)
        NotificationCenter.default.addObserver(self, selector: #selector(TopicsOpinionsExplorer.shouldShowRelatedTopics(_:)), name: NSNotification.Name(rawValue: "notification_should_show_related_topics"), object: nil)
    //    NotificationCenter.default.addObserver(self, selector: #selector(TopicsOpinionsExplorer.openTopic(_:)), name: Notification.Name.init("notification_open_topic"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TopicsOpinionsExplorer.contentUpdated(_:)), name: NSNotification.Name(rawValue: "notification_main_content_updated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loggedOut), name: NSNotification.Name(rawValue: "notification_logged_out"), object: nil)

    }
    
    func loggedOut(sender:Notification) {
        topics_table_own.setData([], ownTable: true)
    }
    
    func shouldShowRelatedTopics(_ sender:Notification) {
        should_show_related_topics = sender.userInfo!["topicId"] as! Int
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if layed_out {
            return
        }
        bg_view.frame = view.bounds
        upper_page_switcher = UpperPageSwitcher(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: PAGE_SWITCHER_HEIGHT))
        upper_page_switcher.addTarget(self, action: #selector(TopicsOpinionsExplorer.pageSwitched(_:)), for: .valueChanged)
        view.addSubview(upper_page_switcher)
        let page_1 = UIView(frame: CGRect(x: 0, y: upper_page_switcher.bounds.height, width: view.bounds.width, height: view.bounds.height - upper_page_switcher.bounds.height))
        page_1.backgroundColor = UIColor.clear
        let page_2 = UIView(frame: page_1.frame)

            page_2.center.x += view.bounds.width
        page_2.backgroundColor = UIColor.clear
        view.addSubview(page_1)
        view.addSubview(page_2)
        pages.append(page_1)
        pages.append(page_2)
        page_switcher_gesture_recognizer = UIPanGestureRecognizer(target: self, action: #selector(TopicsOpinionsExplorer.pageDidMove(_:)))
        page_switcher_gesture_recognizer.delegate = self
        view.addGestureRecognizer(page_switcher_gesture_recognizer)
        topics_table = TopicsTable(topicsSizeStyle: TopicsSizesStyles.huge, topicsColorStyle: TopicsColorsStyles.default, frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: page_1.bounds.height), paradigm : LoadableParadigm(origin: paradigm_type == "events" ? LoadableOrigin.events : LoadableOrigin.sponsors, type: LoadableType.all, id: -1))
        topics_table_own = TopicsTable(topicsSizeStyle: TopicsSizesStyles.huge, topicsColorStyle: TopicsColorsStyles.default, frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: page_2.bounds.height), paradigm : LoadableParadigm(origin: paradigm_type == "events" ? LoadableOrigin.events : LoadableOrigin.sponsors, type: LoadableType.own, id: -1))
        page_1.addSubview(topics_table)
        page_2.addSubview(topics_table_own)
        let add_topic_button = UIButton(type: .custom)
        add_topic_button.frame = CGRect(x: view.bounds.width - ADD_TOPIC_BUTTON_MARGIN_RIGHT - ADD_TOPIC_BUTTON_WIDTH, y: view.bounds.height - ADD_TOPIC_BUTTON_MARGIN_BOTTOM - ADD_TOPIC_BUTTON_WIDTH, width: ADD_TOPIC_BUTTON_WIDTH, height: ADD_TOPIC_BUTTON_WIDTH)
        add_topic_button.addTarget(self, action: "addTopicButtonPressed:", for: .touchUpInside)
        add_topic_button.setImage(UIImage(named: "add_topic_button")!, for: UIControlState())
        //view.addSubview(add_topic_button)
        loader_view = LoaderView(frame: CGRect(x: 0, y: 0, width: LOADER_SIZE, height: LOADER_SIZE), topBottomInset: 0.0)
        loader_view.alpha = 0.0
        loader_view.center = view.center
        view.addSubview(loader_view)
        layed_out = true
        updateContents()
        if (paradigm_type == "events" ? General.events_all : General.sponsors_all).count == 0 && !should_stop_loader {
            loader_view.alpha = 1.0
            loader_view.startLoading()
        }
    
    }
    /*
    func openTopic(_ sender:Notification) {
        if let newTopic = sender.userInfo!["newTopic"] as? Bool {
            if newTopic {
                if let topicsParadigm = topics_table.paradigm {
                    if topicsParadigm.type == LoadableType.latest {
                        if let newTopicData = sender.userInfo!["topicData"] as? HailyTopic {
                            topics_table.topics_data.insert(newTopicData, at: 0)
                            topics_table.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .automatic)
                        }
                    }
                }
            }
        }
    }
    
 */
    func contentUpdated(_ sender:Notification) {
        updateContents()
    }
    
    func updateContents() {
        should_stop_loader = true
        if layed_out {
            print("updaing content layed out")
            loader_view.alpha = 0.0
            loader_view.stopLoading()
            if (paradigm_type == "events" ? General.events_all : General.sponsors_all).count != 0 {
                topics_table.setData(paradigm_type == "events" ? General.events_all : General.sponsors_all, ownTable: false)
                if let ends = General.dataEndsStates {
                    topics_table.flow_state = paradigm_type == "events" ? ends["events_all"] ?? false ? FlowState.end : FlowState.normal : ends["sponsors_all"] ?? false ? FlowState.end : FlowState.normal
                }
            }
            else {
                topics_table.setData([], ownTable: false)
            }
            if (paradigm_type == "events" ? General.events_favorite : General.sponsors_favorite).count != 0 {
                topics_table_own.setData(paradigm_type == "events" ? General.events_favorite : General.sponsors_favorite,ownTable:true)
                if let ends = General.dataEndsStates {
                    topics_table_own.flow_state = paradigm_type == "events" ? ends["events_favorite"] ?? false ? FlowState.end : FlowState.normal : ends["sponsors_favorite"] ?? false ? FlowState.end : FlowState.normal
                }
            }
            else {
                topics_table_own.setData([], ownTable: true)
            }
            topics_table.reloadData()
 
        }
    }
    
    func contentReceivedWithTopicsData(_ topicsData:[HailyInjectable], opinionsData:[HailyInjectable]) {
        
    }
    
    func pageSwitched(_ sender:UpperPageSwitcher) {
        print("just switched to page \(sender.selected_page)")
        
        selected_page = sender.selected_page
        let shift = view.bounds.width * (selected_page == 1 ? 1.0 : -1.0)
        UIView.animate(withDuration: PAGE_TRANSITION_DURATION, animations: {
            self.pages[0].center.x += shift
            self.pages[1].center.x += shift
        })
    }
    
    func pageDidMove(_ sender:UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            let translation_x = sender.translation(in: self.view).x / PAN_TRANSLATION_REQUIRED_COMPLETED
            if (translation_x >= 0 && selected_page == 1) || (translation_x < 0 && selected_page == 2) {
                return
            }
            var start_page_1:CGFloat = view.center.x
            var start_page_2:CGFloat = start_page_1 + view.bounds.width
            if translation_x >= 0 {
                start_page_2 = view.center.x
                start_page_1 = start_page_2 - view.bounds.width
            }
            pages[0].center.x = start_page_1 + translation_x
            pages[1].center.x = start_page_2 + translation_x
            upper_page_switcher.setBubbleTranslationToPageNo(translation_x >= 0 ? 1 : 2, percentCompleted:abs(translation_x) / view.bounds.width)
        case .ended:
            if abs(sender.translation(in: self.view).x) >= PAN_TRANSLATION_CONSIDERED_COMPLETED * view.bounds.width {
                let final_page = (sender.translation(in: self.view).x >= 0) ? 1 : 2
                upper_page_switcher.setBubbleTranslationFinishedToPageNo(final_page)
                UIView.animate(withDuration: PAGE_TRANSITION_DURATION, animations: {
                    if final_page == 1 {
                        self.pages[0].center.x = self.view.center.x
                        self.pages[1].center.x = self.view.bounds.width * 1.5
                    }
                    else {
                        self.pages[1].center.x = self.view.center.x
                        self.pages[0].center.x = -self.view.bounds.width * 0.5
                    }
                })
                selected_page = final_page
                
            }
            else {
                upper_page_switcher.setBubbleTranslationCancelled()
                let final_page = selected_page
                UIView.animate(withDuration: PAGE_TRANSITION_DURATION, animations: {
                    if final_page == 1 {
                        self.pages[0].center.x = self.view.center.x
                        self.pages[1].center.x = self.view.bounds.width * 1.5
                    }
                    else {
                        self.pages[1].center.x = self.view.center.x
                        self.pages[0].center.x = -self.view.bounds.width * 0.5
                    }
                })
            }
        default:
            break
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == page_switcher_gesture_recognizer {
            if (selected_page == 1 && page_switcher_gesture_recognizer.translation(in: self.view).x >= 0) || (selected_page == 2 && page_switcher_gesture_recognizer.translation(in: self.view).x < 0) {
                return false
            }
            return true
        }
        else {
            return true
        }
    }
    
}
