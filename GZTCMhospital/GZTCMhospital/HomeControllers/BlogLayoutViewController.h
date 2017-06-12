//
//  BlogLayoutViewController.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/19.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HMSegmentedControl;

@interface BlogLayoutViewController : UIViewController

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;

@property (nonatomic, copy) NSString *ClassID;
@property (nonatomic, strong) NSArray *informationChannelModels; //存放InformationChannelModel对象的数组

@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UIScrollView *blogScroll;

@end
