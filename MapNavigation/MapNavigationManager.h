//
//  MapNavigationManager.h
//  MapNavigation
//
//  Created by apple on 16/2/14.
//  Copyright © 2016年 王琨. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import CoreLocation;
@import MapKit;
typedef enum : NSUInteger {
    Address = 0,
    Coordinates
} MapNavStyle;

@interface MapNavigationManager : NSObject

+ (void)showSheetWithCity:(NSString *)city start:(NSString *)start end:(NSString *)end;
+ (void)showSheetWithCoordinate2D:(CLLocationCoordinate2D)Coordinate2D;

@end
