//
//  CheckNewWorkStatus.h
//  GZTCMhospital
//
//  Created by Chris on 15/9/6.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

typedef void(^actionBlokc)();

typedef NS_ENUM(NSInteger, NetworkType) {
    NETWORK_TYPE_NONE= 0,
    NETWORK_TYPE_2G= 1,
    NETWORK_TYPE_3G= 2,
    NETWORK_TYPE_4G= 3,
    NETWORK_TYPE_5G= 4, //5G
    NETWORK_TYPE_WIFI= 5,
};

@interface CheckNetWorkStatus : NSObject

@property (nonatomic, strong) void(^callBackBlock)(NSInteger NetworkStatus);

//检测当前网络状况
+ (void)checkNewWorking:(NSString *)url WithSucessBlock:(actionBlokc)success andWithFaildBlokc:(actionBlokc)faild;

//获取AFHTTPRequestOperationManager单例
+ (AFHTTPRequestOperationManager *)shareManager;

//检测当前连接的网络类型
+ (NetworkType)getNetworkTypeFromStatusBar;

@end
