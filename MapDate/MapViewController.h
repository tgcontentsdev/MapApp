//
//  MapViewController.h
//  MapDate
//
//  Created by tgaiacontentsdev on 2016/01/08.
//  Copyright © 2016年 tgaiacontentsdev. All rights reserved.
//

#import "ViewController.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : ViewController

@property(assign,nonatomic)BOOL isLocation;

@property(assign,nonatomic) CLLocationDegrees longitude;
@property(assign,nonatomic) CLLocationDegrees latitude;

@end
