//
//  MemorandumTableView.m
//  GZTCMhospital
//
//  Created by Chris on 16/1/21.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "MemorandumTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "UITableView+Improve.h"
#import "MJRefresh.h"

#import "CheckNetWorkStatus.h"
#import "CommonWebView.h"
#import "MemorandumCell.h"
#import "FormModel.h"
#import "FormSecondModel.h"
#import "FormItemModel.h"
#import "LimitListModel.h"
#import "DeleteResultModel.h"

static const CGFloat delayTime = 1.0;

#define kNumberOfItemsEachLoad 20

@interface MemorandumTableView ()

@property (nonatomic, assign) int more;
@property (nonatomic, copy) NSString *memorandumUrl;
@property (nonatomic, strong) DeleteResultModel *deleteResultModel;

@property (nonatomic, strong) FormModel *formModel;
@property (nonatomic, strong) FormSecondModel *formSecondModel;
@property (nonatomic, strong) LimitListModel *limitListModel;
@property (nonatomic, strong) FormItemModel *formItemModel;

@end

@implementation MemorandumTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.more = 0;
    self.memorandumUrl = [NSString stringWithFormat:@"%@OperatorID=%@&FormID=3524&PageID=1&PageSize=20", MemorandumBaseUrl, GetOperatorID];
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshForAddMemorandum:) name:@"refreshForAddMemorandum" object:nil];
    
    [self setupRefresh]; //集成刷新控件
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 数组对象初始化

- (NSMutableArray *)formItemModels {
    if (!_formItemModels) {
        self.formItemModels = [NSMutableArray array];
    }
    return _formItemModels;
}

- (NSMutableArray *)moreUrlArray {
    if (!_moreUrlArray) {
        self.moreUrlArray = [NSMutableArray array];
    }
    return _moreUrlArray;
}

#pragma mark - NSNotificationCenter 通知方法

- (void)refreshForAddMemorandum:(NSNotificationCenter *)notification {
    [self setupRefresh];
}

#pragma mark - 销毁通知

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshForAddMemorandum" object:nil];
}

#pragma mark - MJRefresh 集成刷新控件

- (void)setupRefresh { //集成刷新控件
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadNewData];
    }];
    [self.tableView.header beginRefreshing];
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData];
    }];
    
    // 默认先隐藏footer
    self.tableView.footer.hidden = YES;
}

- (void)loadNewData { //下拉刷新数据    
    [self loadNetworkData:self.memorandumUrl withType:@"dropDownRefresh"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
    });
}

- (void)loadMoreData { //上拉加载更多数据;
    if (self.moreUrlArray.count) {
        if (_more < self.moreUrlArray.count) {
            self.moreURL = self.moreUrlArray[_more];
            [self loadNetworkData:self.moreURL withType:@"pullToRefresh"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            _more++;
        } else {
            // 所有数据已经全部加载完，变为没有更多数据的状态
            [self.tableView.footer noticeNoMoreData];
        }
    } else {
        // count=0，没有数据，变为没有更多数据的状态
        [self.tableView.footer noticeNoMoreData];
    }
}

#pragma mark - loadNetworkData: 加载网络数据

- (void)loadNetworkData:(NSString *) url withType:(NSString *) type {
    if (url) {
        [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
            AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
            
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                self.formModel = [FormModel objectWithKeyValues:responseObject];
                self.formSecondModel = self.formModel.List;
                self.limitListModel = self.formSecondModel.LimitList.firstObject;
                
                if ([type isEqualToString:@"dropDownRefresh"]) {
                    self.more = 0;
                    [self.formItemModels removeAllObjects];
                    [self.moreUrlArray removeAllObjects];
                }
                
                [self.formItemModels addObjectsFromArray:self.formSecondModel.DataList];
                
                if ([type isEqualToString:@"dropDownRefresh"]) {
                    for (NSInteger i = 2; i <= (long)ceilf((float)self.formModel.Count / kNumberOfItemsEachLoad); i++) {
                        
                        NSString *newPageID = [NSString stringWithFormat:@"PageID=%ld", (long)i];
                        self.moreURL = [url stringByReplacingOccurrencesOfString:@"PageID=1" withString:newPageID];
                        [self.moreUrlArray addObject:self.moreURL];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
                
                [self.tableView.header endRefreshing];
                [self.tableView.footer endRefreshing];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self.tableView.header endRefreshing];
                NSLog(@"Error: %@", error);
            }];
        } andWithFaildBlokc:^{
            [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
            [self.tableView.header endRefreshing];
            [self.tableView.footer endRefreshing];
        }];
    } else {
        NSLog(@"url 为null！！！");
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 11;
    }
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.formItemModels.count - 1) {
        return 10;
    }
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    self.formItemModel = self.formItemModels[indexPath.section];
    
    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&OperatorID=%@&ActionType=SubmitedView", BrowseBaseUrl, self.formItemModel.FormID, self.formItemModel.DetailID, GetOperatorID];
    
    webVC.linkUrl = url;
    
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 设置尾部控件的显示和隐藏
    self.tableView.footer.hidden = self.formItemModels.count == 0;
    return self.formItemModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.formItemModel = self.formItemModels[indexPath.section];
    MemorandumCell *memorandumCell = [tableView dequeueReusableCellWithIdentifier:@"memorandumCell" forIndexPath:indexPath];
     memorandumCell.memorandumTitle.text = self.formItemModel.Title;
     memorandumCell.memorandumCreateTime.text = [self.formItemModel.CreateDateTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
     return memorandumCell;
 }

#pragma mark - Action method

- (IBAction)modifyMemorandumAction:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    self.formItemModel = self.formItemModels[selectedIndexPath.section];
    
    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&OperatorID=%@&ActionType=SubmitedModify", ModifyBaseUrl, self.formItemModel.FormID, self.formItemModel.DetailID, GetOperatorID];
    
    webVC.linkUrl = url;
    webVC.refreshForAdd = YES;
    
    [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)deleteMemorandumAction:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    self.formItemModel = self.formItemModels[selectedIndexPath.section];

    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&OperatorID=%@", DeleteBaseUrl, self.formItemModel.FormID, self.formItemModel.DetailID, GetOperatorID];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:KindlyRemind message:DeleteComfirmTip preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:SheetCancel style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:DeleteButtonTip style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
            AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
            
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                self.deleteResultModel = [DeleteResultModel objectWithKeyValues:responseObject];
                
                if ([self.deleteResultModel.ResultID isEqualToString:@"1"]) {
                    [self.formItemModels removeObjectAtIndex:selectedIndexPath.section];
                    
                    [SVProgressHUD showInfoWithStatus: self.deleteResultModel.ResultMessage maskType:SVProgressHUDMaskTypeNone];
                    
                    [self.tableView reloadData];
                }
            } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                NSLog(@"Error: %@", error);
            }];
        } andWithFaildBlokc:^{
            [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)addMemorandumAction:(UIBarButtonItem *)sender {
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    
    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=0&OperatorID=%@&ActionType=Add", ModifyBaseUrl, self.formModel.FormID, GetOperatorID];
    
    webVC.linkUrl = url;
    webVC.refreshForAdd = YES;
    
    [self.navigationController pushViewController:webVC animated:YES];
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
