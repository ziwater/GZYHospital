//
//  DownloadListTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/3.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "DownloadListTableView.h"

#import "SVProgressHUD.h"
#import "UITableView+Improve.h"
#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "SSVideoPlayContainer.h"
#import "SSVideoPlayController.h"

#import "WHC_DownloadFileCenter.h"
#import "UIView+WHC_Toast.h"
#import "UIView+WHC_Loading.h"
#import "UIScrollView+WHC_PullRefresh.h"
#import "WHC_ClientAccount.h"

#import "CheckNetWorkStatus.h"
#import "CourseFileModel.h"
#import "CourseFileCell.h"
#import "CourseVideoCell.h"
#import "MD5Method.h"

@interface DownloadListTableView () <WHCDownloadDelegate>

@property (nonatomic, strong) CourseFileModel *courseFileModel;
@property (nonatomic, copy) NSString *plistPath;

@property (nonatomic, assign) BOOL updateToDownloadingStatus;
@property (nonatomic, assign) BOOL updateToDownloadedStatus;

@end

@implementation DownloadListTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadCourseFileDownloadListData];
    
    self.title = FilesList;
    UIBarButtonItem *customBackItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = customBackItem;
    self.navigationItem.rightBarButtonItem = self.enterDownloadCenterItem;
    
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    //通知中心注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownLoadStatus:) name:@"updateDownLoadStatus" object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - updateDownLoadStatus 通知方法

- (void)updateDownLoadStatus:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)dealloc {
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateDownLoadStatus" object:nil];
}

#pragma mark - 数组对象初始化

- (NSMutableArray *)courseFileModels {
    if (!_courseFileModels) {
        self.courseFileModels = [NSMutableArray array];
    }
    return _courseFileModels;
}

#pragma mark - loadCourseFileDownloadListData 加载课程文件下载列表

- (void)loadCourseFileDownloadListData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        if (self.attachmentUrl) {
            [manager GET:self.attachmentUrl parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                
                self.courseFileModels = [CourseFileModel objectArrayWithKeyValuesArray:[responseObject valueForKeyPath:@"List"]];
                
                [self.tableView reloadData];
                
            } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                [SVProgressHUD showInfoWithStatus:DataLoadFailureTip maskType:SVProgressHUDMaskTypeNone];
                NSLog(@"Error:%@", error);
            }];
        }
        
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.courseFileModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    self.courseFileModel = self.courseFileModels[indexPath.row];
    
    if (([[WHCDownloadCenter fileFormat:self.courseFileModel.FileUrl] caseInsensitiveCompare:@".mp4"] == NSOrderedSame) || ([[WHCDownloadCenter fileFormat:self.courseFileModel.FileUrl] caseInsensitiveCompare:@".mov"] == NSOrderedSame)) {
        CourseVideoCell *courseVideoCell = [tableView dequeueReusableCellWithIdentifier:@"courseVideoCell"];
        courseVideoCell.courseVideoTitleLabel.text = self.courseFileModel.FileTitle;
        
        if ([self queryWithFileName:[MD5Method md5:self.courseFileModel.FileUrl]] == NoneState) {
            courseVideoCell.courseVideoDownloadButton.enabled = YES;
            [courseVideoCell.courseVideoDownloadButton setTitle:DownloadTitle forState:UIControlStateNormal];
        } else if ([self queryWithFileName:[MD5Method md5:self.courseFileModel.FileUrl]] == Downloading) {
            [courseVideoCell.courseVideoDownloadButton setTitle:DownloadingTitle forState:UIControlStateNormal];
            courseVideoCell.courseVideoDownloadButton.enabled = NO;
        } else if ([self queryWithFileName:[MD5Method md5:self.courseFileModel.FileUrl]] == DownloadCompleted) {
            //CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            //CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 1, 0, 0, 1 });
            //[courseFileCell.courseFileDownloadButton.layer setBorderColor:colorref];
            [courseVideoCell.courseVideoDownloadButton setTitleColor:RGBColorWithAlpha(0, 153, 153, 0.5) forState:UIControlStateDisabled];
            courseVideoCell.courseVideoDownloadButton.enabled = NO;
            [courseVideoCell.courseVideoDownloadButton setTitle:DownloadedTitle forState:UIControlStateDisabled];
        }
        
        return courseVideoCell;
    } else {
        CourseFileCell *courseFileCell = [tableView dequeueReusableCellWithIdentifier:@"courseFileCell" forIndexPath:indexPath];
        courseFileCell.courseFileTitleLabel.text = self.courseFileModel.FileTitle;
        
        NSLog(@"记录文件状态%ld", (long)[self queryWithFileName:[MD5Method md5:self.courseFileModel.FileUrl]]);
        
        if ([self queryWithFileName:[MD5Method md5:self.courseFileModel.FileUrl]] == NoneState) {
            courseFileCell.courseFileDownloadButton.enabled = YES;
            [courseFileCell.courseFileDownloadButton setTitle:DownloadTitle forState:UIControlStateNormal];
        } else if ([self queryWithFileName:[MD5Method md5:self.courseFileModel.FileUrl]] == Downloading) {
            [courseFileCell.courseFileDownloadButton setTitle:DownloadingTitle forState:UIControlStateNormal];
            courseFileCell.courseFileDownloadButton.enabled = NO;
        } else if ([self queryWithFileName:[MD5Method md5:self.courseFileModel.FileUrl]] == DownloadCompleted) {
            //        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            //        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 1, 0, 0, 1 });
            //        [courseFileCell.courseFileDownloadButton.layer setBorderColor:colorref];
            [courseFileCell.courseFileDownloadButton setTitleColor:RGBColorWithAlpha(0, 153, 153, 0.5) forState:UIControlStateDisabled];
            
            courseFileCell.courseFileDownloadButton.enabled = NO;
            [courseFileCell.courseFileDownloadButton setTitle:DownloadedTitle forState:UIControlStateDisabled];
        }
        
        return courseFileCell;
    }
}

#pragma mark - downloadFileAction method

- (IBAction)downloadFileAction:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"getNetworkTypeFromStatusBar = %ld", (long)[CheckNetWorkStatus getNetworkTypeFromStatusBar]);
    if (![[userDefaults objectForKey:@"downloadStatus"] boolValue] && ([CheckNetWorkStatus getNetworkTypeFromStatusBar] != NETWORK_TYPE_WIFI)) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:KindlyRemind message:NotWiFiDownloadTip preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:AbandonDownloadTip style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:ContinueToDownloadTip style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self beginDownloadFile:selectedIndexPath];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [sender setEnabled:NO];
        [self beginDownloadFile:selectedIndexPath];
    }
}

- (IBAction)playLiveVideoAction:(UIButton *)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![[userDefaults objectForKey:@"downloadStatus"] boolValue] && ([CheckNetWorkStatus getNetworkTypeFromStatusBar] != NETWORK_TYPE_WIFI)) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:KindlyRemind message:NotWiFiPlayTip preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:AbandonDownloadTip style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:ContinueToPlayTip style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self beginPlay:selectedIndexPath];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self beginPlay:selectedIndexPath];
    }
}

- (void)beginDownloadFile:(NSIndexPath *)selectedIndexPath {
    [self.view startLoading];
    
    self.updateToDownloadingStatus = YES;
    self.updateToDownloadedStatus = YES;
    
    self.courseFileModel = self.courseFileModels[selectedIndexPath.row];
    
    NSString * saveFilePath = Account.docFileFolder;
    
    NSLog(@"save path = %@", saveFilePath);
    NSURL *url = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        url = [NSURL URLWithString:[self.courseFileModel.FileUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    } else {
        url = [NSURL URLWithString:[self.courseFileModel.FileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [WHCDownloadCenter startDownloadWithURL:url savePath:saveFilePath savefileName:[MD5Method md5:self.courseFileModel.FileUrl] tureFileName:self.courseFileModel.FileTitle delegate:self];
}

- (void)beginPlay:(NSIndexPath *)selectedIndexPath {
    self.courseFileModel = self.courseFileModels[selectedIndexPath.row];
    
    NSString *url = nil;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        url = [self.courseFileModel.FileUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    } else {
        url = [self.courseFileModel.FileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSArray *paths = @[url
                       ];
    NSArray *names = @[self.courseFileModel.FileTitle];
    NSMutableArray *videoList = [NSMutableArray array];
    for (NSInteger i = 0; i < paths.count; i++) {
        SSVideoModel *model = [[SSVideoModel alloc]initWithName:names[i] path:paths[i]];
        [videoList addObject:model];
    }
    SSVideoPlayController *playController = [[SSVideoPlayController alloc]initWithVideoList:videoList];
    SSVideoPlayContainer *playContainer = [[SSVideoPlayContainer alloc]initWithRootViewController:playController];
    [self presentViewController:playContainer animated:NO completion:nil];
}

#pragma mark - queryWithFileName 查询下载记录文件(依据文件savefileName即MD5后的FileUrl)

- (DownloadState)queryWithFileName:(NSString *)MD5FileName {
    _plistPath = Account.videoFileRecordPath;
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if (![fileManage fileExistsAtPath:_plistPath]) {
        [fileManage createFileAtPath:_plistPath contents:nil attributes:nil];
        [@{}.mutableCopy writeToFile:_plistPath atomically:YES];
    }
    NSMutableDictionary *downloadRecordDict = [NSMutableDictionary dictionaryWithContentsOfFile:_plistPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *fileArr = [[fileManager contentsOfDirectoryAtPath:Account.docFileFolder error:&error] mutableCopy];
    if (fileArr) {
        for (NSString *recordFileName in fileArr) {
            if (![recordFileName isEqualToString:@".DS_Store"] && [[recordFileName stringByDeletingPathExtension] isEqualToString:MD5FileName]) {
                NSMutableDictionary *tempDict = downloadRecordDict[recordFileName];
                if (tempDict && (([tempDict[@"state"] integerValue] == DownloadUncompleted) || ([tempDict[@"state"] integerValue] == Downloading) || ([tempDict[@"state"] integerValue] == DownloadWaitting))) {
                    return Downloading;  //2
                }
                if (tempDict && ([tempDict[@"state"] integerValue] == DownloadCompleted)) {
                    return DownloadCompleted;  //3
                }
            }
        }
        return NoneState;
    } else {
        return NoneState;
    }
}

#pragma mark - WHCDownloadDelegate

//得到第一响应并判断要下载的文件是否已经完整下载了
- (void)WHCDownload:(WHC_Download *)download filePath:(NSString *)filePath hasACompleteDownload:(BOOL)has {
    [self.view stopLoading];
    [SVProgressHUD showInfoWithStatus:AddToDownloadQueue maskType:SVProgressHUDMaskTypeNone];
    if (has) {
        [self.view toast:RepeatDownloadTip];
        return;
    }
}

//下载出错
- (void)WHCDownload:(WHC_Download *)download error:(NSError *)error {
    NSMutableDictionary *downloadRecordDict = [NSMutableDictionary dictionaryWithContentsOfFile:_plistPath];
    NSMutableDictionary *dict = downloadRecordDict[download.saveFileName];
    if (dict) {
        [dict setObject:@(DownloadUncompleted) forKey:@"state"];
        [downloadRecordDict setObject:dict forKey:download.saveFileName];
        [downloadRecordDict writeToFile:_plistPath atomically:YES];
    }
    
    [self.view toast:[NSString stringWithFormat:@"%@%@%@",download.tureFileName, DownloadFailure, error]];
    [self.view stopLoading];
}

//更新下载进度
- (void)WHCDownload:(WHC_Download *)download didReceivedLen:(uint64_t)receivedLen totalLen:(uint64_t)totalLen networkSpeed:(NSString *)networkSpeed {
    
    if (self.updateToDownloadingStatus) {
        //NSLog(@"DownloadUncompleted 仅执行一次 刷新tableview 下载中");
        self.updateToDownloadingStatus = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDownLoadStatus" object:nil];
    }
    
    if ((download.totalLen == download.downloadLen) && self.updateToDownloadedStatus) {
        //NSLog(@"DownloadCompleted 仅执行一次 刷新tableview 已下载");
        self.updateToDownloadedStatus = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDownLoadStatus" object:nil];
    }
    
    NSMutableDictionary *downloadRecordDict = [NSMutableDictionary dictionaryWithContentsOfFile:Account.videoFileRecordPath];
    NSMutableDictionary *dict = downloadRecordDict[download.saveFileName];
    CGFloat percent = (CGFloat)(download.downloadLen) / download.totalLen * 100.0;
    if (dict == nil) {
        [downloadRecordDict setObject:@{@"fileName":download.saveFileName,
                                        @"tureFileName":download.tureFileName,
                                        @"currentDownloadLen":[NSString stringWithFormat:@"%.1fMB",((CGFloat)(download.downloadLen) / kWHC_1MB)],
                                        @"totalLen":[NSString stringWithFormat:@"%.1fMB",((CGFloat)(download.totalLen) / kWHC_1MB)],
                                        @"speed":@"0KB/S",
                                        @"processValue":@(percent / 100.0),
                                        @"downPath":download.downPath,
                                        @"state":@((download.totalLen == download.downloadLen) ? DownloadCompleted : DownloadUncompleted)
                                        }.mutableCopy forKey:download.saveFileName];
        [downloadRecordDict writeToFile:Account.videoFileRecordPath atomically:YES];
    } else {
        [dict setObject:([NSString stringWithFormat:@"%.1fMB",((CGFloat)(download.downloadLen) / kWHC_1MB)]).copy forKey:@"currentDownloadLen"];
        [dict setObject:[NSString stringWithFormat:@"%.1fMB",((CGFloat)(download.totalLen) / kWHC_1MB)] forKey:@"totalLen"];
        [dict setObject:@(percent / 100.0) forKey:@"processValue"];
        [dict setObject:@((download.totalLen == download.downloadLen) ? DownloadCompleted : DownloadUncompleted) forKey:@"state"];
        if ([dict[@"downPath"] isEqualToString:@""]) {
            [dict setObject:download.downPath forKey:@"downPath"];
        }
        [downloadRecordDict setObject:dict forKey:download.saveFileName];
        [downloadRecordDict writeToFile:Account.videoFileRecordPath atomically:YES];
    }
}

//下载结束
- (void)WHCDownload:(WHC_Download *)download filePath:(NSString *)filePath isSuccess:(BOOL)success {
    if (success) {
        //        [self.view toast:[NSString stringWithFormat:@"%@%@", download.tureFileName, DownloadSuccess]];
    }
    [self.view stopLoading];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
