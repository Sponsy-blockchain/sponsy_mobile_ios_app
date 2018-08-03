//
//  RequestsViewController.swift
//  Sponsy
//
//  Created by Admin on 22.09.17.
//  Copyright © 2017 Vano Production. All rights reserved.
//

import UIKit

class RequestsViewController : ChildTabViewController {
    
    var layed_out = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if layed_out {
            return
        }
        /*
        let own_events_button = TableLikeButton(frame: CGRect.init(x: 15, y: 15, width: view.bounds.width - 30, height: 40), withLeftImage: UIImage.init(named: "own_events_icon")!, withText: "My events")
        own_events_button.addTarget(self, action: #selector(RequestsViewController.ownEventsPressed(_:)), for: .touchUpInside)
        view.addSubview(own_events_button)
        let own_sponsors_button = TableLikeButton(frame: CGRect.init(x: 15, y: own_events_button.frame.maxY + 15, width: view.bounds.width - 30, height: 40), withLeftImage: UIImage.init(named: "own_sponsors_icon")!, withText: "My sponsors")
        own_sponsors_button.addTarget(self, action: #selector(RequestsViewController.ownSponsorsPressed(_:)), for: .touchUpInside)
        view.addSubview(own_sponsors_button)
 */
        let requests_sent_button = TableLikeButton(frame: CGRect.init(x: 15, y: 15, width: view.bounds.width - 30, height: 40), withLeftImage: UIImage.init(named: "outgoing_requests_icon")!, withText: "Sent requests")
        requests_sent_button.addTarget(self, action: #selector(RequestsViewController.requestsSentPressed(_:)), for: .touchUpInside)
        view.addSubview(requests_sent_button)
        let requests_received_button = TableLikeButton(frame: CGRect.init(x: 15, y: requests_sent_button.frame.maxY + 15, width: view.bounds.width - 30, height: 40), withLeftImage: UIImage.init(named: "incoming_requests_icon")!, withText: "Received requests")
        requests_received_button.addTarget(self, action: #selector(RequestsViewController.requestsReceivedPressed(_:)), for: .touchUpInside)
        view.addSubview(requests_received_button)
        layed_out = true
    }
    
    func ownEventsPressed(_ sender:TableLikeButton) {
        if checkEligibility() {
            NotificationCenter.default.post(name: Notification.Name.init("notification_open_lister"), object: nil, userInfo: ["title":"My events","paradigm":LoadableParadigm.init(origin: LoadableOrigin.events, type: LoadableType.own, id: -1)])
        }
    }
    
    func ownSponsorsPressed(_ sender:TableLikeButton) {
        if checkEligibility() {
            NotificationCenter.default.post(name: Notification.Name.init("notification_open_lister"), object: nil, userInfo: ["title":"My sponsors","paradigm":LoadableParadigm.init(origin: LoadableOrigin.sponsors, type: LoadableType.own, id: -1)])
        }
    }
    
    func requestsSentPressed(_ sender:TableLikeButton) {
        if checkEligibility() {
            NotificationCenter.default.post(name: Notification.Name.init("notification_open_lister"), object: nil, userInfo: ["title":"Sent Requests","paradigm":LoadableParadigm.init(origin: LoadableOrigin.messages, type: LoadableType.sentMessages, id: -1)])
        }
    }

    func requestsReceivedPressed(_ sender:TableLikeButton) {
        if checkEligibility() {
            NotificationCenter.default.post(name: Notification.Name.init("notification_open_lister"), object: nil, userInfo: ["title":"Received Requests","paradigm":LoadableParadigm.init(origin: LoadableOrigin.messages, type: LoadableType.receivedMessages, id: -1)])
        }
    }
    
    func checkEligibility() -> Bool {
        if !General.authorized {
            let login_alert = UIAlertController.init(title: "You are not logged in", message: "In order to continue you must enter your credentials", preferredStyle: .alert)
            login_alert.addAction(UIAlertAction.init(title: "Proceed to login", style: .default, handler: {
                (act:UIAlertAction) in
                let login_vc = self.storyboard!.instantiateViewController(withIdentifier: "login_vc") as! LoginViewController
                self.present(login_vc, animated: true, completion: nil)
            }))
            login_alert.addAction(UIAlertAction.init(title: "Cancel", style: .destructive, handler: nil))
            present(login_alert, animated: true, completion: nil)
        }
        return General.authorized
    }
    
}
