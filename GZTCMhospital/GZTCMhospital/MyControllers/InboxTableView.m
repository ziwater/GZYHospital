//
//  InboxTableView.m
//  GZTCMhospital
//
//  Created by Chris on 16/3/1.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "InboxTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "UITableView+Improve.h"

#import "CheckNetWorkStatus.h"
#import "MailModel.h"
#import "InboxCell.h"
#import "InformationWebView.h"
#import "DeleteResultModel.h"

static const CGFloat delayTime = 0.0;

#define kNumberOfItemsEachLoad 20

@interface InboxTableView ()

@property (nonatomic, copy) NSString *moreURL;
@property (nonatomic, assign) int more;
@property (nonatomic, copy) NSString *mailUrl;
@property (nonatomic, strong) NSMutableArray *moreUrlArray;  //存moreUrl的数组
@property (nonatomic, strong) NSMutableArray *mailModels; //存MailModel的数组
@property (nonatomic, strong) MailModel *mailModel;
@property (nonatomic, strong) DeleteResultModel *deleteResultModel;

@end

@implementation InboxTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.more = 0;
    
    NSString *urlString = nil;
    if ([self.inboxOrOutboxIndentifier isEqualToString:@"inbox"]) {
        urlString = [NSString stringWithFormat:@"%@StafferName=%@&OperatorID=%@&PageID=1&PageSize=20", InboxBaseUrl, GetStafferName, GetOperatorID];
    }
    if ([self.inboxOrOutboxIndentifier isEqualToString:@"outbox"]) {
        urlString = [NSString stringWithFormat:@"%@StafferName=%@&OperatorID=%@&PageID=1&PageSize=20", OutboxBaseUrl, GetStafferName, GetOperatorID];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.mailUrl = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    } else {
        self.mailUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
}

#pragma mark - 数组对象初始化

- (NSMutableArray *)mailModels {
    if (!_mailModels) {
        self.mailModels = [NSMutableArray array];
    }
    return _mailModels;
}

- (NSMutableArray *)moreUrlArray {
    if (!_moreUrlArray) {
        self.moreUrlArray = [NSMutableArray array];
    }
    return _moreUrlArray;
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
    [self loadNetworkData:self.mailUrl withType:@"dropDownRefresh"];
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

#pragma mark - loadNetworkData: 加载收件箱列表数据

- (void)loadNetworkData:(NSString *) url withType:(NSString *) type {
    if (url) {
        [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
            AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
            
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                if ([type isEqualToString:@"dropDownRefresh"]) {
                    self.more = 0;
                    [self.mailModels removeAllObjects];
                    [self.moreUrlArray removeAllObjects];
                }
                
                [self.mailModels addObjectsFromArray:[MailModel objectArrayWithKeyValuesArray:[responseObject valueForKeyPath:@"List"]]];
                
                if ([type isEqualToString:@"dropDownRefresh"]) {
                    for (NSInteger i = 2; i <= (long)ceilf((float)[[responseObject valueForKeyPath:@"Count"] intValue] / kNumberOfItemsEachLoad); i++) {
                        
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
    if (section == self.mailModels.count - 1) {
        return 10;
    }
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InformationWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"informationWebView"];
    self.mailModel = self.mailModels[indexPath.section];
    
    webVC.mailIdentifier = @"mail";
    webVC.mailModel = self.mailModel;
    webVC.title = self.mailModel.Title;
    
    [self.navigationController pushViewController:webVC animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 设置尾部控件的显示和隐藏
    self.tableView.footer.hidden = self.mailModels.count == 0;
    return self.mailModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InboxCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inboxCell" forIndexPath:indexPath];
    self.mailModel = self.mailModels[indexPath.section];
    
    cell.sendTimeLabel.text = self.mailModel.SendTime;
    cell.inboxTitleLabel.text = self.mailModel.Title;
    
    if ([self.inboxOrOutboxIndentifier isEqualToString:@"inbox"]) {
        cell.senderLabel.text = self.mailModel.Sender;
    } else {
        cell.senderLabel.text = self.mailModel.Receiver;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //一般情况下，先更新数据源，再插入或者删除
        self.mailModel = self.mailModels[indexPath.section];
        
        NSString *url= nil;
        NSString *urlString = [NSString stringWithFormat:@"%@OperatorID=%@&IDs=%@&StafferName=%@", DeleteMailBaseUrl, GetOperatorID, self.mailModel.MessageID, GetStafferName];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            url = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        } else {
            url = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
            AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
            
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                self.deleteResultModel = [DeleteResultModel objectWithKeyValues:responseObject];
                
                if ([self.deleteResultModel.ResultID isEqualToString:@"1"]) {
                    [self.mailModels removeObjectAtIndex:indexPath.section];
                    
                    [SVProgressHUD showInfoWithStatus: self.deleteResultModel.ResultMessage maskType:SVProgressHUDMaskTypeNone];
                    
                    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                    
                    [self.tableView reloadData];
                }
            } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                NSLog(@"Error: %@", error);
            }];
        } andWithFaildBlokc:^{
            [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
        }];
    }
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
