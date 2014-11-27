//
//  RunAnnotationView.h
//  MapKitDemo
//
//  Created by Jecky on 14/11/13.
//  Copyright (c) 2014年 Jecky. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface RunAnnotationView : MKAnnotationView

@property (nonatomic, strong) UIImageView  *annotationImageView;
@property (nonatomic, strong) UILabel      *nameLabel;

@end
