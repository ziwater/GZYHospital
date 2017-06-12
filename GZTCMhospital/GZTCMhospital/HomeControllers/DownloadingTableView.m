//
//  DownloadingTableView.m
//  Download
//
//  Created by Chris on 15/12/8.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "DownloadingTableView.h"

#import "WHC_ClientAccount.h"
#import "WHC_DownloadFileCenter.h"
#import "DownloadObject.h"
#import "UITableView+Improve.h"

#import "DownloadingCell.h"

@interface DownloadingTableView ()

@property (nonatomic, strong) NSMutableArray *fileObjectArr;  //慢病宣教文件数组
@property (nonatomic, copy) NSString *plistPath;

@end

@implementation DownloadingTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    //通知中心注册通知
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(removeDownloadedCell:) name:@"removeDownloadedCell" object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Account saveDownloadRecord];
//    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - removeDownloadedCell 通知方法

- (void)removeDownloadedCell:(NSNotification *)notification {
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)notification.object];
    [_fileObjectArr removeObjectAtIndex:selectedIndexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)dealloc {
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeDownloadedCell" object:nil];
}

- (void)initData {
    _plistPath = Account.videoFileRecordPath;
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:_plistPath]){
        [fm createFileAtPath:_plistPath contents:nil attributes:nil];
        [@{}.mutableCopy writeToFile:_plistPath atomically:YES];
    }
    [WHCDownloadCenter replaceCurrentDownloadDelegate:self];
    _fileObjectArr = [NSMutableArray array];
    NSMutableDictionary * downloadRecordDict = [NSMutableDictionary dictionaryWithContentsOfFile:_plistPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *fileArr = [[fileManager contentsOfDirectoryAtPath:Account.docFileFolder error:&error] mutableCopy];
    if (fileArr) {
        for (NSInteger i = 0; i < fileArr.count; i++) {
            NSString *fileName = fileArr[i];
            if (![fileName isEqualToString:@".DS_Store"]) {
                DownloadObject *object = [DownloadObject new];
                NSMutableDictionary *tempDict = downloadRecordDict[fileName];
                uint64_t fileSize = [[fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@%@",Account.docFileFolder,fileName] error:&error] fileSize];
                NSString *strCurrentLen = [NSString stringWithFormat:@"%.1fMB",((CGFloat)(fileSize) / kWHC_1MB)];
                if (tempDict) {
                    object.fileName = tempDict[@"fileName"];
                    object.tureFileName = tempDict[@"tureFileName"];
                    object.processValue = [[strCurrentLen componentsSeparatedByString:@"MB"].firstObject doubleValue] / [(NSString *)[tempDict[@"totalLen"] componentsSeparatedByString:@"MB"].firstObject doubleValue];
                    object.currentDownloadLen = [NSString stringWithFormat:@"%.1fMB",((CGFloat)(fileSize) / kWHC_1MB)];
                    object.totalLen = tempDict[@"totalLen"];
                    object.speed = [tempDict[@"totalLen"] isEqualToString:tempDict[@"currentDownloadLen"]] ? CompleteStatus : SuspendStatus;
                    object.downPath = tempDict[@"downPath"];
                    object.state = [tempDict[@"totalLen"] isEqualToString:strCurrentLen] ? DownloadCompleted : DownloadUncompleted;
                    [tempDict setObject:@(object.processValue) forKey:@"processValue"];
                    [tempDict setObject:strCurrentLen forKey:@"currentDownloadLen"];
                    [tempDict setObject:@(object.state) forKey:@"state"];
                    [downloadRecordDict setObject:tempDict forKey:fileName];
                } else {
                    object.fileName = fileName;
                    object.processValue = 0;
                    object.currentDownloadLen = strCurrentLen;
                    object.totalLen = [NSString stringWithFormat:@"%.1fMB",((CGFloat)(fileSize) / kWHC_1MB)];
                    object.speed = SuspendStatus;
                    object.state = DownloadCompleted;
                    object.downPath = @"";
                    [downloadRecordDict setObject:@{@"fileName":fileName,
                                                    @"currentDownloadLen":object.currentDownloadLen,
                                                    @"totalLen":object.totalLen,
                                                    @"speed":@"0KB/S",
                                                    @"processValue":@(1.0),
                                                    @"downPath":object.downPath,
                                                    @"state":@(DownloadCompleted)}.mutableCopy forKey:fileName];
                }
                [downloadRecordDict writeToFile:_plistPath atomically:YES];
                if (object.state != DownloadCompleted) {
                    [_fileObjectArr addObject:object];
                }
            }
        }
    }
    NSArray *downloadArr = [WHCDownloadCenter downloadList];
    for (WHC_Download *download in downloadArr) {
        if (download.downloading == NO) {  //等待下载
            DownloadObject *object = [DownloadObject new];
            object.fileName = download.saveFileName;
            object.tureFileName = download.tureFileName;
            object.processValue = 0.0;
            object.currentDownloadLen = @"0MB";
            object.totalLen = @"0MB";
            object.speed = WaitingStatus;
            object.state = DownloadWaitting;
            object.downPath = download.downPath;
            [_fileObjectArr addObject:object];
        }
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fileObjectArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    DownloadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downloadingCell" forIndexPath:indexPath];
     DownloadObject * object = _fileObjectArr[indexPath.row];
    [WHCDownloadCenter replaceCurrentDownloadDelegate:cell fileName:object.fileName];
    cell.fileObjectArr = _fileObjectArr;
    [cell displayCell:_fileObjectArr[indexPath.row]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadObject *object = _fileObjectArr[indexPath.row];
    
    //删除文件
    NSFileManager *fileManage = [NSFileManager defaultManager];
    NSString *filePath = [Account.docFileFolder stringByAppendingPathComponent:object.fileName];
    
    if ([fileManage fileExistsAtPath:filePath]) {
        [fileManage removeItemAtPath:filePath error:nil];
    }
    
    //删除下载记录文件
    NSMutableDictionary * downloadRecordDict = [NSMutableDictionary dictionaryWithContentsOfFile:_plistPath];
    NSDictionary *tempDict = downloadRecordDict[object.fileName];
    if(tempDict){
        [downloadRecordDict removeObjectForKey:object.fileName];
        [downloadRecordDict writeToFile:_plistPath atomically:YES];
    }
    
    //删除数据源数据，刷新tableView
    [WHCDownloadCenter cancelDownloadWithFileName:object.fileName delFile:YES];
    [_fileObjectArr removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    //发出通知，更新DownloadingTableView的UI
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDownLoadStatus" object:nil];
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
