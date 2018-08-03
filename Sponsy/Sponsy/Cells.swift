//
//  TopicCells.swift
//  Haily
//
//  Created by Admin on 13.11.16.
//  Copyright © 2016 Vanoproduction. All rights reserved.
//

import UIKit

let BOUNCE_ANIM_DURATION:CFTimeInterval = 0.37

class BounceAnimation {
    
    var bounce_anim:CAKeyframeAnimation!
    
    init(duration:CFTimeInterval, keyPath:String,bounceType:String) {
        bounce_anim = CAKeyframeAnimation(keyPath: keyPath)
        bounce_anim.keyPath = keyPath
        bounce_anim.duration = duration
        bounce_anim.values = bounceType == "change" ? [0.1,0.8,1.1,0.9,1.0] : [1.0,1.2,0.8,1.1,0.9,1.0]
        var timing_funcs:[CAMediaTimingFunction] = []
        for _ in 1...bounce_anim.values!.count - 1 {
            timing_funcs.append(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
        bounce_anim.timingFunctions = timing_funcs
    }

}

class MenuTableCell : UITableViewCell {
    
    let OPTION_FONT_SIZE:CGFloat = 19
    let OPTION_ICON_WIDTH:CGFloat = 17
    let OPTION_ICON_MARGIN_LEFT:CGFloat = 12
    let OPTION_LABEL_MARGIN_LEFT:CGFloat = 11
    
    var option_label:UILabel!
    var option_icon:UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        option_icon = UIImageView()
        option_icon.contentMode = .scaleAspectFit
        option_label = UILabel()
        option_label.font = UIFont(name: "ProximaNovaCond-Semibold", size: OPTION_FONT_SIZE)!
        option_label.textAlignment = .left
        contentView.addSubview(option_icon)
        contentView.addSubview(option_label)
    }
    
    func setOptionTitle(_ title:String, image:UIImage?, titleColor:UIColor) {
        option_label.text = title
        option_icon.image = image
        option_icon.frame = CGRect(x: OPTION_ICON_MARGIN_LEFT, y: 0, width: OPTION_ICON_WIDTH, height: contentView.bounds.height)
        option_label.frame = CGRect(x: OPTION_ICON_MARGIN_LEFT + OPTION_ICON_WIDTH + OPTION_LABEL_MARGIN_LEFT, y: 0, width: contentView.bounds.width, height: contentView.bounds.height)
        option_label.textColor = titleColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EventCell : UITableViewCell {
    
    let HIGHLIGHTING_DURATION:CFTimeInterval = 0.3
    let IMAGE_HIGHLIGHTED_ALPHA:CGFloat = 0.7
    
    @IBOutlet var event_image:UIImageView!
    @IBOutlet var location_text:UILabel!
    @IBOutlet var audience_text:UILabel!
    @IBOutlet var money_text:UILabel!
    @IBOutlet var date_text:UILabel!
    @IBOutlet var title_text:UILabel!
    
    var event_id = -1
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if event_image != nil {
            UIView.animate(withDuration: animated ? HIGHLIGHTING_DURATION : 0, animations: {
                self.event_image.alpha = highlighted ? self.IMAGE_HIGHLIGHTED_ALPHA : 1.0
            })
        }
    }
    
    func setData(_ eventData:SponsyEvent) {
        event_id = eventData.event_id
        location_text.text = eventData.location_info
        audience_text.text = eventData.audience_info
        money_text.text = "$\(eventData.money_info)"
        date_text.text = eventData.date_info
        title_text.text = eventData.title
    }
    
    func setEventImage(_ image:UIImage,animated:Bool) {
        UIView.transition(with: event_image, duration: animated ? 0.23 : 0.0, options: .transitionCrossDissolve, animations: {
            self.event_image.image = image
        }, completion: nil)
    }
    
    
}

class SponsorCell : UITableViewCell {
    
    let HIGHLIGHTING_DURATION:CFTimeInterval = 0.3
    let IMAGE_HIGHLIGHTED_ALPHA:CGFloat = 0.7
    
    @IBOutlet var sponsor_image:UIImageView!
    @IBOutlet var location_text:UILabel!
    @IBOutlet var age_text:UILabel!
    @IBOutlet var money_text:UILabel!
    @IBOutlet var title_text:UILabel!
    
    var sponsor_id = -1
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if sponsor_image != nil {
            UIView.animate(withDuration: animated ? HIGHLIGHTING_DURATION : 0, animations: {
                self.sponsor_image.alpha = highlighted ? self.IMAGE_HIGHLIGHTED_ALPHA : 1.0
            })
        }
    }
    
    func setData(_ sponsorData:SponsySponsor) {
        sponsor_id = sponsorData.sponsor_id
        location_text.text = sponsorData.location_info
        age_text.text = sponsorData.age_info
        money_text.text = "$\(sponsorData.money_info)"
        title_text.text = sponsorData.title
    }
    
    func setSponsorImage(_ image:UIImage,animated:Bool) {
        UIView.transition(with: sponsor_image, duration: animated ? 0.23 : 0.0, options: .transitionCrossDissolve, animations: {
            self.sponsor_image.image = image
        }, completion: nil)
    }
    
}

class VotingCell : UITableViewCell {
    
    let VOTE_GRAPH_MARGIN_SIDES:CGFloat = 20
    let VOTE_GRAPH_HEIGHT_RELATIVE:CGFloat = 0.65 // relative to vote_yes_icon / vote_no_icon
    
    @IBOutlet var sponsor_image:UIImageView!
    @IBOutlet var event_image:UIImageView!
    @IBOutlet var sponsor_title:UILabel!
    @IBOutlet var event_title:UILabel!
    @IBOutlet var vote_yes_text:UILabel!
    @IBOutlet var vote_no_text:UILabel!
    @IBOutlet var vote_yes_icon:UIImageView!
    @IBOutlet var vote_no_icon:UIImageView!
    
    var sponsor_id = -1
    var event_id = -1
    var vote_yes_graph:UIView!
    var vote_no_graph:UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        vote_yes_graph = UIView.init()
        vote_yes_graph.backgroundColor = UIColor.green
        vote_no_graph = UIView.init()
        vote_no_graph.backgroundColor = UIColor.red
        contentView.addSubview(vote_yes_graph)
        contentView.addSubview(vote_no_graph)
    }
    
    
    func setData(_ votingData:SponsyVote) {
        
        sponsor_id = votingData.sponsor_id
        event_id = votingData.event_id
        sponsor_title.text = votingData.sponsor_title
        event_title.text = votingData.event_title
        let final_yes_votes = votingData.vote_agree_ratio == -1 ? 0 : votingData.vote_agree_ratio
        let final_no_votes = votingData.vote_agree_ratio == -1 ? 0 : (100 - votingData.vote_agree_ratio)
        vote_yes_text.text = "\(final_yes_votes)%"
        vote_no_text.text = "\(final_no_votes)%"
        layoutIfNeeded()
        let graph_top_spacing = vote_yes_icon.bounds.height * (1.0 - VOTE_GRAPH_HEIGHT_RELATIVE) * 0.5
        vote_yes_graph.frame = CGRect.init(x: vote_yes_icon.frame.maxX + VOTE_GRAPH_MARGIN_SIDES, y: vote_yes_icon.frame.minY + graph_top_spacing, width: 0, height: VOTE_GRAPH_HEIGHT_RELATIVE * vote_yes_icon.bounds.height)
        vote_no_graph.frame = CGRect.init(x: vote_yes_graph.frame.minX, y: vote_no_icon.frame.minY + graph_top_spacing, width: 0, height: vote_yes_graph.bounds.height)

        animateGraphsWithVotesYes(final_yes_votes, votesNo: final_no_votes)
    }
    

    
    func animateGraphsWithVotesYes(_ votesYes:Int, votesNo:Int) {
        let vote_yes_target_width = (vote_yes_text.frame.minX - vote_yes_icon.frame.maxX - 2.0 * VOTE_GRAPH_MARGIN_SIDES) * (CGFloat(votesYes) / 100.0)
        let vote_no_target_width = (vote_no_text.frame.minX - vote_no_icon.frame.maxX - 2.0 * VOTE_GRAPH_MARGIN_SIDES) * (CGFloat(votesNo) / 100.0)
        UIView.animate(withDuration: 1.2, delay: 0.8, options: .curveEaseInOut, animations: {
            self.vote_yes_graph.frame = CGRect.init(x: self.vote_yes_graph.frame.minX, y: self.vote_yes_graph.frame.minY, width: vote_yes_target_width, height: self.vote_yes_graph.bounds.height)
            self.vote_no_graph.frame = CGRect.init(x: self.vote_no_graph.frame.minX, y: self.vote_no_graph.frame.minY, width: vote_no_target_width, height: self.vote_no_graph.bounds.height)
        }, completion: nil)
    }
    
    func setSponsorImage(_ image:UIImage, animated:Bool) {
        UIView.transition(with: sponsor_image, duration: animated ? 0.23 : 0.0, options: .transitionCrossDissolve, animations: {
            self.sponsor_image.image = image
        }, completion: nil)
    }
    
    func setEventImage(_ image:UIImage, animated:Bool) {
        UIView.transition(with: event_image, duration: animated ? 0.23 : 0.0, options: .transitionCrossDissolve, animations: {
            self.event_image.image = image
        }, completion: nil)
    }

    
}

class RequestCell : UITableViewCell {
    
    @IBOutlet var title_text:UILabel!
    @IBOutlet var message_text:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutIfNeeded()
    }
    
    override func didMoveToSuperview() {
        self.layoutIfNeeded()
    }
    
    func setData(_ requestData:SponsyRequest) {
        title_text.text = requestData.title
        title_text.setNeedsLayout()
        message_text.text = requestData.message
        message_text.setNeedsLayout()
        message_text.layoutIfNeeded()
        title_text.layoutIfNeeded()
        
    }
    
}

protocol FooterDelegate : class {
    
    func retryConnection()
    
}

protocol ImagePickerDelegate {
    
    func imagePicked(_: (UIImage,String))
}

class DataFooterView : UIView {
    
    let TROUBLE_FONT_SIZE:CGFloat = 16
    let LOADER_INSET:CGFloat = 5
    let BG_COLOR:UIColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1.0)
    
    var trouble_label:UILabel!
    var loader_view:LoaderView!
    weak var footer_delegate:FooterDelegate!
    var footer_state:DataFooterState!
    
    init(frame: CGRect, scheme: String) {
        super.init(frame: frame)
        backgroundColor = scheme == "dark" ? BG_COLOR : UIColor.clear
        trouble_label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        trouble_label.numberOfLines = 0
        trouble_label.text = "Troubles with internet connection. Tap to retry"
        trouble_label.font = UIFont(name: "ProximaNovaCond-Semibold", size: TROUBLE_FONT_SIZE)
        trouble_label.textColor = scheme == "dark" ? UIColor.white : UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1.0)
        trouble_label.textAlignment = .center
        trouble_label.isHidden = true
        addSubview(trouble_label)
        let loader_size = frame.height - LOADER_INSET * 2.0
        loader_view = LoaderView(frame: CGRect(x: frame.width * 0.5 - 0.5 * loader_size, y: LOADER_INSET, width: loader_size, height: loader_size), topBottomInset: 0)
        addSubview(loader_view)
    }
    
    func setDelegate(_ delegate:FooterDelegate) {
        footer_delegate = delegate
    }
    
    func becameVisible() {
        if footer_state == DataFooterState.loading {
            loader_view.startLoading()
        }
    }
    
    func resignedVisible() {
        loader_view.stopLoading()
    }
    
    func setFooterState(_ state:DataFooterState) {
        footer_state = state
        if footer_state == DataFooterState.loading {
            trouble_label.isHidden = true
            loader_view.isHidden = false
            loader_view.startLoading()
            print("here staring loading")
        }
        else if footer_state == DataFooterState.trouble {
            loader_view.stopLoading()
            trouble_label.isHidden = false
            loader_view.isHidden = true
        }
        else {
            loader_view.stopLoading()
            loader_view.isHidden = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if footer_state == DataFooterState.trouble {
            footer_delegate.retryConnection()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

