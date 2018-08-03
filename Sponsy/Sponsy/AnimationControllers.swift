//
//  AnimationControllers.swift
//  Haily
//
//  Created by Admin on 20.11.16.
//  Copyright © 2016 Vanoproduction. All rights reserved.
//

import UIKit

class DetailTopicAnimationController : NSObject, UIViewControllerAnimatedTransitioning {
    
    let SCALED_VIEW_FACTOR:CGFloat = 1.5
    let ANIMATION_TOTAL_DURATION:CFTimeInterval = 1.0
    let ANIMATION_DELAY_PART:CFTimeInterval = 0.3
    let BG_OPACITY:CGFloat = 0.5
    var transitionType:DetailTopicTransitionType = DetailTopicTransitionType.detailTopicAppears
    var navController:UINavigationController!
    var from_snapshot_image:UIImage!

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        print("e")
        if transitionType == .detailTopicAppears {
            let container_view = transitionContext.containerView
            let from_vc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
            let to_vc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
            //from_vc.view.hidden = true
            to_vc.view.frame = container_view.bounds
            to_vc.view.alpha = 0.0
            to_vc.view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            //let snapshot_from = UIImageView(frame: container_view.bounds)
           // snapshot_from.image = from_snapshot_image
            container_view.backgroundColor = UIColor.white
            let bg_view = UIImageView(image: UIImage(named: "bg_neutral")!)
            bg_view.alpha = BG_OPACITY
            bg_view.frame = container_view.bounds
            container_view.addSubview(bg_view)
            //container_view.addSubview(snapshot_from)
            container_view.addSubview(to_vc.view)
            let trans_anim = CABasicAnimation(keyPath: "transform.scale")
            trans_anim.fromValue = SCALED_VIEW_FACTOR
            trans_anim.toValue = 1.0
            trans_anim.duration = ANIMATION_TOTAL_DURATION - ANIMATION_DELAY_PART
            trans_anim.timingFunction = General.anim_func
            trans_anim.beginTime = CACurrentMediaTime() + ANIMATION_DELAY_PART
            //snapshot_to.layer.addAnimation(trans_anim, forKey: "trans_anim")
            UIView.animate(withDuration: 0.25, animations: {
                from_vc.view.alpha = 0.0
                from_vc.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
                //snapshot_from.alpha = 0.0
               // snapshot_from.transform = CGAffineTransformMakeScale(0.1, 0.1)
            })
            let detail_anim = CABasicAnimation(keyPath: "transform.scale")
            detail_anim.fromValue = 1.2
            detail_anim.toValue = 1.0
            detail_anim.duration = 0.25
            detail_anim.timingFunction = General.anim_func
            detail_anim.fillMode = kCAFillModeForwards
            detail_anim.isRemovedOnCompletion = false
            detail_anim.beginTime = CACurrentMediaTime() + 0.1
            to_vc.view.layer.add(detail_anim, forKey: "detail_anim")
            UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveLinear, animations: {
                to_vc.view.alpha = 1.0
                //to_vc.view.transform = CGAffineTransformIdentity
                }, completion: {
                    (fin:Bool) in
                    to_vc.view.transform = CGAffineTransform.identity
                    to_vc.view.layer.removeAllAnimations()
                    from_vc.view.isHidden = false
                    from_vc.view.transform = CGAffineTransform.identity
                    from_vc.view.alpha = 1.0
                    transitionContext.completeTransition(true)
            })
        }
        else {
            
        }
       // transitionContext.completeTransition(true)
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }

}

enum DetailTopicTransitionType {
    case detailTopicAppears, detailTopicDisappears
}
