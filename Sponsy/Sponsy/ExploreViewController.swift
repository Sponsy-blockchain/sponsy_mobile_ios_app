//
//  ExploreViewController.swift
//  Haily
//
//  Created by Admin on 30.11.16.
//  Copyright © 2016 Vanoproduction. All rights reserved.
//

import UIKit
import Kingfisher

class VotingViewController : ChildTabViewController, UITableViewDelegate, UITableViewDataSource, ExploreSearchDelegate {
    
    let EXPLORE_MOST_HEIGHT:CGFloat = 70.0
    let EXPLORE_MOST_ACTIVE_HEIGHT:CGFloat = 60.0
    let EXPLORE_RANDOM_HEIGHT:CGFloat = 45.0
    let EXPLORE_BOLD_HEIGHT:CGFloat = 70.0
    let UPPER_COLORED_PART_COLOR = UIColor(red: 200/255, green: 59/255, blue: 51/255, alpha: 1.0)
    let SEARCH_BAR_HEIGHT:CGFloat = 44
    let SEARCH_BAR_WIDTH_RELATIVE:CGFloat = 0.925
    let voting_table_WIDTH_RELATIVE:CGFloat = 0.925
    let EXPLORE_CELLS_SPACING:CGFloat = 10
    let voting_table_SPACING_TOP:CGFloat = 14 // from seacrh bar
    let SEARCH_VIEW_SPACING_TOP:CGFloat = 19
    let RANDOM_CELL_BG_COLOR = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1.0)
    let RANDOM_CELL_IMAGE_HEIGHT_RELATIVE:CGFloat = 0.6
    let RANDOM_CELL_TEXT_SIZE:CGFloat = 19
    let ANIMATION_VERTICAL_SHIFTING_VALUE:CGFloat = 100
    let ANIMATION_SHIFTING_DURATION:CFTimeInterval = 0.18
    let ANIMATION_SHIFTING_DELAY:CFTimeInterval = 0.1
    let TIME_WAIT_BEFORE_FIRING_SEARCH_TASK:CFTimeInterval = 1.5
    let VOTING_HEIGHT:CGFloat = 200
    let TABLE_SCROLL_RELATIVE_UPDATE:CGFloat = 0.83
    let EMPTY_ICON_HEIGHT:CGFloat = 65
    let EMPTY_LABEL_COLOR = UIColor(red: 125/255, green: 125/255, blue: 125/255, alpha: 1.0)
    let EMPTY_LABEL_TEXT_SIZE:CGFloat = 18
    let EMPTY_LABEL_SPACING_TOP:CGFloat = 8
    let EMPTY_LABEL_WIDTH_RELATIVE:CGFloat = 0.89 // to whole view width
    
    
    var upper_colored_part:UIView!
    var explore_search_bar:ExploreSearchBar!
    var voting_table:UITableView!
    var search_results_view:SearchResultsView!
    
    var voting_data:[SponsyVote] = []
    var flow_state:FlowState = FlowState.normal
    var showing_explore = true // showing explore OR search
    var layed_out = false
    var queued_search_task_builder:HailyTaskBuilder? = nil
    var queued_search_task_timer:Timer? = nil
    var empty_label:UILabel!
    var empty_icon:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        upper_colored_part = UIView()
        upper_colored_part.backgroundColor = UPPER_COLORED_PART_COLOR
        view.addSubview(upper_colored_part)
        empty_label = UILabel()
        empty_label.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(emptyTapped)))
        empty_label.isUserInteractionEnabled = true
        empty_label.numberOfLines = 0
        empty_label.textColor = EMPTY_LABEL_COLOR
        empty_label.textAlignment = .center
        empty_label.font = UIFont(name: "ProximaNova-Regular", size: EMPTY_LABEL_TEXT_SIZE)
        empty_label.alpha = 0.0
        view.addSubview(empty_label)
        empty_icon = UIImageView(image: UIImage(named: "data_empty_image_icon")!)
        empty_icon.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(emptyTapped)))
        empty_icon.isUserInteractionEnabled = true
        empty_icon.contentMode = .scaleAspectFit
        empty_icon.alpha = 0.0
        view.addSubview(empty_icon)
        NotificationCenter.default.addObserver(self, selector: #selector(VotingViewController.shootHint), name: Notification.Name.init("notification_votes_tutorial"), object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if layed_out {
            return
        }
        NotificationCenter.default.addObserver(self, selector: #selector(shouldUpdateVotings), name: Notification.Name.init("notification_update_votings"), object: nil)
        loadInitialVotings()
        upper_colored_part.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: SEARCH_BAR_HEIGHT * 0.5)
        let voting_table_width = view.bounds.width * voting_table_WIDTH_RELATIVE
        voting_table = UITableView(frame: CGRect(x: view.center.x - 0.5 * voting_table_width, y: upper_colored_part.frame.maxY, width: voting_table_width, height: view.bounds.height - upper_colored_part.bounds.height), style: .plain)
        voting_table.keyboardDismissMode = .onDrag
        voting_table.register(UINib.init(nibName: "VotingCell", bundle: nil), forCellReuseIdentifier: "voting_cell")
        voting_table.contentInset = UIEdgeInsetsMake(voting_table_SPACING_TOP + 0.5 * SEARCH_BAR_HEIGHT, 0, 2, 0)
        voting_table.delegate = self
        voting_table.rowHeight = UITableViewAutomaticDimension
        voting_table.estimatedRowHeight = 500
        voting_table.dataSource = self
        voting_table.backgroundColor = UIColor.clear
        voting_table.tableFooterView = UIView()
        voting_table.separatorColor = UIColor.gray
        voting_table.separatorStyle = .singleLine
        voting_table.showsVerticalScrollIndicator = false
        view.addSubview(voting_table)
        explore_search_bar = ExploreSearchBar(frame: CGRect(x: (1.0 - SEARCH_BAR_WIDTH_RELATIVE) * 0.5 * view.bounds.width, y: 0, width: view.bounds.width * SEARCH_BAR_WIDTH_RELATIVE, height: SEARCH_BAR_HEIGHT))
        explore_search_bar.search_delegate = self
        view.addSubview(explore_search_bar)
        search_results_view = SearchResultsView(frame: CGRect(x: 0, y: explore_search_bar.frame.maxY + SEARCH_VIEW_SPACING_TOP, width: view.bounds.width, height: view.bounds.height - explore_search_bar.frame.maxY - voting_table_SPACING_TOP))
        search_results_view.alpha = 0.0
        search_results_view.center.y += ANIMATION_VERTICAL_SHIFTING_VALUE
        view.addSubview(search_results_view)
        layed_out = true
    }
    
    func shootHint(sender:Notification) {
        if !UserDefaults().bool(forKey: "tutorial_votes_passed") {
            if let first_vote_cell = voting_table.cellForRow(at: IndexPath.init(row: 0, section: 0)) {
                let cell_rect = first_vote_cell.convert(first_vote_cell.bounds, to: UIApplication.shared.keyWindow!).insetBy(dx: 0, dy: -8)
                NotificationCenter.default.post(name: Notification.Name.init("notification_show_hint"), object: nil, userInfo: ["hintText":"This is one of potential future sponsorship deals. Express your opinion on this deal by voting either YES or NO. Your vote will help sponsor and sponsee to understand how their partnership is perceived by public.","transparentHole":NSValue.init(cgRect: cell_rect),"hintTappedHandler":NSNull()])
                UserDefaults().set(true, forKey: "tutorial_votes_passed")
            }
        }
    }
    
    
    func shouldUpdateVotings(sender:Notification) {
        loadInitialVotings()
    }
    
    func emptyTapped(sender:UITapGestureRecognizer) {
        print("eempty tapped")
        loadInitialVotings()
    }
    
    func fireSearchTask(_ sender:Timer) {
        if let searchTaskBuilder = queued_search_task_builder {
            
            searchTaskBuilder.sendTasksWithCompletionHandler({
                (parsedResponse:[HailyParsedResponse]?,error:Error?) in
                var success = false
                if let responses = parsedResponse {
                    print("Received search results")
                    success = true
                    var sponsors_found:[SponsySponsor]? = nil
                    var events_found:[SponsyEvent]? = nil
                    for response in responses {
                        if let _sponsors = response.sponsors {
                            if _sponsors.count > 0 {
                                sponsors_found = _sponsors.map({$0 as! SponsySponsor})
                            }
                        }
                        if let _events = response.events {
                            if _events.count > 0 {
                                events_found = _events.map({$0 as! SponsyEvent})
                            }
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        self.search_results_view.setSponsorsData(sponsors_found)
                        self.search_results_view.setEventsData(events_found)
                    })
                }
                if !success {
                    print("Error while receiving search results")
                    if let _error = error {
                        print(_error)
                    }
                    DispatchQueue.main.async(execute: {
                        NotificationCenter.default.post(kHailyDataRetrievalErrorSliderNotification)
                        self.search_results_view.clearDataWithStoppingLoading(true)
                    })
                }
            })
            print("Sending search tasks...")
        }
        sender.invalidate()
        queued_search_task_timer = nil
        queued_search_task_builder = nil
    }
    
    //in testing purposes - type "show" to show data, "empty" - to no data. otherwise - endless loading process
    func searchTextChangedTo(_ searchText:String?) {
        var shifting_anim = false
        if let now_searching_text = searchText {
            if showing_explore {
                shifting_anim = true
                showing_explore = false
            }
            /*
            if now_searching_text == "marina" {
                search_results_view.setResultsData([HailyTopic(topicId: 911, title: "Marina is a good girl!"),HailyTopic(topicId: 912, title: "Having such a friend as Marina - discussion!"),HailyTopic(topicId: 913, title: "Marina")], usersData: [HailyProfile(authorId: 11, authorTitle: "marianNN"),HailyProfile(authorId: 12, authorTitle: "vano_medaluga")])
            }
            else if now_searching_text == "empty" {
                search_results_view.setResultsData(nil, usersData: nil) //means nothing found
            }
            else if now_searching_text == "empty part" {
                search_results_view.setResultsData(nil, usersData: [HailyProfile(authorId: 111, authorTitle: "pseudoGuy")])
            }
            else {
                search_results_view.setLoading()
            }
*/
            search_results_view.setLoading()
            let task_builder = HailyTaskBuilder(session: General.session_data, anonymous: true, degradePossible: true)
            let search_users_task = HailySearchTask(searchType: HailySearchType.events, searchText: now_searching_text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
            let search_topics_task = HailySearchTask(searchType: HailySearchType.sponsors, searchText: now_searching_text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
            task_builder.addTasks([search_topics_task,search_users_task])
            if let timer = queued_search_task_timer {
                timer.invalidate()
                queued_search_task_timer = nil
            }
            queued_search_task_timer = Timer.scheduledTimer(timeInterval: TIME_WAIT_BEFORE_FIRING_SEARCH_TASK, target: self, selector: #selector(VotingViewController.fireSearchTask(_:)), userInfo: nil, repeats: false)
            queued_search_task_builder = task_builder
        }
        else {
            if let timer = queued_search_task_timer {
                timer.invalidate()
            }
            queued_search_task_timer = nil
            queued_search_task_builder = nil
            shifting_anim = true
            showing_explore = true
            search_results_view.clearDataWithStoppingLoading(true)
        }
        if shifting_anim {
            UIView.animate(withDuration: ANIMATION_SHIFTING_DURATION, animations: {
                if self.showing_explore {
                    self.search_results_view.alpha = 0.0
                    self.search_results_view.center.y += self.ANIMATION_VERTICAL_SHIFTING_VALUE
                }
                else {
                    self.voting_table.alpha = 0.0
                    self.voting_table.center.y += self.ANIMATION_VERTICAL_SHIFTING_VALUE
                }
            })
            UIView.animate(withDuration: ANIMATION_SHIFTING_DURATION, delay: ANIMATION_SHIFTING_DELAY, options: .curveLinear, animations: {
                if self.showing_explore {
                    self.voting_table.center.y -= self.ANIMATION_VERTICAL_SHIFTING_VALUE
                    self.voting_table.alpha = 1.0
                }
                else {
                    self.search_results_view.alpha = 1.0
                    self.search_results_view.center.y -= self.ANIMATION_VERTICAL_SHIFTING_VALUE
                }
                }, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if flow_state == FlowState.normal {
                if scrollView.contentOffset.y >= max((TABLE_SCROLL_RELATIVE_UPDATE * scrollView.contentSize.height - voting_table.bounds.height), scrollView.contentSize.height - 3.5 * voting_table.bounds.height)  {
                    print("should load new users...")
                    flow_state = FlowState.loading
                    let votes_task = HailyReceiveTask(dataOrigin: HailyDataOrigin.vote, dataType: HailyDataType.all)
                    let task_builder = HailyTaskBuilder(session: General.session_data, anonymous: false, degradePossible: false)
                    
                    var lastId:Int? = nil
                    if voting_data.count > 0 {
                        lastId = voting_data.last?.vote_id
                    }
                    votes_task.lastId = lastId
                    task_builder.addTasks([votes_task])
                    task_builder.sendTasksWithCompletionHandler({
                        (parsedResponse:[HailyParsedResponse]?, error:Error?) in
                        var success = false
                        if let responses = parsedResponse {
                            if responses.count == 1 {
                                print("Received additional votings response, handling now")
                                self.flow_state = responses[0].dataEnd ? FlowState.end : FlowState.normal
                                let init_count = self.voting_data.count
                                var indices_add:[IndexPath] = []
                                if let votes = responses[0].votings {
                                    if votes.count > 0 {
                                        self.voting_data.append(contentsOf: votes)
                                        success = true
                                        for i in 0 ... votes.count - 1 {
                                            indices_add.append(IndexPath.init(row: i + init_count, section: 0))
                                        }
                                    }
                                }
                                if success {
                                    DispatchQueue.main.async(execute: {
                                        self.voting_table.insertRows(at: indices_add, with: .fade)
                                    })
                                }
                            }
                        }
                        if !success {
                            print("Error while loading new profiles")
                            DispatchQueue.main.async(execute: {
                                NotificationCenter.default.post(kHailyDataRetrievalErrorSliderNotification)
                            })
                            if let _err = error {
                                print(_err)
                            }
                        }
                    })
                    print("Sending new profiles request")
                }
            }
    }
    
    func setEmptyStateWithText(_ emptyText:String?) {
        if let newEmptyText = emptyText {
            empty_label.text = newEmptyText
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
        }
        else {
            UIView.animate(withDuration: 0.4, animations: {
                self.empty_label.alpha = 0.0
                self.empty_icon.alpha = 0.0
            })
        }
    }
    
    func loadInitialVotings() {
        let votes_task = HailyReceiveTask(dataOrigin: HailyDataOrigin.vote, dataType: HailyDataType.all)
        let task_builder = HailyTaskBuilder(session: General.session_data, anonymous: false, degradePossible: false)
        task_builder.addTasks([votes_task])
        task_builder.sendTasksWithCompletionHandler({
            (parsedResponse:[HailyParsedResponse]?, error:Error?) in
            var success = false
            if let responses = parsedResponse {
                if responses.count == 1 {
                    print("Received initial votings response, handling now")
                    self.flow_state = responses[0].dataEnd ? FlowState.end : FlowState.normal
                    if let votes = responses[0].votings {
                        self.voting_data = Array.init(votes)
                        if votes.count == 0 {
                            DispatchQueue.main.async(execute: {
                                self.setEmptyStateWithText("No partnerships are available for voting yet\nTap here to retry")
                            })
                        }
                        else {
                            DispatchQueue.main.async(execute: {
                                self.setEmptyStateWithText(nil)
                            })
                        }
                        success = true
                    }
                    if success {
                        DispatchQueue.main.async(execute: {
                            self.voting_table.reloadData()
                        })
                    }
                    
                }
            }
            if !success {
                print("Error with receiving initial votings!!")
                if let _error = error {
                    print(_error)
                }
                DispatchQueue.main.async(execute: {
                    self.setEmptyStateWithText("Troubles while loading votings\nTap here to retry")
                    self.flow_state = FlowState.trouble
                    NotificationCenter.default.post(kHailyDataRetrievalErrorSliderNotification)
                })
            }
            
        })
        print("Sent initial profiles request, waiting for response")
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "voting_cell") as! VotingCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let voting = voting_data[indexPath.section]
        let menu = UIAlertController.init(title: "Vote on \(voting.sponsor_title) and \(voting.event_title) partnership!", message: nil, preferredStyle: .actionSheet)
        menu.addAction(UIAlertAction.init(title: "Open Event details", style: .default, handler: {
            (action:UIAlertAction) in
            NotificationCenter.default.post(name: Notification.Name.init("notification_open_event"), object: nil, userInfo: ["origin":"voting","votingData":voting])
        }))
        menu.addAction(UIAlertAction.init(title: "Open Sponsor details", style: .default, handler: {
            (action:UIAlertAction) in
            NotificationCenter.default.post(name: Notification.Name.init("notification_open_sponsor"), object: nil, userInfo: ["origin":"voting","votingData":voting])
        }))
        menu.addAction(UIAlertAction.init(title: "Vote YES", style: .default, handler: {
            (action:UIAlertAction) in
            self.voteYes(true, onVotingId: voting.vote_id)
        }))
        menu.addAction(UIAlertAction.init(title: "Vote NO", style: .default, handler: {
            (action:UIAlertAction) in
            self.voteYes(false, onVotingId: voting.vote_id)
        }))
        menu.addAction(UIAlertAction.init(title: "Close", style: .cancel, handler: nil))
        present(menu, animated: true, completion: nil)
        if UIDevice().userInterfaceIdiom != .phone {
            menu.popoverPresentationController?.sourceView = UIApplication.shared.keyWindow
            var finalRect = CGRect.init(x: 0, y: 60, width: view.bounds.width, height: 150)
            if let selectedCell = voting_table.cellForRow(at: indexPath) {
                finalRect = selectedCell.convert(selectedCell.bounds, to: UIApplication.shared.keyWindow!)
            }
            menu.popoverPresentationController?.sourceRect = finalRect
            menu.popoverPresentationController?.permittedArrowDirections = [.any]
        }
    }
    
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return VOTING_HEIGHT
    }
    */
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacer_view = UIView(frame: CGRect(x: 0, y: 0, width: voting_table.bounds.width, height: EXPLORE_CELLS_SPACING))
        spacer_view.backgroundColor = UIColor.clear
        return section == voting_data.count - 1 ? nil : spacer_view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == voting_data.count - 1 ? 0.0 : EXPLORE_CELLS_SPACING
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func voteYes(_ yes:Bool, onVotingId:Int) {
        if General.authorized {
            let vote_task = HailyVoteTask(voteId: onVotingId, voteYes: yes)
            let task_builder = HailyTaskBuilder(session: General.session_data, anonymous: false, degradePossible: false)
            task_builder.addTasks([vote_task])
            task_builder.sendTasksWithCompletionHandler({
                (parsedResponse:[HailyParsedResponse]?, error:Error?) in
                var success = false
                if let responses = parsedResponse {
                    if responses.count == 1 {
                        print("received voting response")
                        if let votingResult = responses[0].result {
                            if votingResult == HailyResponseResult.ok {
                                success = true
                                DispatchQueue.main.async(execute: {
                                    let ok_screen = UIAlertController.init(title: "Success!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                                    ok_screen.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                    self.present(ok_screen, animated: true, completion: nil)
                                    self.loadInitialVotings()
                                })
                            }
                        }
                        
                    }
                }
                if !success {
                    print("Error with receiving vote_resulkt!!")
                    if let _error = error {
                        print(_error)
                    }
                    DispatchQueue.main.async(execute: {
                        NotificationCenter.default.post(kHailyDataRetrievalErrorSliderNotification)
                        let error_screen = UIAlertController.init(title: "Error", message: "Could not vote. Possible reasons:\n1) You have already voted\n2) There are connection troubles", preferredStyle: UIAlertControllerStyle.alert)
                        error_screen.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                        self.present(error_screen, animated: true, completion: nil)
                    })
                }
            })
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! VotingCell).setData(voting_data[indexPath.section] )
        let event_id = voting_data[indexPath.section].event_id
        let sponsor_id = voting_data[indexPath.section].sponsor_id
        General.events_images_cache.retrieveImage(forKey: "\(event_id)", options: nil, completionHandler: {
            (image:UIImage?, cache:CacheType) in
            if let _image = image {
                (cell as? VotingCell)?.setEventImage(_image, animated: false)
            }
            else {
                ImageDownloader.default.downloadImage(with: URL.init(string: "\(General.images_bucket_address)event\(event_id)")!, options: nil, progressBlock: nil, completionHandler: {
                    (image:UIImage?, error:NSError?, url:URL?, data:Data?) in
                    if let _image = image {
                        print("downloaded image for row \(indexPath.row)")
                        if let voteCell = cell as? VotingCell {
                            if let votingData = self.voting_data[indexPath.section] as? SponsyVote {
                                if votingData.event_id == voteCell.event_id {
                                    voteCell.setEventImage(_image, animated: true)
                                }
                            }
                        }
                        General.events_images_cache.store(_image, original: data, forKey: "\(event_id)")
                    }
                    if let err = error {
                        print("error with getting from s3 for topic id \(event_id)")
                        print(err)
                    }
                })
            }
        })
        General.sponsors_images_cache.retrieveImage(forKey: "\(sponsor_id)", options: nil, completionHandler: {
            (image:UIImage?, cache:CacheType) in
            if let _image = image {
                //print("retrieved img from cache for row \(indexPath.row)")
                (cell as? VotingCell)?.setSponsorImage(_image, animated: false)
            }
            else {
                ImageDownloader.default.downloadImage(with: URL.init(string: "\(General.images_bucket_address)sponsor\(sponsor_id)")!, options: nil, progressBlock: nil, completionHandler: {
                    (image:UIImage?, error:NSError?, url:URL?, data:Data?) in
                    if let _image = image {
                        print("downloaded image for row \(indexPath.row)")
                        if let voteCell = cell as? VotingCell {
                            if let votingData = self.voting_data[indexPath.section] as? SponsyVote {
                                if votingData.sponsor_id == voteCell.sponsor_id {
                                    voteCell.setSponsorImage(_image, animated: true)
                                }
                            }
                        }
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return voting_data.count
    }
    
}
