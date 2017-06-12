//
//  BlogCell.h
//  GZTCMhospital
//
//  Created by Chris on 15/9/16.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlogCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *portraitImage;
@property (weak, nonatomic) IBOutlet UILabel *blogTitle;
@property (weak, nonatomic) IBOutlet UILabel *publisher;
@property (weak, nonatomic) IBOutlet UILabel *newsPubdate;
@property (weak, nonatomic) IBOutlet UILabel *commentNumber;

@end
