//
//  ScheduleTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/29.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "ScheduleTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "UITableView+Improve.h"

#import "CheckNetWorkStatus.h"
#import "ScheduleListModel.h"
#import "ScheduleModel.h"
#import "ScheduleItemModel.h"
#import "LimitListModel.h"
#import "CommonWebView.h"
#import "ScheduleCell.h"
#import "DeleteResultModel.h"

static const CGFloat delayTime = 1.5;

#define kNumberOfItemsEachLoad 20

@interface ScheduleTableView ()

@property (nonatomic, assign) int more;

@property (nonatomic, strong) DeleteResultModel *deleteResultModel;

@property (nonatomic, strong) ScheduleListModel *scheduleListModel;
@property (nonatomic, strong) ScheduleModel *scheduleModel;
@property (nonatomic, strong) LimitListModel *limitListModel;
@property (nonatomic, strong) ScheduleItemModel *scheduleItemModel;

@property (nonatomic, copy) NSString *patientNameTip;
@property (nonatomic, copy) NSString *scheduleNameTip;
@property (nonatomic, copy) NSString *beginDateTip;
@property (nonatomic, copy) NSString *beginTimeTip;
@property (nonatomic, copy) NSString *scheduleCategoryTip;
@property (nonatomic, copy) NSString *IDcardTip;

@end

@implementation ScheduleTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.more = 0;
    
    //通知中心注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAddScheduleItem:) name:@"showAddScheduleItem" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshForAddSchedule:) name:@"refreshForAddSchedule" object:nil];
    
    [self setupRefresh]; //集成刷新控件
    
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - NSNotificationCenter 通知方法

- (void)showAddScheduleItem:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem = self.addScheduleItem;
}

- (void)refreshForAddSchedule:(NSNotificationCenter *)notification {
    [self setupRefresh];
}

#pragma mark - 销毁通知

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showAddScheduleItem" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshForAddSchedule" object:nil];
}

#pragma mark - 数组对象初始化

- (NSMutableArray *)scheduleItemModels {
    if (!_scheduleItemModels) {
        self.scheduleItemModels = [NSMutableArray array];
    }
    return _scheduleItemModels;
}

- (NSMutableArray *)moreUrlArray {
    if (!_moreUrlArray) {
        self.moreUrlArray = [NSMutableArray array];
    }
    return _moreUrlArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self loadNetworkData:self.scheduleUrl withType:@"dropDownRefresh"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)loadMoreData { //上拉加载更多数据
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
                self.scheduleListModel = [ScheduleListModel objectWithKeyValues:responseObject];
                self.scheduleModel = self.scheduleListModel.List;
                self.limitListModel = self.scheduleModel.LimitList.firstObject;
                
                if (self.limitListModel.IsCreate == 1) { //通知显示增加barItem
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAddScheduleItem" object:nil];
                }
                
                NSString *originalFieldDescString = [self.scheduleListModel.List.FieldsRemark.firstObject valueForKeyPath:@"FieldDesc"];
                NSString *fieldDescString = [originalFieldDescString substringToIndex:originalFieldDescString.length - 1]; //去除最后一分号
                NSArray *fieldDescArray = [fieldDescString componentsSeparatedByString:@";"];
                
                for (NSString *filterString in fieldDescArray) {
                    NSArray *filterArray = [filterString componentsSeparatedByString:@","];
                    NSString *filterKey = filterArray[0];
                    NSString *filterValue = filterArray[1];
                    
                    if ([filterKey isEqualToString:@"F134"]) {
                        self.patientNameTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F140"]) {
                        self.IDcardTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F149"]) {
                        self.scheduleNameTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F138"]) {
                        self.beginDateTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F139"]) {
                        self.beginTimeTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F128"]) {
                        self.scheduleCategoryTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                }
                
                if ([type isEqualToString:@"dropDownRefresh"]) {
                    self.more = 0;
                    [self.scheduleItemModels removeAllObjects];
                    [self.moreUrlArray removeAllObjects];
                }
                
                [self.scheduleItemModels addObjectsFromArray:self.scheduleModel.DataList];
                
                if ([type isEqualToString:@"dropDownRefresh"]) {
                    for (NSInteger i = 2; i <= (long)ceilf((float)self.scheduleListModel.Count / kNumberOfItemsEachLoad); i++) {
                        
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
    if (section == self.scheduleItemModels.count - 1) {
        return 10;
    }
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    self.scheduleItemModel = self.scheduleItemModels[indexPath.section];
    
    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&OperatorID=%@&ActionType=SubmitedView", BrowseBaseUrl, self.scheduleItemModel.info_formoid, self.scheduleItemModel.Info_oid, GetOperatorID];
    
    webVC.linkUrl = url;
    
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 设置尾部控件的显示和隐藏
    self.tableView.footer.hidden = self.scheduleItemModels.count == 0;
    
    return self.scheduleItemModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.scheduleItemModel = self.scheduleItemModels[indexPath.section];
    
    ScheduleCell *scheduleCell = [tableView dequeueReusableCellWithIdentifier:@"scheduleCell" forIndexPath:indexPath];
    
    scheduleCell.patientNameTipLabel.text = self.patientNameTip;
    scheduleCell.patientNameLabel.text = self.scheduleItemModel.F134;
    
    if ([self.scheduleItemModel.F130 isEqualToString:UnHandled]) {
        scheduleCell.whetherHandleLabel.textColor = [UIColor redColor];
    } else if ([self.scheduleItemModel.F130 isEqualToString:Handled]){
        scheduleCell.whetherHandleLabel.textColor = RGBColor(0, 194, 155);
    } else {
        scheduleCell.whetherHandleLabel.textColor = [UIColor orangeColor];
    }
    
    scheduleCell.whetherHandleLabel.text = self.scheduleItemModel.F130;
    
    scheduleCell.scheduleNameTipLabel.text = self.scheduleNameTip;
    scheduleCell.scheduleNameLabel.text = self.scheduleItemModel.F149;
    
    scheduleCell.beginDateTipLabel.text = self.beginDateTip;
    scheduleCell.beginDateLabel.text = self.scheduleItemModel.F138;
    scheduleCell.beginTimeTipLabel.text = self.beginTimeTip;
    scheduleCell.beginTimeLabel.text = self.scheduleItemModel.F139;
    
    scheduleCell.scheduleCategoryTipLabel.text = self.scheduleCategoryTip;
    scheduleCell.scheduleCategoryLabel.text = self.scheduleItemModel.F128;
    
    scheduleCell.IDCardTipLabel.text = self.IDcardTip;
    scheduleCell.IDCardLabel.text = self.scheduleItemModel.F140;
    
    if ((self.limitListModel.IsModify == 0 && self.limitListModel.IsDelete == 0)) { //无相应的操作权限则动态移除操作面板
        [scheduleCell.modifyScheduleButton removeFromSuperview];
        [scheduleCell.deleteScheduleButton removeFromSuperview];
        
        id bottomConstraints = [NSLayoutConstraint constraintWithItem:scheduleCell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:scheduleCell.separateView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        [scheduleCell.contentView addConstraints:@[bottomConstraints]];
    } else if (self.limitListModel.IsModify == 0) {
        [scheduleCell.modifyScheduleButton removeFromSuperview];
        id trailingConstraints = [NSLayoutConstraint constraintWithItem:scheduleCell.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:scheduleCell.deleteScheduleButton attribute:NSLayoutAttributeTrailing multiplier:1 constant:15];
        
        [scheduleCell.contentView addConstraints:@[trailingConstraints]];
    } else if (self.limitListModel.IsDelete == 0) {
        [scheduleCell.deleteScheduleButton removeFromSuperview];
    }
    
    return scheduleCell;
}

#pragma mark - button Action method

- (IBAction)addScheduleAction:(UIBarButtonItem *)sender {
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=0&ActionType=Add&OperatorID=%@", ModifyBaseUrl, self.scheduleListModel.FormID, GetOperatorID];
    
    webVC.linkUrl = url;
    webVC.refreshForAdd = YES;
    
    [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)modifyScheduleAction:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    self.scheduleItemModel = self.scheduleItemModels[selectedIndexPath.section];
    
    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&ActionType=SubmitedModify&OperatorID=%@", ModifyBaseUrl, self.scheduleItemModel.info_formoid, self.scheduleItemModel.Info_oid, GetOperatorID];
    
    webVC.linkUrl = url;
    webVC.refreshForAdd = YES;
    
    [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)deleteScheduleAction:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    self.scheduleItemModel = self.scheduleItemModels[selectedIndexPath.section];
    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&OperatorID=%@", DeleteBaseUrl, self.scheduleItemModel.info_formoid, self.scheduleItemModel.Info_oid, GetOperatorID];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:KindlyRemind message:DeleteComfirmTip preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:SheetCancel style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:DeleteButtonTip style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
            AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
            
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                self.deleteResultModel = [DeleteResultModel objectWithKeyValues:responseObject];
                
                if ([self.deleteResultModel.ResultID isEqualToString:@"1"]) {
                    [self.scheduleItemModels removeObjectAtIndex:selectedIndexPath.section];
                    
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
