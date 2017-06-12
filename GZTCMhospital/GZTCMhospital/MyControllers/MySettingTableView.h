//
//  MySettingTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/21.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MySettingTableView : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *downloadSettingSwitch;
- (IBAction)downloadSettingChangeAction:(UISwitch *)sender;

@end
