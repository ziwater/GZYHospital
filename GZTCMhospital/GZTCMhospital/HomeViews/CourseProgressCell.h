//
//  CourseProgressCell.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/2.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseProgressCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *learningPersonLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *courseProgress;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;

@end
