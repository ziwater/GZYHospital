//
//  OrderResultTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/23.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderResultTableView : UITableViewController

@property (nonatomic, copy) NSString *orderResultUrl;
@property (nonatomic, copy) NSString *moreURL;

@property (nonatomic, copy) NSString *addDepartmentOrderIdentify;

@property (nonatomic, strong) NSMutableArray *moreUrlArray;  //存moreUrl的数组
@property (nonatomic, strong) NSMutableArray *orderResultItemModels; //存放OrderResultItemModel对象的数组

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addOrderItem;

- (IBAction)orderModifyAction:(id)sender;
- (IBAction)orderDeleteAction:(id)sender;
- (IBAction)orderAddAction:(UIBarButtonItem *)sender;

@end
