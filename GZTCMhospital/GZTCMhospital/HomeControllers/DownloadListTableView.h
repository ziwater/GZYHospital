//
//  DownloadListTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/3.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadListTableView : UITableViewController

@property (nonatomic, strong) NSMutableArray *courseFileModels; //存放courseFileModel对象的数组
@property (nonatomic, copy) NSString *attachmentUrl;  //加载附件列表的url

@property (strong, nonatomic) IBOutlet UIBarButtonItem *enterDownloadCenterItem;

- (IBAction)downloadFileAction:(id)sender;
- (IBAction)playLiveVideoAction:(UIButton *)sender;

@end
