//
//  TopicsOpinionsLister.swift
//  Haily
//
//  Created by Admin on 27.11.16.
//  Copyright © 2016 Vanoproduction. All rights reserved.
//

import UIKit

class TopicsOpinionsLister : UIViewController{
    
    let LOADER_SIZE:CGFloat = 40.0
    let USERS_TABLE_WIDTH_RELATIVE:CGFloat = 0.93
    let OPINIONS_COLLECTION_INSET:CGFloat = 15.0
    let USERS_TABLE_INSET:CGFloat = 10.0
    let EMPTY_ICON_HEIGHT:CGFloat = 65
    let EMPTY_LABEL_COLOR = UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 1.0)
    let EMPTY_LABEL_TEXT_SIZE:CGFloat = 18
    let EMPTY_LABEL_SPACING_TOP:CGFloat = 8
    let EMPTY_LABEL_WIDTH_RELATIVE:CGFloat = 0.89 // to whole view width
    let BG_OPACITY:CGFloat = 0.5
    let BG_OPACITY_LOWERED:CGFloat = 0.2
    
    var topics_table:TopicsTable!
    var messages_table:MessagesTableView!
    var layed_out = false
    var lister_title = ""
    var paradigm:LoadableParadigm!
    var loader_view:LoaderView!
    var data_ready = false
    var topics_color = TopicsColorsStyles.default
    var default_empty_text:String? = nil
    var empty_label:UILabel!
    var empty_icon:UIImageView!
    var bg_view:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge()
        bg_view = UIImageView(image: UIImage(named: "bg_neutral")!)
        bg_view.contentMode = .scaleAspectFill
        bg_view.alpha = BG_OPACITY
        //view.addSubview(bg_view)
        empty_label = UILabel()
        empty_label.numberOfLines = 0
        empty_label.textColor = EMPTY_LABEL_COLOR
        empty_label.textAlignment = .center
        empty_label.font = UIFont(name: "ProximaNova-Regular", size: EMPTY_LABEL_TEXT_SIZE)
        empty_label.alpha = 0.0
        view.addSubview(empty_label)
        empty_icon = UIImageView(image: UIImage(named: "data_empty_image_icon")!)
        empty_icon.contentMode = .scaleAspectFit
        empty_icon.alpha = 0.0
        view.addSubview(empty_icon)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !data_ready {
            loader_view.alpha = 1.0
            loader_view.startLoading()
        }
        //let _ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "demoEmpty:", userInfo: nil, repeats: false)
    }
    
    
    func demoEmpty(_ sender:Timer) {
      //  setEmptyState()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if layed_out {
            return
        }
        print("layouting lister")
        bg_view.frame = view.bounds
        if paradigm.origin == LoadableOrigin.events || paradigm.origin == LoadableOrigin.sponsors {
            topics_table = TopicsTable(topicsSizeStyle: TopicsSizesStyles.huge, topicsColorStyle: topics_color, frame: view.bounds, paradigm: self.paradigm, registerObservers: false)
            topics_table.alpha = 0.0
            view.addSubview(topics_table)
        }
        else if paradigm.origin == LoadableOrigin.messages {
            messages_table = MessagesTableView(frame: view.bounds, tableInset: 5.0, shouldDisplayEmptyHeader: false, paradigm: paradigm)
            messages_table.alpha = 0.0
            view.addSubview(messages_table)
        }
        loader_view = LoaderView(frame: CGRect(x: view.center.x - 0.5 * LOADER_SIZE, y: view.center.y - 0.5 * LOADER_SIZE, width: LOADER_SIZE, height: LOADER_SIZE), topBottomInset: 0.0)
        loader_view.alpha = 0.0
        view.addSubview(loader_view)
        layed_out = true
        performInitialLoading()
        //bg_view.alpha = paradigm.origin == LoadableOrigin.users ? BG_OPACITY_LOWERED : BG_OPACITY
        view.backgroundColor = UIColor(patternImage: UIImage.init(named:  paradigm.origin != LoadableOrigin.events && paradigm.origin != LoadableOrigin.sponsors ? "bg_art_lowered" : "bg_art")!)
    }
    
    func setData(_ data:[HailyInjectable]) {
        data_ready = true
        loader_view.alpha = 0.0
        if paradigm.origin == LoadableOrigin.events || paradigm.origin == LoadableOrigin.sponsors {
            topics_table.setData(data, ownTable: false)
            topics_table.alpha = 1.0
        }
    }
    
    func setEmptyStateWithText(_ emptyText:String) {
        empty_label.text = emptyText
        empty_label.frame = CGRect(x: 0, y: 0, width: view.bounds.width * EMPTY_LABEL_WIDTH_RELATIVE, height: 1000)
        let real_empty_label_size = empty_label.textRect(forBounds: empty_label.bounds, limitedToNumberOfLines: 0)
        let empty_icon_width = EMPTY_ICON_HEIGHT / (empty_icon.image!.size.height / empty_icon.image!.size.width)
        let total_height = real_empty_label_size.height + EMPTY_ICON_HEIGHT + EMPTY_LABEL_SPACING_TOP
        empty_icon.frame = CGRect(x: view.center.x - 0.5 * empty_icon_width, y: 0.5 * view.bounds.height - 0.5 * total_height, width: empty_icon_width, height: EMPTY_ICON_HEIGHT)
        empty_label.frame = CGRect(x: view.center.x - 0.5 * real_empty_label_size.width, y: empty_icon.frame.maxY + EMPTY_LABEL_SPACING_TOP, width: real_empty_label_size.width, height: real_empty_label_size.height)
        UIView.animate(withDuration: 0.4, animations: {
            self.empty_label.alpha = 1.0
            self.empty_icon.alpha = 1.0
        })
        loader_view.alpha = 0.0
    }
   

    
    func prepareListerWithTitle(_ title:String, paradigm:LoadableParadigm, emptyText:String?, addButtonRequired:Bool, topicsStyle:TopicsColorsStyles?) {
        self.paradigm = paradigm
        navigationItem.title = title
        lister_title = title
        default_empty_text = emptyText
        if let style = topicsStyle {
            topics_color = style
        }
    }
    
    func performInitialLoading() {
        print("lister initial loading")
        switch paradigm.origin! {
        case .events, .sponsors:
            topics_table.loadInitialDataWithAnswerHandler({
                (success:Bool) in
                self.data_ready = true
                if success {
                    if self.topics_table.data.count > 0 {
                        self.topics_table.alpha = 1.0
                        self.loader_view.alpha = 0.0
                    }
                    else if let standart_empty_text = self.default_empty_text {
                        self.setEmptyStateWithText(standart_empty_text)
                    }
                }
                else {
                    self.setEmptyStateWithText("Something went wrong while receiving sponsors / events...")
                }
            })
        case .messages:
            messages_table.loadInitialDataWithAnswerHandler({
                (success:Bool) in
                self.data_ready = true
                if success {
                    
                    if self.messages_table.messages_data.count > 0 {
                        self.messages_table.alpha = 1.0
                        self.loader_view.alpha = 0.0
                    }
                    else if let standart_text = self.default_empty_text {
                        self.setEmptyStateWithText(standart_text)
                    }

                }
                else {
                    self.setEmptyStateWithText("Something went wrong while loading requests to show...")
                }
            })
            break
        default:
          break
        }
    }
    
       
}
