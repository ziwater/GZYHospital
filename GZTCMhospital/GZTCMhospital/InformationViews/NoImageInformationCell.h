//
//  NoImageInformationCell.h
//  GZTCMhospital
//
//  Created by Chris on 15/8/31.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoImageInformationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *newsTitle;
@property (weak, nonatomic) IBOutlet UILabel *newsPubdate;
@property (weak, nonatomic) IBOutlet UILabel *commentNumber;

@end
