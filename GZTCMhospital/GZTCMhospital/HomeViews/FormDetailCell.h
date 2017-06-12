//
//  FormDetailCell.h
//  GZTCMhospital
//
//  Created by Chris on 15/10/14.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *formTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *stafferNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateTimeLabel;

@property (weak, nonatomic) IBOutlet UIView *separateView;
@property (weak, nonatomic) IBOutlet UIButton *modifyFormButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteFormButton;

@end
