//
//  OrderLayoutViewController.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/23.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HMSegmentedControl;

@interface OrderLayoutViewController : UIViewController

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UIScrollView *orderScroll;

@end
