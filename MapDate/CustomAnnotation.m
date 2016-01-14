//
//  CustomAnnotation.m
//  MapDate
//
//  Created by tgaiacontentsdev on 2016/01/08.
//  Copyright © 2016年 tgaiacontentsdev. All rights reserved.
//

#import "CustomAnnotation.h"


@implementation CustomAnnotation

-(id)initWithCoordinate:(CLLocationCoordinate2D)c{
    self.coordinate = c;
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.coordinate.longitude forKey:@"longitude"];
    
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.subtitle forKey:@"subtitle"];
    
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    
    if (self) {
        CGFloat latitude = [aDecoder decodeDoubleForKey:@"latitude"];
        CGFloat longitude = [aDecoder decodeDoubleForKey:@"longitude"];
        
        self.coordinate = CLLocationCoordinate2DMake(latitude,longitude);
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.subtitle = [aDecoder decodeObjectForKey:@"subtitle"];
        
    }
    return self;
}

@end

