//
//  TreamentPlanLayoutViewController.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/4.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HMSegmentedControl;

@interface TreamentPlanLayoutViewController : UIViewController

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;

@property (nonatomic, assign) NSInteger EditionID;

@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UIScrollView *planScroll;

- (void)addTreatmentPlan;

@end
