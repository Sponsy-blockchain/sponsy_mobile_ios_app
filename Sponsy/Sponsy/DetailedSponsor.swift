//
//  DetailedSponsor.swift
//  Sponsy
//
//  Created by Admin on 22.09.17.
//  Copyright © 2017 Vano Production. All rights reserved.
//

import UIKit
import Kingfisher

class DetailedSponsorViewController : UIViewController, UIScrollViewDelegate {
    
    let TITLE_LABEL_TEXT_COLOR_PLACEHOLDER:UIColor = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1.0)
    let TITLE_LABEL_TEXT_COLOR:UIColor = UIColor.white
    let TOPIC_IMAGE_PLACEHOLDER_BG_COLOR:UIColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1.0)
    let TOPIC_IMAGE_HEIGHT_RELATIVE:CGFloat = 0.185
    let TOPIC_IMAGE_HEIGHT_FIXED:CGFloat = 123
    let TOPIC_TEXT_WIDTH_RELATIVE:CGFloat = 0.61
    let TOPIC_TEXT_TOP_BOTTOM_MARGIN:CGFloat = 14
    let TOPIC_TEXT_MAX_FONT_SIZE:CGFloat = 32
    let MENU_BUTTON_SPACING_RIGHT:CGFloat = 15
    let BACK_BUTTON_SPACING_LEFT:CGFloat = 15
    let MENU_BUTTON_CENTER_SPACING_TOP:CGFloat = 48
    let BACK_BUTTON_CENTER_SPACING_TOP:CGFloat = 48
    let MENU_BUTTON_WIDTH:CGFloat = 28
    let BACK_BUTTON_WIDTH:CGFloat = 24
    let MENU_BUTTON_ASPECT:CGFloat = 0.25
    let BACK_BUTTON_ASPECT:CGFloat = 0.71
    let ELLIPSE_MASK_WIDTH_RELATIVE:CGFloat = 1.53 // to screen's width
    let ELLIPSE_MASK_HEIGHT_RELATIVE:CGFloat = 1.925 // to image's height
    let BOTTOM_BUTTONS_HEIGHT:CGFloat = 60
    let BG_OPACITY:CGFloat = 1.0 // 0.5
    let TEXT_COLOR_LOVE = UIColor(red: 0, green: 143/255, blue: 0, alpha: 1.0)
    let TEXT_COLOR_HATE = UIColor(red: 206/255, green: 27/255, blue: 27/255, alpha: 1.0)
    let LI_HEART_HEIGHT:CGFloat = 57
    let LI_HEART_VISIBLE_PART_WIDTH:CGFloat = 0.613
    let LI_HEART_ASPECT:CGFloat = 0.894
    let OPINIONS_ICON_HEIGHT:CGFloat = 47
    let OPINIONS_ICON_VISIBLE_PART_WIDTH:CGFloat = 0.727
    let OPINIONS_ICON_ASPECT:CGFloat = 0.968
    let BIG_NUMBER_SPACING_TOP:CGFloat = 12 // from heart or opinion icon top
    let BIG_NUMBER_SPACING_TOP_ELLIPSE:CGFloat = 8 // spacing from upper ellipse
    let BIG_NUMBER_FONT_SIZE:CGFloat = 42
    let BIG_NUMBER_SPACING_FROM_ICON:CGFloat = 10
    let SMALL_CAPTION_SPACING_TOP:CGFloat = -4
    let SMALL_CAPTION_FONT_SIZE:CGFloat = 14
    let MASK_WAVES_STEP_WIDTH:CGFloat = 15
    let MASK_WAVES_STEP_HEIGHT:CGFloat = 1
    let TOPIC_DATA_SLIDING_DURATION:CFTimeInterval = 0.4
    let MASK_WAVES_ANIMATION_DURATION:CFTimeInterval = 2.2
    let TOPIC_DATA_BOUNCE_ANIMATION_DURATION:CFTimeInterval = 0.4
    let OPINIONS_INSET:CGFloat = 20 // from the bottom of heart and LI etc...
    let BOTTOM_BUTTONS_INCLINATION_ANGLE:CGFloat = 1.45 //in rads
    let DATA_HIDES_ANIMATION_DURATION:CFTimeInterval = 0.3
    let EMOTIONAL_SWITCHER_BOTTOM_MARGIN:CGFloat = 9
    let LOADER_SIZE:CGFloat = 40
    let EMPTY_ICON_HEIGHT:CGFloat = 65
    let EMPTY_LABEL_COLOR = UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 1.0)
    let EMPTY_LABEL_TEXT_SIZE:CGFloat = 18
    let EMPTY_LABEL_SPACING_TOP:CGFloat = 8
    let EMPTY_LABEL_WIDTH_RELATIVE:CGFloat = 0.89 // to whole view width
    let SWIPE_RECOGNITION_AREA_RELATIVE:CGFloat = 0.11
    
    var layed_out = false
    var image_here = false
    var sponsor_id = -1
    var sponsor_data_detailed:SponsySponsorDetailed?
    var sponsor_title = ""
    var topic_image_view:UIImageView!
    var back_button:UIButton!
    var topic_title_label:UILabel!
    var empty_label:UILabel!
    var empty_icon:UIImageView!
    var loader_view:LoaderView!
    
    @IBOutlet var money_required_text:UILabel!
    @IBOutlet var time_sponsoring_text:UILabel!
    @IBOutlet var total_spent_text:UILabel!
    @IBOutlet var audience_text:UILabel!
    @IBOutlet var events_types_text:UILabel!
    @IBOutlet var location_text:UILabel!
    @IBOutlet var description_text:UILabel!
    @IBOutlet var data_view:UIScrollView!
    @IBOutlet var put_voting_button:UIButton!
    @IBOutlet var send_request_button:UIButton!
    @IBOutlet var content_view:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = UIColor(patternImage: UIImage.init(named: "bg_art")!)
        topic_image_view = UIImageView()
        topic_title_label = UILabel()
        topic_title_label.numberOfLines = 0
        topic_title_label.textColor = TITLE_LABEL_TEXT_COLOR_PLACEHOLDER
        topic_title_label.textAlignment = .center
        back_button = UIButton(type: .custom)
        back_button.addTarget(self, action: #selector(DetailedSponsorViewController.backButtonPressed(_:)), for: .touchUpInside)
        view.addSubview(topic_image_view)
        view.addSubview(back_button)
        view.addSubview(topic_title_label)
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if layed_out {
            return
        }
        let topic_image_height:CGFloat = 123.0
        print(topic_image_height)
        //topic_image_view.image = UIImage(named: "image_placeholder_2")!
        topic_image_view.contentMode = .center
        topic_image_view.backgroundColor = TOPIC_IMAGE_PLACEHOLDER_BG_COLOR
        topic_image_view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: topic_image_height)
        let mask = MaskView(frame: CGRect(x: (1.0 - ELLIPSE_MASK_WIDTH_RELATIVE) * 0.5 * view.bounds.width, y: topic_image_height * (1.0 - ELLIPSE_MASK_HEIGHT_RELATIVE), width: ELLIPSE_MASK_WIDTH_RELATIVE * view.bounds.width, height: ELLIPSE_MASK_HEIGHT_RELATIVE * topic_image_height))
        topic_image_view.mask = mask
        back_button.setImage(UIImage(named: "back_button_topic_dark")!, for: UIControlState())
        back_button.frame = CGRect(x: 0, y: 0, width: BACK_BUTTON_WIDTH + BACK_BUTTON_SPACING_LEFT * 2.0, height: BACK_BUTTON_WIDTH)
        back_button.center = CGPoint(x: BACK_BUTTON_SPACING_LEFT + BACK_BUTTON_WIDTH * 0.5, y: BACK_BUTTON_CENTER_SPACING_TOP)
        let top_bottom_back_edge = (BACK_BUTTON_WIDTH - BACK_BUTTON_WIDTH * BACK_BUTTON_ASPECT) * 0.5
        back_button.imageEdgeInsets = UIEdgeInsetsMake(top_bottom_back_edge, BACK_BUTTON_SPACING_LEFT, top_bottom_back_edge, BACK_BUTTON_SPACING_LEFT)
        positionTopicTitle()
        loader_view = LoaderView(frame: CGRect(x: 0, y: 0, width: LOADER_SIZE, height: LOADER_SIZE), topBottomInset : 0)
        loader_view.center = CGPoint(x: view.center.x, y: (view.bounds.height - BOTTOM_BUTTONS_HEIGHT - TOPIC_IMAGE_HEIGHT_FIXED) * 0.5 + TOPIC_IMAGE_HEIGHT_FIXED)
        loader_view.alpha = 0.0
        view.addSubview(loader_view)
        data_view.alpha = 0.0
        layed_out = true
        data_view.delegate = self
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return image_here ? .lightContent : .default
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        shootHint()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loader_view.alpha = 1.0
        loader_view.startLoading()
        let task_builder = HailyTaskBuilder(session: General.session_data, anonymous: true, degradePossible: true)
        let sponsor_task = HailyReceiveTask(dataOrigin: HailyDataOrigin.sponsor, dataType: HailyDataType.details)
        sponsor_task.sponsor_id = sponsor_id
        task_builder.addTasks([sponsor_task])
        task_builder.sendTasksWithCompletionHandler({
            (parsedResponse:[HailyParsedResponse]?,error:Error?) in
            DispatchQueue.main.async(execute: {
                self.loader_view.stopLoading()
                self.loader_view.alpha = 0.0
            })
            var success = false
            if let responses = parsedResponse {
                if let sponsor_data = responses[0].sponsorDataDetailed {
                    success = true
                    DispatchQueue.main.async(execute: {
                        self.setSponsorData(sponsor_data)
                    })
                }
            }
            if let _error = error {
                print("error with populating detail event with event id \(self.sponsor_id)")
                //maybe should pop view controller?
                print(_error)
            }
            if !success {
                DispatchQueue.main.async(execute: {
                    self.setEmptyStateWithText("Troubles while loading this sponsor details")
                    NotificationCenter.default.post(kHailyDataRetrievalErrorSliderNotification)
                })
            }
        })
        General.sponsors_images_cache.retrieveImage(forKey: "\(sponsor_id)", options: nil, completionHandler: {
            (image:UIImage?, cache: CacheType) in
            if let img = image {
                General.prepareSizedImage(img, toFitSize: CGSize(width: self.view.bounds.width, height: self.TOPIC_IMAGE_HEIGHT_FIXED), withAlignment: SizedImageAlignment.center , withOverlayStyle: TopicsColorsStyles.default , completionHandler: {
                    (finalImage:UIImage) in
                    self.setTopicImage(finalImage)
                })
            }
            else {
                ImageDownloader.default.downloadImage(with: URL.init(string: "\(General.images_bucket_address)sponsor\(self.sponsor_id)")!, options: nil, progressBlock: nil, completionHandler: {
                    (image:UIImage?, error:NSError?, url:URL?, data:Data?) in
                    if let img = image {
                        General.prepareSizedImage(img, toFitSize: CGSize(width: self.view.bounds.width, height: self.TOPIC_IMAGE_HEIGHT_FIXED), withAlignment: SizedImageAlignment.center , withOverlayStyle: TopicsColorsStyles.default , completionHandler: {
                            (finalImage:UIImage) in
                            self.setTopicImage(finalImage)
                        })
                        General.sponsors_images_cache.store(img, original: data, forKey: "\(self.sponsor_id)")
                    }
                })
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setTopicImage(_ image:UIImage) {
        UIView.transition(with: topic_image_view, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.topic_image_view.image = image
        }, completion: nil)
        back_button.setImage(UIImage(named: "back_button_topic_light")!, for: UIControlState())
        topic_title_label.textColor = TITLE_LABEL_TEXT_COLOR
        image_here = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func setEmptyStateWithText(_ emptyText:String?) {
        if let newEmptyText = emptyText {
            empty_label.text = newEmptyText
            empty_label.frame = CGRect(x: 0, y: 0, width: view.bounds.width * EMPTY_LABEL_WIDTH_RELATIVE, height: 1000)
            let real_empty_label_size = empty_label.textRect(forBounds: empty_label.bounds, limitedToNumberOfLines: 0)
            let empty_icon_width = EMPTY_ICON_HEIGHT / (empty_icon.image!.size.height / empty_icon.image!.size.width)
            let total_height = real_empty_label_size.height + EMPTY_ICON_HEIGHT + EMPTY_LABEL_SPACING_TOP
            empty_icon.frame = CGRect(x: view.center.x - 0.5 * empty_icon_width, y: 0.5 * (view.bounds.height - BOTTOM_BUTTONS_HEIGHT - topic_image_view.bounds.height) + topic_image_view.frame.maxY - 0.5 * total_height, width: empty_icon_width, height: EMPTY_ICON_HEIGHT)
            empty_label.frame = CGRect(x: view.center.x - 0.5 * real_empty_label_size.width, y: empty_icon.frame.maxY + EMPTY_LABEL_SPACING_TOP, width: real_empty_label_size.width, height: real_empty_label_size.height)
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
    
    func prepareWith(sponsorId:Int, sponsorTitle:String) {
        sponsor_id = sponsorId
        sponsor_title = sponsorTitle
    }
    
    func shootHint() {
        if !UserDefaults().bool(forKey: "tutorial_sponsor_passed") {
            let bottom_button_rect = put_voting_button.convert(put_voting_button.bounds, to: view)
            if bottom_button_rect.midY <= view.bounds.height {
                NotificationCenter.default.post(name: Notification.Name.init("notification_show_hint"), object: nil, userInfo: ["hintText":"Send request to sponsors you like. This is the first step towards landing a sponsorship deal.\nIn order to do this, you must have an event profile setup in Sponsy website interface.","transparentHole":NSValue.init(cgRect: send_request_button.convert(send_request_button.bounds.insetBy(dx: -6, dy: -6), to: UIApplication.shared.keyWindow!)),"hintTappedHandler":{
                    let voting_button_hole = self.put_voting_button.convert(self.put_voting_button.bounds, to: UIApplication.shared.keyWindow!).insetBy(dx: -4, dy: -4)
                    NotificationCenter.default.post(name: Notification.Name.init("notification_show_hint"), object: nil, userInfo: ["hintText":"Use this button to put a potential sponsorship deal between your event and this sponsor to public voting. People will vote about the appropriateness of this partnership.\nIn order to do this, you must have an event profile setup in Sponsy website interface.","transparentHole":NSValue.init(cgRect: voting_button_hole),"hintTappedHandler":NSNull()])
                    UserDefaults().set(true, forKey: "tutorial_sponsor_passed")
                    }])
            }
        }
    }
    
    func setSponsorData(_ data:SponsySponsorDetailed) {
        print("setting sap data")
        UIView.animate(withDuration: 0.5, animations: {
            self.data_view.alpha = 1.0
        })
        self.sponsor_data_detailed = data
        money_required_text.text = "$\(data.money_info)"
        location_text.text = data.location_info
        total_spent_text.text = "$\(data.money_spent_info)"
        time_sponsoring_text.text = data.age_info
        audience_text.text = data.audience_required_info
        description_text.text = data.description
        events_types_text.text = data.events_types
        view.setNeedsLayout()
        view.layoutIfNeeded()
        //data_view.contentSize = CGSize.init(width: data_view.bounds.width, height: put_voting_button.frame.maxY + 10)
        put_voting_button.addTarget(self, action: #selector(DetailedSponsorViewController.putForVotingPressed(_:)), for: .touchUpInside)
        shootHint()
    }
    
    func positionTopicTitle() {
        let max_text_height = TOPIC_IMAGE_HEIGHT_FIXED - TOPIC_TEXT_TOP_BOTTOM_MARGIN * 2.0 - UIApplication.shared.statusBarFrame.height
        let text_width = view.bounds.width * TOPIC_TEXT_WIDTH_RELATIVE
        topic_title_label.frame = CGRect(x: 0, y: 0, width: text_width, height: 1000)
        topic_title_label.text = sponsor_title
        let topic_title_font_size = getTitleFontSizeForTitleLabel(topic_title_label, maxHeight: max_text_height)
        topic_title_label.font = UIFont(name: "ProximaNovaCond-Bold", size: topic_title_font_size)!
        let real_text_height = topic_title_label.textRect(forBounds: topic_title_label.bounds, limitedToNumberOfLines: 0).height
        topic_title_label.frame = CGRect(x: 0.5 * view.bounds.width - text_width * 0.5, y: (TOPIC_IMAGE_HEIGHT_FIXED - UIApplication.shared.statusBarFrame.height - real_text_height) * 0.5 + UIApplication.shared.statusBarFrame.height , width: text_width, height: real_text_height)
    }
    
    func getTitleFontSizeForTitleLabel(_ titleLabel:UILabel, maxHeight:CGFloat) -> CGFloat {
        let test_label = titleLabel
        var resultingFontSize:CGFloat = TOPIC_TEXT_MAX_FONT_SIZE
        for final_font_size in stride(from : TOPIC_TEXT_MAX_FONT_SIZE, to : 1.0 , by : -1.0) {
            test_label.font = UIFont(name: "ProximaNova-Bold", size: final_font_size)!
            let test_size = test_label.textRect(forBounds: test_label.bounds, limitedToNumberOfLines: 0)
            if test_size.height <= maxHeight {
                resultingFontSize = final_font_size
                break
            }
        }
        return resultingFontSize
    }
    
    func backButtonPressed(_ sender:UIButton) {
        //calculating some interest score...
        //NSNotificationCenter.defaultCenter().postNotificationName("notification_should_show_related_topics", object: nil, userInfo: ["topicId":topic_id])
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func sendRequestPressed(sender:UIButton) {
        print("send pressed")
        if General.authorized {
            let send_request_vc = self.storyboard!.instantiateViewController(withIdentifier: "suggestions_vc") as! SuggestionsViewController
            send_request_vc.prepareWithRequestDestination("sponsor", destinationTitle: sponsor_title, destinationId: sponsor_id)
            navigationController!.pushViewController(send_request_vc, animated: true)
        }
        else {
            let login_alert = UIAlertController.init(title: "You are not logged in", message: "In order to continue you must enter your credentials", preferredStyle: .alert)
            login_alert.addAction(UIAlertAction.init(title: "Proceed to login", style: .default, handler: {
                (act:UIAlertAction) in
                let login_vc = self.storyboard!.instantiateViewController(withIdentifier: "login_vc") as! LoginViewController
                self.present(login_vc, animated: true, completion: nil)
            }))
            login_alert.addAction(UIAlertAction.init(title: "Cancel", style: .destructive, handler: nil))
            present(login_alert, animated: true, completion: nil)
        }
    }
    
    func putForVotingPressed(_ sender:UIButton) {
        print("put pressed")
        if General.authorized {
            let voting_alert = UIAlertController.init(title: "Put for a vote", message: "You are about to make your potential partnership with this sponsor available for public voting. This action requires having an active event position. You can create one in an online interface.", preferredStyle: .alert)
            voting_alert.addAction(UIAlertAction.init(title: "Proceed", style: .default, handler: {
                (act:UIAlertAction) in
                let vote_task = HailyPutForVotingTask(partyId: self.sponsor_id, partyType: "sponsor")
                let task_builder = HailyTaskBuilder(session: General.session_data, anonymous: false, degradePossible: false)
                task_builder.addTasks([vote_task])
                task_builder.sendTasksWithCompletionHandler({
                    (parsedResponse:[HailyParsedResponse]?, error:Error?) in
                    var success = false
                    if let responses = parsedResponse {
                        if responses.count == 1 {
                            print("received putting to voting response")
                            if let votingResult = responses[0].result {
                                if votingResult == HailyResponseResult.ok {
                                    success = true
                                    DispatchQueue.main.async(execute: {
                                        let ok_screen = UIAlertController.init(title: "Success!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                                        ok_screen.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                        self.present(ok_screen, animated: true, completion: nil)
                                        NotificationCenter.default.post(name: Notification.Name.init("notification_update_votings"), object: nil, userInfo: nil)
                                    })
                                }
                            }
                            
                        }
                    }
                    if !success {
                        print("Error with receiving put to voting vote_resulkt!!")
                        if let _error = error {
                            print(_error)
                        }
                        DispatchQueue.main.async(execute: {
                            NotificationCenter.default.post(kHailyDataRetrievalErrorSliderNotification)
                            let error_screen = UIAlertController.init(title: "Error", message: "Could not put this partnership to a public voting. Possible reasons:\n1) The voting for partnership with this particular sponsor has already started\n2) You haven't specified your event data. Go to www.sponsy.org to add this info.\n3) There are connection troubles", preferredStyle: UIAlertControllerStyle.alert)
                            error_screen.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                            self.present(error_screen, animated: true, completion: nil)
                        })
                    }
                })
            }))
            voting_alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            present(voting_alert, animated: true, completion: nil)
        }
        else {
            let login_alert = UIAlertController.init(title: "You are not logged in", message: "In order to continue you must enter your credentials", preferredStyle: .alert)
            login_alert.addAction(UIAlertAction.init(title: "Proceed to login", style: .default, handler: {
                (act:UIAlertAction) in
                let login_vc = self.storyboard!.instantiateViewController(withIdentifier: "login_vc") as! LoginViewController
                self.present(login_vc, animated: true, completion: nil)
            }))
            login_alert.addAction(UIAlertAction.init(title: "Cancel", style: .destructive, handler: nil))
            present(login_alert, animated: true, completion: nil)
        }
    }
    
}
