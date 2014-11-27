//
//  RunAnnotationView.m
//  MapKitDemo
//
//  Created by Jecky on 14/11/13.
//  Copyright (c) 2014年 Jecky. All rights reserved.
//

#import "RunAnnotationView.h"
#import "MKUtil.h"

#define kWidthRunAnnotationView  26.f
#define kHeightRunAnnotationView 56.f

@interface RunAnnotationView()

@end

@implementation RunAnnotationView

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bounds = CGRectMake(0.f, 0.f, kWidthRunAnnotationView, kHeightRunAnnotationView);
        self.backgroundColor = [UIColor clearColor];
        
        /* Create image view and add to view hierarchy. */
        [self annotationImageView];
        [self nameLabel];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.annotationImageView.image = nil;
    self.nameLabel.text = @"";
}

#pragma mark - getter
- (UIImageView *)annotationImageView{
    if (!_annotationImageView) {
        _annotationImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _annotationImageView.backgroundColor = [UIColor clearColor];
        _annotationImageView.userInteractionEnabled = YES;
        _annotationImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_annotationImageView];
    }
    return _annotationImageView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, floorf((kHeightRunAnnotationView-20)/2), kWidthRunAnnotationView, 20)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [MKUtil getColor:@"318BB9"];
        _nameLabel.font = [UIFont systemFontOfSize:11.0f];
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}

@end
