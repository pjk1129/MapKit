//
//  ViewController.swift
//  MapKitSwift
//
//  Created by Jecky on 14/11/13.
//  Copyright (c) 2014年 Jecky. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    var mapView:MKMapView?
    var dataView:RunDataView?
    var locationButton:UIButton?
    
    var startPointDrawed:Bool!
    var isRunning:Bool!
    
    var runTimer:NSTimer?
    var totalMile:Double!       = 0.0      //跑步距离
    var totalSecond:NSInteger?   = 0      //跑步时间
    var paceTime:NSInteger?      = 0      //记录配速的时间
    var paceMile:NSInteger?      = 0      //记录配速的距离
    
    var currentLocation:CLLocation?
    var locationManager:CLLocationManager?
    var points:NSMutableArray?
    var pointsPerKm:NSMutableArray!

    // the data representing the route points.
    var routeLine:MKPolyline?
    
    // the view we create for the line on the map
    var routeLineView:MKPolylineRenderer?
    
    var northEastPoint:MKMapPoint?
    var southWestPoint:MKMapPoint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = "MapKitSwift"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "开始", style: UIBarButtonItemStyle.Plain, target: self, action: "start")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "暂停", style: UIBarButtonItemStyle.Plain, target: self, action: "pauseRun")
        
        locationManager = CLLocationManager()
        if locationManager!.respondsToSelector("requestWhenInUseAuthorization") {
            locationManager!.requestWhenInUseAuthorization()
        }
        
        isRunning = false
        startPointDrawed = false
        
        initUI()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopUpdatingLocation", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startUpdatingLocation", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !CLLocationManager.locationServicesEnabled() || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
            
            var alert = UIAlertView()
            alert.title = "系统提示"
            alert.message = "位置服务不可用，请先进入设置-隐私中开启定位服务"
            alert.addButtonWithTitle("我知道了")
            alert.show()
        }else{
            locationManager!.startUpdatingLocation()
        }
        

    }
    
    func startUpdatingLocation() {
        locationManager!.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        if isRunning! {
            return
        }
        
        locationManager!.stopUpdatingLocation()
    }
    
    func showUserLocationCenter() {
        if mapView!.userLocation.coordinate.latitude == 0.0&&mapView!.userLocation.coordinate.longitude == 0.0 {
            NSLog("=======NO Location=========")
            return
        }
        self.mapView!.setCenterCoordinate(self.mapView!.userLocation.coordinate, animated: true)
    }
    
    // TODO:
    //MARK: -----Run------
    func start() {
        NSLog("======== Start ============")
        if (isRunning!) {
            return
        }
        
        isRunning = true
        points = NSMutableArray(capacity: 0)
        pointsPerKm = NSMutableArray(capacity: 0)
        
        self.totalSecond = 0
        self.totalMile = 0.0
        
        setRunTimer()
        
        locationManager?.startUpdatingLocation()
    }
    
    func pauseRun() {
        NSLog("======== pauseRun ============")
        
        isRunning = false
        runTimer?.invalidate()
        runTimer = nil
        
        if (points!.count>1){
            var location = points!.lastObject as CLLocation
            addPointAnnotation(location.coordinate, title: "终点")
        }
    }
    
    func setRunTimer(){
        if (runTimer != nil) {
            runTimer!.invalidate()
            runTimer = nil
        }
        runTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateRunStatusView", userInfo: nil, repeats: true)
    }
    
    func updateRunStatusView() {
        locationManager!.startUpdatingLocation()

        let integerPi = Int(totalMile!/1000.0)
        
        if paceMile != integerPi {
            paceMile = integerPi
            
            var location = points?.lastObject as CLLocation
            if (points?.count > 0) {
                pointsPerKm.addObject(location)
                addPointAnnotation(location.coordinate, title: "\(pointsPerKm.count)")
            }

            paceTime = totalSecond
        }
        
        totalSecond!++
        
        dataView?.updateRunData(totalSecond!, totalMile: totalMile!)
    }
    
    func configureRoutes() {
        // define minimum, maximum points
        northEastPoint = MKMapPointMake(0.0, 0.0)
        southWestPoint = MKMapPointMake(0.0, 0.0)
        
        var pointArray: UnsafeMutablePointer<MKMapPoint> = UnsafeMutablePointer.alloc(points!.count)
        
        for (var idx = 0; idx < points!.count; idx++){
            var location:CLLocation = points!.objectAtIndex(idx) as CLLocation
            // create our coordinate and add it to the correct spot in the array
            var point = MKMapPointForCoordinate(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)) as MKMapPoint
            
            // if it is the first point, just use them, since we have nothing to compare to yet.
            if (idx == 0) {
                northEastPoint = point;
                southWestPoint = point;
            } else {
                if (point.x > northEastPoint!.x){
                    northEastPoint!.x = point.x;
                }
                if(point.y > northEastPoint!.y){
                    northEastPoint!.y = point.y;
                }
                if (point.x < southWestPoint!.x){
                    southWestPoint!.x = point.x;
                }
                if (point.y < southWestPoint!.y){
                    southWestPoint!.y = point.y;
                }
            }
            
            pointArray[idx] = point
        }

        if (routeLine != nil) {
            self.mapView?.removeOverlay(routeLine)
        }
        
        routeLine = MKPolyline(points: pointArray, count: points!.count)

        if (routeLine != nil) {
            self.mapView?.addOverlay(routeLine)
        }
        free(pointArray);
        
    }
    
    func addPointAnnotation(coordinate:CLLocationCoordinate2D, title:NSString){
        var annotation:MKPointAnnotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        self.mapView?.addAnnotation(annotation)
    }
    
    // TODO:
    //MARK: -----MKMapViewDelegate------
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!){
        
        if (!isRunning) {
            return
        }
        
        if(userLocation.coordinate.latitude == 0.0 || userLocation.coordinate.longitude == 0.0){
            return
        }
        
        var location:CLLocation! = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        if userLocation.location.horizontalAccuracy < 70 && userLocation.location.verticalAccuracy < 70{
            if totalSecond! < 3 {
                return
            }
            
            if points!.count > 0 {
                var distance:CLLocationDistance = location.distanceFromLocation(self.currentLocation)
                if distance>0 {
                    totalMile! = totalMile! + distance
                }
            }
            
            if totalSecond!%2 == 0 {
                if points!.count < totalSecond! {
                    points?.addObject(location)
                    configureRoutes()
                }
            }
            
            if ((points!.count==1)&&(!startPointDrawed!)){
                startPointDrawed = true
                addPointAnnotation(location.coordinate, title: "起点")
            }
            self.currentLocation = location;
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation.isKindOfClass(MKPointAnnotation) {
            let CustomAnnotationReuseIndetifier = "CustomAnnotationReuseIndetifier"

            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(CustomAnnotationReuseIndetifier) as? CustomAnnotationView
            if annotationView == nil {
                annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: CustomAnnotationReuseIndetifier)
                annotationView?.bounds = CGRectMake(0.0, 0.0, 26.0, 56.0)
                annotationView?.backgroundColor = UIColor.clearColor()
            }
            
            if (annotation.title == "起点") {
                annotationView!.annotationImageView.image = UIImage(named: "bg_run_start_point")
            }else if (annotation.title == "终点") {
                annotationView!.annotationImageView.image = UIImage(named: "bg_run_end_point")
            }else{
                annotationView!.annotationImageView.image = UIImage(named: "bg_run_inter_point")
                annotationView!.nameLabel.text = annotation.title
            }
            return annotationView;
            
        }

        return nil
    }

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer!{
        if overlay is MKPolyline {
            var renderer:MKPolylineRenderer = MKPolylineRenderer(polyline: routeLine!)
            renderer.fillColor = UIColor.orangeColor()
            renderer.strokeColor = UIColor.orangeColor()
            renderer.lineWidth = 4
            return renderer
        }
        
        return nil
    }
    
    // TODO:
    //MARK: -----Init UI------
    func initUI() {
        dataView = RunDataView(frame: CGRectMake(0, 64, self.view.bounds.size.width, 157))
        self.view.addSubview(dataView!)
        
        mapView = MKMapView(frame: CGRectMake(0, CGRectGetMaxY(dataView!.frame)-10, self.view.bounds.size.width, self.view.bounds.size.height-CGRectGetMaxY(dataView!.frame)+10))
        mapView?.delegate = self
        mapView?.showsUserLocation = true
        mapView?.userInteractionEnabled = true
        mapView?.zoomEnabled = true
        mapView?.rotateEnabled = false
        mapView?.showsBuildings = true
        mapView?.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(31.27189408, 121.47583771), MKCoordinateSpanMake(0.001, 0.001))
        mapView?.userTrackingMode = MKUserTrackingMode.FollowWithHeading
        self.view.insertSubview(mapView!, belowSubview: dataView!)
        
        var img:UIImage! = UIImage(named: "btn_fix_nor")
        locationButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        locationButton?.frame = CGRectMake(0, self.view.bounds.size.height-140, img.size.width, img.size.height)
        locationButton?.setBackgroundImage(img, forState: UIControlState.Normal)
        locationButton?.setBackgroundImage(UIImage(named: "btn_fix_press"), forState: UIControlState.Selected)
        locationButton?.exclusiveTouch = true
        locationButton?.addTarget(self, action: "showUserLocationCenter", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(locationButton!)

    }

}

