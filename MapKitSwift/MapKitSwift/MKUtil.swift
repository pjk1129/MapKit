//
//  MKUtil.swift
//  MapKitSwift
//
//  Created by Jecky on 14/11/13.
//  Copyright (c) 2014年 Jecky. All rights reserved.
//

import UIKit

class MKUtil: NSObject {
    /**
    根据输入16进制数据，得到UIColor对象
    :param: hexString
    :returns: UIColor对象
    */
    class func colorWithHexString(hexString: NSString) -> UIColor {
        var cString:NSString = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        // String should be 6 or 8 characters
        if cString.length < 6 {
            return UIColor.clearColor()
        }
        
        // strip 0X if it appears
        if cString.hasPrefix("0X") {
            cString = cString .substringFromIndex(2)
        }
        if cString .hasPrefix("#") {
            cString = cString .substringFromIndex(1)
        }
        
        if cString.length != 6 {
            return UIColor.clearColor()
        }
        
        // Separate into r, g, b substrings
        var rString:NSString = cString.substringWithRange(NSMakeRange(0, 2))
        var gString:NSString = cString.substringWithRange(NSMakeRange(2, 2))
        var bString:NSString = cString.substringWithRange(NSMakeRange(4, 2))
        
        // Scan values
        var r:UInt32 = UInt32.min
        var g:UInt32 = UInt32.min
        var b:UInt32 = UInt32.min
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        let newRed   = CGFloat(Double(r) / 255.0)
        let newGreen = CGFloat(Double(g) / 255.0)
        let newBlue  = CGFloat(Double(b) / 255.0)
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: CGFloat(1.0))
    }
    
    class func computeCalorie(paceSpeed:CGFloat, second:NSInteger) -> CGFloat {
        if paceSpeed == 0.0 {
            return 0.0
        }
        
        var K = 400/(paceSpeed*60)
        K = 30/K
        var hour = CGFloat(second)/3600.0 as CGFloat
        var weight = 60.0 as CGFloat
        
        var w = 60.0 as CGFloat
        
        if w > 0 {
            weight = w
        }
        var result = K * weight * hour
        
        if isnan(result) || isinf(result){
            return 0.0
        }
        
        return result
        
    }
    
    class func paceString(dis:CGFloat, minute:CGFloat) -> NSString{
        if dis <= 0.0 {
            return "0:00"
        }
        
        var pace = minute/dis;
        var legspeedStr = "0:00"
        var paceStr = NSString(format: "%.3f", pace)
        var array = paceStr.componentsSeparatedByString(".") as NSArray
        
        if array.count>1 {
            var min = array.objectAtIndex(0) as NSString
            if min.integerValue < 100 {
                var sec = array.objectAtIndex(1) as NSString
                var secStr = NSString(format: ".%@", sec) as NSString
                var secInt = Int(secStr.floatValue * 60)
                var second = "00"
                if (secInt < 10 && secInt>=0) {
                    second = NSString(format:"0%d",secInt) as NSString
                }else if secInt >= 10{
                    second = NSString(format:"%d",secInt) as NSString
                }
                
                legspeedStr = NSString(format:"%@:%@",min, second) as NSString
            }else{
                legspeedStr = "99:59"
            }
        }
        
        return legspeedStr
    }
    
    class func dateStringFromSecond(seconds:NSInteger) -> NSString {
        var hour = 0
        var min = 0
        var sec = 0
        
        if seconds > 3600 {
            hour = seconds/3600
            min = (seconds%3600)/60
            sec = (seconds%3600)%60
        }else if seconds<3600&&seconds>60 {
            min = seconds/60;
            sec = seconds%60;
        }else if seconds<60{
            sec = seconds%60;
        }
        
        return NSString(format: "%02d:%02d:%02d", hour,min,sec)
    }
}
