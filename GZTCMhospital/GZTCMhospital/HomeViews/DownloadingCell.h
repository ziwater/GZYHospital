//
//  DownloadingCell.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/7.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DownloadObject;

@interface DownloadingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *downloadFileTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadingSizeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *fileDownloadProgress;
@property (weak, nonatomic) IBOutlet UIButton *pauseOrContinueButton;

@property (nonatomic , strong) NSMutableArray *fileObjectArr;    //慢病宣教文件数组

- (void)displayCell:(DownloadObject *)object;

- (IBAction)clickButtonAction:(id)sender;

@end
