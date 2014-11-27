//
//  RunDataView.swift
//  MapKitSwift
//
//  Created by Jecky on 14/11/13.
//  Copyright (c) 2014年 Jecky. All rights reserved.
//

import UIKit

class RunDataView: UIView {
    
    var topImageView:UIImageView?
    var bottomImageView:UIImageView?
    var timeLabel:UILabel?
    var mileLabel:UILabel?
    var speedLabel:UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        initUI()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        topImageView = UIImageView(frame: CGRectMake(0, 0, CGRectGetWidth(self.frame), 94))
        topImageView?.backgroundColor = UIColor.whiteColor()
        
        timeLabel = UILabel(frame: CGRectMake(0, 27, CGRectGetWidth(self.frame), 40))
        timeLabel?.backgroundColor = UIColor.clearColor()
        timeLabel?.textColor = UIColor.blackColor()
        timeLabel?.text = "00:00:00"
        timeLabel?.textAlignment = NSTextAlignment.Center
        timeLabel?.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 50)
        topImageView?.addSubview(timeLabel!)
        self.addSubview(topImageView!)
        
        bottomImageView = UIImageView(frame: CGRectMake(0, CGRectGetMaxY(topImageView!.frame), CGRectGetWidth(self.frame), 63))
        bottomImageView?.backgroundColor = UIColor.clearColor()
        bottomImageView?.image = UIImage(named: "bg_run_info")?.resizableImageWithCapInsets(UIEdgeInsetsMake(10, 100, 30, 100), resizingMode: UIImageResizingMode.Stretch)

        mileLabel = UILabel(frame: CGRectMake(0, 20, CGRectGetWidth(self.frame)/2, 23))
        mileLabel?.backgroundColor = UIColor.clearColor()
        mileLabel?.textColor = UIColor.blackColor()
        mileLabel?.text = "0.00km"
        mileLabel?.textAlignment = NSTextAlignment.Center
        mileLabel?.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 30)
        bottomImageView?.addSubview(mileLabel!)
        
        speedLabel = UILabel(frame: CGRectMake(CGRectGetWidth(self.frame)/2, 20, CGRectGetWidth(self.frame)/2, 23))
        speedLabel?.backgroundColor = UIColor.clearColor()
        speedLabel?.textColor = UIColor.blackColor()
        speedLabel?.text = "0.00km/h"
        speedLabel?.textAlignment = NSTextAlignment.Center
        speedLabel?.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 30)
        bottomImageView?.addSubview(speedLabel!)
        
        self.addSubview(bottomImageView!)
    }
    
    func updateRunData(totalSecond:NSInteger, totalMile:Double) {
        timeLabel?.text = MKUtil.dateStringFromSecond(totalSecond)
        mileLabel?.text = NSString(format: "%.2f", Double(totalMile)/1000.0) + "km"
        
        var kmPerH = (totalMile/1000.0)/(Double(totalSecond)/3600.0);
        speedLabel?.text = NSString(format: "%.2f", kmPerH) + "km/h"
        
        
    }

}
