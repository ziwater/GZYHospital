//
//  DownloadCompletedTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/8.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "DownloadCompletedTableView.h"

#import "WHC_ClientAccount.h"
#import "WHC_DownloadFileCenter.h"
#import "DownloadObject.h"
#import "UITableView+Improve.h"
#import "SSVideoPlayContainer.h"
#import "SSVideoPlayController.h"

#import "MyDownloadViewController.h"

@interface DownloadCompletedTableView () <UIDocumentInteractionControllerDelegate>

@property (nonatomic, copy) NSString *plistPath;
@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@end

@implementation DownloadCompletedTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self queryDownloadedFile];
    
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    //向通知中心注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableOrDisableDeleteItem:) name:@"enableOrDisableDeleteItem" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryAgainAndRefresh:) name:@"queryAgainAndRefresh" object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 数组初始化

- (NSMutableArray *)downloadedFiles {
    if (!_downloadedFiles) {
        self.downloadedFiles = [NSMutableArray array];
    }
    return _downloadedFiles;
}

- (NSMutableArray *)selectedData {
    if (!_selectedData) {
        _selectedData = [NSMutableArray array];
    }
    return _selectedData;
}

#pragma mark - 通知方法

- (void)enableOrDisableDeleteItem:(NSNotification *)notification {
    if (self.selectedData.count) {
        ((MyDownloadViewController *)self.parentViewController).deleteBarButtonItem.enabled = YES;
    } else {
        ((MyDownloadViewController *)self.parentViewController).deleteBarButtonItem.enabled = NO;
    }
}

- (void)queryAgainAndRefresh:(NSNotificationCenter *)notification {
    [self.downloadedFiles removeAllObjects];    //清空数据源
    
    [self queryDownloadedFile];
    [self.tableView reloadData];
}

#pragma mark - 移除通知

- (void)dealloc {
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"enableOrDisableDeleteItem" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"queryAgainAndRefresh" object:nil];
}

#pragma mark - 查询已下载文件

- (void)queryDownloadedFile {
    [self.downloadedFiles removeAllObjects];    //清空数据源
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
            if (![recordFileName isEqualToString:@".DS_Store"]) {
                NSMutableDictionary *tempDict = downloadRecordDict[recordFileName];
                if (tempDict && ([tempDict[@"state"] integerValue] == DownloadCompleted)) {
                    if (tempDict[@"tureFileName"]) {
                        [self.downloadedFiles addObject:@{recordFileName:tempDict[@"tureFileName"]}];
                    }
                }
            }
        }
    }
}

#pragma mark - UIViewController method

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
    if (editing) {
        self.navigationController.toolbarHidden = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"enableOrDisableDeleteItem" object:nil];
    } else {
        [self.selectedData removeAllObjects];
        self.navigationController.toolbarHidden = YES;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editing) {
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.tableView.editing) {
        NSDictionary *selectedItem = self.downloadedFiles[indexPath.row];
        if (![self.selectedData containsObject:selectedItem]) {
            [self.selectedData addObject:selectedItem];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"enableOrDisableDeleteItem" object:nil];
        }
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSArray *fileComponents = [[self.downloadedFiles[indexPath.row] allKeys].firstObject componentsSeparatedByString:@"."];
        
        if (([fileComponents.lastObject caseInsensitiveCompare:@"mp4"] == NSOrderedSame) || ([fileComponents.lastObject caseInsensitiveCompare:@"mov"] == NSOrderedSame)) {
            NSString *filename = [self.downloadedFiles[indexPath.row] allKeys].firstObject;
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", Account.docFileFolder, filename];
            
            NSArray *paths = @[filePath
                               ];
            NSArray *names = @[filename];
            NSMutableArray *videoList = [NSMutableArray array];
            for (NSInteger i = 0; i<paths.count; i++) {
                SSVideoModel *model = [[SSVideoModel alloc]initWithName:names[i] path:paths[i]];
                [videoList addObject:model];
            }
            SSVideoPlayController *playController = [[SSVideoPlayController alloc]initWithVideoList:videoList];
            SSVideoPlayContainer *playContainer = [[SSVideoPlayContainer alloc]initWithRootViewController:playController];
            [self presentViewController:playContainer animated:NO completion:nil];
        } else {
            NSLog(@"file name ******* %@", [self.downloadedFiles[indexPath.row] allKeys].firstObject);
            NSURL *url = [self fileToURL:[self.downloadedFiles[indexPath.row] allKeys].firstObject];
            NSLog(@"url ===== %@", url);
            
            self.documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
            
            self.documentController.delegate = self;
            self.documentController.UTI = @"com.microsoft.word.doc";
            [self.documentController presentOpenInMenuFromRect:CGRectMake(760, 20, 100, 100) inView:self.view animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableView.editing) {
        NSDictionary *selectedItem = self.downloadedFiles[indexPath.row];
        if ([self.selectedData containsObject:selectedItem]) {
            [self.selectedData removeObject:selectedItem];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"enableOrDisableDeleteItem" object:nil];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloadedFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downloadCompletedCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.downloadedFiles[indexPath.row] allValues].firstObject;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除文件
        NSFileManager *fileManage = [NSFileManager defaultManager];
        NSString *fileName = [self.downloadedFiles[indexPath.row] allKeys].firstObject;
        NSString *filePath = [Account.docFileFolder stringByAppendingPathComponent:fileName];
        NSLog(@"%@", filePath);
        
        if ([fileManage fileExistsAtPath:filePath]) {
            NSLog(@"文件存在");
            [fileManage removeItemAtPath:filePath error:nil];
        }
        
        //删除下载记录文件
        NSMutableDictionary * downloadRecordDict = [NSMutableDictionary dictionaryWithContentsOfFile:_plistPath];
        NSDictionary * tempDict = downloadRecordDict[fileName];
        if(tempDict){
            [downloadRecordDict removeObjectForKey:fileName];
            [downloadRecordDict writeToFile:_plistPath atomically:YES];
        }
        
        [self.downloadedFiles removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //发出通知，更新DownloadingTableView的UI
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDownLoadStatus" object:nil];
    }
}

#pragma mark - fileToURL 文件path转URL

- (NSURL *)fileToURL:(NSString*)filename {
    NSLog(@"%@", filename);
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", Account.docFileFolder, filename];
    
    return [NSURL fileURLWithPath:filePath];
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
