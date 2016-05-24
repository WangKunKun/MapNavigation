//
//  MapNavigationManager.m
//  MapNavigation
//
//  Created by apple on 16/2/14.
//  Copyright © 2016年 王琨. All rights reserved.
//

#import "MapNavigationManager.h"

//调用方式
typedef enum : NSUInteger {
    Address = 0,
    Coordinates
} MapNavStyle;

//地图类型
typedef enum : NSUInteger {
    Apple = 0,
    Baidu,
    Google,
    Gaode,
    Tencent
} MapSelect;


static MapNavigationManager * MBManager = nil;

@interface MapNavigationManager ()<UIActionSheetDelegate>

@property (strong, nonatomic) NSString * urlScheme;//当前App返回的url  用于调用地图后返回
@property (strong, nonatomic) NSString * appName;//当前App名字

@property (assign, nonatomic) MapNavStyle style;//调用方式

//地名模式
@property (strong, nonatomic) NSString * start;//起点
@property (strong, nonatomic) NSString * end;//终点
@property (strong, nonatomic) NSString * city;//城市名
//经纬度模式
@property (assign, nonatomic) CLLocationCoordinate2D Coordinate2D;



@end

@implementation MapNavigationManager


+ (MapNavigationManager *)shardMBManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MBManager = [[MapNavigationManager alloc] init];
    });
    return MBManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //!!! 需要自己改，方便弹回来
        
        self.urlScheme = @"WKMapNavTest://";
        self.appName = @"WKMapNavTest";
    }
    return self;
}


- (void)showSheet
{
    NSString * appleMap  = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]] ? @"苹果地图" : nil;
    
    NSString * baiduMap  = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]] ? @"百度地图" : nil;
    NSString * gaodeMap  = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]] ? @"高德地图":nil;
    //不能用，需翻墙
    NSString * googleMap = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]] ? nil :nil;
    //暂时不支持
    NSString * tencentMap  = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://map/"]] ? nil : nil;
    
    
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择您已经安装的导航工具" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:gaodeMap otherButtonTitles:appleMap,baiduMap,googleMap,tencentMap,nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString * str = [actionSheet buttonTitleAtIndex:buttonIndex];
    //和枚举对应
    NSArray <NSString *> * mapArray = @[@"苹果地图",@"百度地图",@"谷歌地图",@"高德地图",@"腾讯地图"];
    NSUInteger i = 0 ;
    for (; i < mapArray.count; i ++) {
        if ([str isEqualToString:mapArray[i]]) {
            break;
        }
    }
    
    [self startNavigation:i];
}

- (void)startNavigation:(MapSelect)index
{
    NSString * urlString = [self getUrlStr:index];
    if (urlString != nil) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
    else if(_style == Coordinates)
    {
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.Coordinate2D addressDictionary:nil]];
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }
    
    
}

- (NSString *)getUrlStr:(MapSelect)index
{
    NSString * urlStr = nil;
    if (index == Apple && _style == Coordinates) {
        return urlStr;
    }
    switch (_style) {
        case Coordinates:
            urlStr = [self getUrlStrWithCoordinates:index];
            break;
        case Address:
            urlStr = [self getUrlStrWithAddress:index];
            break;
        default:
            break;
    }
    return urlStr;
}

- (NSString *)getUrlStrWithCoordinates:(MapSelect)index
{
    NSString * urlString = nil;
    MapNavigationManager * mb = [MapNavigationManager shardMBManager];

    NSString * baiduUrlStr = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",mb.Coordinate2D.latitude, mb.Coordinate2D.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString * goooleUrlStr = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",_appName,_urlScheme,mb.Coordinate2D.latitude, mb.Coordinate2D.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString * gaodeUrlStr= [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2",_appName,_urlScheme,mb.Coordinate2D.latitude, mb.Coordinate2D.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    switch (index) {

        case Baidu:
            urlString = baiduUrlStr;
            break;
        case Google:
            urlString = goooleUrlStr;
            break;
        case Gaode:
            urlString = gaodeUrlStr;
            break;

        default:
            break;
    }
    return urlString;
}

- (NSString *)getUrlStrWithAddress:(MapSelect)index
{
    NSString * urlString = nil;
    MapNavigationManager * mb = [MapNavigationManager shardMBManager];
    //地址系列
    //腾讯
    NSString * tencentAddressUrl = [[NSString stringWithFormat:@"qqmap://map/routeplan?type=walk&from=%@&to=%@&policy=1&referer=%@",mb.start, mb.end,_appName] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //苹果
    NSString *appleAddressUrl = [[NSString stringWithFormat:@"http://maps.apple.com/?saddr=%@&daddr=%@&dirflg=w",_start, mb.end] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //百度
    NSString *baiduAddressUrl = [[NSString stringWithFormat:@"baidumap://map/direction?origin=%@&destination=%@&mode=walking&region=%@&src=%@",mb.start, mb.end,_city,_appName] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //高德
    NSString *gaodeAddressUrl = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&sid=BGVIS1&sname=%@&did=BGVIS2&dname=%@&dev=0&m=2&t=2",_appName,mb.start,mb.end] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //谷歌
    NSString *googleAddressUrl = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=%@&daddr=%@&directionsmode=bicycling",_appName,_urlScheme,mb.start, mb.end] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    switch (index) {
        case Apple:
            urlString = appleAddressUrl;
            break;
        case Baidu:
            urlString = baiduAddressUrl;
            break;
        case Google:
            urlString = googleAddressUrl;
            break;
        case Gaode:
            urlString = gaodeAddressUrl;
            break;
        case Tencent:
            urlString = tencentAddressUrl;
            break;
        default:
            break;
    }
    
    return urlString;
}


+ (void)showSheetWithCity:(NSString *)city start:(NSString *)start end:(NSString *)end
{
    MapNavigationManager * mb = [self shardMBManager];
    mb.city = city;
    mb.start = start;
    mb.end = end;
    mb.style = Address;
    [mb showSheet];
    
}

+ (void)showSheetWithCoordinate2D:(CLLocationCoordinate2D)Coordinate2D
{
    MapNavigationManager * mb = [self shardMBManager];
    mb.style = Coordinates;
    mb.Coordinate2D = Coordinate2D;
    [mb showSheet];
    
}

@end
