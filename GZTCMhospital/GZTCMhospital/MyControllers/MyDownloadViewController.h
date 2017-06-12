//
//  MyDownloadViewController.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/3.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyDownloadViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *downloadManageSegmented;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBarButtonItem;
- (IBAction)deleteItemAction:(UIBarButtonItem *)sender;

@end
