//
//  NurseSearchTableView.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/18.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NurseSearchTableView : UITableViewController

@property (nonatomic, copy) NSString *nurseSearchIdentify;

@property (weak, nonatomic) IBOutlet UITextField *organizationName;
@property (weak, nonatomic) IBOutlet UITextField *nurseName;
@property (weak, nonatomic) IBOutlet UITextField *nursePhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *nurseStafferID;


@end
