//
//  InformationTableViewController.h
//  GZTCMhospital
//
//  Created by Chris on 15/8/26.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InformationItemModel;

@interface InformationTableViewController : UITableViewController

@property (nonatomic, copy) NSString *addIdentify; //论坛、我的博客增加标识
@property (nonatomic, strong) NSArray *informationChannelModels; //存放InformationChannelModel对象的数组(论坛使用)

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *moreURL;

@property (nonatomic, strong) NSMutableArray *moreUrlArray; // 存moreUrl的数组

@property (nonatomic, strong) NSMutableArray *newsArray; //存InformationModel类型对象的数组

@property (nonatomic, strong) InformationItemModel *informationItemModel;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addForumBarItem;

- (void)setupRefresh;

@end
