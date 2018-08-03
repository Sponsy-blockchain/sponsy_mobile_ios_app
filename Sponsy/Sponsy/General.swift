//
//  General.swift
//  Haily
//
//  Created by Admin on 12.11.16.
//  Copyright © 2016 Vanoproduction. All rights reserved.
//

import UIKit
import Kingfisher
import CoreLocation

let kHailyShowSliderNotification = "notification_show_troubles_slider"
let kHailyUnauthorizedSliderNotification = Notification(name: Notification.Name(rawValue: kHailyShowSliderNotification), object: nil, userInfo: ["shown":true,"slider_type":TroubleTopSliderType.ephermal.rawValue,"slider_text":"You must be authorized!","slider_color":TroubleTopSliderColor.black.rawValue])
let kHailyDataRetrievalErrorSliderNotification = Notification(name: Notification.Name(rawValue: kHailyShowSliderNotification), object: nil, userInfo: ["shown":true,"slider_type":TroubleTopSliderType.ephermal.rawValue,"slider_text":"Data error. Try again","slider_color":TroubleTopSliderColor.purple.rawValue])

class General {
    
    static let TOTAL_SCHEDULED_CHALLENGE_NOTIFICATIONS:Int = 11
    static let NOTIFICATIONS_MORNING_PERIOD_START = 10
    static let NOTIFICATIONS_MORNING_PERIOD_END = 13
    static let NOTIFICATIONS_EVENING_PERIOD_START = 18
    static let NOTIFICATIONS_EVENING_PERIOD_END = 22
    static let anim_func:CAMediaTimingFunction = CAMediaTimingFunction(controlPoints: 0.48, -0.055, 0.275, 1.38)
    static let OVERLAY_DEFAULT:UIColor = UIColor(red: 63/255, green: 63/255, blue: 63/255, alpha: 0.53)
    static let OVERLAY_GREEN:UIColor = UIColor(red: 23/255, green: 115/255, blue: 34/255, alpha: 0.7)
    static let OVERLAY_RED:UIColor = UIColor(red: 133/255, green: 21/255, blue: 21/255, alpha: 0.7)
    static let TITLE_MAX_LENGTH = 115
    static let TITLE_MIN_LENGTH = 3
    static let OPINION_MAX_LENGTH = 600
    static let OPINION_MIN_LENGTH = 10
    static let OPINION_CHARACTERS_LEFT_WARNING = 30
    static let NICKNAME_MAX_LENGTH = 20
    static let NICKNAME_MIN_LENGTH = 2
    static let ABOUT_MAX_LENGTH = 500
    static let EMAIL_MIN_LENGTH:Int = 3
    static let EMAIL_MAX_LENGTH:Int = 100
    static let PASS_MIN_LENGTH:Int = 5
    static let PASS_MAX_LENGTH:Int = 40
    static let RANDOM_PROFILE_IMAGE_SIZE:CGFloat = 500
    static let RANDOM_PROFILE_IMAGE_TEXT_WIDTH_RELATIVE:CGFloat = 0.7
    static let RANDOM_PROFILE_IMAGE_TEXT_HEIGHT_RELATIVE:CGFloat = 0.8
    static let RANDOM_PROFILE_IMAGE_COLOR_SATURATION_VALUE:CGFloat = 0.16
    static let DETAIL_TOPIC_TIME_SPENT_INTERESTED:CFTimeInterval = 7.0
    static let TOPICS_OPENS_MIN_PROPOSE_NOTIFICATIONS = 3
    static let TOPIC_IMAGE_UPLOADING_MAX_SIZE:CGFloat = 550 // pixels at most
    static let online_address:String? = "https://task.sponsy.org/Sponsy/" //
    static var images_bucket_address:String = "http://vanoproductionsponsy.s3.amazonaws.com/" // add topN or profN
    static let appLink:String = "https://itunes.apple.com/app/id1243036651"
    static let appId:String = "1243036651"

    static var events_all:[HailyInjectable] = []
    static var events_favorite:[HailyInjectable] = []
    static var sponsors_all:[HailyInjectable] = []
    static var sponsors_favorite:[HailyInjectable] = []
    static var dataEndsStates:[String:Bool]? = nil
    static var trendingLastValues:[String:Double]? = nil
    static var troubles_internet = false
    static var authorized = false
    static var session_data:URLSession!
    
    static var events_images_cache:ImageCache!
    static var sponsors_images_cache:ImageCache!
    static var current_location_array:[Double]? // [long,lat]
    static var myProfileId:Int?
    
    static let INTERSTITIAL_1:Int = 2 // after this amount of chances - show ad
    static let INTERSTITIAL_2:Int = 6
    static let INTERSTITIAL_3:Int = 10
    
    static var delayedTopicNotificationUserInfo:[AnyHashable:Any]?
    static var delayedProfileNotificationUserInfo:[AnyHashable:Any]?
    
    /*
    
    static func parseExploreDictData(_ jsonData:Data) -> NSDictionary {
        let explore_dict_unparsed = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! NSDictionary
        let final_explore_dict = NSMutableDictionary()
        final_explore_dict["issue_date"] = explore_dict_unparsed["issue_date"] as! String
        var default_explore_categories:[ExploreItem] = []
        let categories_dict = explore_dict_unparsed["categories"] as! [NSDictionary]
        for categoryDict in categories_dict {
            let exploreItem = ExploreItem(dataDict: categoryDict)
            default_explore_categories.append(exploreItem)
        }
        final_explore_dict["categories"] = default_explore_categories
        return final_explore_dict
    }
 */
    
    static func apprFontSize(_ str:String?, str_attr:NSAttributedString?, fontName:String, ref_value:CGFloat, type:String, attributed:Bool, maxFontSize:CGFloat) -> CGFloat {
        var final_size:CGFloat = 0
        for s in stride(from: maxFontSize,to: 0.0, by: -1.0) {
            let font = UIFont(name: fontName, size: s)!
            var this_size:CGSize = CGSize(width: 0, height: 0)
            if attributed {
                this_size = str_attr!.size()
            }
            else {
                this_size = str!.size(attributes: [NSFontAttributeName:font])
            }
            if type == "w" {
                if this_size.width <= ref_value {
                    final_size = s
                    break
                }
            }
            else {
                if this_size.height <= ref_value {
                    final_size = s
                    break
                }
            }
        }
        return final_size
    }
    
    
    static func prepareSizedImage(_ image:UIImage, toFitSize:CGSize, withAlignment:SizedImageAlignment, withOverlayStyle:TopicsColorsStyles, completionHandler:@escaping (_ finalImage:UIImage) -> Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            let originalSize = image.size
            var finalSize = CGSize.zero
            let targetSize = CGSize.init(width: toFitSize.width / 1.0, height: toFitSize.height / 1.0)
            //let width_dominant = max(toFitSize.width,originalSize.width) / min(toFitSize.width,originalSize.width) > max(toFitSize.height,originalSize.height) / min(toFitSize.height,originalSize.height)
            
            if originalSize.width > targetSize.width && originalSize.height > targetSize.height {
                let max_scale_factor = max(targetSize.height / originalSize.height , targetSize.width / originalSize.width)
                finalSize = CGSize(width: originalSize.width * max_scale_factor, height: originalSize.height * max_scale_factor)
            }
            else {
                let max_scale_factor = min(originalSize.width / targetSize.width , originalSize.height / targetSize.height)
                finalSize = CGSize(width: originalSize.width / max_scale_factor, height: originalSize.height / max_scale_factor)
            }
            print("Having final size \(finalSize)")
            //let img_context = CGContext(data: nil, width: Int(targetSize.width), height: Int(targetSize.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: base_color_space ?? image.cgImage!.colorSpace!, bitmapInfo: image.cgImage!.bitmapInfo.rawValue)
            let img_context = CGContext.init(data: nil, width: Int(targetSize.width), height: Int(targetSize.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
            let start_point_x = Int(finalSize.width) > Int(targetSize.width) ? CGFloat(Int((finalSize.width - targetSize.width) * (withAlignment == SizedImageAlignment.center ? -0.5 : withAlignment == SizedImageAlignment.bottomRight ? -1.0 : 0.0))) : 0.0
            let start_point_y = Int(finalSize.height) > Int(targetSize.height) ? CGFloat(Int((finalSize.height - targetSize.height) * (withAlignment == SizedImageAlignment.center ? -0.5 : withAlignment == SizedImageAlignment.topLeft ? -1.0 : 0.0))) : 0.0
            img_context?.draw(image.cgImage!, in: CGRect(x: start_point_x, y: start_point_y, width: finalSize.width, height: finalSize.height).integral)
            if withOverlayStyle != TopicsColorsStyles.none {
                var overlay_color:UIColor
                switch withOverlayStyle {
                case .default:
                    overlay_color = OVERLAY_DEFAULT
                case .hated:
                    overlay_color = OVERLAY_RED
                case .loved:
                    overlay_color = OVERLAY_GREEN
                default:
                    overlay_color = UIColor.clear
                }
                img_context?.setFillColor(overlay_color.cgColor)
                img_context?.fill(CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height).integral)
            }
            let made_image = img_context?.makeImage()
            if let _made_image = made_image {
                let final_image = UIImage(cgImage: _made_image, scale: 1.0, orientation: UIImageOrientation.up)
                DispatchQueue.main.async(execute: {
                    completionHandler(final_image)
                })
            }
        })
    }
    
    static func rotateCameraImageToProperOrientation(imageSource : UIImage, maxResolution : CGFloat) -> UIImage? {
        let imgRef = imageSource.cgImage!
        let width = CGFloat(imgRef.width)
        let height = CGFloat(imgRef.height)
        var bounds = CGRect.init(x: 0, y: 0, width: width, height: height)
        var scaleRatio : CGFloat = 1
        if (width > maxResolution || height > maxResolution) {
            scaleRatio = min(maxResolution / bounds.size.width, maxResolution / bounds.size.height)
            bounds.size.height = bounds.size.height * scaleRatio
            bounds.size.width = bounds.size.width * scaleRatio
        }
        var transform = CGAffineTransform.identity
        let orient = imageSource.imageOrientation
        switch(imageSource.imageOrientation) {
        case .up :
            transform = CGAffineTransform.identity
        case .upMirrored :
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .down :
            transform = transform.translatedBy(x: width, y: height)
            transform = transform.rotated(by: CGFloat(M_PI))
        case .downMirrored :
            transform = transform.translatedBy(x: 0.0, y: height)
            transform = transform.scaledBy(x: 1.0, y: -1.0)
        case .left :
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width;
            bounds.size.width = storedHeight;
            transform = transform.translatedBy(x: 0, y: width)
            transform = transform.rotated(by: 3.0 * CGFloat(M_PI) / 2.0)
        case .leftMirrored :
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width;
            bounds.size.width = storedHeight;
            transform = transform.translatedBy(x: height, y: width)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            transform = transform.rotated(by: 3.0 * CGFloat(M_PI) / 2.0)
        case .right :
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width;
            bounds.size.width = storedHeight;
            transform = transform.translatedBy(x: height, y: 0.0)
            transform = transform.rotated(by: CGFloat(M_PI) / 2.0)
        case .rightMirrored :
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width;
            bounds.size.width = storedHeight;
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat(M_PI) / 2.0)
        }
        UIGraphicsBeginImageContext(bounds.size)
        let context = UIGraphicsGetCurrentContext()
        if orient == .right || orient == .left {
            context?.scaleBy(x: -scaleRatio, y: scaleRatio)
            context?.translateBy(x: -height, y: 0.0)
        }
        else {
            context?.scaleBy(x: scaleRatio, y: -scaleRatio)
            context?.translateBy(x: 0.0, y: -height)
        }
        context?.concatenate(transform)
        context?.draw(imgRef, in: CGRect.init(x: 0, y: 0, width: width, height: height))
        let imageCopy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageCopy
    }
    
    static func prepareExploreCellImageWithTitle(_ title:String, completionHandler: (_ finalImage:UIImage) -> Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            
        })
    }
}


