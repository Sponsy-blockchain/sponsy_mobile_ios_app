//
//  CustomControls-2.swift
//  Haily
//
//  Created by Admin on 30.11.16.
//  Copyright © 2016 Vanoproduction. All rights reserved.
//

import UIKit

enum SizedImageAlignment {
    case topLeft, center, bottomRight
}

protocol ExploreSearchDelegate : class {
    func searchTextChangedTo(_ searchText:String?)
}


class ExploreSearchBar : UIControl, UITextFieldDelegate {
    
    let SEARCH_ICON_SPACING_LEFT:CGFloat = 15
    let SEARCH_ICON_HEIGHT_RELATIVE:CGFloat = 0.37
    let SEARCH_FIELD_SPACING_SIDES:CGFloat = 10
    let SEARCH_FIELD_TEXT_SIZE:CGFloat = 17
    let SEARCH_FIELD_TEXT_COLOR_PLACEHOLDER = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
    let SEARCH_FIELD_TEXT_COLOR_NORMAL = UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1.0)
    let CANCEL_ICON_HEIGHT_RELATIVE:CGFloat = 0.4
    let CHANGES_ANIMATION_DURATION:CFTimeInterval = 0.2
    let CORNER_RADIUS:CGFloat = 5.0
    let SHADOW_OPACITY:CGFloat = 0.2
    let SHADOW_OFFSET:CGSize = CGSize(width: 0.0, height: 4.0)
    
    var search_icon:UIImageView!
    var search_field:UITextField!
    var cancel_button:UIButton!
    weak var search_delegate:ExploreSearchDelegate!
    var keyboard_toolbar:UIToolbar!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        keyboard_toolbar = UIToolbar()
        keyboard_toolbar.sizeToFit()
        keyboard_toolbar.items = [UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(ExploreSearchBar.doneKeyboardPressed))]
        backgroundColor = UIColor.white
        //layer.masksToBounds = true
        layer.cornerRadius = CORNER_RADIUS
        layer.shadowOpacity = Float(SHADOW_OPACITY)
        layer.shadowOffset = SHADOW_OFFSET
        layer.shadowRadius = 1.0
        search_icon = UIImageView(image: UIImage(named: "search_icon")!)
        search_icon.contentMode = .scaleAspectFit
        let search_icon_height = frame.height * SEARCH_ICON_HEIGHT_RELATIVE
        let search_icon_width = search_icon_height / (search_icon.image!.size.height / search_icon.image!.size.width)
        search_icon.frame = CGRect(x: SEARCH_ICON_SPACING_LEFT, y: 0.5 * frame.height - 0.5 * search_icon_height, width: search_icon_width, height: search_icon_height)
        addSubview(search_icon)
        cancel_button = UIButton(type: .custom)
        cancel_button.alpha = 0.0
        cancel_button.setImage(UIImage(named: "cancel_search_icon")!, for: UIControlState())
        let real_image_size = CANCEL_ICON_HEIGHT_RELATIVE * frame.height
        let image_edge = 0.5 * (frame.height - real_image_size)
        cancel_button.imageEdgeInsets = UIEdgeInsetsMake(image_edge, image_edge, image_edge, image_edge)
        cancel_button.frame = CGRect(x: frame.width - frame.height, y: 0, width: frame.height, height: frame.height)
        cancel_button.addTarget(self, action: #selector(ExploreSearchBar.cancelPressed(_:)), for: .touchUpInside)
        addSubview(cancel_button)
        search_field = UITextField(frame: CGRect(x: search_icon.frame.maxX + SEARCH_FIELD_SPACING_SIDES, y: 0, width: cancel_button.frame.minX - SEARCH_FIELD_SPACING_SIDES * 2.0 - search_icon.frame.maxX, height: frame.height))
        search_field.inputAccessoryView = keyboard_toolbar
        search_field.defaultTextAttributes = [NSFontAttributeName:UIFont(name: "ProximaNovaCond-Regular", size: SEARCH_FIELD_TEXT_SIZE)!,NSForegroundColorAttributeName:SEARCH_FIELD_TEXT_COLOR_NORMAL]
        let placeholder_attr = NSMutableAttributedString(string: "Search events and sponsors...", attributes: [NSFontAttributeName:UIFont(name: "ProximaNovaCond-Regular", size: SEARCH_FIELD_TEXT_SIZE)!,NSForegroundColorAttributeName:SEARCH_FIELD_TEXT_COLOR_PLACEHOLDER])
        search_field.attributedPlaceholder = placeholder_attr
        search_field.addTarget(self, action: #selector(ExploreSearchBar.searchFieldTextChanged(_:)), for: .editingChanged)
        search_field.delegate = self
        addSubview(search_field)
        search_icon.center.y -= 1
        
    }
    
    func doneKeyboardPressed(sender:UIBarButtonItem) {
        search_field.endEditing(true)
    }
    
    func cancelPressed(_ sender:UIButton) {
        UIView.animate(withDuration: CHANGES_ANIMATION_DURATION, animations: {
            sender.alpha = 0.0
        })
        if search_field.text! != "" {
            search_delegate.searchTextChangedTo(nil)
        }
        search_field.endEditing(true)
        search_field.text = ""
    }
    
    func searchFieldTextChanged(_ sender:UITextField) {
        search_delegate.searchTextChangedTo(sender.text! == "" ? nil : sender.text!)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: CHANGES_ANIMATION_DURATION, animations: {
            self.cancel_button.alpha = 1.0
        })
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("did end editing ")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        print("whole bar received touched")
        if !search_field.isEditing {
            print("veocming fist responder")
            search_field.becomeFirstResponder()
        }
        return true
    }
}

class SearchResultsSwitcher : UIControl {
    
    let SLIDER_THICKNESS:CGFloat = 4
    let SLIDER_SPACING:CGFloat = 4
    let SLIDER_WIDTH_RELATIVE:CGFloat = 1.6
    let ITEMS_TEXT_SIZE:CGFloat = 17
    let ITEMS_TEXT_COLOR = UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1.0)
    let ITEMS_OPACITY_UNSELECTED:CGFloat = 0.7
    let ITEMS_MAX_INTER_SPACING:CGFloat = 107
    let ITEMS_MIN_SIDES_SPACING:CGFloat = 15
    let SLIDER_COLOR = UIColor(red: 200/255, green: 59/255, blue: 51/255, alpha: 1.0)
    let ANIM_DURATION:CFTimeInterval = 0.23
    
    var item_label_left:UILabel!
    var item_label_right:UILabel!
    var slider:CALayer!
    var slider_left_frame:CGRect!
    var slider_right_frame:CGRect!
    
    var topics_selected = true
    
    override init(frame: CGRect) {
        let item_left_size = ("SPONSORS" ).size(attributes: [NSFontAttributeName:UIFont(name: "ProximaNova-Semibold", size: ITEMS_TEXT_SIZE)!])
        let item_right_size = ("SPONSESS" ).size(attributes: [NSFontAttributeName:UIFont(name: "ProximaNova-Semibold", size: ITEMS_TEXT_SIZE)!])
        let items_inter_spacing = min(ITEMS_MAX_INTER_SPACING,(frame.width - item_left_size.width - item_right_size.width - ITEMS_MIN_SIDES_SPACING * 2.0))
        let total_content_width = items_inter_spacing + item_right_size.width + item_left_size.width
        let total_content_height = max(item_left_size.height,item_right_size.height) + SLIDER_SPACING + SLIDER_THICKNESS
        super.init(frame: CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: total_content_height))
        item_label_left = UILabel(frame: CGRect(x: 0.5 * (frame.width - total_content_width), y: 0, width: item_left_size.width, height: item_left_size.height))
        item_label_left.font = UIFont(name: "ProximaNova-Semibold", size: ITEMS_TEXT_SIZE)
        item_label_left.textColor = ITEMS_TEXT_COLOR
        item_label_left.text = "SPONSORS"
        addSubview(item_label_left)
        item_label_right = UILabel(frame: CGRect(x: item_label_left.frame.maxX + items_inter_spacing, y: 0, width: item_right_size.width, height: item_right_size.height))
        item_label_right.font = item_label_left.font
        item_label_right.text = "SPONSEES"
        item_label_right.textColor = ITEMS_TEXT_COLOR
        item_label_right.alpha = ITEMS_OPACITY_UNSELECTED
        addSubview(item_label_right)
        slider_left_frame = CGRect(x: max(0.0,item_label_left.frame.minX - 0.5 * (SLIDER_WIDTH_RELATIVE - 1.0) * item_label_left.frame.width), y: item_label_left.frame.maxY + SLIDER_SPACING, width: SLIDER_WIDTH_RELATIVE * item_left_size.width, height: SLIDER_THICKNESS)
        slider_right_frame = CGRect(x: min((frame.width - SLIDER_WIDTH_RELATIVE * item_right_size.width), (item_label_right.frame.minX - 0.5 * (SLIDER_WIDTH_RELATIVE - 1.0) * item_label_right.bounds.width)), y: slider_left_frame.minY, width: item_label_right.bounds.width * SLIDER_WIDTH_RELATIVE, height: SLIDER_THICKNESS)
        slider = CALayer()
        slider.frame = slider_left_frame
        slider.backgroundColor = SLIDER_COLOR.cgColor
        layer.addSublayer(slider)
    }
    
    func setLeftSelected(_ leftSelected:Bool) {
        topics_selected = leftSelected
        sendActions(for: .valueChanged)
        item_label_left.alpha = topics_selected ? 1.0 : ITEMS_OPACITY_UNSELECTED
        item_label_right.alpha = topics_selected ? ITEMS_OPACITY_UNSELECTED : 1.0
        let slider_anim = CABasicAnimation(keyPath: "frame")
        slider_anim.timingFunction = General.anim_func
        slider_anim.fromValue = NSValue(cgRect : topics_selected ? slider_right_frame : slider_left_frame)
        slider_anim.toValue = NSValue(cgRect: topics_selected ? slider_left_frame : slider_right_frame)
        slider_anim.duration = ANIM_DURATION
        slider.frame = topics_selected ? slider_left_frame : slider_right_frame
        slider.add(slider_anim, forKey: "slider")
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        var animating = false
        if touch.location(in: self).x >= 0.5 * frame.width && topics_selected {
            setLeftSelected(false)
        }
        else if touch.location(in: self).x < 0.5 * frame.width && !topics_selected {
            setLeftSelected(true)
        }
        return false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class SearchResultsView : UIView{
    
    let LOADER_SIZE:CGFloat = 32
    let LOADER_SPACING_TOP:CGFloat = 26
    let EMPTY_LABEL_TEXT_SIZE:CGFloat = 18
    let TABLE_SPACING_TOP:CGFloat = 16
    let TABLE_WIDTH_RELATIVE:CGFloat = 0.91
    let CELLS_SPACING:CGFloat = 8
    let CELLS_BG_COLOR = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    let TOPICS_ABOUT_TEXT_SIZE:CGFloat = 15
    let TOPICS_MAIN_TEXT_SIZE:CGFloat = 18
    let CELLS_HEIGHT:CGFloat = 40
    let TOPICS_ABOUT_TEXT_COLOR = UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1.0)
    let TOPICS_MAIN_TEXT_COLOR = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1.0)
    let SWITCHING_ANIMATION_DURATION:CFTimeInterval = 0.23
    
    var results_switcher:SearchResultsSwitcher!
    var results_sponsors_table:TopicsTextualTableView!
    var results_events_table:TopicsTextualTableView!
    var loader_view:LoaderView!
    var topics_empty_label:UILabel!
    
    var search_topics_selected = true
    var currently_loading = false
    var sponsors_results_data:[SponsySponsor] = []
    var events_results_data:[SponsyEvent] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let table_width = bounds.width * TABLE_WIDTH_RELATIVE
        results_switcher = SearchResultsSwitcher(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 120))
        results_switcher.addTarget(self, action: #selector(SearchResultsView.searchSwitcherSelected(_:)), for: .valueChanged)
        results_sponsors_table = TopicsTextualTableView(frame: CGRect(x: 0.5 * (bounds.width - table_width) , y: results_switcher.frame.maxY + TABLE_SPACING_TOP, width: table_width, height: bounds.height - TABLE_SPACING_TOP - results_switcher.bounds.height), shouldDisplayEmptyHeader: true)
        results_events_table = TopicsTextualTableView(frame: CGRect(x: 0.5 * (bounds.width - table_width) , y: results_switcher.frame.maxY + TABLE_SPACING_TOP, width: table_width, height: bounds.height - TABLE_SPACING_TOP - results_switcher.bounds.height), shouldDisplayEmptyHeader: true)
        results_events_table.alpha = 0.0
        results_events_table.center.x += bounds.width
        addSubview(results_switcher)
        addSubview(results_sponsors_table)
        addSubview(results_events_table)
        loader_view = LoaderView(frame: CGRect(x: 0, y: 0, width: LOADER_SIZE, height: LOADER_SIZE), topBottomInset: 0.0)
        loader_view.center = CGPoint(x: 0.5 * bounds.width, y: results_switcher.frame.maxY + LOADER_SPACING_TOP)
        loader_view.alpha = 0.0
        addSubview(loader_view)
        let tap_gest = UITapGestureRecognizer(target: self, action: #selector(SearchResultsView.searchViewPressed(_:)))
        tap_gest.cancelsTouchesInView = false
        addGestureRecognizer(tap_gest)
    }
    
    func searchViewPressed(_ sender:UITapGestureRecognizer) {
        if let _superView = superview {
            _superView.endEditing(true)
        }
    }
    
    func setLoading() {
        if currently_loading {
            return
        }
        currently_loading = true
        clearDataWithStoppingLoading(false)
        UIView.animate(withDuration: 0.2, animations: {
            self.loader_view.alpha = 1.0
            }, completion: {
                (fin:Bool) in
                self.loader_view.startLoading()
        })
    }
    
    func clearDataWithStoppingLoading(_ stopLoading:Bool) {
        results_sponsors_table.clearData()
        results_events_table.clearData()
        if stopLoading {
            if !search_topics_selected {
                results_switcher.setLeftSelected(true)
            }
            loader_view.stopLoading()
            loader_view.alpha = 0.0
            currently_loading = false
        }
    }
    
    func setSponsorsData(_ data:[SponsySponsor]?) {
        currently_loading = false
        loader_view.alpha = 0.0
        loader_view.stopLoading()
        results_sponsors_table.setData(data)
    }
    
    func setEventsData(_ data:[SponsyEvent]?) {
        currently_loading = false
        loader_view.alpha = 0.0
        loader_view.stopLoading()
        results_events_table.setData(data)
    }
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func searchSwitcherSelected(_ sender:SearchResultsSwitcher) {
        search_topics_selected = sender.topics_selected
        let shifting_value = bounds.width * (search_topics_selected ? 1.0 : -1.0)
        UIView.animate(withDuration: SWITCHING_ANIMATION_DURATION, animations: {
            self.results_sponsors_table.alpha = self.search_topics_selected ? 1.0 : 0.0
            self.results_sponsors_table.center.x += shifting_value
            self.results_events_table.alpha = self.search_topics_selected ? 0.0 : 1.0
            self.results_events_table.center.x += shifting_value
        })
    }
    
}

class MessagesTableView : UITableView, UITableViewDelegate, UITableViewDataSource {
    
    let EMPTY_LABEL_TEXT_SIZE:CGFloat = 18
    let EMPTY_LABEL_TEXT_COLOR = UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1.0)
    let CELLS_SPACING:CGFloat = 8
    let CELLS_BG_COLOR = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    let USERS_MAIN_TEXT_SIZE_REGULAR:CGFloat = 18
    let USERS_MAIN_TEXT_SIZE_EXTENDED:CGFloat = 20
    let USERS_DETAIL_TEXT_SIZE:CGFloat = 16
    let CELLS_HEIGHT_REGULAR:CGFloat = 40
    let CELLS_HEIGHT_EXTENDED:CGFloat = 60
    let USERS_MAIN_TEXT_COLOR = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1.0)
    let TABLE_SCROLL_RELATIVE_UPDATE:CGFloat = 0.83
    
    var flow_state:FlowState = FlowState.normal
    var users_empty_label:UILabel!
    var shouldDisplayEmptyHeader = true
    var paradigm:LoadableParadigm? = nil
    var messages_data:[SponsyRequest] = []
    
    init(frame:CGRect, tableInset:CGFloat, shouldDisplayEmptyHeader:Bool, paradigm:LoadableParadigm?) {
        super.init(frame: frame, style: .plain)
        self.shouldDisplayEmptyHeader = shouldDisplayEmptyHeader
        self.paradigm = paradigm
        if tableInset != 0.0 {
            contentInset = UIEdgeInsetsMake(tableInset, 0, tableInset, 0)
        }
        rowHeight = 100
        estimatedRowHeight = 140
        register(UINib.init(nibName: "RequestCell", bundle: nil), forCellReuseIdentifier: "request_cell")
        keyboardDismissMode = .onDrag
        backgroundColor = UIColor.clear
        let empty_label_size = ("Nothing found" ).size(attributes: [NSFontAttributeName:UIFont(name: "ProximaNovaCond-Regular", size: EMPTY_LABEL_TEXT_SIZE)!])
        users_empty_label = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width, height: empty_label_size.height))
        users_empty_label.text = "Nothing found"
        users_empty_label.textAlignment = .center
        users_empty_label.font = UIFont(name: "ProximaNovaCond-Regular", size: EMPTY_LABEL_TEXT_SIZE)
        users_empty_label.textColor = EMPTY_LABEL_TEXT_COLOR
        delegate = self
        dataSource = self
        tableFooterView = UIView()
        UIView.performWithoutAnimation {
            self.beginUpdates()
            self.endUpdates()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clearData() {
        tableHeaderView = nil
        reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /*
        if let par = paradigm {
            if flow_state == FlowState.normal {
                if scrollView.contentOffset.y >= max((TABLE_SCROLL_RELATIVE_UPDATE * scrollView.contentSize.height - bounds.height), scrollView.contentSize.height - 3.5 * bounds.height)  {
                    print("should load new messages...")
                    flow_state = FlowState.loading
                    let requests_task = HailyReceiveTask(dataOrigin: HailyDataOrigin.request, dataType: paradigm!.type == LoadableType.receivedMessages ? HailyDataType.incoming : HailyDataType.outgoing)
                    var lastId:Int? = nil
                    if messages_data.count > 0 {
                        lastId = messages_data.last!.message_id
                    }
                    requests_task.lastId = lastId
                    let task_builder = HailyTaskBuilder(session: General.session_data, anonymous: false, degradePossible: false)
                    task_builder.addTasks([requests_task])
                    task_builder.sendTasksWithCompletionHandler({
                        (parsedResponse:[HailyParsedResponse]?, error:Error?) in
                        var success = false
                        if let responses = parsedResponse {
                            if responses.count == 1 {
                                if let new_requests = responses[0].requests {
                                    DispatchQueue.main.async(execute: {
                                        var indices_insert:[IndexPath] = []
                                        for i in 0 ... new_requests.count - 1 {
                                            indices_insert.append(IndexPath.init(row: 0, section: self.messages_data.count + i))
                                        }
                                        self.messages_data.append(contentsOf: new_requests)
                                        self.insertRows(at: indices_insert, with: .fade)
                                    })
                                }
                            }
                        }
                        if !success {
                            print("Error while loading new requests")
                            DispatchQueue.main.async(execute: {
                                NotificationCenter.default.post(kHailyDataRetrievalErrorSliderNotification)
                            })
                            if let _err = error {
                                print(_err)
                            }
                        }
                    })
                    print("Sending new  request")
                }
            }
        }
 */
    }
    
    func loadInitialDataWithAnswerHandler(_ answerHandler:@escaping ((_ success:Bool) -> Void)) {
        let requests_task = HailyReceiveTask(dataOrigin: HailyDataOrigin.request, dataType: paradigm!.type == LoadableType.receivedMessages ? HailyDataType.incoming : HailyDataType.outgoing)
        let task_builder = HailyTaskBuilder(session: General.session_data, anonymous: false, degradePossible: false)
        task_builder.addTasks([requests_task])
        task_builder.sendTasksWithCompletionHandler({
            (parsedResponse:[HailyParsedResponse]?, error:Error?) in
            var success = false
            if let responses = parsedResponse {
                if responses.count == 1 {
                    print("Received initial requests response, handling now")
                    if let requests = responses[0].requests {
                        success = true
                        DispatchQueue.main.async(execute: {
                            self.messages_data = Array.init(requests)
                            if requests.count > 0 {
                                var rows_add:[IndexPath] = []
                                for i in 0 ... requests.count - 1 {
                                    rows_add.append(IndexPath.init(row: i, section: 0))
                                }
                                self.insertRows(at: rows_add, with: .fade)
                            }
                        })
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                            self.reloadData()
                        })
                    }
                    self.flow_state = responses[0].dataEnd ? FlowState.end : FlowState.normal
                    if let _lastValue = responses[0].lastValue {
                        self.paradigm!.lastValue = _lastValue
                    }
                }
            }
            if !success {
                print("Error with receiving initial requests")
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
        print("Sent initial  request, waiting for response")
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var message_cell = tableView.dequeueReusableCell(withIdentifier: "request_cell") as! RequestCell
        message_cell.layoutIfNeeded()
        message_cell.layoutSubviews()
        message_cell.setNeedsDisplay()
        message_cell.didMoveToSuperview()
        return message_cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let req = messages_data[indexPath.row]
        let menu = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        menu.addAction(UIAlertAction.init(title: "See Requester Details", style: .default, handler: {
            (act:UIAlertAction) in
            NotificationCenter.default.post(name: Notification.Name.init("notification_open_\(req.party_type)"), object: nil, userInfo: ["origin":"request","requestData":req])
        }))
        menu.addAction(UIAlertAction.init(title: "Close", style: .destructive, handler: nil))
        window?.rootViewController?.present(menu, animated: true, completion: nil)
        if UIDevice().userInterfaceIdiom != .phone {
            menu.popoverPresentationController?.sourceView = UIApplication.shared.keyWindow
            var finalRect = CGRect.init(x: 0, y: 60, width: bounds.width, height: 150)
            if let selectedCell = cellForRow(at: indexPath) {
                finalRect = selectedCell.convert(selectedCell.bounds, to: UIApplication.shared.keyWindow!)
            }
            menu.popoverPresentationController?.sourceRect = finalRect
            menu.popoverPresentationController?.permittedArrowDirections = [.any]
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! RequestCell).setData(messages_data[indexPath.row])
        cell.layoutIfNeeded()
        cell.layoutSubviews()
        cell.setNeedsDisplay()
        cell.didMoveToSuperview()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages_data.count
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

class TopicsTextualTableView : UITableView, UITableViewDelegate, UITableViewDataSource {
    
    let EMPTY_LABEL_TEXT_SIZE:CGFloat = 18
    let EMPTY_LABEL_TEXT_COLOR = UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1.0)
    let CELLS_SPACING:CGFloat = 8
    let CELLS_BG_COLOR = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    let USERS_MAIN_TEXT_SIZE:CGFloat = 18
    let CELLS_HEIGHT:CGFloat = 40
    let USERS_MAIN_TEXT_COLOR = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1.0)
    let TOPICS_ABOUT_TEXT_COLOR = UIColor(red: 124/255, green: 124/255, blue: 124/255, alpha: 1.0)
    let TOPICS_ABOUT_TEXT_SIZE:CGFloat = 15
    let TOPICS_MAIN_TEXT_COLOR = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1.0)
    let TOPICS_MAIN_TEXT_SIZE:CGFloat = 18
    
    var topics_results_data:[HailyInjectable] = []
    var topics_empty_label:UILabel!
    var shouldDisplayEmptyHeader = true
    var selected_item_handler:((_ openItem:HailyInjectable)->Void)? = nil
    
    init(frame:CGRect, shouldDisplayEmptyHeader:Bool) {
        super.init(frame: frame, style: .plain)
        self.shouldDisplayEmptyHeader = shouldDisplayEmptyHeader
        keyboardDismissMode = .onDrag
        delegate = self
        dataSource = self
        backgroundColor = UIColor.clear
        tableFooterView = UIView()
        let empty_label_size = ("Nothing found" ).size(attributes: [NSFontAttributeName:UIFont(name: "ProximaNovaCond-Regular", size: EMPTY_LABEL_TEXT_SIZE)!])
        topics_empty_label = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width, height: empty_label_size.height))
        topics_empty_label.text = "Nothing found"
        topics_empty_label.textAlignment = .center
        topics_empty_label.font = UIFont(name: "ProximaNovaCond-Regular", size: EMPTY_LABEL_TEXT_SIZE)
        topics_empty_label.textColor = TOPICS_ABOUT_TEXT_COLOR
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var topic_cell = tableView.dequeueReusableCell(withIdentifier: "topic_result_cell")
        if topic_cell == nil {
            topic_cell = UITableViewCell(style: .default, reuseIdentifier: "topic_result_cell")
        }
        var topic_title = ""
        var result_type = "" // event or sponsor
        if topics_results_data[indexPath.section] is SponsySponsor {
            topic_title = (topics_results_data[indexPath.section] as! SponsySponsor).title
            result_type = "sponsor"
        }
        else {
            topic_title = (topics_results_data[indexPath.section] as! SponsyEvent).title
            result_type = "event"
        }
        topic_title = topic_title.lowercased()
        topic_title.replaceSubrange(topic_title.startIndex ... topic_title.startIndex, with: topic_title.substring(to: topic_title.index(topic_title.startIndex, offsetBy: 1)).uppercased())
        topic_cell!.backgroundColor = CELLS_BG_COLOR
        let about_range = result_type == "event" ? NSMakeRange(0, 5) : NSMakeRange(0, 7)
        let attr_text = NSMutableAttributedString(string: "\(result_type) \(topic_title)")
        attr_text.addAttributes([NSFontAttributeName:UIFont(name: "ProximaNovaCond-Regular", size: TOPICS_ABOUT_TEXT_SIZE)!,NSForegroundColorAttributeName:TOPICS_ABOUT_TEXT_COLOR], range: about_range)
        attr_text.addAttributes([NSForegroundColorAttributeName:TOPICS_MAIN_TEXT_COLOR,NSFontAttributeName:UIFont(name: "ProximaNovaCond-Semibold", size: TOPICS_MAIN_TEXT_SIZE)!], range: NSMakeRange(about_range.length, attr_text.length - about_range.length))
        topic_cell!.textLabel!.attributedText = attr_text
        topic_cell!.accessoryType = .disclosureIndicator
        return topic_cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let select_handler = selected_item_handler {
            select_handler(topics_results_data[indexPath.section])
        }
        else {
            let item = topics_results_data[indexPath.section]
            var item_type = ""
            if item is SponsySponsor {
                item_type = "sponsor"
                NotificationCenter.default.post(name: Notification.Name.init("notification_open_sponsor"), object: nil, userInfo: ["origin":"sponsor","sponsorData":item])
            }
            else {
                item_type = "event"
                NotificationCenter.default.post(name: Notification.Name.init("notification_open_event"), object: nil, userInfo: ["origin":"event","eventData":item])
            }
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CELLS_HEIGHT
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("topics table asked for cells amount")
        return topics_results_data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer_sp = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: CELLS_SPACING))
        footer_sp.backgroundColor = UIColor.clear
        return section == topics_results_data.count - 1 ? nil : footer_sp
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == topics_results_data.count - 1 ? 0 : CELLS_SPACING
    }
    
    func clearData() {
        tableHeaderView = nil
        topics_results_data = []
        reloadData()
    }
    
    func setData(_ data:[HailyInjectable]?) {
        if let _d = data {
            topics_results_data = Array.init(_d)
            tableHeaderView = nil
            let reload_set = IndexSet(0 ..< _d.count)
            insertSections(reload_set, with: .fade)
        }
        else {
            if shouldDisplayEmptyHeader {
                tableHeaderView = topics_empty_label
            }
            topics_results_data = []
            reloadData()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class BoldButtonData : NSObject {
    
    var button_frame_required = false
    var button_color_normal:UIColor!
    var button_color_highlighted:UIColor!
    var text_color_normal:UIColor!
    var text_color_highlighted:UIColor!
    var button_action:()->Void!
    var button_title:String!
    
    init(buttonTitle:String, buttonColorStyle:BoldButtonColorStyle,buttonAction:@escaping ()->Void) {
        button_title = buttonTitle
        button_action = buttonAction
        switch buttonColorStyle {
        case .black:
            button_color_normal = UIColor(red: 11/255, green: 11/255, blue: 11/255, alpha: 1.0)
            button_color_highlighted = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 1.0)
            text_color_normal = UIColor.white
            text_color_highlighted = UIColor.white
        case .red:
            button_color_normal = UIColor(red: 200/255, green: 59/255, blue: 51/255, alpha: 1.0)
            button_color_highlighted = UIColor(red: 168/255, green: 50/255, blue: 43/255, alpha: 1.0)
            text_color_normal = UIColor.white
            text_color_highlighted = UIColor.white
        case .transparent:
            button_color_normal = UIColor.clear
            button_color_highlighted = UIColor.white
            text_color_normal = UIColor.white
            text_color_highlighted = UIColor(red: 230/255, green: 40/255, blue: 30/255, alpha: 1.0)
            button_frame_required = true
        case .blue:
            button_color_normal = UIColor(red: 56/255, green: 48/255, blue: 213/255, alpha: 1.0)
            button_color_highlighted = UIColor(red: 35/255, green: 32/255, blue: 142/255, alpha: 1.0)
            text_color_normal = UIColor.white
            text_color_highlighted = UIColor.white
        }
    }
    
}

enum BoldButtonColorStyle {
    case red, black, transparent, blue
}

class BoldButton : UIButton {
    
    let BOLD_BUTTON_TEXT_SIZE:CGFloat = 19
    let BOLD_BUTTON_FRAME_WIDTH:CGFloat = 3
    
    var button_data:BoldButtonData!
    
    init(frame:CGRect, buttonData:BoldButtonData) {
        super.init(frame: buttonData.button_frame_required ? frame.insetBy(dx: 0, dy: 0) : frame)
        if buttonData.button_frame_required {
            layer.borderColor = UIColor.white.cgColor
            layer.borderWidth = BOLD_BUTTON_FRAME_WIDTH
        }
        button_data = buttonData
        addTarget(self, action: #selector(BoldButton.buttonPressed(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(BoldButton.buttonHighlighted(_:)), for: .touchDown)
        addTarget(self, action: #selector(BoldButton.buttonUnhighlighted(_:)), for: .touchUpOutside)
        backgroundColor = buttonData.button_color_normal
        setTitle(buttonData.button_title, for: UIControlState())
        setTitleColor(UIColor.white, for: UIControlState())
        titleLabel!.font = UIFont(name: "ProximaNovaCond-Semibold", size: BOLD_BUTTON_TEXT_SIZE)
    }
    
    func buttonHighlighted(_ sender:UIButton) {
        sender.backgroundColor = button_data.button_color_highlighted
        sender.setTitleColor(button_data.text_color_highlighted, for: UIControlState())
    }
    
    func buttonUnhighlighted(_ sender:UIButton) {
        sender.backgroundColor = button_data.button_color_normal
        sender.setTitleColor(button_data.text_color_normal, for: UIControlState())
    }
    
    func buttonPressed(_ sender:UIButton) {
        sender.backgroundColor = button_data.button_color_normal
        sender.setTitleColor(button_data.text_color_normal, for: UIControlState())
        button_data.button_action()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class LoadableParadigm : NSObject {
    
    var origin:LoadableOrigin!
    var type:LoadableType!
    var id:Int = -1
    var lastValue:Double? = nil // may be required when loading new trending topics / opinions
    
    init(origin:LoadableOrigin, type:LoadableType,id:Int) {
        self.origin = origin
        self.type = type
        self.id = id
    }
    
}

class TroubleTopSlider : UIView {
    
    let EPHERMAL_SLIDER_PRESENSE_DURATION:CFTimeInterval = 1.5
    
    let BG_COLOR_RED = UIColor(red: 232/255, green: 78/255, blue: 75/255, alpha: 1.0)
    let BG_COLOR_BLACK = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1.0)
    let BG_COLOR_PURPLE = UIColor(red: 71/255, green: 2/255, blue: 135/255, alpha: 1.0)
    let TEXT_SIZE:CGFloat = 18
    let SLIDER_HEIGHT:CGFloat = 32
    let ANIMATION_DURATION:CFTimeInterval = 0.321
    var slider_type:TroubleTopSliderType!
    
    
    var text_label:UILabel!
    
    init(width:CGFloat, sliderType:TroubleTopSliderType, sliderText:String, sliderColor:TroubleTopSliderColor) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: SLIDER_HEIGHT))
        slider_type = sliderType
        backgroundColor = UIColor.clear
        text_label = UILabel(frame: bounds)
        switch sliderColor {
        case .black:
            text_label.backgroundColor = BG_COLOR_BLACK
        case .purple:
            text_label.backgroundColor = BG_COLOR_PURPLE
        case .red:
            text_label.backgroundColor = BG_COLOR_RED
        }
        text_label.text = sliderText
        text_label.font = UIFont(name: "ProximaNovaCond-Semibold", size: TEXT_SIZE)
        text_label.textColor = UIColor.white
        text_label.textAlignment = .center
        text_label.center.y -= SLIDER_HEIGHT
        addSubview(text_label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSliderShown(_ shown:Bool,animated:Bool) {
        var anim_shift = SLIDER_HEIGHT
        if let parentView = superview {
            if parentView.tag == 27 { // means we are dealing with detail topic view
                anim_shift += UIApplication.shared.statusBarFrame.height
            }
        }
        if !shown {
            anim_shift *= -1.0
        }
        UIView.animate(withDuration: animated ? ANIMATION_DURATION : 0.0, animations: {
            self.text_label.center.y += anim_shift
            }, completion: {
                (fin:Bool) in
                if !shown {
                    self.removeFromSuperview()
                }
        })
        if shown && slider_type == TroubleTopSliderType.ephermal {
            let _ = Timer.scheduledTimer(timeInterval: EPHERMAL_SLIDER_PRESENSE_DURATION, target: self, selector: #selector(TroubleTopSlider.removeSlider(_:)), userInfo: nil, repeats: false)
        }
    }
    
    func removeSlider(_ sender:Timer) {
        setSliderShown(false, animated: true)
        sender.invalidate()
    }
    
}

class HintView : UIView {
    
    let OVERLAY_OPACITY:CGFloat = 0.68
    let HINT_BG_WIDTH_RELATIVE:CGFloat = 0.88
    let HINT_BG_COLOR = UIColor(red: 1.0, green: 54/255, blue: 45/255, alpha: 1.0)
    let HINT_BG_PADDING:CGFloat = 6
    let HINT_MAX_FONT_SIZE:CGFloat = 18
    let HINT_BG_MARGIN_MIN:CGFloat = 10 // from transparent hole of drom screen's sides
    
    var overlay_view:UIView!
    var hint_bg_view:UIView!
    var hint_text_label:UILabel!
    var hintTappedHandler:(() -> Void)?
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        isHidden = true
        overlay_view = UIView(frame: bounds)
        overlay_view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: OVERLAY_OPACITY)
        overlay_view.alpha = 0.0
        overlay_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HintView.hintTapped(sender:))))
        hint_bg_view = UIView()
        hint_bg_view.backgroundColor = HINT_BG_COLOR
        hint_bg_view.alpha = 0.0
        hint_text_label = UILabel()
        hint_text_label.alpha = 0.0
        hint_text_label.font = UIFont(name: "ProximaNovaCond-Semibold", size: HINT_MAX_FONT_SIZE)!
        hint_text_label.textAlignment = .center
        hint_text_label.numberOfLines = 0
        hint_text_label.textColor = UIColor.white
        addSubview(overlay_view)
        addSubview(hint_bg_view)
        addSubview(hint_text_label)
    }
    
    func hintTapped(sender:UITapGestureRecognizer) {
        print("tapped hint, having handler:")
        print(hintTappedHandler)
        if let handler = hintTappedHandler {
            hintTappedHandler = nil
            handler()
        }
        else {
            setHintWithText(hintText: nil, CGRect.zero, nil)
        }
    }
    
    func setHintWithText(hintText:String?, _ transparentHole:CGRect, _ hintTappedHandler:(() -> Void)?) {
        self.hintTappedHandler = hintTappedHandler
        if let newHintText = hintText {
            let test_hint_label = UILabel(frame: CGRect.init(x: 0, y: 0, width: 1000, height: 1000))
            test_hint_label.numberOfLines = 0
            test_hint_label.font = hint_text_label.font
            test_hint_label.text = newHintText
            let real_hint_text_size = test_hint_label.textRect(forBounds: CGRect.init(x: 0, y: 0, width: bounds.width * HINT_BG_WIDTH_RELATIVE - 2.0 * HINT_BG_PADDING, height: 1000), limitedToNumberOfLines: 0)
            let real_hint_bg_size = CGSize(width: bounds.width * HINT_BG_WIDTH_RELATIVE, height: real_hint_text_size.height + 2.0 * HINT_BG_PADDING)
            var finalHintBgRect:CGRect!
            var finalHintLabelRect:CGRect!
            let upperHeightFree = transparentHole.minY - 2.0 * HINT_BG_MARGIN_MIN
            let bottomHeightFree = bounds.height - transparentHole.maxY - 2.0 * HINT_BG_MARGIN_MIN
            var upper:Bool?
            if real_hint_bg_size.height < upperHeightFree && real_hint_bg_size.height < bottomHeightFree {
                upper = arc4random_uniform(2) == 1
            }
            else if real_hint_bg_size.height < upperHeightFree {
                upper = true
            }
            else if real_hint_bg_size.height < bottomHeightFree {
                upper = false
            }
            if let normalPositionUpper = upper {
                finalHintBgRect = normalPositionUpper ? CGRect.init(x: (1.0 - HINT_BG_WIDTH_RELATIVE) * 0.5 * bounds.width, y: transparentHole.minY - HINT_BG_MARGIN_MIN - real_hint_bg_size.height, width: real_hint_bg_size.width, height: real_hint_bg_size.height) : CGRect.init(x: 0.5 * (bounds.width - real_hint_bg_size.width), y: transparentHole.maxY + HINT_BG_MARGIN_MIN, width: real_hint_bg_size.width, height: real_hint_bg_size.height)
                finalHintLabelRect = CGRect.init(x: finalHintBgRect.minX + HINT_BG_PADDING, y: finalHintBgRect.minY + HINT_BG_PADDING, width: real_hint_text_size.width, height: real_hint_text_size.height)
            }
            else {
                let normalPositionUpper = arc4random_uniform(2) == 1
                finalHintBgRect = normalPositionUpper ? CGRect.init(x: (1.0 - HINT_BG_WIDTH_RELATIVE) * 0.5 * bounds.width, y: HINT_BG_MARGIN_MIN, width: real_hint_bg_size.width, height: real_hint_bg_size.height) : CGRect.init(x: 0.5 * (bounds.width - real_hint_bg_size.width), y: bounds.height - HINT_BG_MARGIN_MIN - real_hint_bg_size.height, width: real_hint_bg_size.width, height: real_hint_bg_size.height)
                finalHintLabelRect = CGRect.init(x: finalHintBgRect.minX + HINT_BG_PADDING, y: finalHintBgRect.minY + HINT_BG_PADDING, width: real_hint_text_size.width, height: real_hint_text_size.height)
            }
            hint_text_label.text = newHintText
            if isHidden {
                hint_bg_view.frame = finalHintBgRect
                hint_text_label.frame = finalHintLabelRect
                isHidden = false
                UIView.animate(withDuration: 0.25, animations: {
                    self.overlay_view.alpha = 1.0
                })
                UIView.animate(withDuration: 0.25, delay: 0.2, options: .curveLinear, animations: {
                    self.hint_text_label.alpha = 1.0
                    self.hint_bg_view.alpha = 1.0
                    self.overlay_view.mask = TransparentHoleMaskView(frame: self.overlay_view.bounds, hole: transparentHole)
                }, completion: nil)
            }
            else {
                UIView.animate(withDuration: 0.25, animations: {
                    self.hint_bg_view.frame = finalHintBgRect
                    self.hint_text_label.frame = finalHintLabelRect
                    self.overlay_view.mask = TransparentHoleMaskView(frame: self.overlay_view.bounds, hole: transparentHole)
                })
            }
        }
        else {
            UIView.animate(withDuration: 0.35, animations: {
                self.hint_bg_view.alpha = 0.0
                self.hint_text_label.alpha = 0.0
                self.overlay_view.alpha = 0.0
            }, completion: {
                (fin:Bool) in
                self.overlay_view.mask = nil
                self.isHidden = true
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TransparentHoleMaskView : UIView {
    
    var hole:CGRect!
    
    init(frame:CGRect, hole:CGRect) {
        super.init(frame: frame)
        self.hole = hole
        backgroundColor = UIColor.clear
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        ctx?.fill(bounds)
        ctx?.clear(hole)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

enum TroubleTopSliderType : Int {
    case constant = 0, ephermal = 1
}

enum TroubleTopSliderColor :Int {
    case red = 0, black = 1, purple = 2
}

enum LoadableOrigin {
    case events, sponsors, messages, none
}

enum LoadableType {
    case all, own, sentMessages, receivedMessages, none
}
