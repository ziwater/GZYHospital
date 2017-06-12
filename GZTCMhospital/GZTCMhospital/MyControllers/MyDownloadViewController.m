//
//  MyDownloadViewController.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/3.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "MyDownloadViewController.h"

#import "WHC_ClientAccount.h"

#import "DownloadingTableView.h"
#import "DownloadCompletedTableView.h"

@interface MyDownloadViewController ()

@property (nonatomic, strong) UIViewController *currentVC;  //当前控制器

@property (nonatomic, strong) DownloadingTableView *downloadingTableView;
@property (nonatomic, strong) DownloadCompletedTableView *downloadCompletedTableView;

@end

@implementation MyDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbarHidden = YES;
    self.deleteBarButtonItem.enabled = NO;
    
    [self.downloadManageSegmented addTarget:self action:@selector(segmentDidChange:) forControlEvents:UIControlEventValueChanged];
    
    [self addController];
    
    self.downloadManageSegmented.selectedSegmentIndex = 0;
    
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = YES;
    self.currentVC.editing = NO;
    self.navigationController.toolbar.hidden = YES;
}

#pragma mark - addController 加载子控制器

- (void)addController {
    self.downloadCompletedTableView = [self.storyboard instantiateViewControllerWithIdentifier:@"downloadCompletedTableView"];
    [self addChildViewController:self.downloadCompletedTableView];
    
    self.downloadingTableView = [self.storyboard instantiateViewControllerWithIdentifier:@"downloadingTableView"];
    
    [self.view addSubview:self.downloadCompletedTableView.view];
    self.currentVC = self.downloadCompletedTableView;
    self.currentVC.parentViewController.navigationItem.rightBarButtonItem = self.downloadCompletedTableView.editButtonItem;
}

#pragma mark - segmentDidChange:

- (void)segmentDidChange:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl *)sender;

    if ((self.currentVC == self.downloadCompletedTableView && segment.selectedSegmentIndex == 0) || (self.currentVC == self.downloadingTableView && segment.selectedSegmentIndex == 1)) {
        return;
    } else {
        switch (segment.selectedSegmentIndex) {
            case 0:
                [self replaceController:self.currentVC toNewController:self.downloadCompletedTableView];
                self.currentVC.parentViewController.navigationItem.rightBarButtonItem = self.downloadCompletedTableView.editButtonItem;
                self.currentVC.editing = NO;
                self.navigationController.toolbar.hidden = YES;
                
                [(DownloadCompletedTableView *)self.currentVC queryDownloadedFile];
                [((DownloadCompletedTableView *)self.currentVC).tableView reloadData];
                break;
            case 1:
                [self replaceController:self.currentVC toNewController:self.downloadingTableView];
                self.currentVC.parentViewController.navigationItem.rightBarButtonItem = nil;
                self.currentVC.editing = NO;
                self.navigationController.toolbar.hidden = YES;
                break;
            default:
                break;
        }
    }
}

- (void)replaceController:(UIViewController *)oldController toNewController:(UIViewController *)newController
{
    /**
     *  transitionFromViewController:toViewController:duration:options:animations:completion:
     *  fromViewController	  当前显示在父视图控制器中的子视图控制器
     *  toViewController	  将要显示的姿势图控制器
     *  duration			  动画时间
     *  options				  动画效果
     *  animations			  转换过程中得动画
     *  completion			  转换完成
     */
    
    [self addChildViewController:newController];
    [self transitionFromViewController:oldController toViewController:newController duration:0.0 options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
        
        if (finished) {
            
            [newController didMoveToParentViewController:self];
            [oldController willMoveToParentViewController:nil];
            [oldController removeFromParentViewController];
            self.currentVC = newController;
            
        } else {
            self.currentVC = oldController;
        }
    }];
    self.currentVC = newController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - deleteItem Action

- (IBAction)deleteItemAction:(UIBarButtonItem *)sender {
    //得到删除的索引数组
    NSMutableArray *indexArray = [NSMutableArray array];
    self.downloadCompletedTableView = (DownloadCompletedTableView *)self.currentVC;
    for (NSDictionary *selectedItem in self.downloadCompletedTableView.selectedData) {
        NSInteger num = [self.downloadCompletedTableView.downloadedFiles indexOfObject:selectedItem];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:num inSection:0];
        [indexArray addObject:indexPath];
    }
    
    //删除文件
    NSFileManager *fileManage = [NSFileManager defaultManager];

    for (NSIndexPath *indexPath in indexArray) {
        NSString *fileName = [self.downloadCompletedTableView.downloadedFiles[indexPath.row] allKeys].firstObject;
        NSString *filePath = [Account.docFileFolder stringByAppendingPathComponent:fileName];
        NSLog(@"%@", filePath);
        
        if ([fileManage fileExistsAtPath:filePath]) {
            NSLog(@"文件存在");
            [fileManage removeItemAtPath:filePath error:nil];
        }
        
        //删除下载记录文件
        NSMutableDictionary * downloadRecordDict = [NSMutableDictionary dictionaryWithContentsOfFile:Account.videoFileRecordPath];
        NSDictionary * tempDict = downloadRecordDict[fileName];
        if(tempDict){
            [downloadRecordDict removeObjectForKey:fileName];
            [downloadRecordDict writeToFile:Account.videoFileRecordPath atomically:YES];
        }
    }
    
    //修改数据模型
    [self.downloadCompletedTableView.downloadedFiles removeObjectsInArray:self.downloadCompletedTableView.selectedData];
    [self.downloadCompletedTableView.selectedData removeAllObjects];
    
    //刷新
    [self.downloadCompletedTableView.tableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
    self.downloadCompletedTableView.editing = NO;
    self.deleteBarButtonItem.enabled = NO;
    
    //发出通知，更新DownloadingTableView的UI
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDownLoadStatus" object:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
