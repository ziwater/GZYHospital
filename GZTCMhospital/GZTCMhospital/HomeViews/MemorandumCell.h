//
//  MemorandumCell.h
//  GZTCMhospital
//
//  Created by Chris on 16/1/21.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemorandumCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *memorandumTitle;
@property (weak, nonatomic) IBOutlet UILabel *memorandumCreateTime;

@end
