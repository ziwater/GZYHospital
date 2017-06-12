//
//  RemindManageTableView.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/7.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemindManageTableView : UITableViewController

@property (nonatomic, copy) NSString *whetherPullLoadIdentify;

@property (nonatomic, copy) NSString *CardID;
@property (nonatomic, copy) NSString *SyscodeName;
@property (nonatomic, assign) NSInteger EditionID;
//以上属性可删

@property (nonatomic, copy) NSString *remindHandleIdentify;

@property (nonatomic, copy) NSString *remindUrl;
@property (nonatomic, copy) NSString *moreURL;

@property (nonatomic, strong) NSMutableArray *moreUrlArray;  //存moreUrl的数组
//复用TreatmentPlanItemModel模型
@property (nonatomic, strong) NSMutableArray *treatmentPlanItemModels; //存放TreatmentPlanItemModel对象的数组

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addRemindItem;

- (IBAction)modifyRemindAction:(id)sender;
- (IBAction)deleteRemindAction:(id)sender;
- (IBAction)addRemindAction:(UIBarButtonItem *)sender;

- (IBAction)knownHandleAction:(id)sender;
- (IBAction)unprocessedAction:(id)sender;
- (IBAction)processedAction:(id)sender;

@end
