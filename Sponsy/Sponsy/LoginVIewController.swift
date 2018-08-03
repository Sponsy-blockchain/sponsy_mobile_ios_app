//
//  LoginVIewController.swift
//  Haily
//
//  Created by Admin on 12.01.17.
//  Copyright © 2017 Vanoproduction. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController, UITextFieldDelegate {
    
    let TITLE_WIDTH_RELATIVE:CGFloat = 0.52
    let TITLE_LOGO_SPACING:CGFloat = 30
    let LOGO_HEIGHT_RELATIVE:CGFloat = 0.1
    let TITLE_BOTTOM_SPACING_RELATIVE:CGFloat = 0.6
    let LOGIN_TEXT_FONT_SIZE:CGFloat = 20
    let LOGIN_BOX_COLOR = UIColor(red: 255/255, green: 87/255, blue: 87/255, alpha: 1.0)
    let LOGIN_BOX_WIDTH_RELATIVE:CGFloat = 0.93
    let LOGIN_BOX_PADDING:CGFloat = 8
    let BUTTONS_WIDTH_RELATIVE:CGFloat = 0.69
    let BUTTONS_HEIGHT:CGFloat = 42
    let BUTTONS_TOP_BOTTOM_MARGIN:CGFloat = 20
    let BUTTONS_INTER_MARGIN:CGFloat = 13
    let BUTTON_DISABLED_OPACITY:CGFloat = 0.45
    let NICKNAME_TEXT_SIZE:CGFloat = 17
    let NICKNAME_PLACEHOLDER_OPACITY:CGFloat = 0.75
    let NICKNAME_LINE_THICKNESS:CGFloat = 2
    let NICKNAME_LINE_WIDTH_RELATIVE:CGFloat = 0.81
    let NICKNAME_LINE_MARGIN_BOTTOM:CGFloat = 22
    let NICKNAME_LINE_MARGIN_TOP:CGFloat = 11
    let NICKNAME_ICON_PADDING_LEFT:CGFloat = 15
    let NICKNAME_ICON_HEIGHT:CGFloat = 25
    let email_field_MARGIN_LEFT:CGFloat = 17
    let email_field_HEIGHT:CGFloat = 24
    
    @IBOutlet var title_label:UILabel!
    @IBOutlet var signup_button:UIButton!
    @IBOutlet var website_label_field:UILabel!
    @IBOutlet var logo_icon:UIImageView!
    @IBOutlet var email_field:UITextField!
    @IBOutlet var pass_field:UITextField!
    @IBOutlet var login_button:UIButton!
    @IBOutlet var bottom_distance_con:NSLayoutConstraint!
    @IBOutlet var scroll_view:UIScrollView!
    var nickname_icon:UIImageView!
    var nickname_line:CALayer!
    var layed_out = false
    var skipButtonAvailable = true
    var completionHandler:(() -> Void)?
    var current_login_stage = 1 // 1 - propose to login , 2 - entering nickname
    var activity_started = false
    var nickname_entered = false
    var login_source = "profile"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        email_field.autocapitalizationType = .none
        email_field.autocorrectionType = .no
        email_field.spellCheckingType = .no
        email_field.delegate = self
        email_field.defaultTextAttributes = [NSFontAttributeName:UIFont.init(name: "ProximaNovaCond-Regular", size: NICKNAME_TEXT_SIZE)!,NSForegroundColorAttributeName:UIColor.black]
        email_field.attributedPlaceholder = NSMutableAttributedString(string: "email..", attributes: [NSFontAttributeName:UIFont.init(name: "ProximaNovaCond-Regular", size: NICKNAME_TEXT_SIZE)!,NSForegroundColorAttributeName:UIColor.gray])
        email_field.addTarget(self, action: #selector(LoginViewController.emailChanged(sender: )), for: .editingChanged)
        pass_field.autocapitalizationType = .none
        pass_field.autocorrectionType = .no
        pass_field.spellCheckingType = .no
        pass_field.delegate = self
        pass_field.defaultTextAttributes = [NSFontAttributeName:UIFont.init(name: "ProximaNovaCond-Regular", size: NICKNAME_TEXT_SIZE)!,NSForegroundColorAttributeName:UIColor.black]
        pass_field.attributedPlaceholder = NSMutableAttributedString(string: "password...", attributes: [NSFontAttributeName:UIFont.init(name: "ProximaNovaCond-Regular", size: NICKNAME_TEXT_SIZE)!,NSForegroundColorAttributeName:UIColor.gray])
        pass_field.addTarget(self, action: #selector(LoginViewController.passChanged(sender: )), for: .editingChanged)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.screenTapped(sender:))))
        website_label_field.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(LoginViewController.sponsyCaptionLabelPressed(sender:))))
    }
    
    func conductRegistration() {
        let register_task = HailyRegisterTask(email: email_field.text!, pass: pass_field.text!)
        let task_builder = HailyTaskBuilder(session: General.session_data, anonymous: false, degradePossible: false)
        task_builder.addTasks([register_task])
        task_builder.sendTasksWithCompletionHandler({
            (parsedResponse:[HailyParsedResponse]?, error: Error?) in
            var success = false
            var reg_res:HailyRegisterResult?
            if let responses = parsedResponse {
                if responses.count == 1 {
                    print("Received register response :--)")
                    if let registerResult = responses[0].registerResult {
                        reg_res = registerResult
                        if registerResult == HailyRegisterResult.ok {
                            success = true
                        }
                    }
                    if success {
                        DispatchQueue.main.async(execute: {
                            self.dismiss(animated: true, completion: nil)
                            NotificationCenter.default.post(name: Notification.Name.init(rawValue: "notification_initial_request"), object: nil, userInfo: ["fullRequest":false])
                            NotificationCenter.default.post(name: Notification.Name.init(rawValue: "notification_logged_in"), object: nil, userInfo: nil)
                        })
                    }
                }
            }
            if !success {
                print("Error with registering")
                if let _error = error {
                    print(_error)
                }
                DispatchQueue.main.async(execute: {
                    NotificationCenter.default.post(kHailyDataRetrievalErrorSliderNotification)
                    var error_msg = "It was impossible to complete the registration"
                    if let reg = reg_res {
                        if reg == HailyRegisterResult.alreadyRegistered {
                            error_msg = "The profile with this email already exists. Try logging in or use another email"
                        }
                        else if reg == HailyRegisterResult.passError {
                            error_msg = "The password is incorrect."
                        }
                    }
                    let error_screen = UIAlertController.init(title: "Registration error", message: error_msg, preferredStyle: UIAlertControllerStyle.alert)
                    error_screen.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(error_screen, animated: true, completion: nil)
                    
                })
            }
        })
    }
    
    @IBAction func registerButtonPressed(sender:UIButton) {
        if checkFieldsFinal() {
            let confirm_screen = UIAlertController.init(title: "Proceed to Registration?", message: "Would you like to create a profile with the following credentials:?\nemail: \(email_field.text!)\npass: \(pass_field.text!)", preferredStyle: UIAlertControllerStyle.alert)
            confirm_screen.addAction(UIAlertAction(title: "Proceed", style: .default, handler: {
                (act: UIAlertAction) in
                self.conductRegistration()
            }))
            confirm_screen.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            self.present(confirm_screen, animated: true, completion: nil)
        }
        else {
            let error = UIAlertController.init(title: "ERROR!", message: "Check your password and email: maybe there are some protected symbols? Only alphanumerics and punctuation is allowed.", preferredStyle: .alert)
            error.addAction(UIAlertAction.init(title: "I'll check", style: .default, handler: {
                (act:UIAlertAction) in
                error.dismiss(animated: true, completion: nil)
            }))
            present(error, animated: true, completion: nil)
        }
    }
    
    @IBAction func loginButtonPressed(sender:UIButton) {
        if checkFieldsFinal() {
            let login_task = HailyLoginTask(email: email_field.text!, pass: pass_field.text!)
            let task_builder = HailyTaskBuilder(session: General.session_data, anonymous: false, degradePossible: false)
            task_builder.addTasks([login_task])
            task_builder.sendTasksWithCompletionHandler({
                (parsedResponse:[HailyParsedResponse]?, error:Error?) in
                var success = false
                if let responses = parsedResponse {
                    if responses.count == 1 {
                        print("Received login response")
                        if let loginResult = responses[0].loginResult {
                            if loginResult == HailyLoginResult.ok {
                                success = true
                            }
                        }
                        if success {
                            DispatchQueue.main.async(execute: {
                                self.dismiss(animated: true, completion: nil)
                                NotificationCenter.default.post(name: Notification.Name.init(rawValue: "notification_initial_request"), object: nil, userInfo: ["fullRequest":false])
                                NotificationCenter.default.post(name: Notification.Name.init(rawValue: "notification_logged_in"), object: nil, userInfo: nil)
                            })
                        }
                    }
                }
                if !success {
                    print("Error with logging in!")
                    if let _error = error {
                        print(_error)
                    }
                    DispatchQueue.main.async(execute: {
                        NotificationCenter.default.post(kHailyDataRetrievalErrorSliderNotification)
                        let error_screen = UIAlertController.init(title: "Error", message: "Could not log in!", preferredStyle: UIAlertControllerStyle.alert)
                        error_screen.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                        self.present(error_screen, animated: true, completion: nil)
                        
                    })
                }
            })
        }
        else {
            let error = UIAlertController.init(title: "ERROR!", message: "Check your password and email: maybe there are some protected symbols? Only alphanumerics and punctuation is allowed.", preferredStyle: .alert)
            error.addAction(UIAlertAction.init(title: "I'll check", style: .default, handler: {
                (act:UIAlertAction) in
                error.dismiss(animated: true, completion: nil)
            }))
            present(error, animated: true, completion: nil)
        }
    }
    
    func sponsyCaptionLabelPressed(sender:UITapGestureRecognizer) {
        print("pressed opening website")
        if let url_open = URL.init(string: "https://www.sponsy.org") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url_open, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url_open)
            }
        }
    }
    
    @IBAction func skipButtonPressed(sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !nickname_entered {
            nickname_entered = true
        }
    }
    
    func screenTapped(sender:UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func checkFieldsFinal() -> Bool {
        email_field.text = email_field.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        pass_field.text = pass_field.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        var check_ok = true
        if email_field.text!.characters.count > General.EMAIL_MAX_LENGTH || email_field.text!.characters.count < General.EMAIL_MIN_LENGTH || pass_field.text!.characters.count > General.PASS_MAX_LENGTH || pass_field.text!.characters.count < General.PASS_MIN_LENGTH {
            check_ok = false
        }
        var blocked_characters = CharacterSet.alphanumerics
        blocked_characters.formUnion(CharacterSet.punctuationCharacters)
        blocked_characters.invert()
        if email_field.text!.rangeOfCharacter(from: blocked_characters) != nil || pass_field.text!.rangeOfCharacter(from: blocked_characters) != nil {
            check_ok = false
        }
        return check_ok
    }
    
    func keyboardShown(_ sender:Notification) {
        //print("reacting to keyboard shown")
        //let keyboard_height = abs((sender.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height - (sender.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.height)
        
        let keyboard_height = abs((sender.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.minY - (sender.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.minY)
        //print("keyboard shown. having end frame \((sender.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue)")
        //setElementsMovedUp(movedUp: true, withKeyboardHeight: keyboard_height)
        let lowestPointY = UIApplication.shared.keyWindow!.convert((sender.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue, to: view).minY
        let bottom_distance = view.frame.maxY - lowestPointY
        scroll_view.contentOffset = CGPoint.init(x: 0, y: bottom_distance)
        adjustFramesWithBottomDistance(bottom_distance)
    }
    
    func keyboardHidden(_ sender:Notification) {
       // print("reacting to keyboard hidden")
        //let keyboard_height = abs((sender.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height - (sender.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.height)
        //let keyboard_height = abs((sender.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.minY - (sender.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.minY)
        //print("keyboard hidden. having end frame \((sender.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue)")
        //setElementsMovedUp(movedUp: false, withKeyboardHeight: keyboard_height)
        let lowestPointY = UIApplication.shared.keyWindow!.convert((sender.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue, to: view).minY
        let bottom_distance = view.frame.maxY - lowestPointY
        adjustFramesWithBottomDistance(bottom_distance)
    }
    
    func checkFields() {
        if email_field.text!.characters.count > General.EMAIL_MAX_LENGTH || email_field.text!.characters.count < General.EMAIL_MIN_LENGTH || pass_field.text!.characters.count > General.PASS_MAX_LENGTH || pass_field.text!.characters.count < General.PASS_MIN_LENGTH {
            setLoginButtonEnabled(enabled: false, withText: "CONTINUE")
        }
        else {
            setLoginButtonEnabled(enabled: true, withText: "CONTINUE")
        }
    }
    
    func emailChanged(sender:UITextField) {
        let trimmed_nickname = sender.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        sender.text = trimmed_nickname
        checkFields()
    }
    
    func passChanged(sender:UITextField) {
        let trimmed_nickname = sender.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        sender.text = trimmed_nickname
        checkFields()
    }
    
    func adjustFramesWithBottomDistance(_ bottomDistance:CGFloat) {
        print("adjusting bottom distance with \(bottomDistance)")
        
        //bottom_distance_con.constant = bottomDistance
        scroll_view.contentInset = UIEdgeInsetsMake(0, 0, bottomDistance, 0)
        UIView.animate(withDuration: 0.22, animations: {
            self.view.layoutIfNeeded()
        })
    }

    
    func setLoginButtonEnabled(enabled:Bool, withText:String) {
        login_button.isEnabled = enabled
        login_button.alpha = enabled ? 1.0 : BUTTON_DISABLED_OPACITY
        signup_button.isEnabled = enabled
        signup_button.alpha = enabled ? 1.0 : BUTTON_DISABLED_OPACITY
    }
    

}
