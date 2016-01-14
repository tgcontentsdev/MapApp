//
//  CustomAnnotation.h
//  MapDate
//
//  Created by tgaiacontentsdev on 2016/01/08.
//  Copyright © 2016年 tgaiacontentsdev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : MKAnnotationView <MKAnnotation,NSCoding>

@property(nonatomic,assign) CLLocationCoordinate2D coordinate;

@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSString* subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;

-(void)encodeWithCoder:(NSCoder *)aCoder;
-(id)initWithCoder:(NSCoder *)aDecoder;

@end
