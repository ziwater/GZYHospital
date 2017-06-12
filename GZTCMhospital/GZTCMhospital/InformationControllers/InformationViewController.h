//
//  InformationViewController.h
//  GZTCMhospital
//
//  Created by Chris on 15/8/26.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HMSegmentedControl;

@interface InformationViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;

@property (nonatomic, copy) NSString *type; //设置type确定是blog/forum/information,以便代码复用

@property (nonatomic, copy) NSString *editionID;
@property (nonatomic, copy) NSString *formID; //传递FormID用于搜索及发帖

@property (nonatomic, strong) NSArray *informationChannelModels; //存放InformationChannelModel对象的数组
@property (nonatomic, strong) NSArray *blogChannelModels; //存放BlogChannelModel对象的数组

@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (weak, nonatomic) IBOutlet UIScrollView *serviceScroll;

- (void)startSearch;
- (void)addForum;

@end
