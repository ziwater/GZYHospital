//
//  CheckNewWorkStatus.m
//  GZTCMhospital
//
//  Created by Chris on 15/9/6.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "CheckNetWorkStatus.h"

#import "AFHTTPRequestOperationManager.h"

@implementation CheckNetWorkStatus

+ (void)checkNewWorking:(NSString *)url WithSucessBlock:(actionBlokc)success andWithFaildBlokc:(actionBlokc)faild
{
    
    NSURL *baseURL = [NSURL URLWithString:url]; //创建一个URL
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL]; //创建一个Http请求操作管理者
    
    NSOperationQueue *operationQueue = manager.operationQueue;//将操作管理者加入到队列当中
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {//利用block代码实现对网络的检测
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [operationQueue setSuspended:NO];//设置队列暂停为NO
                NSLog(@"网络状态正常");
                success();
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [operationQueue setSuspended:YES];//设置队列暂停为YES
                NSLog(@"网络状态异常");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    faild();
                });
                break;
        }
    }];
    [manager.reachabilityManager startMonitoring];//开启网络监控
}

+ (AFHTTPRequestOperationManager *)shareManager {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 15.f;//请求超时15S
    //默认的Response为json数据,使用如下将得到的是NSData
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return manager;
}

+ (NetworkType)getNetworkTypeFromStatusBar {
    UIApplication *app = [UIApplication sharedApplication];
    
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    
    NSNumber *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    
    NetworkType netType = NETWORK_TYPE_NONE;
    NSNumber * num = [dataNetworkItemView valueForKey:@"dataNetworkType"];
    netType = [num intValue];

    return netType;
}

@end
