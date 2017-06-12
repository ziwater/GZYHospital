//
//  InboxCell.h
//  GZTCMhospital
//
//  Created by Chris on 16/3/1.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *inboxTitleLabel;

@end
