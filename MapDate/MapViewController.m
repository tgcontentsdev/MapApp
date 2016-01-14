//
//  MapViewController.m
//  MapDate
//
//  Created by tgaiacontentsdev on 2016/01/08.
//  Copyright © 2016年 tgaiacontentsdev. All rights reserved.
//

#import "MapViewController.h"
#import "CustomAnnotation.h"
#include "DataViewController.h"

@interface MapViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>
//ロケーションマネージャー
@property(strong,nonatomic) CLLocationManager* locationManager;
@property(strong,nonatomic) NSMutableArray *annotationArray;
//マップキット
@property(weak,nonatomic)IBOutlet MKMapView *mapView;

//ボタン
@property(weak,nonatomic)IBOutlet UIButton *addButton;
@property(weak,nonatomic)IBOutlet UIButton *dataButton;

-(IBAction)addButtonAction:(id)sender;
-(IBAction)dataButtonAction:(id)sender;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //ロケーションマネージャー作成
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    //取得頻度
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    //５m毎
    self.locationManager.distanceFilter = 5;
    
    //使用中のみ取得
    [self.locationManager requestWhenInUseAuthorization];
    self.isLocation = NO;
    
    //位置取得開始
    [self.locationManager startUpdatingLocation];
    
    //地図機能有効化
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *newLocations = locations.firstObject;
    self.longitude = newLocations.coordinate.longitude;
    self.latitude = newLocations.coordinate.latitude;
    
    self.isLocation = YES;
}

//位置取得成功時のコール
/*
-(void)locationManager:(CLLocationManager *)manager didUpdateLocation:(CLLocation *)newLocations fromLocation:(CLLocation *)oldLocation{
    self.longitude = newLocations.coordinate.longitude;
    self.latitude = newLocations.coordinate.latitude;
    
    self.isLocation = YES;
}
 */

//位置取得失敗時のコール
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self.locationManager stopUpdatingLocation];
}

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation{
    if (annotation == mapView.userLocation) {
        return nil;
    }
    MKAnnotationView *annotationView;
    NSString* identifier = @"Pin";
    annotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (nil == annotationView) {
        annotationView =[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    annotationView.canShowCallout =YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    annotationView.annotation = annotation;
    
    return annotationView;
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//初期情報取得
    
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    NSMutableData *data = [nd objectForKey:@"annotationData"];
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    self.annotationArray = [[decoder decodeObjectForKey:@"annotation"]mutableCopy];
    
    [decoder finishDecoding];
    
    if (self.isLocation) {
//地図の中心座標を現在地
        CLLocationCoordinate2D co;
        co.latitude = self.latitude;
        co.longitude = self.longitude;
        self.mapView.centerCoordinate = co;
        
//表示倍率
        MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
        MKCoordinateRegion region = MKCoordinateRegionMake(co, span);
        [self.mapView setRegion:region animated:YES];
        
    }
    
//初期時ピンと経路の削除
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    
//保持ピンなし時の配列初期化
    if (self.annotationArray == nil) {
        self.annotationArray = [NSMutableArray arrayWithCapacity:0];
    }
    
//ピン保持時の表示
    for (CustomAnnotation *annotation in self.annotationArray) {
        [self.mapView addAnnotation:annotation];
    }
    
}

-(IBAction)addButtonAction:(id)sender{
    CLLocationCoordinate2D co;
    co.latitude =self.latitude;
    co.longitude =self.longitude;
    self.mapView.centerCoordinate = co;
    
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01,0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(co, span);
    [self.mapView setRegion:region animated:YES];
    
//リバースジオコーディング
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    CLLocation *location = [[CLLocation alloc]initWithLatitude:self.latitude longitude:self.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *Placemarks, NSError *error) {
        if (error) {
            NSLog(@"リバースジオコーディング失敗");
        }else{
            if (0 < [Placemarks count]) {
                for (CLPlacemark *placemark in Placemarks){
                    NSString *name = [NSString stringWithFormat:@"%@",placemark.name];
                    NSString *address = [NSString stringWithFormat:@"%@%@%@%@%@",placemark.country,placemark.administrativeArea,placemark.locality,placemark.thoroughfare,placemark.subThoroughfare];
                    
                    CustomAnnotation *annotation;
                    CLLocationCoordinate2D annoLocation;
                    annoLocation.latitude = self.latitude;
                    annoLocation.longitude = self.longitude;
                    annotation = [[CustomAnnotation alloc]initWithCoordinate:annoLocation];
                    
                    annotation.title = name;
                    annotation.subtitle = address;
                    [self.mapView addAnnotation:annotation];
                    
                    [self.annotationArray addObject:annotation];
                    
                    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
                    NSMutableData *data = [NSMutableData data];
                    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
                    
                    [encoder encodeObject:[self.annotationArray copy] forKey:@"annotation"];
                    [encoder finishEncoding];
                    [nd setObject:data forKey:@"annotationData"];
                    [nd synchronize];
                    
                }
            }
        }
    }];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    CLLocationCoordinate2D fromCoordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    CLLocationCoordinate2D toCoordinate = view.annotation.coordinate;
    
//CLLocation~2DからMKPlacemark 生成
    MKPlacemark *fromPlacemark = [[MKPlacemark alloc]initWithCoordinate:fromCoordinate addressDictionary:nil];
    MKPlacemark *toPlacemark = [[MKPlacemark alloc]initWithCoordinate:toCoordinate addressDictionary:nil];
    
//MKPlacemakeからMKPlaceItem　生成
    MKMapItem *fromItem = [[MKMapItem alloc ]initWithPlacemark:fromPlacemark];
    MKMapItem *toItem = [[MKMapItem alloc]initWithPlacemark:toPlacemark];
    
//ItemをセットしてMKDirections~を生成
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    request.source = fromItem;
    request.destination =toItem;
    request.requestsAlternateRoutes = YES;
    
//MKDire~RequestからMKDirections 生成
    MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
    
//経路検索実行
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response,NSError *error){
        if (error)return;
        
        if ([response.routes count] > 0){
            MKRoute *route = [response.routes objectAtIndex:0];
            
    //ルート描写
            [self.mapView addOverlay:route.polyline];
        }
    }];
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
}


//地図上に表示させるルートの色など
-(MKOverlayPathRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc]initWithPolyline:route];
        routeRenderer.lineWidth = 5.0;
        routeRenderer.strokeColor = [UIColor redColor];
        return routeRenderer;
        
    }
    else   {
        return nil;
    }
}


-(IBAction)dataButtonAction:(id)sender{
    [self performSegueWithIdentifier:@"DataView" sender:self];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"DataView"]) {
    
        if ([segue.identifier isEqualToString:@"DateView"]) {
            
        }
    
     /*   MapViewController *prevViewController = [segue destinationViewController];
        prevViewController.isLocation =YES;
        prevViewController.latitude = self.latitude;
        prevViewController.longitude = self.longitude;
       */
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)exitFromDataView:(UIStoryboardSegue *)segue{
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
