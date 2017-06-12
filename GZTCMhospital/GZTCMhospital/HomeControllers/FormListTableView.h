//
//  FormListTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/10/13.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormListTableView : UITableViewController

@property (nonatomic, copy) NSString *PersonID;
@property (nonatomic, strong) NSArray *formListModels;

@end
