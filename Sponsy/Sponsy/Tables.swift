//
//  TopicsTables.swift
//  Haily
//
//  Created by Admin on 13.11.16.
//  Copyright © 2016 Vanoproduction. All rights reserved.
//

import UIKit
import Kingfisher

class TopicsTable : UITableView , UITableViewDelegate, UITableViewDataSource, FooterDelegate {
    
    let BG_COLOR:UIColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1.0)
    let EVENT_HEIGHT:CGFloat = 200
    let SPONSOR_HEIGHT:CGFloat = 180
    let SMALL_TOPIC_HEIGHT:CGFloat = 60
    let RELATED_TOPICS_HEIGHT:CGFloat = 92
    let TABLE_FOOTER_HEIGHT:CGFloat = 45
    let TOPICS_TABLE_UPDATE_RELATIVE:CGFloat = 0.82
    let ARCHIVE_ITEMS_COUNT = 11 // how many topics to archive
    let EMPTY_ICON_HEIGHT:CGFloat = 65
    let EMPTY_LABEL_COLOR = UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 1.0)
    let EMPTY_LABEL_TEXT_SIZE:CGFloat = 18
    let EMPTY_LABEL_SPACING_TOP:CGFloat = 8
    let EMPTY_LABEL_WIDTH_RELATIVE:CGFloat = 0.89 // to whole view width
    
    var paradigm:LoadableParadigm!
    var size_style:TopicsSizesStyles
    var color_style:TopicsColorsStyles
    var flow_state:FlowState = FlowState.normal
    var data:[HailyInjectable] = []
    var show_related_topic_id:Int = -1
    var table_footer_view:DataFooterView!
    var footer_state:DataFooterState = DataFooterState.hidden
    var loader_refresh_view:LoaderView!
    var currently_refreshing = false
    var total_refresh_height:CGFloat = 0
    var registerObservers = true
    var backgroundEmptyView:UIView!
    var empty_label:UILabel!
    var empty_icon:UIImageView!
    
    init(topicsSizeStyle:TopicsSizesStyles,topicsColorStyle:TopicsColorsStyles, frame:CGRect, paradigm:LoadableParadigm, registerObservers:Bool = true) {
        size_style = topicsSizeStyle
        color_style = topicsColorStyle
        super.init(frame: frame, style: .grouped)
        self.paradigm = paradigm
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(TopicsTable.refreshTable(_:)), for: .valueChanged)
        refresh.tintColor = UIColor.clear
        addSubview(refresh)
        total_refresh_height = refresh.bounds.height
        let loader_height = total_refresh_height - 20.0
        let loader_frame = CGRect(x: 0.5 * refresh.bounds.width - 0.5 * loader_height, y: 10.0, width: loader_height, height: loader_height)
        loader_refresh_view = LoaderView(frame: loader_frame, topBottomInset: 0)
        refresh.addSubview(loader_refresh_view)
        total_refresh_height = refresh.bounds.height
        loader_refresh_view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        loader_refresh_view.alpha = 0.0
        self.registerObservers = registerObservers
        if registerObservers {
          //  NotificationCenter.default.addObserver(self, selector: #selector(TopicsTable.topicsDataUpdated(_:)), name: NSNotification.Name(rawValue: "notification_data_updated"), object: nil)
        }
        delegate = self
        dataSource = self
        backgroundEmptyView = UIView.init(frame: bounds)
        backgroundEmptyView.backgroundColor = UIColor.clear
        empty_label = UILabel()
        empty_label.numberOfLines = 0
        empty_label.textColor = EMPTY_LABEL_COLOR
        empty_label.textAlignment = .center
        empty_label.font = UIFont(name: "ProximaNova-Regular", size: EMPTY_LABEL_TEXT_SIZE)
        empty_label.alpha = 0.0
        backgroundEmptyView.addSubview(empty_label)
        empty_icon = UIImageView(image: UIImage(named: "data_empty_image_icon")!)
        empty_icon.contentMode = .scaleAspectFit
        empty_icon.alpha = 0.0
        backgroundEmptyView.addSubview(empty_icon)
        backgroundColor = UIColor.clear // BG_COLOR
        backgroundView = backgroundEmptyView
        register(UINib.init(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "event_cell")
        register(UINib.init(nibName: "SponsorCell", bundle: nil), forCellReuseIdentifier: "sponsor_cell")
        table_footer_view = DataFooterView(frame: CGRect(x: 0, y: 0, width: frame.width, height: TABLE_FOOTER_HEIGHT), scheme : "light") //dark scheme
        table_footer_view.setDelegate(self)
        table_footer_view.setFooterState(footer_state)
    }
    
    func setEmptyStateWithText(_ emptyText:String?) {
        if let newEmptyText = emptyText {
            empty_label.text = newEmptyText
            empty_label.frame = CGRect(x: 0, y: 0, width: backgroundEmptyView.bounds.width * EMPTY_LABEL_WIDTH_RELATIVE, height: 1000)
            let real_empty_label_size = empty_label.textRect(forBounds: empty_label.bounds, limitedToNumberOfLines: 0)
            let empty_icon_width = EMPTY_ICON_HEIGHT / (empty_icon.image!.size.height / empty_icon.image!.size.width)
            let total_height = real_empty_label_size.height + EMPTY_ICON_HEIGHT + EMPTY_LABEL_SPACING_TOP
            empty_icon.frame = CGRect(x: backgroundEmptyView.center.x - 0.5 * empty_icon_width, y: 0.5 * backgroundEmptyView.bounds.height - 0.5 * total_height, width: empty_icon_width, height: EMPTY_ICON_HEIGHT)
            empty_label.frame = CGRect(x: backgroundEmptyView.center.x - 0.5 * real_empty_label_size.width, y: empty_icon.frame.maxY + EMPTY_LABEL_SPACING_TOP, width: real_empty_label_size.width, height: real_empty_label_size.height)
            UIView.animate(withDuration: 0.4, animations: {
                self.empty_label.alpha = 1.0
                self.empty_icon.alpha = 1.0
            })
        }
        else {
            UIView.animate(withDuration: 0.4, animations: {
                self.empty_label.alpha = 0.0
                self.empty_icon.alpha = 0.0
            })
        }
    }
    

    func archiveData() {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            if self.paradigm.type != LoadableType.none {
                var arch_items:[AnyObject] = []
                var b = 0
                for i in 0 ..< self.data.count {
                    if b >= self.ARCHIVE_ITEMS_COUNT {
                        break
                    }
                    arch_items.append(self.data[i])
                    b += 1
                }
                var store_key = ""
                if self.paradigm.type == LoadableType.all {
                    store_key = self.paradigm.origin == LoadableOrigin.events ? "events_all" : "sponsors_all"
                }
                else if self.paradigm.type == LoadableType.own {
                    store_key = self.paradigm.origin == LoadableOrigin.events ? "events_own" : "sponsors_own"
                }
                UserDefaults().set(NSKeyedArchiver.archivedData(withRootObject: NSArray(array: arch_items)), forKey: store_key)

            }
        })
    }
    
    
    func setData(_ data:[HailyInjectable], ownTable:Bool) {
        self.data = Array.init(data)
        reloadData()
        if data.count != 0 {
            archiveData()
            setEmptyStateWithText(nil)
        }
        else {
            setEmptyStateWithText(ownTable ? "Use Sponsy website interface to setup your sponsor / event profile\nSlide down to update" : "Nothing to show here\nSlide down to update\n")
        }
    }
    
    
    func addTopicsData(_ topsData:[HailyInjectable]) {
        let topicsData:[HailyInjectable] = topsData.filter({
            (newTopic:HailyInjectable) in
            return !self.data.contains(where: {
                (item:HailyInjectable) in
                if item is SponsyEvent {
                    return (item as! SponsyEvent).event_id == (newTopic as! SponsyEvent).event_id
                }
                else {
                    return (item as! SponsySponsor).sponsor_id == (newTopic as! SponsySponsor).sponsor_id
                }
            })
        })
        data.append(contentsOf: topicsData)
        var indexes_insert:[IndexPath] = []
        for i in data.count - topicsData.count ..< data.count {
            indexes_insert.append(IndexPath(row: i, section: 0))
        }
        insertRows(at: indexes_insert, with: .fade)
        archiveData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !currently_refreshing && scrollView.contentOffset.y < 0 {
            let ratio = min(abs(scrollView.contentOffset.y) / total_refresh_height , 1.0)
            loader_refresh_view.transform = CGAffineTransform(scaleX: ratio, y: ratio)
            loader_refresh_view.alpha = ratio
        }
        if flow_state == FlowState.normal {
            if scrollView.contentOffset.y >= max((TOPICS_TABLE_UPDATE_RELATIVE * contentSize.height - bounds.height), contentSize.height - 3.5 * contentSize.height) && data.count > 0 {
            startAdditionalOpinionsTask()
            //let _ = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "demoLoaded:", userInfo: nil, repeats: false)
            }
        }
    }
    
    func startAdditionalOpinionsTask() {
        footer_state = DataFooterState.loading
        flow_state = FlowState.loading
        updateFooter()
        let new_topics_task = buildInitialRequestTask()
        let task_builder = HailyTaskBuilder(session: General.session_data, anonymous: false, degradePossible: false)
        //should append lastId or lastValue
        var lastId:Int?
        for i in stride(from: data.count - 1, through: 0, by: -1) {
            if data[i].type == HailyInjectableType.sponsyEvent {
                lastId = (data[i] as! SponsyEvent).event_id
            }
            else if data[i].type == HailyInjectableType.sponsySponsor {
                lastId = (data[i] as! SponsySponsor).sponsor_id
            }
            break
        }
        new_topics_task.lastId = lastId
        task_builder.addTasks([new_topics_task])
        task_builder.sendTasksWithCompletionHandler({
            (parsedResponse:[HailyParsedResponse]?,error:Error?) in
            if let responses = parsedResponse {
                if responses.count == 1 {
                    print("Received new sponsors / topics")
                    if let events = responses[0].events {
                        self.dataReceived(events, withSuccess: true)
                    }
                    else if let sponsors = responses[0].sponsors {
                        self.dataReceived(sponsors, withSuccess: true)
                    }
                    else {
                        self.dataReceived(nil, withSuccess: false)
                    }
                    self.flow_state = responses[0].dataEnd ? FlowState.end : FlowState.normal
                    if let newLastValue = responses[0].lastValue {
                        self.paradigm!.lastValue = newLastValue
                    }
                }
            }
            else {
                print("Error with receing new sponsors / events")
                if let _error = error {
                    print(_error)
                }
                self.dataReceived(nil, withSuccess: false)
            }
        })
        print("sent task to receive new opinions")

    }
    
    func demoLoaded(_ sender:Timer) {
       //topicsReceived([HailyTopic(topicId: 214, title: "LOADED TOPIC", opinionsAmount: 8, lastEntryTime: Date().timeIntervalSince1970, favourite: false, loveIndex: 8, relatedTopics: [HailyTopic(topicId: 66, title: "Going on somewhere"),HailyTopic(topicId: 67, title: "No idea what's up"),HailyTopic(topicId: 777, title: "Some sampel related topic")])], withSuccess: true)
    }
    
    func dataReceived(_ newData:[HailyInjectable]?, withSuccess:Bool) {
        if withSuccess {
            if newData!.count > 0 {
                flow_state = FlowState.normal
                DispatchQueue.main.async(execute: {
                    self.addTopicsData(newData!)
                })
            }
            else {
                flow_state = FlowState.end
            }
            footer_state = DataFooterState.hidden
        }
        else {
            flow_state = FlowState.trouble
            footer_state = DataFooterState.trouble
        }
        updateFooter()
    }
    
    func updateFooter() {
        DispatchQueue.main.async(execute: {
            self.table_footer_view.setFooterState(self.footer_state)
        })
        //reloadSections(NSMutableIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func buildInitialRequestTask() -> HailyReceiveTask {
        var refresh_task:HailyReceiveTask!
        switch paradigm!.type! {
        case .all:
            refresh_task = HailyReceiveTask(dataOrigin: paradigm!.origin == LoadableOrigin.events ? HailyDataOrigin.event : HailyDataOrigin.sponsor, dataType: HailyDataType.all)
        case .own:
            refresh_task = HailyReceiveTask(dataOrigin: paradigm!.origin == LoadableOrigin.events ? HailyDataOrigin.event : HailyDataOrigin.sponsor, dataType: HailyDataType.own)
        default:
            break
        }
        return refresh_task
    }
    
    func loadInitialDataWithAnswerHandler(_ answerHandler:@escaping ((_ success:Bool) -> Void)) {
        let refresh_task = buildInitialRequestTask()
        let task_builder = HailyTaskBuilder(session: General.session_data, anonymous: false, degradePossible: false)
        task_builder.addTasks([refresh_task])
        task_builder.sendTasksWithCompletionHandler({
            (parsedResponse:[HailyParsedResponse]?, error:Error?) in
            var success = false
            if let responses = parsedResponse {
                if responses.count == 1 {
                    print("Received initial sponsors / events response, handling now")
                    if let events = responses[0].events {
                        DispatchQueue.main.async(execute: {
                            self.setData(events, ownTable: false)
                           // NotificationCenter.default.post(name: Notification.Name(rawValue: "notification_data_updated"), object: nil, userInfo: ["topicsData":topics.map({$0 as! HailyTopic})])
                        })
                        success = true
                    }
                    if let sponsors = responses[0].sponsors {
                        DispatchQueue.main.async(execute: {
                            self.setData(sponsors, ownTable: false)
                            // NotificationCenter.default.post(name: Notification.Name(rawValue: "notification_data_updated"), object: nil, userInfo: ["topicsData":topics.map({$0 as! HailyTopic})])
                        })
                        success = true
                    }
                    self.flow_state = responses[0].dataEnd ? FlowState.end : FlowState.normal
                    if let _lastValue = responses[0].lastValue {
                        self.paradigm!.lastValue = _lastValue
                    }
                }
            }
            if !success {
                print("Error with receiving initial topics")
                if let _error = error {
                    print(_error)
                }
                DispatchQueue.main.async(execute: {
                    NotificationCenter.default.post(kHailyDataRetrievalErrorSliderNotification)
                })
            }
            DispatchQueue.main.async(execute: {
                answerHandler(success)
            })
        })
        print("Sent initial sponsors / events request, waiting for response")
    }
    
    func refreshTable(_ sender:UIRefreshControl) {
        currently_refreshing = true
        //let _ = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "sw:", userInfo: sender, repeats: false)
        loadInitialDataWithAnswerHandler({
            (success:Bool) in
            sender.endRefreshing()
            self.loader_refresh_view.stopLoading()
            self.loader_refresh_view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.loader_refresh_view.alpha = 0.0
            self.currently_refreshing = false
        })
        loader_refresh_view.startLoading()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("returning topics table with count of \(data.count)")
        return data.count
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
       // (view as! DataFooterView).resignedVisible()
        print("stopped displaying footer table")
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        print("will display footer table")
        (view as! DataFooterView).becameVisible()
        //depending on the state
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return table_footer_view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return TABLE_FOOTER_HEIGHT
    }
    /*
    func topicsDataUpdated(_ sender:Notification) {
        var reload_rows_indices:[IndexPath] = []
        let newTopicsData = sender.userInfo!["topicsData"] as! [HailyTopic]
        for newTopicData in newTopicsData {
            if let topicIndex = data.index(where: {($0 as? HailyTopic)?.topic_id == newTopicData.topic_id}) {
                (data[topicIndex] as! HailyTopic).last_entry_time = newTopicData.last_entry_time
                (data[topicIndex] as! HailyTopic).opinions_amount = newTopicData.opinions_amount!
                if let topic_cell = cellForRow(at: IndexPath(row: topicIndex, section: 0)) as? TopicCell {
                    if topic_cell.topic_id == newTopicData.topic_id {
                        reload_rows_indices.append(IndexPath(row: topicIndex, section: 0))
                    }
                }
            }
        }
        reloadRows(at: reload_rows_indices, with: .fade)
    }
 */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if data[indexPath.row].type == HailyInjectableType.sponsyEvent {
            return tableView.dequeueReusableCell(withIdentifier: "event_cell") as! EventCell
        }
        else {
            return tableView.dequeueReusableCell(withIdentifier: "sponsor_cell") as! SponsorCell
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if data[indexPath.row].type == HailyInjectableType.sponsyEvent {
            (cell as! EventCell).setData(data[indexPath.row] as! SponsyEvent)
            let event_id = (data[indexPath.row] as! SponsyEvent).event_id
            General.events_images_cache.retrieveImage(forKey: "\(event_id)", options: nil, completionHandler: {
                (image:UIImage?, cache:CacheType) in
                if let _image = image {
                    //print("retrieved img from cache for row \(indexPath.row)")
                    General.prepareSizedImage(_image, toFitSize: CGSize(width: self.bounds.width, height: self.EVENT_HEIGHT), withAlignment: SizedImageAlignment.center , withOverlayStyle: self.color_style , completionHandler: {
                        (finalImage:UIImage) in
                        (cell as? EventCell)?.setEventImage(finalImage, animated: false)
                    })
                }
                else {
                    ImageDownloader.default.downloadImage(with: URL.init(string: "\(General.images_bucket_address)event\(event_id)")!, options: nil, progressBlock: nil, completionHandler: {
                        (image:UIImage?, error:NSError?, url:URL?, data:Data?) in
                        if let _image = image {
                            print("downloaded image for row \(indexPath.row)")
                            General.prepareSizedImage(_image, toFitSize: CGSize(width: self.bounds.width, height: self.EVENT_HEIGHT), withAlignment: SizedImageAlignment.center , withOverlayStyle: self.color_style , completionHandler: {
                                (finalImage:UIImage) in
                                if let eventCell = cell as? EventCell {
                                    if let eventData = self.data[indexPath.row] as? SponsyEvent {
                                        if eventData.event_id == eventCell.event_id {
                                            eventCell.setEventImage(finalImage, animated: true)
                                        }
                                    }
                                }
                                //(cell as? TopicCell)?.setTopicImage(finalImage,animated:true)
                            })
                            General.events_images_cache.store(_image, original: data, forKey: "\(event_id)")
                        }
                        if let err = error {
                            print("error with getting from s3 for topic id \(event_id)")
                            print(err)
                        }
                    })
                }
            })
        }
        else if data[indexPath.row].type == HailyInjectableType.sponsySponsor {
            (cell as! SponsorCell).setData(data[indexPath.row] as! SponsySponsor)
            let sponsor_id = (data[indexPath.row] as! SponsySponsor).sponsor_id
            General.sponsors_images_cache.retrieveImage(forKey: "\(sponsor_id)", options: nil, completionHandler: {
                (image:UIImage?, cache:CacheType) in
                if let _image = image {
                    //print("retrieved img from cache for row \(indexPath.row)")
                    General.prepareSizedImage(_image, toFitSize: CGSize(width: self.bounds.width, height: self.SPONSOR_HEIGHT), withAlignment: SizedImageAlignment.center , withOverlayStyle: self.color_style , completionHandler: {
                        (finalImage:UIImage) in
                        (cell as? SponsorCell)?.setSponsorImage(finalImage, animated: false)
                    })
                }
                else {
                    ImageDownloader.default.downloadImage(with: URL.init(string: "\(General.images_bucket_address)sponsor\(sponsor_id)")!, options: nil, progressBlock: nil, completionHandler: {
                        (image:UIImage?, error:NSError?, url:URL?, data:Data?) in
                        if let _image = image {
                            print("downloaded image for row \(indexPath.row)")
                            General.prepareSizedImage(_image, toFitSize: CGSize(width: self.bounds.width, height: self.SPONSOR_HEIGHT), withAlignment: SizedImageAlignment.center , withOverlayStyle: self.color_style , completionHandler: {
                                (finalImage:UIImage) in
                                if let sponsorCell = cell as? SponsorCell {
                                    if let sponsorData = self.data[indexPath.row] as? SponsySponsor {
                                        if sponsorData.sponsor_id == sponsorCell.sponsor_id {
                                            sponsorCell.setSponsorImage(finalImage, animated: true)
                                        }
                                    }
                                }
                                //(cell as? TopicCell)?.setTopicImage(finalImage,animated:true)
                            })
                            General.sponsors_images_cache.store(_image, original: data, forKey: "\(sponsor_id)")
                        }
                        if let err = error {
                            print("error with getting from s3 for topic id \(sponsor_id)")
                            print(err)
                        }
                    })
                }
            })
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if data[indexPath.row].type == HailyInjectableType.sponsyEvent {
            return EVENT_HEIGHT
        }
        else {
            return SPONSOR_HEIGHT
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        tableView.cellForRow(at: indexPath)?.setHighlighted(false, animated: true)
        if paradigm.origin == LoadableOrigin.events {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "notification_open_event"), object: nil, userInfo: ["origin":"event","eventData":data[indexPath.row] as! SponsyEvent])
        }
        else {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "notification_open_sponsor"), object: nil, userInfo: ["origin":"sponsor","sponsorData":data[indexPath.row] as! SponsySponsor])
        }
    }
    
    func retryConnection() {
        startAdditionalOpinionsTask()
    }
    
}

enum TopicsColorsStyles {
    case loved, hated, `default`, none
}

enum TopicsSizesStyles {
    case huge, small
}
