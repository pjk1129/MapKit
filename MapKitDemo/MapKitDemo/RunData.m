//
//  RunData.m
//  MapKitDemo
//
//  Created by Jecky on 14/11/13.
//  Copyright (c) 2014年 Jecky. All rights reserved.
//

#import "RunData.h"

@interface RunData()

@property (nonatomic, strong) UIImageView   *topImageView;
@property (nonatomic, strong) UIImageView   *bottomImageView;

@property (nonatomic, strong) UILabel       *timeLabel;
@property (nonatomic, strong) UILabel       *mileLabel;
@property (nonatomic, strong) UILabel       *speedLabel;

@end

@implementation RunData

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        
        [self bottomImageView];
    }
    return self;
}

- (NSString*)dateStringFromSecond:(NSInteger)seconds{
    
    NSInteger hour = 0;
    NSInteger min  = 0;
    NSInteger sec  = 0;
    
    if(!seconds<3600){
        hour = seconds/3600;
        min = (seconds%3600)/60;
        sec = ((seconds%3600)%60);
    }else if(seconds<3600&&seconds>60){
        
        min = seconds/60;
        sec = seconds%60;
    }else if(seconds<60){
        
        sec = seconds%60;
    }
    
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hour,(long)min,(long)sec];
}

- (void)updateRunData:(NSInteger)totalSecond mile:(NSInteger)totalMile
{
    self.timeLabel.text = [self dateStringFromSecond:totalSecond];
    self.mileLabel.text = [NSString stringWithFormat:@"%.2fkm",totalMile/1000.0];
    
    CGFloat kmPerH = (totalMile/1000.0)/(totalSecond/3600.0);
    self.speedLabel.text = [NSString stringWithFormat:@"%.2fkm/h",kmPerH];
}

#pragma mark - getter
- (UIImageView *)topImageView{
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 94)];
        _topImageView.backgroundColor = [UIColor whiteColor];
        _topImageView.userInteractionEnabled = YES;
        
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 27, CGRectGetWidth(self.frame), 40)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor blackColor];
        _timeLabel.text= @"00:00:00";
        _timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:50];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [_topImageView addSubview:_timeLabel];
        
        [self addSubview:_topImageView];
    }
    return _topImageView;
}

- (UIImageView *)bottomImageView{
    if (!_bottomImageView) {
        _bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.topImageView.frame), CGRectGetWidth(self.frame), 63)];
        _bottomImageView.userInteractionEnabled = YES;
        _bottomImageView.backgroundColor = [UIColor clearColor];
        _bottomImageView.image = [[UIImage imageNamed:@"bg_run_info"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 100, 30, 100) resizingMode:UIImageResizingModeStretch];
        
        _mileLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.frame)/2, 23)];
        _mileLabel.backgroundColor = [UIColor clearColor];
        _mileLabel.textColor = [UIColor blackColor];
        _mileLabel.text= @"0.00km";
        _mileLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:30];
        _mileLabel.textAlignment = NSTextAlignmentCenter;
        [_bottomImageView addSubview:_mileLabel];
        
        _speedLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2, 20, CGRectGetWidth(self.frame)/2, 23)];
        _speedLabel.backgroundColor = [UIColor clearColor];
        _speedLabel.textColor = [UIColor blackColor];
        _speedLabel.text= @"0.00km/h";
        _speedLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:30];
        _speedLabel.textAlignment = NSTextAlignmentCenter;
        [_bottomImageView addSubview:_speedLabel];
        
        [self addSubview:_bottomImageView];
    }
    return _bottomImageView;
}
@end
