//
//  CourseLayoutViewController.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/1.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HMSegmentedControl;

@interface CourseLayoutViewController : UIViewController

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UIScrollView *courseScroll;

@property (nonatomic, assign) NSInteger EditionID;

- (void)addCourse;

@end
