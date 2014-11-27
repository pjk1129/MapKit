//
//  CustomAnnotationView.swift
//  MapKitSwift
//
//  Created by Jecky on 14/11/17.
//  Copyright (c) 2014年 Jecky. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotationView: MKAnnotationView {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.annotationImageView.image = nil
        self.nameLabel.text = ""
        
    }
    
    lazy var annotationImageView:UIImageView = {
        
        NSLog("======初始化 annotationImageView========")
        var imgView:UIImageView = UIImageView(frame: self.bounds)
        imgView.backgroundColor = UIColor.clearColor()
        imgView.userInteractionEnabled = true
        imgView.contentMode = UIViewContentMode.Center
        self.addSubview(imgView)
        return imgView
    }()
    
    lazy var nameLabel:UILabel = {
        NSLog("======初始化 nameLabel========")
        var label:UILabel = UILabel(frame: CGRectMake(0, CGFloat(floorf((56.0-20)/2)), 26.0, 20))
        label.backgroundColor = UIColor.clearColor()
        label.textAlignment = NSTextAlignment.Center
        label.textColor = MKUtil.colorWithHexString("318BB9")
        label.font = UIFont.systemFontOfSize(11.0)
        self.addSubview(label)
        return label;
    }()

}
