//
//  AppDelegate.m
//  GZTCMhospital
//
//  Created by Chris on 15/8/26.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "AppDelegate.h"

#import "SVProgressHUD.h"
#import "IQKeyboardManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "MJExtension.h"

#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"

#import "WHC_ClientAccount.h"

#import "AFHTTPRequestOperationManager.h"
#import "WZLBadgeImport.h"
#import "CheckNetWorkStatus.h"
#import "MD5Method.h"
#import "RemindWayAndRecordModel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UITabBarController *tabBarController = [storyboard instantiateInitialViewController];
    UITabBar *tabBar = tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    
    //设置tabBarItemt选中图片
    tabBarItem1.selectedImage = [[UIImage imageNamed:@"home_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem2.selectedImage = [[UIImage imageNamed:@"information_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem3.selectedImage = [[UIImage imageNamed:@"my_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    //设置tabBarItem选中时文本颜色
    NSMutableDictionary *selectedtextAttrs = [NSMutableDictionary dictionary];
    selectedtextAttrs[NSForegroundColorAttributeName] = RGBColor(0, 194, 155);
    [tabBarItem1 setTitleTextAttributes:selectedtextAttrs forState:UIControlStateSelected];
    [tabBarItem2 setTitleTextAttributes:selectedtextAttrs forState:UIControlStateSelected];
    [tabBarItem3 setTitleTextAttributes:selectedtextAttrs forState:UIControlStateSelected];
    
    self.window.rootViewController = tabBarController;
    
    //SVProgressHUD设置
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:0.5]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    //设置NavigationBar背景颜色
    [[UINavigationBar appearance] setBarTintColor:RGBColor(0, 194, 155)];
    //修改返回及系统文字颜色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //修改导航栏字体颜色
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //引用第三方框架解决键盘遮挡输入控件问题
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    [[IQKeyboardManager sharedManager] setShouldToolbarUsesTextFieldTintColor:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    
    //请求网络时状态栏显示ActivityIndicator
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    //友盟分享相关设置
    [UMSocialData setAppKey:@"560403bae0f55a3219001fd4"]; //设置设置友盟AppKey
    
    //设置微信AppId、appSecret，分享url  //待更改
    [UMSocialWechatHandler setWXAppId:@"wx1cded1ee254a2c57" appSecret:@"14f87f13dbaa683933d61b11bee1330e" url:@"http://www.umeng.com/social"];
    
    //设置分享到QQ/Qzone的应用Id，和分享url链接
    [UMSocialQQHandler setQQWithAppId:@"100424468" appKey:@"c7394704798a158208a74ab60104f0ba" url:@"http://www.umeng.com/social"];
    
    //隐藏未安装平台
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession,UMShareToWechatTimeline]];
    
    //保存下载默认设置
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"downloadStatus"]) {
        [userDefaults setObject:@NO forKey:@"downloadStatus"];
        [userDefaults synchronize];
    }
    
    if (GetOperatorID) { //只有登录后才检测new remind
        [self loadRemindWayAndRecordNumberJson:tabBarItem1];
    }
    return YES;
}

//加载提醒管理-所有提醒方式和记录条数json并MD5化
- (void)loadRemindWayAndRecordNumberJson:(UITabBarItem *)tabBarItem {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        NSString *urlString = [NSString stringWithFormat:@"%@OperatorID=%@&PageID=1&PageSize=20", RemindWayAndRecordNumberBaseUrl, GetOperatorID];
        
        [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *jsonString = [NSString stringWithFormat:@"%@", responseObject];
            NSString *md5JsonString = [MD5Method md5:jsonString];
            
            NSArray *remindWayAndRecordModels = [RemindWayAndRecordModel objectArrayWithKeyValuesArray:[[responseObject valueForKeyPath:@"List"] valueForKeyPath:@"DataList"]];
            
            //保存该json的MD5值
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            //无值或不相等则进行保存
            if ((![userDefaults objectForKey:@"remindWayAndRecordNumberJsonMD5"]) || (![[userDefaults objectForKey:@"remindWayAndRecordNumberJsonMD5"] isEqualToString:md5JsonString])) {
                [userDefaults setObject:md5JsonString forKey:@"remindWayAndRecordNumberJsonMD5"];
                [userDefaults synchronize];
                
                //设置tabBar红点提示
                //tabBarItem.badgeCenterOffset = CGPointMake(-50, 8);
                //[tabBarItem showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
                
                NSInteger i;
                for (i = 0; i < remindWayAndRecordModels.count; i++) {
                    RemindWayAndRecordModel *remindWayAndRecordModel = remindWayAndRecordModels[i];
                    if (remindWayAndRecordModel.Count != 0) {
                        break;
                    }
                }
                
                if (i < remindWayAndRecordModels.count) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBadgeForItem" object:nil];
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        
    }];
}

//添加两个系统回调方法
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return  [UMSocialSnsService handleOpenURL:url];
}

#pragma mark - Backgrounding Methods -

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler {
    self.backgroundSessionCompletionHandler = completionHandler;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [Account saveDownloadRecord];
}

@end
