//
//  ViewController.m
//  MapKitDemo
//
//  Created by Jecky on 14/11/13.
//  Copyright (c) 2014年 Jecky. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "RunData.h"
#import "MKUtil.h"
#import "RunAnnotationView.h"

#define kRunAnnotationStartPointTitle     @"起点"
#define kRunAnnotationEndPointTitle       @"终点"

@interface ViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>{
    // the map view
    MKMapView* _mapView;
    
    // routes points
    NSMutableArray* _points;
    
    NSMutableArray  *_pointsPerKm;

    
    // the data representing the route points.
    MKPolyline* _routeLine;
    
    // the view we create for the line on the map
    MKPolylineView* _routeLineView;
    
    // the rect that bounds the loaded points
    MKMapRect _routeRect;
    
    // location manager
    CLLocationManager* _locationManager;
    
    // current location
    CLLocation* _currentLocation;
    
}

@property (nonatomic, retain) MKMapView  *mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) RunData *dataView;
@property (nonatomic, strong) UIButton       *locationButton;    //定位 中心

@property (nonatomic, strong) NSTimer          *runTimer;      //跑步计时器
@property (nonatomic, assign) CGFloat          totalMile;      //总路程
@property (nonatomic, assign) NSInteger        totalSecond;    //总时间
@property (nonatomic, assign) NSInteger        paceTime;       //记录配速的时间
@property (nonatomic, assign) NSInteger        paceMile;       //记录配速的距离

@property (nonatomic, assign) BOOL        isRunning;
@property (nonatomic, assign) BOOL        startPointDrawed;     //开始点是否被绘制

@property (nonatomic, assign) MKMapPoint  northEastPoint;
@property (nonatomic, assign) MKMapPoint  southWestPoint;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"MapKitDemo";
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self dataView];
    [self mapView];
    [self locationButton];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"开始" style:UIBarButtonItemStylePlain target:self action:@selector(start)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"暂停" style:UIBarButtonItemStylePlain target:self action:@selector(pauseRun)];

    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [_locationManager requestWhenInUseAuthorization];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopUpdatingLocation)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startUpdatingLocation)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //提示用户打开定位服务
    if (![CLLocationManager locationServicesEnabled]|| [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"系统提示"
                                                        message:@"位置服务不可用，请先进入设置-隐私中开启定位服务"
                                                       delegate:self
                                              cancelButtonTitle:@"我知道了"
                                              otherButtonTitles:nil];
        [alert show];
    }else{
        [self startUpdatingLocation];
    }
}

- (void)startUpdatingLocation
{
    [_locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
    if (_isRunning) {
        return;
    }
    
    [_locationManager stopUpdatingLocation];
}

- (void)showUserLocationCenter
{
    if (self.mapView.userLocation.coordinate.latitude == 0.0
        &&self.mapView.userLocation.coordinate.longitude == 0.0) {
        NSLog(@"========没有定位点========");
        return;
    }
    
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}

- (void)start{
    NSLog(@"=========开始==========");
    if (_isRunning) {
        return;
    }
    
    _isRunning = YES;
    _points = [NSMutableArray arrayWithCapacity:0];
    _pointsPerKm = [NSMutableArray arrayWithCapacity:0];
    self.totalSecond = 0;
    self.totalMile = 0;
    
    if ([_runTimer isValid]) {
        [_runTimer invalidate];
        _runTimer = nil;
    }
    _runTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                 target:self
                                               selector:@selector(updateRunStatusView)
                                               userInfo:nil
                                                repeats:YES];
    
    [_locationManager startUpdatingLocation];
}


- (void)pauseRun
{
    [_runTimer invalidate];
    _runTimer = nil;
    _isRunning = NO;
    
    
    if ([_points count]>1) {
        CLLocation *location = [_points lastObject];
        [self addPointAnnotation:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude) title:kRunAnnotationEndPointTitle];
        
    }
}

- (void)updateRunStatusView
{
    [_locationManager startUpdatingLocation];

    if(_paceMile != (NSInteger)floor(_totalMile/100.0)){
        _paceMile = (NSInteger)floor(_totalMile/100.0);
        
        CLLocation  *location = [_points lastObject];
        if (location) {
            [_pointsPerKm addObject:location];
            NSString  *locat= [NSString stringWithFormat:@"%lu",(unsigned long)[_pointsPerKm count]];
            [self addPointAnnotation:location.coordinate title:locat];
        }

        _paceTime = _totalSecond;
    }

    self.totalSecond++;
    
    [self.dataView updateRunData:_totalSecond mile:_totalMile];
}

- (void)configureRoutes
{
    // define minimum, maximum points
    _northEastPoint = MKMapPointMake(0.f, 0.f);
    _southWestPoint = MKMapPointMake(0.f, 0.f);
    
    // create a c array of points.
    MKMapPoint* pointArray = malloc(sizeof(CLLocationCoordinate2D) * _points.count);
    
    for(int idx = 0; idx < _points.count; idx++)
    {
        CLLocation *location = [_points objectAtIndex:idx];
        CLLocationDegrees latitude  = location.coordinate.latitude;
        CLLocationDegrees longitude = location.coordinate.longitude;
        
        // create our coordinate and add it to the correct spot in the array
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        MKMapPoint point = MKMapPointForCoordinate(coordinate);
        
        // if it is the first point, just use them, since we have nothing to compare to yet.
        if (idx == 0) {
            _northEastPoint = point;
            _southWestPoint = point;
        } else {
            if (point.x > _northEastPoint.x)
                _northEastPoint.x = point.x;
            if(point.y > _northEastPoint.y)
                _northEastPoint.y = point.y;
            if (point.x < _southWestPoint.x)
                _southWestPoint.x = point.x;
            if (point.y < _southWestPoint.y)
                _southWestPoint.y = point.y;
        }
        
        pointArray[idx] = point;
    }
    
    if (_routeLine) {
        [self.mapView removeOverlay:_routeLine];
    }
    
    _routeLine = [MKPolyline polylineWithPoints:pointArray count:_points.count];
    
    // add the overlay to the map
    if (nil != _routeLine) {
        [self.mapView addOverlay:_routeLine];
    }
    
    // clear the memory allocated earlier for the points
    free(pointArray);
    
    /*
     double width = northEastPoint.x - southWestPoint.x;
     double height = northEastPoint.y - southWestPoint.y;
     
     _routeRect = MKMapRectMake(southWestPoint.x, southWestPoint.y, width, height);    	
     
     // zoom in on the route. 
     [self.mapView setVisibleMapRect:_routeRect];
     */
}

- (void)showInMapView:(CLPlacemark *) placemark
{
    CLLocationCoordinate2D coordinate = placemark.location.coordinate;
    // 添加MapView
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);			// 跨度（比例）
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);       // 范围、区域
    [self.mapView setRegion:region];
}

-(void)addPointAnnotation:(CLLocationCoordinate2D)coordinate title:(NSString *)titile
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    annotation.title    = titile;
    [self.mapView addAnnotation:annotation];
}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{

    if (!_isRunning) {
        return;
    }
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude
                                                      longitude:userLocation.coordinate.longitude];
    // check the zero point
    if  (userLocation.coordinate.latitude == 0.0f ||
         userLocation.coordinate.longitude == 0.0f)
        return;
    
    //坐标点为同一点
    if (location.coordinate.latitude == _currentLocation.coordinate.latitude
        &&location.coordinate.longitude == _currentLocation.coordinate.longitude){
        return;
    }
    
    if(userLocation.location.horizontalAccuracy <70 && userLocation.location.verticalAccuracy<70){
        if(_totalSecond<3)//前三秒不取点
            return;
        
        if (_points.count > 0) {
            CLLocationDistance distance = [location distanceFromLocation:_currentLocation];
            if(distance>0){
                _totalMile = _totalMile + distance;
            }
        }
        //两秒取一次用户位置
        if(_totalSecond%5 == 0){
            if(_points.count<_totalSecond){ //保证每秒获取一个经纬度信息点
                [_points addObject:location];
                [self configureRoutes];
            }
        }

        if ([_points count]==1&&!_startPointDrawed) {
            _startPointDrawed = YES;
            [self addPointAnnotation:location.coordinate title:kRunAnnotationStartPointTitle];
        }
        _currentLocation = location;
        
    }
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id )annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]]){

        static NSString *CustomAnnotationReuseIndetifier = @"CustomAnnotationReuseIndetifier";
        RunAnnotationView *annotationView = (RunAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:CustomAnnotationReuseIndetifier];
        if (annotationView == nil) {
            annotationView = [[RunAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:CustomAnnotationReuseIndetifier];
        }
        
        if ([[annotation title] isEqualToString:kRunAnnotationStartPointTitle]){ /* 起点. */
            annotationView.annotationImageView.image = [UIImage imageNamed:@"bg_run_start_point"];
        }else if([[annotation title] isEqualToString:kRunAnnotationEndPointTitle]){ /* 终点. */
            annotationView.annotationImageView.image = [UIImage imageNamed:@"bg_run_end_point"];
        }else{
            annotationView.annotationImageView.image = [UIImage imageNamed:@"bg_run_inter_point"];
            annotationView.nameLabel.text    = [annotation title];
        }
        
        return annotationView;
    }
    return nil;
    

}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    NSLog(@"%@ ----- %@", self, NSStringFromSelector(_cmd));
    MKOverlayView* overlayView = nil;
    if(overlay == _routeLine)
    {
        //if we have not yet created an overlay view for this overlay, create it now.
        if (_routeLineView) {
            [_routeLineView removeFromSuperview];
        }
        
        _routeLineView = [[MKPolylineView alloc] initWithPolyline:_routeLine];
        _routeLineView.fillColor = [UIColor orangeColor];
        _routeLineView.strokeColor = [UIColor orangeColor];
        _routeLineView.lineWidth = 4;
        
        overlayView = _routeLineView;
    }
    
    return overlayView;
}

#pragma mark - getter
- (MKMapView *)mapView{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.dataView.frame)-10, self.view.bounds.size.width, self.view.bounds.size.height-CGRectGetMaxY(self.dataView.frame)+10)];
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
        _mapView.userInteractionEnabled = YES;
        _mapView.zoomEnabled = YES;
        _mapView.rotateEnabled = NO;
        _mapView.showsBuildings = YES;
        //setup default display map region
        _mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(31.27189408, 121.47583771), MKCoordinateSpanMake(0.001, 0.001));
        _mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
        [self.view insertSubview:_mapView belowSubview:self.dataView];
    }
    return _mapView;
}

- (RunData *)dataView{
    if (!_dataView) {
        _dataView = [[RunData alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 157)];
        [self.view addSubview:_dataView];

    }
    return _dataView;
}

- (UIButton *)locationButton{
    if (!_locationButton) {
        UIImage  *img = [UIImage imageNamed:@"btn_fix_nor"];
        _locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _locationButton.frame = CGRectMake(0, self.view.bounds.size.height-140, img.size.width, img.size.height);
        [_locationButton setBackgroundImage:img forState:UIControlStateNormal];
        [_locationButton setBackgroundImage:[UIImage imageNamed:@"btn_fix_press"] forState:UIControlStateSelected];
        _locationButton.exclusiveTouch = YES;
        [_locationButton addTarget:self action:@selector(showUserLocationCenter) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_locationButton];
    }
    return _locationButton;
}

@end
