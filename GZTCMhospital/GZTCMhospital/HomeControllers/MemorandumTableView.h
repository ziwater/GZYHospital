//
//  MemorandumTableView.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/21.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemorandumTableView : UITableViewController

@property (nonatomic, copy) NSString *moreURL;

@property (nonatomic, strong) NSMutableArray *moreUrlArray;  //存moreUrl的数组
@property (nonatomic, strong) NSMutableArray *formItemModels; //存放FormItemModel对象的数组

- (IBAction)modifyMemorandumAction:(id)sender;
- (IBAction)deleteMemorandumAction:(id)sender;
- (IBAction)addMemorandumAction:(UIBarButtonItem *)sender;

@end
