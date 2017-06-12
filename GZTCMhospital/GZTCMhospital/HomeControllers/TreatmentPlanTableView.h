//
//  TreatmentPlanTableView.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/4.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TreatmentPlanTableView : UITableViewController

@property (nonatomic, assign) NSInteger EditionID;
@property (nonatomic, copy) NSString *type;

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *moreURL;

@property (nonatomic, strong) NSMutableArray *moreUrlArray;  //存moreUrl的数组
@property (nonatomic, strong) NSMutableArray *treatmentPlanItemModels; //存放TreatmentPlanItemModel对象的数组

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addTreatmenPlanItem;

- (IBAction)modifyTreatmentPlanAction:(id)sender;
- (IBAction)deleteTreatmentPlanAction:(id)sender;
- (IBAction)addTreatmentPlanAction:(UIBarButtonItem *)sender;

- (void)setupRefresh;

@end
