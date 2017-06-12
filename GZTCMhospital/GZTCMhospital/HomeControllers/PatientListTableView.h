//
//  PatientListTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/22.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PatientListTableView : UITableViewController

@property (nonatomic, copy) NSString *patientListIdentify;

@property (nonatomic, copy) NSString *patientUrl;

@property (nonatomic, copy) NSString *moreURL;

@property (nonatomic, strong) NSMutableArray *moreUrlArray;  //存moreUrl的数组
@property (nonatomic, strong) NSMutableArray *patientItemModels; //存放PatientItemModel对象的数组

@end
