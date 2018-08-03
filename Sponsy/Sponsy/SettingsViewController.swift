//
//  SettingsViewController.swift
//  Haily
//
//  Created by Admin on 18.01.17.
//  Copyright © 2017 Vanoproduction. All rights reserved.
//

import UIKit

class SettingsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let NAVIGATION_BAR_COLOR:UIColor = UIColor(red: 200/255, green: 59/255, blue: 51/255, alpha: 1.0)
    
    var layed_out = false
    var profile_updating = false
    var settings_table:UITableView!
    var settings_dict:[[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constructSettingsDict()
        settings_table = UITableView(frame: view.bounds, style: .grouped)
        settings_table.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        settings_table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 7))
        //settings_table.backgroundColor = UIColor.clear
        settings_table.delegate = self
        settings_table.dataSource = self
        view.addSubview(settings_table)
        NotificationCenter.default.addObserver(self, selector: #selector(loggedIn), name: Notification.Name.init("notification_logged_in"), object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if layed_out {
            return
        }
        print("will layout")
        settings_table.frame = view.bounds
        navigationController!.navigationBar.barStyle = UIBarStyle.black
        navigationController!.navigationBar.tintColor = UIColor.white
        navigationController!.navigationBar.barTintColor = NAVIGATION_BAR_COLOR
        navigationController!.navigationBar.isTranslucent = false
        navigationController!.navigationBar.backgroundColor = NAVIGATION_BAR_COLOR
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController!.navigationBar.shadowImage = UIImage()
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(SettingsViewController.close(_:))), animated: false)
        navigationItem.title = "Settings"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("did layout called")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //settings_table.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .fade)
    }
    
    func loggedIn(sender:Notification) {
        dismiss(animated: true, completion: nil)
    }
    
    func constructSettingsDict() {
        settings_dict = []
        settings_dict.append(["type":"login"])
        settings_dict.append(["type":"terms"])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch settings_dict[indexPath.row]["type"] as! String {
        case "terms" :
            navigationController!.pushViewController(self.storyboard!.instantiateViewController(withIdentifier: "plain_text_vc"), animated: true)
        case "login" :
            if General.authorized {
                let alert = UIAlertController(title: "Warning!", message: "Are you sure you'd like to log out?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: {
                    (act:UIAlertAction) in
                    alert.dismiss(animated: true, completion: nil)
                    General.authorized = false
                    General.sponsors_favorite = []
                    General.events_favorite = []
                    UserDefaults().removeObject(forKey: "auth_token")
                    NotificationCenter.default.post(name: Notification.Name.init("notification_logged_out"), object: nil, userInfo: nil)
                    self.dismiss(animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let login_vc = self.storyboard!.instantiateViewController(withIdentifier: "login_vc") as! LoginViewController
                present(login_vc, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "settings_cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "settings_cell")
        }
        var cellText = ""
        var cellColor = UIColor.black
        var cellIconTitle = ""
        var arrowRequired = true
        switch settings_dict[indexPath.row]["type"] as! String {
        case "terms" :
            cellText = "Terms and conditions"
            cellIconTitle = "settings_terms_icon"
        case "login" :
            cellIconTitle = "settings_logout_icon"
            cellText = General.authorized ? "Logout" : "Login"
            cellColor = UIColor.red
            arrowRequired = false
        default:
            break
        }
        cell!.textLabel?.text = cellText
        cell!.textLabel?.textColor = cellColor
        cell!.imageView?.image = UIImage(named: cellIconTitle)!
        cell!.imageView?.contentMode = .center
        cell!.accessoryType = arrowRequired ? .disclosureIndicator : .none
        cell!.accessoryView = nil
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings_dict.count
    }
    
    func close(_ sender:UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

class SuggestionsViewController : UIViewController, UITextViewDelegate {
    
    let ABOUT_FIELD_MARGIN_SIDES:CGFloat = 10
    let ABOUT_FIELD_CORNER_RADIUS:CGFloat = 6
    let ABOUT_FIELD_TEXT_SIZE:CGFloat = 14
    let ABOUT_FIELD_TEXT_COLOR_NORMAL = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1.0)
    let ABOUT_FIELD_TEXT_COLOR_PLACEHOLDER = UIColor(red: 136/255, green: 136/255, blue: 136/255, alpha: 1.0)
    let ABOUT_FIELD_FRAME_COLOR_PLACEHOLDER = UIColor(red: 201/255, green: 201/255, blue: 201/255, alpha: 1.0)
    let ABOUT_FIELD_FRAME_COLOR_NORMAL = UIColor(red: 111/255, green: 111/255, blue: 111/255, alpha: 1.0)
    let ABOUT_FIELD_FRAME_WIDTH_NORMAL:CGFloat = 2.0
    let ABOUT_FIELD_FRAME_WIDTH_PLACEHOLDER:CGFloat = 1.0
    let SEND_BUTTON_WIDTH_RELATIVE:CGFloat = 0.8
    let SEND_BUTTON_MARGIN_TOP_BOTTOM:CGFloat = 11
    let SEND_BUTTON_HEIGHT:CGFloat = 42
    var MAX_TEXT_FIELD_HEIGHT:CGFloat = 100
    let TEXT_FIELD_MARGIN_TOP:CGFloat = 12
    let MAX_CHARACTERS_COUNT = 1000
    
    var message_text:UITextView!
    @IBOutlet var enter_label:UILabel!
    var send_button:BoldButton!
    let placeholder_text = "Enter your message here..."
    var keyboard_toolbar:UIToolbar!
    var destination_type:String = ""
    var destination_id:Int = -1
    var destination_title = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboard_toolbar = UIToolbar()
        keyboard_toolbar.sizeToFit()
        keyboard_toolbar.items = [UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(SuggestionsViewController.doneKeyboardPressed))]
        message_text = UITextView()
        message_text.inputAccessoryView = keyboard_toolbar
        message_text.delegate = self
        message_text.layer.borderColor = ABOUT_FIELD_FRAME_COLOR_PLACEHOLDER.cgColor
        message_text.layer.borderWidth = ABOUT_FIELD_FRAME_WIDTH_PLACEHOLDER
        message_text.layer.cornerRadius = ABOUT_FIELD_CORNER_RADIUS
        view.addSubview(message_text)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SuggestionsViewController.outsideTap)))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        enter_label.text = "You are about to send request to \(destination_title)"
        message_text.typingAttributes = [NSFontAttributeName:UIFont(name: "ProximaNova-Regular", size: ABOUT_FIELD_TEXT_SIZE)!,NSForegroundColorAttributeName:ABOUT_FIELD_TEXT_COLOR_PLACEHOLDER]
        message_text.text = placeholder_text
        let about_field_width = view.bounds.width - 2.0 * ABOUT_FIELD_MARGIN_SIDES
        let about_field_text_size = (message_text.text as NSString).boundingRect(with: CGSize(width: about_field_width, height: 1000), options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: [NSFontAttributeName:UIFont(name: "ProximaNova-Regular", size: ABOUT_FIELD_TEXT_SIZE)!], context: nil)
        message_text.frame = CGRect(x: ABOUT_FIELD_MARGIN_SIDES, y: enter_label.frame.maxY + TEXT_FIELD_MARGIN_TOP, width: about_field_width, height: message_text.contentSize.height)
        let send_button_width = SEND_BUTTON_WIDTH_RELATIVE * view.bounds.width
        send_button = BoldButton(frame: CGRect.init(x: 0.5 * view.bounds.width - 0.5 * send_button_width, y: view.bounds.height - SEND_BUTTON_MARGIN_TOP_BOTTOM - SEND_BUTTON_HEIGHT, width: send_button_width, height: SEND_BUTTON_HEIGHT), buttonData: BoldButtonData(buttonTitle: "SEND", buttonColorStyle: .red, buttonAction: {
            self.view.endEditing(true)
            if self.message_text.text == self.placeholder_text || self.message_text.text.characters.count == 0 {
                self.showAlertWithMessage(message: "Enter something!")
            }
            else {
                let text_send = (self.message_text.text.characters.count > self.MAX_CHARACTERS_COUNT ? self.message_text.text.substring(to: self.message_text.text.index(self.message_text.text.startIndex, offsetBy: 1000)) : self.message_text.text)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                let task_builder = HailyTaskBuilder(session: General.session_data, anonymous: false, degradePossible: true)
                task_builder.addTasks([HailySuggestionTask.init(type: self.destination_type, id: self.destination_id, suggestionText: text_send!)])
                task_builder.sendTasksWithCompletionHandler({
                    (parsedResponse:[HailyParsedResponse]?,error:Error?) in
                    var success = false
                    if let responses = parsedResponse {
                        if responses.count == 1 {
                            if let result = responses[0].result {
                                if result == HailyResponseResult.ok {
                                    print("Sent your request succesfully")
                                    success = true
                                }
                            }
                        }
                    }
                    if !success {
                        print("Troubles while sending your request")
                        if let _error = error {
                            print(_error)
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        self.showAlertWithMessage(message: success ? "Your request was sent successfully" : "Regretfully, could not send your request. Possible reasons:\n1) You are trying to send request to \(self.destination_type) without having specified your \(self.destination_type == "event" ? "sponsor" : "event") data\n2) There are some connection troubles")
                        if success {
                            self.message_text.text = ""
                            self.textViewDidEndEditing(self.message_text)
                        }
                    })
                })
                print("Sending request")
            }
        }))
        view.addSubview(send_button)
        MAX_TEXT_FIELD_HEIGHT = send_button.frame.minY - SEND_BUTTON_MARGIN_TOP_BOTTOM - message_text.frame.minY
    }
    
    func prepareWithRequestDestination(_ destinationType:String, destinationTitle:String, destinationId:Int) {
        self.destination_id = destinationId
        self.destination_type = destinationType
        self.destination_title = destinationTitle
    }
    
    func doneKeyboardPressed(sender:UIBarButtonItem) {
        message_text.endEditing(true)
    }
    
    func showAlertWithMessage(message:String) {
        let alert = UIAlertController(title: "Result", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (act:UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func outsideTap(sender:UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderColor = ABOUT_FIELD_FRAME_COLOR_NORMAL.cgColor
        textView.layer.borderWidth = ABOUT_FIELD_FRAME_WIDTH_NORMAL
        if textView.text == placeholder_text {
            textView.text = ""
        }
        textView.typingAttributes = [NSFontAttributeName:UIFont(name: "ProximaNova-Regular", size: ABOUT_FIELD_TEXT_SIZE)!, NSForegroundColorAttributeName:ABOUT_FIELD_TEXT_COLOR_NORMAL]
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        message_text.layer.borderColor = ABOUT_FIELD_FRAME_COLOR_PLACEHOLDER.cgColor
        message_text.layer.borderWidth = ABOUT_FIELD_FRAME_WIDTH_PLACEHOLDER
        if textView.text == "" {
            textView.typingAttributes = [NSFontAttributeName:UIFont(name: "ProximaNova-Regular", size: ABOUT_FIELD_TEXT_SIZE)!, NSForegroundColorAttributeName:ABOUT_FIELD_TEXT_COLOR_PLACEHOLDER]
            textView.text = placeholder_text
        }
        else {
            textView.text = textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        textView.frame = CGRect(x: textView.frame.minX, y: textView.frame.minY, width: textView.bounds.width, height: textView.contentSize.height)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.frame = CGRect(x: textView.frame.minX, y: textView.frame.minY, width: textView.bounds.width, height: min(textView.contentSize.height, MAX_TEXT_FIELD_HEIGHT))
    }
    
}

class PlainTextViewController : UIViewController {
    
    @IBOutlet var plain_text:UITextView!
    var termsText:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let termsString = termsText {
            UIView.transition(with: plain_text, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.plain_text.text = termsString
            }, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HailyTaskBuilder(session: General.session_data, anonymous: true, degradePossible: true).loadS3FileWithPath("terms.txt", completionHandler: {
            (data:Data?,error:Error?) in
            if let termsData = data {
                let terms_string = String.init(data: termsData, encoding: String.Encoding.utf8)
                if self.plain_text != nil {
                    UIView.transition(with: self.plain_text, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.plain_text.text = terms_string
                    }, completion: nil)
                }
                else {
                    self.termsText = terms_string
                }
            }
            else {
                print("Can not load terms text!")
                if let err = error {
                    print(err)
                }
            }
        })
    }
}
