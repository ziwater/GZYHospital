//
//  RemindFunctionTableView.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/7.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemindFunctionTableView : UITableViewController

@property (nonatomic, assign) NSInteger EditionID;
@property (nonatomic, copy) NSString *showNewRemindBadge;

@property (weak, nonatomic) IBOutlet UILabel *forBadgeLabel;

@end
