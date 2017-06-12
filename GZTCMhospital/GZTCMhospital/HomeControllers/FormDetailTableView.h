//
//  FormDetailTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/10/14.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormDetailTableView : UITableViewController

@property (nonatomic, copy) NSString *PersonID;

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *moreURL;

@property (nonatomic, strong) NSMutableArray *moreUrlArray; // 存moreUrl的数组
@property (nonatomic, strong) NSMutableArray *formItemModels; //存FormItemModel类型对象的数组

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addFormBarItem;

- (IBAction)modifyAction:(id)sender;
- (IBAction)deleteAction:(id)sender;
- (IBAction)addFormAction:(UIBarButtonItem *)sender;

@end
