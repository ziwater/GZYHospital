//
//  CourseCell.h
//  GZTCMhospital
//
//  Created by Chris on 15/11/12.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *courseTitleTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *courseCommonTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseCommonLabel;

@property (weak, nonatomic) IBOutlet UILabel *courseTimeTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseTimeLabel;

@property (weak, nonatomic) IBOutlet UIView *separateView;

@property (weak, nonatomic) IBOutlet UIButton *deleteCourseButton;
@property (weak, nonatomic) IBOutlet UIButton *modifyCourseButton;

@end
