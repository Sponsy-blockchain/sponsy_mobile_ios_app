//
//  CustomControls.swift
//  Haily
//
//  Created by Admin on 12.11.16.
//  Copyright © 2016 Vanoproduction. All rights reserved.
//

import UIKit


let PROFILE_EMBEDDED_OPINIONS_AMOUNT = 5
let PROFILE_EMBEDDED_TOPICS_AMOUNT = 4

enum HailyInjectableType : Int {
    case topicsButton = 1,  disableNotificationsSlider = 2,  sponsyEvent = 3, sponsySponsor = 4, sponsyVote = 5
}


enum ExploreItemType {
    case exploreItemBold, exploreItemSemibold
}

enum FlowState {
    case normal, loading, end, trouble
}

enum DataFooterState {
    case loading, trouble, hidden
}

protocol HailyInjectable : AnyObject{
    
    var type:HailyInjectableType { get set}
    
}


class ChildTabViewController : UIViewController {
    
    func prepareContent() {
        
    }
    
    var paradigm_type = ""
    
}


class TopicButton : NSObject, HailyInjectable {
    
    var type = HailyInjectableType.topicsButton
    var info = "" // loved, hated - for profile buttons
    var text = ""
    var range:NSRange?
    var color:UIColor?
    
    init(title:String,emphasizeRange:NSRange?,emphasizeColor:UIColor?) {
        text = title
        range = emphasizeRange
        color = emphasizeColor
    }
    
}

class SponsySponsorDetailed {
    
    var title = ""
    var sponsor_id = -1
    var sponsor_title = ""
    var location_info = ""
    var age_info = ""
    var money_info = ""
    var money_spent_info = ""
    var audience_required_info = ""
    var events_types = ""
    var description = ""
    
    init(dataDict:NSDictionary) {
        if let _sponsor_id = dataDict["_id"] as? Int {
            self.sponsor_id = _sponsor_id
        }
        if let _title = dataDict["title"] as? String {
            self.title = _title
        }
        if let _location = dataDict["location_info"] as? String {
            location_info = _location
        }
        if let _money = dataDict["money_info"] as? String {
            money_info = _money
        }
        if let _age = dataDict["age_info"] as? String {
            age_info = _age
        }
        if let _money_spent = dataDict["money_spent_info"] as? String {
            money_spent_info = _money_spent
        }
        if let _required_people = dataDict["audience_required_info"] as? String {
            audience_required_info = _required_people
        }
        if let _types = dataDict["event_types"] as? String {
            events_types = _types
        }
        if let descr = dataDict["description"] as? String {
            description = descr
        }
    }
    
}

class SponsyEventDetailed {
    
    var title = ""
    var event_id:Int = -1
    var location_info = ""
    var date_info = ""
    var money_info = ""
    var audience_info = ""
    var age_info = ""
    var media_info = ""
    var gender_info = ""
    var description = ""
    
    
    init(dataDict:NSDictionary) {
        if let _event_id = dataDict["_id"] as? Int {
            self.event_id = _event_id
        }
        if let _title = dataDict["title"] as? String {
            self.title = _title
        }
        if let _location = dataDict["location_info"] as? String {
            location_info = _location
        }
        if let _date = dataDict["date_info"] as? String {
            date_info = _date
        }
        if let _age = dataDict["age_info"] as? String {
            age_info = _age
        }
        if let _money = dataDict["money_info"] as? String {
            money_info = _money
        }
        if let _people = dataDict["audience_info"] as? String {
            audience_info = _people
        }
        if let _media = dataDict["media_info"] as? String {
            media_info = _media
        }
        if let gender = dataDict["gender_info"] as? String {
            gender_info = gender
        }
        if let descr = dataDict["description"] as? String {
            description = descr
        }
    }
    
}

class SponsyRequest {
    
    var title = ""
    var message = ""
    var new = false
    var message_id = -1
    var party_id = -1
    var party_type = "" // event, sponsor
    
    init(dataDict:NSDictionary) {
        if let _message_id = dataDict["_id"] as? Int {
            message_id = _message_id
        }
        if let _from = dataDict["party_id"] as? Int {
            party_id = _from
        }
        if let _title = dataDict["title"] as? String {
            title = _title
        }
        if let _from_type = dataDict["party_type"] as? String {
            party_type = _from_type
        }
        if let _msg = dataDict["message"] as? String {
            message = _msg
        }
        if let _new = dataDict["new"] as? Bool {
            new = _new
        }
    }
    
}


class SponsySponsor : NSObject, HailyInjectable, NSCoding {
    
    var type = HailyInjectableType.sponsySponsor
    var title = ""
    var sponsor_id:Int = -1
    var location_info = ""
    var age_info = ""
    var money_info = ""
    
    init(sponsorId:Int,sponsorTitle:String) {
        sponsor_id = sponsorId
        title = sponsorTitle
    }
    
    init(dataDict:NSDictionary) {
        if let _sponsor_id = dataDict["_id"] as? Int {
            self.sponsor_id = _sponsor_id
        }
        if let _title = dataDict["title"] as? String {
            self.title = _title
        }
        if let _location = dataDict["location_info"] as? String {
            location_info = _location
        }
        if let _money = dataDict["money_info"] as? String {
            money_info = _money
        }
        if let _age = dataDict["age_info"] as? String {
            age_info = _age
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        sponsor_id = aDecoder.decodeInteger(forKey: "_id")
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.age_info = aDecoder.decodeObject(forKey: "age") as! String
        self.money_info = aDecoder.decodeObject(forKey: "money") as! String
        self.location_info = aDecoder.decodeObject(forKey: "location") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(sponsor_id, forKey: "_id")
        aCoder.encode(location_info, forKey: "location")
        aCoder.encode(money_info, forKey: "money")
        aCoder.encode(age_info, forKey: "age")
    }
    
    
}


class SponsyEvent : NSObject, HailyInjectable, NSCoding {
    
    var type = HailyInjectableType.sponsyEvent
    var title = ""
    var event_id:Int = -1
    var location_info = ""
    var date_info = ""
    var money_info = ""
    var audience_info = ""
    
    init(eventId:Int,eventTitle:String) {
        self.event_id = eventId
        self.title = eventTitle
    }
    
    init(dataDict:NSDictionary) {
        if let _event_id = dataDict["_id"] as? Int {
            self.event_id = _event_id
        }
        if let _title = dataDict["title"] as? String {
            self.title = _title
        }
        if let _location = dataDict["location_info"] as? String {
            location_info = _location
        }
        if let _date = dataDict["date_info"] as? String {
            date_info = _date
        }
        if let _money = dataDict["money_info"] as? String {
            money_info = _money
        }
        if let _people = dataDict["audience_info"] as? String {
            audience_info = _people
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        event_id = aDecoder.decodeInteger(forKey: "_id")
        self.title = aDecoder.decodeObject(forKey: "title") as! String
        self.date_info = aDecoder.decodeObject(forKey: "date") as! String
        self.audience_info = aDecoder.decodeObject(forKey: "audience") as! String
        self.money_info = aDecoder.decodeObject(forKey: "money") as! String
        self.location_info = aDecoder.decodeObject(forKey: "location") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(event_id, forKey: "_id")
        aCoder.encode(date_info, forKey: "date")
        aCoder.encode(location_info, forKey: "location")
        aCoder.encode(money_info, forKey: "money")
        aCoder.encode(audience_info, forKey: "audience")
    }
    
}

class SponsyVote : HailyInjectable {
    
    var type = HailyInjectableType.sponsyVote
    var vote_id = -1
    var event_id = -1
    var sponsor_id = -1
    var sponsor_title = ""
    var event_title = ""
    var vote_agree_ratio = -1
    
    init(voteId:Int) {
        
    }
    
    init(dataDict:NSDictionary) {
        if let _vote_id = dataDict["_id"] as? Int {
            vote_id = _vote_id
        }
        if let _event_id = dataDict["event_id"] as? Int {
            event_id = _event_id
        }
        if let _sponsor_id = dataDict["sponsor_id"] as? Int {
            sponsor_id = _sponsor_id
        }
        if let _sponsor_title = dataDict["sponsor_title"] as? String {
            sponsor_title = _sponsor_title
        }
        if let _event_title = dataDict["event_title"] as? String {
            event_title = _event_title
        }
        if let ratio = dataDict["vote_agree_ratio"] as? Int {
            vote_agree_ratio = ratio
        }
    }
}


class BottomTabBar : UIControl {
    
    let BOTTOM_LABEL_SPACING:CGFloat = 1
    let UPPER_LABEL_SPACING:CGFloat = 4
    let UPPER_IMAGE_SPACING:CGFloat = 6
    let MAX_LABEL_WIDTH_RELATIVE:CGFloat = 0.75
    let MAX_LABEL_HEIGHT_RELATIVE:CGFloat = 0.45
    let LABEL_COLOR_SELECTED:UIColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
    let LABEL_COLOR_UNSELECTED:UIColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1.0)
    let SEPARATOR_COLOR:UIColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
    let SEPARATOR_WIDTH:CGFloat = 1
    let SEPARATOR_HEIGHT_RELATIVE:CGFloat = 0.5
    let SELECTED_BG_COLOR:UIColor = UIColor(red: 231/255, green: 40/255, blue: 30/255, alpha: 1.0)
    let TAB_SWITCH_ANIMATION_DURATION:CFTimeInterval = 0.25
    
    let tabs_labels_titles:[String] = ["SPONSEES","SPONSORS","VOTE","REQUESTS"]
    var tabs_labels:[UILabel] = []
    var tabs_pics:[UIImageView] = []
    var sep_y_top:CGFloat = 0
    var sep_y_bottom:CGFloat = 0
    var selected_bg:UIView!
    var selected_bg_layer:CALayer!
    var selected_tab:Int = 1
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        self.backgroundColor = UIColor.white
        selected_bg_layer = CALayer()
        selected_bg_layer.backgroundColor = SELECTED_BG_COLOR.cgColor
        selected_bg_layer.frame = CGRect(x: 0, y: 0, width: bounds.width / 4.0, height: bounds.height)
        selected_bg_layer.actions = ["position":NSNull()]
        self.layer.addSublayer(selected_bg_layer)
        sep_y_top = bounds.height * SEPARATOR_HEIGHT_RELATIVE * 0.5
        sep_y_bottom = sep_y_top + bounds.height * SEPARATOR_HEIGHT_RELATIVE
        var min_font:CGFloat = 999999
        for tab_label in tabs_labels_titles {
            let current_size_width = General.apprFontSize(tab_label, str_attr: nil, fontName: "ProximaNovaCond-Semibold", ref_value: MAX_LABEL_WIDTH_RELATIVE * self.bounds.width / 4.0, type: "w", attributed: false, maxFontSize: 30)
            let current_size_height = General.apprFontSize(tab_label, str_attr: nil, fontName: "ProximaNovaCond-Semibold", ref_value: MAX_LABEL_HEIGHT_RELATIVE * self.bounds.height, type: "h", attributed: false, maxFontSize: 30)
            if current_size_width < min_font {
                min_font = current_size_width
            }
            if current_size_height < min_font {
                min_font = current_size_height
            }
        }
        for no in 1...4 {
            tabs_labels.append(getLabelForTabNo(no, withMinFontSize: min_font))
            tabs_pics.append(getImageForTabNo(no))
        }
        self.setNeedsDisplay()
        for tab_label in tabs_labels {
            addSubview(tab_label)
        }
        for tab_pic in tabs_pics {
            addSubview(tab_pic)
        }
    }
    
    func getImageForTabNo(_ no:Int) -> UIImageView {
        let img = UIImageView(frame: CGRect(x: CGFloat(no - 1) * self.bounds.width / 4.0, y: UPPER_IMAGE_SPACING, width: bounds.width / 4.0, height: tabs_labels[no - 1].frame.minY - UPPER_IMAGE_SPACING - UPPER_LABEL_SPACING))
        img.contentMode = .scaleAspectFit
        img.image = UIImage(named: no == 1 ? "bottom_bar_selected_tab_\(no)" : "bottom_bar_unselected_tab_\(no)")!
        return img
    }
    
    func getLabelForTabNo(_ no:Int,withMinFontSize:CGFloat) -> UILabel {
        let label_1 = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        label_1.text = tabs_labels_titles[no - 1]
        label_1.textColor = no == 1 ? LABEL_COLOR_SELECTED : LABEL_COLOR_UNSELECTED
        label_1.textAlignment = .center
        let label_height_1 = label_1.textRect(forBounds: label_1.bounds, limitedToNumberOfLines: 1).height
        label_1.frame = CGRect(x: CGFloat(no - 1) * self.bounds.width / 4.0 , y: bounds.height - BOTTOM_LABEL_SPACING - label_height_1, width: self.bounds.width / 4.0, height: label_height_1)
        label_1.font = UIFont(name: "ProximaNovaCond-Semibold", size: withMinFontSize)
        print("bottom_var_label height \(label_1.bounds.height)")
        return label_1
    }
    
    override func draw(_ rect: CGRect) {
        print("drawing...")
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setLineWidth(SEPARATOR_WIDTH)
        ctx?.setStrokeColor(SEPARATOR_COLOR.cgColor)
        for sep in 1...3 {
            ctx?.move(to: CGPoint(x: CGFloat(sep) * self.bounds.width / 4.0, y: sep_y_top))
            ctx?.addLine(to: CGPoint(x: CGFloat(sep) * self.bounds.width / 4.0, y: sep_y_bottom))
        }
        ctx?.strokePath()
        /*
        CGContextMoveToPoint(ctx, 0, 1)
        CGContextAddLineToPoint(ctx, bounds.width, 1)
        CGContextSetStrokeColorWithColor(ctx, UIColor.redColor().CGColor)
        CGContextStrokePath(ctx)
*/
    }
    
    func setSelectedTab(_ target_tab:Int) {
        tabs_labels[selected_tab - 1].textColor = LABEL_COLOR_UNSELECTED
        tabs_labels[target_tab - 1].textColor = LABEL_COLOR_SELECTED
        tabs_pics[selected_tab - 1].image = UIImage(named: "bottom_bar_unselected_tab_\(selected_tab)")!
        tabs_pics[target_tab - 1].image = UIImage(named: "bottom_bar_selected_tab_\(target_tab)")!
        let final_bg_center = (CGFloat(target_tab - 1) + 0.5) * bounds.width / 4.0
        let start_bg_center = selected_bg_layer.position.x
        let bg_anim = CABasicAnimation(keyPath: "position.x")
        bg_anim.duration = TAB_SWITCH_ANIMATION_DURATION
        bg_anim.fromValue = start_bg_center
        bg_anim.toValue = final_bg_center
        bg_anim.timingFunction = General.anim_func
        selected_bg_layer.position.x = final_bg_center
        selected_bg_layer.add(bg_anim, forKey: "bg_anim")
        selected_tab = target_tab
        sendActions(for: UIControlEvents.valueChanged)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let target_tab = Int(touch.location(in: self).x / (bounds.width / 4.0)) + 1
        if target_tab != selected_tab {
            setSelectedTab(target_tab)
        }
        return false
    }
}

class UpperPageSwitcher : UIControl {
    
    let BG_COLOR:UIColor = UIColor(red: 200/255, green: 59/255, blue: 51/255, alpha: 1.0)
    let LABEL_TEXT_SIZE:CGFloat = 16
    let LABEL_TEXT_COLOR:UIColor = UIColor.white
    let LABEL_SPACING_SIDES:CGFloat = 9 // padding from bubble's around
    let LABEL_SPACING_UP_BOTTOM:CGFloat = 4
    let SLIDER_COLOR:UIColor = UIColor.white
    let SLIDER_WIDTH:CGFloat = 3
    let SLIDER_WIDTH_RELATIVE:CGFloat = 1.2 // to bubble's width
    let SLIDER_BOTTOM_SPACING:CGFloat = 2
    let BUBBLE_CORNER_RADIUS:CGFloat = 7
    let BUBBLE_BG_COLOR:UIColor = UIColor(red: 169/255, green: 45/255, blue: 38/255, alpha: 1.0)
    let LABEL_UNSELECTED_OPACITY:CGFloat = 0.75
    let PAGE_TRANSITION_DURATION:CFTimeInterval = 0.35
    
    var selected_page:Int = 1
    let pages_titles:[String] = ["ALL","OWN"]
    var pages_labels:[UILabel] = []
    var bubbles_frames:[CGRect] = []
    var sliders_frames:[CGRect] = []
    var bubble_layer:CALayer!
    var slider_layer:CALayer!
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        backgroundColor = BG_COLOR
        for no in 1...2 {
            let label = getPageLabelForPageNo(no)
            pages_labels.append(label)
            let bubble_frame = CGRect(x: label.frame.minX - LABEL_SPACING_SIDES, y: 0, width: LABEL_SPACING_SIDES * 2.0 + label.bounds.width, height: LABEL_SPACING_UP_BOTTOM * 2.0 + label.bounds.height)
            bubbles_frames.append(bubble_frame)
            sliders_frames.append(CGRect(x: bubble_frame.minX - (SLIDER_WIDTH_RELATIVE - 1.0) * 0.5 * bubble_frame.width, y: bounds.height - SLIDER_BOTTOM_SPACING - SLIDER_WIDTH, width: bubble_frame.width * SLIDER_WIDTH_RELATIVE, height: SLIDER_WIDTH))
        }
        pages_labels[1].alpha = LABEL_UNSELECTED_OPACITY
        bubble_layer = CALayer()
        bubble_layer.actions = ["frame":NSNull()]
        bubble_layer.cornerRadius = BUBBLE_CORNER_RADIUS
        bubble_layer.backgroundColor = BUBBLE_BG_COLOR.cgColor
        bubble_layer.frame = bubbles_frames[0]
        slider_layer = CALayer()
        //slider_layer.hidden = true
        slider_layer.actions = ["frame":NSNull()]
        slider_layer.backgroundColor = SLIDER_COLOR.cgColor
        slider_layer.frame = sliders_frames[0]
        layer.addSublayer(slider_layer)
        layer.addSublayer(bubble_layer)
        for pageLabel in pages_labels {
            addSubview(pageLabel)
        }
    }
    
    func setBubbleTranslationToPageNo(_ no:Int, percentCompleted:CGFloat) {
        let final_page = no - 1
        let start_page = final_page == 0 ? 1 : 0
        let width_delta = (bubbles_frames[final_page].width - bubbles_frames[start_page].width) * percentCompleted
        let frame_min_x_delta = (bubbles_frames[final_page].minX - bubbles_frames[start_page].minX) * percentCompleted
        let final_frame = CGRect(x: bubbles_frames[start_page].minX + frame_min_x_delta, y: bubbles_frames[0].minY, width: bubbles_frames[start_page].width + width_delta, height: bubbles_frames[0].height)
        bubble_layer.frame = final_frame
        let slider_width_delta = (sliders_frames[final_page].width - sliders_frames[start_page].width) * percentCompleted
        let slider_min_x_delta = (sliders_frames[final_page].minX - sliders_frames[start_page].minX) * percentCompleted
        let final_slider_frame = CGRect(x: sliders_frames[start_page].minX + slider_min_x_delta, y: sliders_frames[0].minY, width: sliders_frames[start_page].width + slider_width_delta, height: sliders_frames[0].height)
        slider_layer.frame = final_slider_frame
    }
    
    func setBubbleTranslationFinishedToPageNo(_ no:Int) {
        slider_layer.frame = sliders_frames[no - 1]
        bubble_layer.frame = bubbles_frames[no - 1]
        pages_labels[selected_page - 1].alpha = LABEL_UNSELECTED_OPACITY
        pages_labels[no - 1].alpha = 1.0
        selected_page = no
    }
    
    func setBubbleTranslationCancelled() {
        bubble_layer.frame = bubbles_frames[selected_page - 1]
        slider_layer.frame = sliders_frames[selected_page - 1]
    }
    
    func getPageLabelForPageNo(_ no:Int) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 70))
        label.textAlignment = .center
        label.textColor = LABEL_TEXT_COLOR
        label.font = UIFont(name: "ProximaNova-Semibold", size: LABEL_TEXT_SIZE)!
        label.text = pages_titles[no - 1]
        let label_dimensions = label.textRect(forBounds: label.bounds, limitedToNumberOfLines: 1)
        label.frame = CGRect(x: (CGFloat(no - 1) * 0.5 + 0.25) * bounds.width - 0.5 * label_dimensions.width, y: LABEL_SPACING_UP_BOTTOM, width: label_dimensions.width, height: label_dimensions.height)
        return label
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let target_page = touch.location(in: self).x >= 0.5 * bounds.width ? 2 : 1
        if target_page != selected_page {
            let start_frame = bubbles_frames[selected_page - 1]
            let fin_frame = bubbles_frames[target_page - 1]
            let bubble_anim = CABasicAnimation(keyPath: "frame")
            bubble_anim.duration = PAGE_TRANSITION_DURATION
            bubble_anim.timingFunction = General.anim_func
            bubble_anim.fromValue = NSValue(cgRect : start_frame)
            bubble_anim.toValue = NSValue(cgRect : fin_frame)
            bubble_layer.frame = fin_frame
            bubble_layer.add(bubble_anim, forKey: "bubble_anim")
            let slider_anim = CABasicAnimation(keyPath: "frame")
            let slider_start_frame = sliders_frames[selected_page - 1]
            let slider_fin_frame = sliders_frames[target_page - 1]
            slider_anim.duration = PAGE_TRANSITION_DURATION
            slider_anim.timingFunction = General.anim_func
            slider_anim.fromValue = NSValue(cgRect : slider_start_frame)
            slider_anim.toValue = NSValue(cgRect : slider_fin_frame)
            slider_layer.frame = slider_fin_frame
            slider_layer.add(slider_anim, forKey: "slider_anim")
            pages_labels[target_page - 1].alpha = 1.0
            pages_labels[selected_page - 1].alpha = LABEL_UNSELECTED_OPACITY
            selected_page = target_page
            sendActions(for: UIControlEvents.valueChanged)
        }
        return false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

enum BottomMenuType {
    
    case opinionMenu, topicMenu, imagePickerMenu
    
}

enum MenuAction {
    
    case topicShare, opinionShare, addFavorites, opinionReport, topicReport, undefined, imagePicked, pickImageGallery
}
/*
class BottomMenu : UIControl, UITableViewDataSource, UITableViewDelegate, CAAnimationDelegate, ImagePickerDelegate{
    
    let OVERLAY_OPACITY:CGFloat = 0.67
    let MENU_TABLE_SPACING_BOTTOM:CGFloat = 14
    let MENU_TABLE_SPACING_SECTIONS:CGFloat = 8
    let MENU_TABLE_CELL_HEIGHT_REGULAR:CGFloat = 42
    let MENU_TABLE_CELL_HEIGHT_IMAGE_PICKER:CGFloat = 100
    let MENU_TABLE_WIDTH_RELATIVE:CGFloat = 0.91
    let MENU_OPINION_ITEMS_AMOUNT:CGFloat = 3.0 //cancel inclusive
    let MENU_TOPIC_ITEMS_AMOUNT:CGFloat = 4.0
    let MENU_TABLE_CORNER_RADIUS:CGFloat = 9
    let OPTION_TEXT_COLOR_NORMAL:UIColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1.0)
    let OPTION_TEXT_COLOR_WARNING:UIColor = UIColor(red: 190/255, green: 46/255, blue: 46/255, alpha: 1.0)
    let MENU_PRESENTATION_DURATION:CFTimeInterval = 0.26
    
    var overlay_view:UIView!
    var picker_images:[(image:UIImage,imageUrl:String)]?
    var menu_type:BottomMenuType
    var menu_table:UITableView!
    var menu_table_hidden_center_y:CGFloat = 0
    var menu_Table_visible_center_y:CGFloat = 0
    var selected_action:MenuAction = .undefined
    var pickedImage:(image:UIImage,imageUrl:String)?
    var opinionView:UIView?
    var opinionHeartIconFrame:CGRect?
    var opinionMenuButtonFrame:CGRect?
    var topicMenuButtonView:UIView?
    var origin_id:Int = -1
    var originData:HailyInjectable?
    
    init(frame: CGRect, menuType:BottomMenuType, originId: Int) {
        menu_type = menuType
        origin_id = originId
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(BottomMenu.setupImagesRequest), name: Notification.Name.init("notification_setup_images"), object: nil)
        self.isHidden = true
        overlay_view = UIView(frame: self.frame)
        overlay_view.backgroundColor = UIColor(red: 36/255, green: 36/255, blue: 36/255, alpha: 1.0)
        overlay_view.alpha = 0
        overlay_view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BottomMenu.overlayTapped(_:))))
        addSubview(overlay_view)
        let table_width = MENU_TABLE_WIDTH_RELATIVE * bounds.width
        let table_height = getTableHeight()
        let table_frame = CGRect(x: 0.5 * bounds.width - 0.5 * table_width, y: bounds.height , width: table_width, height: table_height)
        menu_table_hidden_center_y = table_frame.midY
        menu_Table_visible_center_y = menu_table_hidden_center_y - MENU_TABLE_SPACING_BOTTOM - table_height
        menu_table = UITableView(frame: table_frame, style: .plain)
        menu_table.backgroundColor = UIColor.clear
        menu_table.layer.cornerRadius = MENU_TABLE_CORNER_RADIUS
        menu_table.register(MenuTableCell.self, forCellReuseIdentifier: "menu_table_cell")
        menu_table.register(MenuTableImagePickerCell.self, forCellReuseIdentifier: "menu_table_image_picker_cell")
        menu_table.dataSource = self
        menu_table.delegate = self
        menu_table.isScrollEnabled = false
        addSubview(menu_table)
    }
    
    func setupImagesRequest(sender:Notification) {
        if let images_setup = sender.userInfo!["imagesSetup"] as? [(image:UIImage,imageUrl:String)] {
            setupImages(images: images_setup)
        }
    }
    
    func setupImages(images:[(image:UIImage,imageUrl:String)]?) {
        if menu_type == BottomMenuType.imagePickerMenu {
            if let picker_cell = menu_table.cellForRow(at: IndexPath(row: 0, section: 0)) as? MenuTableImagePickerCell {
                picker_images = images
                picker_cell.setupImages(images: images)
            }
        }
    }
    
    func setMenuType(_ menuType:BottomMenuType, withOriginId:Int) {
        origin_id = withOriginId
        menu_type = menuType
        let table_width = MENU_TABLE_WIDTH_RELATIVE * bounds.width
        let table_height = getTableHeight()
        let table_frame = CGRect(x: 0.5 * bounds.width - 0.5 * table_width, y: bounds.height , width: table_width, height: table_height)
        menu_table_hidden_center_y = table_frame.midY
        menu_Table_visible_center_y = menu_table_hidden_center_y - MENU_TABLE_SPACING_BOTTOM - table_height
        menu_table.frame = table_frame
        menu_table.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return menu_type == BottomMenuType.imagePickerMenu && indexPath.section == 0 && indexPath.row == 0 ? tableView.dequeueReusableCell(withIdentifier: "menu_table_image_picker_cell") as! MenuTableImagePickerCell : tableView.dequeueReusableCell(withIdentifier: "menu_table_cell") as! MenuTableCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var regular_cell = true
        var option_text_color = OPTION_TEXT_COLOR_NORMAL
        var option_text:String!
        var option_icon:UIImage? = nil
        switch indexPath.section {
        case 0:
            switch menu_type {
            case BottomMenuType.opinionMenu:
                switch indexPath.row {
                case 0:
                    option_text = "Share"
                    option_icon = UIImage(named: "menu_share_icon")!
                case 1:
                    option_text = "Report"
                    option_icon = UIImage(named: "menu_report_icon")!
                    option_text_color = OPTION_TEXT_COLOR_WARNING
                default:
                    break
                }
            case .topicMenu:
                switch indexPath.row {
                case 0:
                    option_text = "Share"
                    option_icon = UIImage(named: "menu_share_icon")!
                case 1:
                    option_text = "Report"
                    option_icon = UIImage(named: "menu_report_icon")!
                    option_text_color = OPTION_TEXT_COLOR_WARNING
                case 2:
                    option_text = General.topicIsFavorite(origin_id) ? "Remove from favorites" : "Add to favorites"
                    option_icon = UIImage(named: "menu_favorites_icon")!
                default:
                    break
                }
            case .imagePickerMenu:
                switch indexPath.row {
                case 0:
                    regular_cell = false
                case 1:
                    option_text = "Upload image"
                    option_icon = UIImage(named: "bg_picture_icon")!
                default:
                    break
                }
            }
        case 1:
            option_text = "Cancel"
        default:
            break
        }
        if regular_cell {
            (cell as! MenuTableCell).setOptionTitle(option_text, image: option_icon, titleColor: option_text_color)
        }
        else {
            (cell as! MenuTableImagePickerCell).setupImages(images: picker_images)
            (cell as! MenuTableImagePickerCell).image_picker_delegate = self
        }
        cell.backgroundColor = UIColor.white
    }
    
    func imagePicked(_ imagePicked: (UIImage, String)) {
        selected_action = MenuAction.imagePicked
        pickedImage = imagePicked
        sendActions(for: .valueChanged)
        setMenuShown(false)
    }
    
    func getTableHeight() -> CGFloat {
        if menu_type == BottomMenuType.imagePickerMenu {
            return 2.0 * MENU_TABLE_CELL_HEIGHT_REGULAR + MENU_TABLE_SPACING_SECTIONS + MENU_TABLE_CELL_HEIGHT_IMAGE_PICKER
        }
        else {
            return MENU_TABLE_CELL_HEIGHT_REGULAR * (menu_type == .opinionMenu ? MENU_OPINION_ITEMS_AMOUNT : MENU_TOPIC_ITEMS_AMOUNT) + MENU_TABLE_SPACING_SECTIONS
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return menu_type == BottomMenuType.imagePickerMenu ? indexPath.row == 0 && indexPath.section == 0 ? MENU_TABLE_CELL_HEIGHT_IMAGE_PICKER : MENU_TABLE_CELL_HEIGHT_REGULAR : MENU_TABLE_CELL_HEIGHT_REGULAR
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? MENU_TABLE_SPACING_SECTIONS : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let section_spacing = UIView(frame: CGRect(x: 0, y: 0, width: menu_table.bounds.width, height: MENU_TABLE_SPACING_SECTIONS))
        section_spacing.backgroundColor = UIColor.clear
        return section == 0 ? section_spacing : nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        }
        switch menu_type {
        case .imagePickerMenu:
            return 2
        case .opinionMenu:
            return Int(MENU_OPINION_ITEMS_AMOUNT) - 1
        case .topicMenu:
            return Int(MENU_TOPIC_ITEMS_AMOUNT) - 1
        }
    }
    
    func setMenuShown(_ shown:Bool) {
        if shown {
            isHidden = false
        }
        else {
            picker_images = nil
        }
        let present_anim = CABasicAnimation(keyPath: "position.y")
        present_anim.setValue(shown ? "setShown" : "setHidden", forKey: "animType")
        present_anim.delegate = self
        present_anim.beginTime = CACurrentMediaTime() + 0.1
        present_anim.fromValue = shown ? menu_table_hidden_center_y : menu_Table_visible_center_y
        present_anim.toValue = shown ? menu_Table_visible_center_y : menu_table_hidden_center_y
        present_anim.duration = MENU_PRESENTATION_DURATION
        present_anim.timingFunction = General.anim_func
        menu_table.layer.add(present_anim, forKey: "present_anim")
        UIView.animate(withDuration: MENU_PRESENTATION_DURATION, animations: {
            self.overlay_view.alpha = shown ? self.OVERLAY_OPACITY : 0.0
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0 {
            switch menu_type {
            case BottomMenuType.opinionMenu:
                switch indexPath.row {
                case 0:
                    selected_action = .opinionShare
                case 1:
                    selected_action = .opinionReport
                default:
                    break
                }
            case BottomMenuType.topicMenu:
                switch indexPath.row {
                case 0:
                    selected_action = .topicShare
                case 1:
                    selected_action = .topicReport
                case 2:
                    selected_action = .addFavorites
                default:
                    break
                }
            case .imagePickerMenu:
                switch indexPath.row {
                case 0:
                    return
                case 1:
                    selected_action = .pickImageGallery
                default:
                    break
                }
            }
            sendActions(for: .valueChanged)
        }
        setMenuShown(false)
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        menu_table.center.y = anim.value(forKey: "animType") as! String == "setShown" ? menu_Table_visible_center_y : menu_table_hidden_center_y
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim.value(forKey: "animType") as! String == "setHidden" {
            isHidden = true
        }
    }
    
    func overlayTapped(_ sender:UITapGestureRecognizer) {
        setMenuShown(false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
 */

enum EmotionButtonType {
    case love,hate
}

class EmotionExpressionButton : UIControl {
    
    let FONTS_SIZE_DIF:CGFloat = 5
    var INCLINATION_ANGLE:CGFloat = 0.0
    let MIN_ELEMS_SPACING:CGFloat = 20
    let ICON_TEXT_SPACING:CGFloat = 20
    let HEART_WIDTH_LOVE:CGFloat = 32
    let HEART_WIDTH_HATE:CGFloat = 32
    let HEART_ASPECT_LOVE:CGFloat = 0.892
    let HEART_ASPECT_HATE:CGFloat = 0.852
    let BG_COLOR_HATE = UIColor(red: 211/255, green: 26/255, blue: 26/255, alpha: 1.0)
    let BG_COLOR_HATE_HIGHLIGHTED = UIColor(red: 172/255, green: 21/255, blue: 21/255, alpha: 1.0)
    let BG_COLOR_LOVE = UIColor(red: 0, green: 143/255, blue: 3/255, alpha: 1.0)
    let BG_COLOR_LOVE_HIGHLIGHTED = UIColor(red: 0, green: 114/255, blue: 2/255, alpha: 1.0)
    let TEXT_COLOR_LOVE = UIColor(red: 223/255, green: 255/255, blue: 224/255, alpha: 1.0)
    let TEXT_COLOR_HATE = UIColor(red: 253/255, green: 227/255, blue: 228/255, alpha: 1.0)
    let TEXT_MAX_FONT_SIZE:CGFloat = 33.0
    
    var emotionSelected:EmotionButtonType!
    var control_state = "neutral" // neutral, love, hate
    var love_attr_string:NSMutableAttributedString!
    var hate_attr_string:NSMutableAttributedString!
    var path_love:UIBezierPath!
    var path_hate:UIBezierPath!
    var love_heart_frame:CGRect!
    var hate_heart_frame:CGRect!
    var love_string_point:CGPoint!
    var hate_string_point:CGPoint!
    
    init(frame:CGRect, inclinationAngel:CGFloat) {
        super.init(frame: frame)
        INCLINATION_ANGLE = inclinationAngel
        let inclination_dif_center = frame.height / tan(INCLINATION_ANGLE) * 2.0
        let inclination_left = frame.width * 0.5 - inclination_dif_center
        let inclination_right = frame.width * 0.5 + inclination_dif_center
        path_love = UIBezierPath()
        path_love.move(to: CGPoint(x: 0, y: 0))
        path_love.addLine(to: CGPoint(x: inclination_right, y: 0))
        path_love.addLine(to: CGPoint(x: inclination_left, y: frame.height))
        path_love.addLine(to: CGPoint(x: 0, y: frame.height))
        path_love.addLine(to: CGPoint(x: 0, y: 0))
        path_love.close()
        path_hate = UIBezierPath()
        path_hate.move(to: CGPoint(x: frame.width, y: 0))
        path_hate.addLine(to: CGPoint(x: frame.width, y: frame.height))
        path_hate.addLine(to: CGPoint(x: inclination_left, y: frame.height))
        path_hate.addLine(to: CGPoint(x: inclination_right, y: 0))
        path_hate.addLine(to: CGPoint(x: frame.width, y: 0))
        path_hate.close()
        let max_total_text_width = frame.width - 4.0 * MIN_ELEMS_SPACING - HEART_WIDTH_HATE - HEART_WIDTH_LOVE - ICON_TEXT_SPACING * 2.0
        let str1 = "i LOVE it"
        let str2 = "i HATE it"
        let str1_big_range = NSMakeRange(1, 6)
        let str2_big_range = NSMakeRange(1, 6)
        let fonts_sizes = apprFontSize(str1, str2: str2, str1RangeBig: str1_big_range, str2RangeBig: str2_big_range, maxTotalWidth: max_total_text_width)
        let str1_r_small_1 = NSMakeRange(0, str1_big_range.location)
        let str1_r_small_2 = NSMakeRange(str1_big_range.location + str1_big_range.length, (str1 as NSString).length - str1_big_range.location - str1_big_range.length)
        let str2_r_small_1 = NSMakeRange(0, str2_big_range.location)
        let str2_r_small_2 = NSMakeRange(str2_big_range.location + str2_big_range.length, (str2 as NSString).length - str2_big_range.location - str2_big_range.length)
        love_attr_string = NSMutableAttributedString(string: str1)
        love_attr_string.addAttribute(NSForegroundColorAttributeName, value: TEXT_COLOR_LOVE, range: NSMakeRange(0, love_attr_string.length))
        love_attr_string.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNovaExCn-Extrabld", size: fonts_sizes.maxFont)!, range: str1_big_range)
        love_attr_string.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNovaExCn-Extrabld", size: fonts_sizes.minFont)!, range: str1_r_small_1)
        love_attr_string.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNovaExCn-Extrabld", size: fonts_sizes.minFont)!, range: str1_r_small_2)
        hate_attr_string = NSMutableAttributedString(string: str2)
        hate_attr_string.addAttribute(NSForegroundColorAttributeName, value: TEXT_COLOR_HATE, range: NSMakeRange(0, hate_attr_string.length))
        hate_attr_string.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNovaExCn-Extrabld", size: fonts_sizes.maxFont)!, range: str2_big_range)
        hate_attr_string.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNovaExCn-Extrabld", size: fonts_sizes.minFont)!, range: str2_r_small_1)
        hate_attr_string.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNovaExCn-Extrabld", size:fonts_sizes.minFont)!, range: str2_r_small_2)
        let love_attr_size = love_attr_string.size()
        let hate_attr_size = hate_attr_string.size()
        let real_spacings = (frame.width - HEART_WIDTH_LOVE - HEART_WIDTH_HATE - love_attr_size.width - hate_attr_size.width - ICON_TEXT_SPACING * 2.0) / 4.0
        let love_heart_height = HEART_WIDTH_LOVE * HEART_ASPECT_LOVE
        let hate_heart_height = HEART_WIDTH_HATE * HEART_ASPECT_HATE
        love_heart_frame = CGRect(x: real_spacings, y: (frame.height - love_heart_height) * 0.5, width: HEART_WIDTH_LOVE, height: love_heart_height)
        hate_heart_frame = CGRect(x: frame.width - real_spacings - HEART_WIDTH_HATE, y: (frame.height - hate_heart_height) * 0.5, width: HEART_WIDTH_HATE, height: hate_heart_height)
        love_string_point = CGPoint(x: love_heart_frame.maxX + ICON_TEXT_SPACING, y: (frame.height - love_attr_size.height) * 0.5)
        hate_string_point = CGPoint(x: hate_heart_frame.minX - ICON_TEXT_SPACING - hate_attr_size.width, y: (frame.height - hate_attr_size.height) * 0.5)
        setNeedsDisplay()
    }

    func apprFontSize(_ str1:String, str2:String, str1RangeBig:NSRange, str2RangeBig:NSRange, maxTotalWidth:CGFloat) -> (minFont:CGFloat,maxFont:CGFloat) {
        var bigger_font:CGFloat = 0
        var smaller_font:CGFloat = 0
        let str1_r_small_1 = NSMakeRange(0, str1RangeBig.location)
        let str1_r_small_2 = NSMakeRange(str1RangeBig.location + str1RangeBig.length, (str1 as NSString).length - str1RangeBig.location - str1RangeBig.length)
        let str2_r_small_1 = NSMakeRange(0, str2RangeBig.location)
        let str2_r_small_2 = NSMakeRange(str2RangeBig.location + str2RangeBig.length, (str2 as NSString).length - str2RangeBig.location - str2RangeBig.length)
        for s in stride(from: TEXT_MAX_FONT_SIZE, to : 0.0, by: -1.0) {
            var this_size:CGSize = CGSize(width: 0, height: 0)
            let attr1 = NSMutableAttributedString(string: str1)
            attr1.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNovaExCn-Extrabld", size: s)!, range: str1RangeBig)
            attr1.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNovaExCn-Extrabld", size: s - FONTS_SIZE_DIF)!, range: str1_r_small_1)
            attr1.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNovaExCn-Extrabld", size: s - FONTS_SIZE_DIF)!, range: str1_r_small_2)
            let attr2 = NSMutableAttributedString(string: str2)
            attr2.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNovaExCn-Extrabld", size: s)!, range: str2RangeBig)
            attr2.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNovaExCn-Extrabld", size: s - FONTS_SIZE_DIF)!, range: str2_r_small_1)
            attr2.addAttribute(NSFontAttributeName, value: UIFont(name: "ProximaNovaExCn-Extrabld", size: s - FONTS_SIZE_DIF)!, range: str2_r_small_2)
            let total_width = attr1.size().width + attr2.size().width
            if total_width < maxTotalWidth {
                bigger_font = s
                smaller_font = s - FONTS_SIZE_DIF
                break
            }
        }
        return (minFont:smaller_font,maxFont:bigger_font)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.clear(rect)
        ctx?.setFillColor(control_state == "love" ? BG_COLOR_LOVE_HIGHLIGHTED.cgColor : BG_COLOR_LOVE.cgColor)
        ctx?.addPath(path_love.cgPath)
        ctx?.fillPath()
        ctx?.setFillColor(control_state == "hate" ? BG_COLOR_HATE_HIGHLIGHTED.cgColor : BG_COLOR_HATE.cgColor)
        ctx?.addPath(path_hate.cgPath)
        ctx?.fillPath()
        love_attr_string.draw(at: love_string_point)
        hate_attr_string.draw(at: hate_string_point)
        UIImage(named: "love_heart_button")!.draw(in: love_heart_frame)
        UIImage(named: "hate_heart_button")!.draw(in: hate_heart_frame)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touch_coords = touch.location(in: self)
        control_state = path_love.contains(touch_coords) ? "love" : "hate"
        emotionSelected = control_state == "love" ? EmotionButtonType.love : EmotionButtonType.hate
        setNeedsDisplay()
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if self.frame.contains(touch!.location(in: self)) {
            sendActions(for: .touchUpInside)
        }
        control_state = "neutral"
        setNeedsDisplay()
    }
    
}

enum EmotionSwitcherState {
    case loveOnly,hateOnly,neutral
}

class EmotionSwitcherView : UIView {
    
    let NEUTRAL_CIRCLE_WIDTH:CGFloat = 30
    let EMOTION_SWITCHED_SCALE_FACTOR:CGFloat = 1.28
    let PIPE_WIDTH:CGFloat = 18 // visible one
    let PIPE_HEIGHT:CGFloat = 9
    let PIPE_COLOR_HATE = UIColor(red: 221/255, green: 131/255, blue: 131/255, alpha: 1.0)
    let PIPE_COLOR_LOVE = UIColor(red: 102/255, green: 195/255, blue: 117/255, alpha: 1.0)
    let PIPE_COLOR_NEUTRAL = UIColor(red: 189/255, green: 189/255, blue: 189/255, alpha: 1.0)
    let ANIMATION_DURATION:CFTimeInterval = 0.4
    
    var img_hate:UIImageView!
    var img_love:UIImageView!
    
    var pipe_frame:CGRect!
    var neutral_love_frame:CGRect!
    var neutral_hate_frame:CGRect!
    var emotional_love_frame:CGRect!
    var emotional_hate_frame:CGRect!
    var switcher_state:EmotionSwitcherState = EmotionSwitcherState.neutral
    
    init(bottomCenterPoint:CGPoint) {
        let bigger_circle_width = NEUTRAL_CIRCLE_WIDTH * EMOTION_SWITCHED_SCALE_FACTOR
        let max_width = PIPE_WIDTH + NEUTRAL_CIRCLE_WIDTH * 2.0 * EMOTION_SWITCHED_SCALE_FACTOR
        let max_height = bigger_circle_width
        super.init(frame: CGRect(x: bottomCenterPoint.x - 0.5 * max_width, y: bottomCenterPoint.y - max_height, width: max_width, height: max_height))
        backgroundColor = UIColor.clear
        neutral_hate_frame = CGRect(x: (EMOTION_SWITCHED_SCALE_FACTOR - 1.0) * NEUTRAL_CIRCLE_WIDTH, y: max_height - NEUTRAL_CIRCLE_WIDTH, width: NEUTRAL_CIRCLE_WIDTH, height: NEUTRAL_CIRCLE_WIDTH)
        emotional_hate_frame = CGRect(x: 0, y: 0, width: EMOTION_SWITCHED_SCALE_FACTOR * NEUTRAL_CIRCLE_WIDTH, height: max_height)
        neutral_love_frame = CGRect(x: max_width - EMOTION_SWITCHED_SCALE_FACTOR * NEUTRAL_CIRCLE_WIDTH, y: max_height - NEUTRAL_CIRCLE_WIDTH, width: NEUTRAL_CIRCLE_WIDTH, height: NEUTRAL_CIRCLE_WIDTH)
        emotional_love_frame = CGRect(x: max_width - EMOTION_SWITCHED_SCALE_FACTOR * NEUTRAL_CIRCLE_WIDTH, y: 0, width: EMOTION_SWITCHED_SCALE_FACTOR * NEUTRAL_CIRCLE_WIDTH, height: max_height)
        pipe_frame = CGRect(x: neutral_hate_frame.midX, y: neutral_hate_frame.midY - 0.5 * PIPE_HEIGHT, width: PIPE_WIDTH + NEUTRAL_CIRCLE_WIDTH, height: PIPE_HEIGHT)
        if UIDevice().userInterfaceIdiom == .pad {
            swap(&emotional_hate_frame, &emotional_love_frame)
            swap(&neutral_love_frame, &neutral_hate_frame)
        }
        img_hate = UIImageView(frame: neutral_hate_frame)
        img_hate.contentMode = .scaleAspectFit
        img_hate.image = UIImage(named: "switcher_neutral_hate")!
        img_love = UIImageView(frame: neutral_love_frame)
        img_love.contentMode = .scaleAspectFit
        img_love.image = UIImage(named: "switcher_neutral_love")!
        setNeedsDisplay()
        addSubview(img_hate)
        addSubview(img_love)
    }
    
    func setSwitcherState(_ state:EmotionSwitcherState) {
        let prev_state = switcher_state
        switcher_state = state
        if UIDevice().userInterfaceIdiom == .pad {
            if state == EmotionSwitcherState.hateOnly {
                switcher_state = EmotionSwitcherState.loveOnly
            }
            else if state == EmotionSwitcherState.loveOnly {
                switcher_state = EmotionSwitcherState.hateOnly
            }
        }
        setNeedsDisplay()
        switch switcher_state {
        case .neutral:
            if prev_state == .hateOnly {
                img_hate.frame = neutral_hate_frame
                img_hate.image = UIImage(named: "switcher_neutral_hate")!
                img_hate.layer.add(BounceAnimation(duration: ANIMATION_DURATION, keyPath: "transform.scale", bounceType: "change").bounce_anim, forKey: "bounce")
            }
            else {
                img_love.frame = neutral_love_frame
                img_love.image = UIImage(named: "switcher_neutral_love")!
                img_love.layer.add(BounceAnimation(duration: ANIMATION_DURATION, keyPath: "transform.scale", bounceType: "change").bounce_anim, forKey: "bounce")
            }
        case .hateOnly:
            img_hate.frame = emotional_hate_frame
            img_hate.image = UIImage(named: "switcher_emotional_hate")!
            img_hate.layer.add(BounceAnimation(duration: ANIMATION_DURATION, keyPath: "transform.scale", bounceType: "change").bounce_anim, forKey: "bounce")
        case .loveOnly:
            img_love.frame = emotional_love_frame
            img_love.image = UIImage(named: "switcher_emotional_love")!
            img_love.layer.add(BounceAnimation(duration: ANIMATION_DURATION, keyPath: "transform.scale", bounceType: "change").bounce_anim, forKey: "bounce")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.clear(rect)
        ctx?.setFillColor(switcher_state == EmotionSwitcherState.neutral ? PIPE_COLOR_NEUTRAL.cgColor : switcher_state == EmotionSwitcherState.loveOnly ? PIPE_COLOR_LOVE.cgColor : PIPE_COLOR_HATE.cgColor)
        ctx?.fill(pipe_frame)
    }
    
}

class LoaderView : UIView {
    
    let FILL_1 = UIColor(red: 245/255, green: 120/255, blue: 76/255, alpha: 1.0)
    let FILL_2 = UIColor(red: 245/255, green: 100/255, blue: 56/255, alpha: 1.0)
    let FILL_3 = UIColor(red: 245/255, green: 76/255, blue: 17/255, alpha: 1.0)
    let LOADER_SCALE_FACTOR:CGFloat = 0.7
    let LOADER_STEP_ANIMATION_DURATION:CFTimeInterval = 0.35
    
    var loader:CAShapeLayer!
    var loader_anim_size:CABasicAnimation!
    var loader_anim_color:CAKeyframeAnimation!
    
    init(frame: CGRect, topBottomInset:CGFloat) {
        let real_frame = CGRect(x: frame.minX, y: frame.minY - topBottomInset, width: frame.width, height: frame.height + 2.0 * topBottomInset)
        super.init(frame: real_frame)
        loader = CAShapeLayer()
        loader.frame = CGRect(x: 0, y: topBottomInset, width: frame.width, height: frame.height)
        loader.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: frame.width, height: frame.height)).cgPath
        loader.fillColor = FILL_1.cgColor
        layer.addSublayer(loader)
        loader_anim_size = CABasicAnimation(keyPath: "transform.scale")
        loader_anim_size.fromValue = 1.0
        loader_anim_size.toValue = LOADER_SCALE_FACTOR
        loader_anim_size.autoreverses = true
        loader_anim_size.repeatCount = HUGE
        loader_anim_size.duration = LOADER_STEP_ANIMATION_DURATION
        loader_anim_color = CAKeyframeAnimation(keyPath: "fillColor")
        loader_anim_color.values = [FILL_1.cgColor,FILL_1.cgColor,FILL_2.cgColor,FILL_2.cgColor,FILL_3.cgColor,FILL_3.cgColor,FILL_1.cgColor]
        loader_anim_color.repeatCount = HUGE
        loader_anim_color.duration = LOADER_STEP_ANIMATION_DURATION * 6.0
        loader_anim_color.keyTimes = [0.0,0.25,0.333,0.583,0.666,0.916,1.0]
    }
    
    func startLoading() {
        loader.removeAllAnimations()
       // let bounce_anim = BounceAnimation(duration: 0.3, keyPath: "transform.scale", bounceType: "change").bounce_anim
       // bounce_anim.setValue("initial", forKey: "type")
       // bounce_anim.delegate = self
        //loader.addAnimation(bounce_anim, forKey: "init_bounce")
        loader.add(loader_anim_size, forKey: "size")
        loader.add(loader_anim_color, forKey: "color")
    }
    
    func stopLoading() {
        let _ = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(LoaderView.removeAnims(_:)), userInfo: nil, repeats: false)
    }
    
    func removeAnims(_ sender:Timer) {
        sender.invalidate()
        loader.removeAllAnimations()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim.value(forKey: "type") as! String == "initial" {
            loader.add(loader_anim_size, forKey: "size")
            loader.add(loader_anim_color, forKey: "color")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ProfileSwitcher : UIControl {
    
    let TITLE_FONT_SIZE:CGFloat = 19
    let SUBTITLE_FONT_SIZE:CGFloat = 14
    let TITLE_COLOR = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1.0)
    let SUBTITLE_COLOR = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
    let SLIDER_COLOR = UIColor(red: 200/255, green: 59/255, blue: 51/255, alpha: 1.0)
    let SEPARATOR_COLOR = UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1.0)
    let SLIDER_THICKNESS:CGFloat = 4
    let SLIDER_SPACING:CGFloat = 6
    let SLIDER_WIDTH_RELATIVE:CGFloat = 1.4 // to title width
    let INSIDE_SPACE:CGFloat = 34
    let SUBTITLE_SPACING_TOP:CGFloat = 1
    let SEPARATOR_THICKNESS:CGFloat = 2
    let UNSELECTED_OPACITY:CGFloat = 0.4
    let SEPARATOR_HEIGHT_RELATIVE:CGFloat = 0.6 // to height
    let SLIDER_ANIM_DURATION:CFTimeInterval = 0.15
    
    var topics_title:UILabel!
    var opinions_title:UILabel!
    var topics_caption:UILabel!
    var opinions_caption:UILabel!
    var slider:CALayer!
    var slider_frame_left:CGRect!
    var slider_frame_right:CGRect!
    var control_center_x:CGFloat = 0
    var separator_center_y:CGFloat = 0
    var sep_height:CGFloat = 0
    
    var topics_selected = true
    
    init() {
        topics_title = UILabel(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        topics_title.numberOfLines = 1
        topics_title.textAlignment = .center
        topics_title.textColor = TITLE_COLOR
        topics_title.font = UIFont(name: "ProximaNova-Bold", size: TITLE_FONT_SIZE)
        topics_title.text = "TOPICS"
        let topics_title_size = topics_title.textRect(forBounds: topics_title.bounds, limitedToNumberOfLines: 1)
        topics_caption = UILabel(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        topics_caption.font = UIFont(name: "ProximaNova-Semibold", size: SUBTITLE_FONT_SIZE)
        topics_caption.text = "999 total"
        topics_caption.textColor = SUBTITLE_COLOR
        topics_caption.textAlignment = .center
        let topics_caption_size = topics_caption.textRect(forBounds: topics_caption.bounds, limitedToNumberOfLines: 1)
        opinions_title = UILabel(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        opinions_title.alpha = UNSELECTED_OPACITY
        opinions_title.textColor = TITLE_COLOR
        opinions_title.font = topics_title.font
        opinions_title.text = "OPINIONS"
        opinions_title.textAlignment = .center
        let opinions_title_size = opinions_title.textRect(forBounds: opinions_title.bounds, limitedToNumberOfLines: 1)
        opinions_caption = UILabel(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        opinions_caption.alpha = UNSELECTED_OPACITY
        opinions_caption.font = topics_caption.font
        opinions_caption.textColor = SUBTITLE_COLOR
        opinions_caption.textAlignment = .center
        opinions_caption.text = "999 total"
        let opinions_caption_size = opinions_caption.textRect(forBounds: opinions_caption.bounds, limitedToNumberOfLines: 1)
        let max_left_text_width = max(topics_title_size.width, topics_caption_size.width)
        let max_right_text_width = max(opinions_caption_size.width, opinions_title_size.width)
        let slider_left_width = max_left_text_width * SLIDER_WIDTH_RELATIVE
        let slider_right_width = max_right_text_width * SLIDER_WIDTH_RELATIVE
        let total_width = INSIDE_SPACE * 2.0 + max_left_text_width + max_right_text_width + (SLIDER_WIDTH_RELATIVE - 1.0) * max_left_text_width * 0.5 + (SLIDER_WIDTH_RELATIVE - 1.0) * max_right_text_width * 0.5
        topics_title.frame = CGRect(x: (slider_left_width - max_left_text_width) * 0.5, y: 0, width: max_left_text_width, height: topics_title_size.height)
        topics_caption.frame = CGRect(x: topics_title.frame.minX, y: topics_title_size.height + SUBTITLE_SPACING_TOP, width: max_left_text_width, height: topics_caption_size.height)
        slider_frame_left = CGRect(x: 0, y: topics_caption.frame.maxY + SLIDER_SPACING, width: slider_left_width, height: SLIDER_THICKNESS)
        control_center_x = slider_left_width - (SLIDER_WIDTH_RELATIVE - 1.0) * 0.5 * max_left_text_width + INSIDE_SPACE
        opinions_title.frame = CGRect(x: control_center_x + INSIDE_SPACE, y: topics_title.frame.minY, width: max_right_text_width, height: opinions_title_size.height)
        opinions_caption.frame = CGRect(x: opinions_title.frame.minX, y: topics_caption.frame.minY, width: max_right_text_width, height: opinions_caption_size.height)
        slider_frame_right = CGRect(x: opinions_title.frame.minX - (slider_right_width - max_right_text_width) * 0.5, y: slider_frame_left.minY, width: slider_right_width, height: SLIDER_THICKNESS)
        separator_center_y = opinions_caption.frame.maxY * 0.5
        sep_height = opinions_caption.frame.maxY * SEPARATOR_HEIGHT_RELATIVE
        slider = CALayer()
        slider.backgroundColor = SLIDER_COLOR.cgColor
        slider.frame = slider_frame_left
        slider.actions = ["frame":NSNull()]
        super.init(frame: CGRect(x: 0, y: 0, width: total_width, height: slider_frame_left.maxY))
        backgroundColor = UIColor.clear
        addSubview(opinions_title)
        addSubview(opinions_caption)
        addSubview(topics_title)
        addSubview(topics_caption)
        layer.addSublayer(slider)
        setNeedsDisplay()
    }
    
    func parseNumberCount(count:Int) -> String {
        return count > 999 ? "\(count / 1000)k" : "\(count)"
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setStrokeColor(SEPARATOR_COLOR.cgColor)
        ctx?.setLineWidth(SEPARATOR_THICKNESS)
        ctx?.move(to: CGPoint(x: control_center_x, y: separator_center_y - 0.5 * sep_height))
        ctx?.addLine(to: CGPoint(x: control_center_x, y: separator_center_y + 0.5 * sep_height))
        ctx?.strokePath()
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        let coords_x = touch.location(in: self).x
        if (coords_x >= control_center_x && topics_selected) || (coords_x < control_center_x && !topics_selected) {
            let slider_anim = CABasicAnimation(keyPath: "frame")
            slider_anim.fromValue = NSValue(cgRect: topics_selected ? slider_frame_left : slider_frame_right)
            slider_anim.toValue = NSValue(cgRect : topics_selected ? slider_frame_right : slider_frame_left)
            slider_anim.duration = SLIDER_ANIM_DURATION
            slider_anim.timingFunction = General.anim_func
            slider.add(slider_anim, forKey: "slider")
            slider.frame = topics_selected ? slider_frame_right : slider_frame_left
            topics_title.alpha = topics_selected ? UNSELECTED_OPACITY : 1.0
            topics_caption.alpha = topics_selected ? UNSELECTED_OPACITY : 1.0
            opinions_title.alpha = topics_selected ? 1.0 : UNSELECTED_OPACITY
            opinions_caption.alpha = topics_selected ? 1.0 : UNSELECTED_OPACITY
            topics_selected = !topics_selected
            sendActions(for: .valueChanged)
        }
        return false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TableLikeButton : UIControl {
    
    let BG_COLOR_NORMAL = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    let BG_COLOR_HIGHlIGHTED = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1.0)
    let SPACING_IMAGE_LEFT:CGFloat = 9
    let SPACING_TEXT_LEFT:CGFloat = 12
    let SPACING_IMAGE_DISCLOSURE_RIGHT:CGFloat = 15
    let IMAGE_LEFT_HEIGHT_RELATIVE:CGFloat = 0.55
    let IMAGE_DISCLOSURE_HEIGHT_RELATIVE:CGFloat = 0.38
    let TEXT_FONT_SIZE:CGFloat = 18
    let IMAGE_DISCLOSURE_ASPECT:CGFloat = 1.516
    
    var img_left:UIImageView!
    var img_disc:UIImageView!
    var text_label:UILabel!
    var shouldTrackTouches = true
    
    init(frame:CGRect, withLeftImage:UIImage?,withText:String) {
        super.init(frame: frame)
        backgroundColor = BG_COLOR_NORMAL
        img_disc = UIImageView(image: UIImage(named: "disclosure_icon_related_cell")!)
        img_disc.contentMode = .scaleAspectFit
        addSubview(img_disc)
        if let leftImg = withLeftImage {
            img_left = UIImageView(image: leftImg)
            img_left.contentMode = .scaleAspectFit
            addSubview(img_left)
        }
        text_label = UILabel()
        text_label.font = UIFont(name: withLeftImage == nil ? "ProximaNovaCond-Regular" : "ProximaNovaCond-Semibold", size: TEXT_FONT_SIZE)
        text_label.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
        text_label.text = withText
        addSubview(text_label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("table like button is layoting")
        let img_disc_height = frame.height * IMAGE_DISCLOSURE_HEIGHT_RELATIVE
        let img_disc_width = img_disc_height / IMAGE_DISCLOSURE_ASPECT
        img_disc.frame = CGRect(x: frame.width - SPACING_IMAGE_DISCLOSURE_RIGHT - img_disc_width, y: (frame.height - img_disc_height) * 0.5, width: img_disc_width, height: img_disc_height)
        var left_text_spacing:CGFloat = SPACING_TEXT_LEFT
        if img_left != nil {
            let img_left_height = frame.height * IMAGE_LEFT_HEIGHT_RELATIVE
            let img_left_width = img_left_height / (img_left.image!.size.height / img_left.image!.size.width)
            img_left.frame = CGRect(x: SPACING_IMAGE_LEFT, y: (frame.height - img_left_height) * 0.5, width: img_left_width, height: img_left_height)
            left_text_spacing += img_left.frame.maxX
        }
        text_label.frame =  CGRect(x: left_text_spacing, y: 0, width: frame.width - img_disc.frame.width - left_text_spacing - SPACING_IMAGE_DISCLOSURE_RIGHT, height: frame.height)
    }
    
    func setHighlightedState(_ high:Bool) {
        backgroundColor = high ? BG_COLOR_HIGHlIGHTED : BG_COLOR_NORMAL
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if shouldTrackTouches {
            setHighlightedState(true)
        }
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if shouldTrackTouches {
            setHighlightedState(false)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

