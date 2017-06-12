//
//  OrderResultTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/23.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "OrderResultTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "UITableView+Improve.h"

#import "CheckNetWorkStatus.h"
#import "OrderListModel.h"
#import "OrderResultModel.h"
#import "LimitListModel.h"
#import "OrderResultItemModel.h"
#import "OrderResultCell.h"
#import "CommonWebView.h"
#import "DeleteResultModel.h"

static const CGFloat delayTime = 1.5;

#define kNumberOfItemsEachLoad 20

@interface OrderResultTableView ()

@property (nonatomic, assign) int more;

@property (nonatomic, strong) DeleteResultModel *deleteResultModel;

@property (nonatomic, strong) OrderListModel *orderListModel;
@property (nonatomic, strong) OrderResultModel *orderResultModel;
@property (nonatomic, strong) LimitListModel *limitListModel;
@property (nonatomic, strong) OrderResultItemModel *orderResultItemModel;

@property (nonatomic, copy) NSString *patientNameTip;
@property (nonatomic, copy) NSString *orderIDTip;
@property (nonatomic, copy) NSString *orderStatusTip;
@property (nonatomic, copy) NSString *treatmentDataTip;
@property (nonatomic, copy) NSString *treatmentTimeTip;
@property (nonatomic, copy) NSString *registrationFreeTip;
@property (nonatomic, copy) NSString *IDcardTip;
@property (nonatomic, copy) NSString *registrationTypeTip;
@property (nonatomic, copy) NSString *specialistTip;
@property (nonatomic, copy) NSString *departmentTip;
@property (nonatomic, copy) NSString *doctorNameTip;
@property (nonatomic, copy) NSString *createStafferNameTip;
@property (nonatomic, copy) NSString *createdDateTip;

@end

@implementation OrderResultTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.more = 0;
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    //通知中心注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAddOrderItem:) name:@"showAddOrderItem" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshForAddOrder:) name:@"refreshForAddOrder" object:nil];
    
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

- (NSMutableArray *)orderResultItemModels {
    if (!_orderResultItemModels) {
        self.orderResultItemModels = [NSMutableArray array];
    }
    return _orderResultItemModels;
}

- (NSMutableArray *)moreUrlArray {
    if (!_moreUrlArray) {
        self.moreUrlArray = [NSMutableArray array];
    }
    return _moreUrlArray;
}

#pragma mark - NSNotificationCenter 通知方法

- (void)showAddOrderItem:(NSNotification *)notification {

    if ([self.addDepartmentOrderIdentify isEqualToString:@"addDepartmentOrderIdentify"]) {
        self.parentViewController.navigationItem.rightBarButtonItem = self.addOrderItem;
    } else {
        self.navigationItem.rightBarButtonItem = self.addOrderItem;
    }
}

- (void)refreshForAddOrder:(NSNotificationCenter *)notification {
    [self setupRefresh];
}

#pragma mark - 销毁通知

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showAddOrderItem" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshForAddOrder" object:nil];
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
    [self loadNetworkData:self.orderResultUrl withType:@"dropDownRefresh"];
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
                self.orderListModel = [OrderListModel objectWithKeyValues:responseObject];
                self.orderResultModel = self.orderListModel.List;
                self.limitListModel = self.orderResultModel.LimitList.firstObject;
                
                if (self.limitListModel.IsCreate == 1) { //通知显示增加barItem
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAddOrderItem" object:nil];
                }
                
                NSString *originalFieldDescString = [self.orderListModel.List.FieldsRemark.firstObject valueForKeyPath:@"FieldDesc"];
                NSString *fieldDescString = [originalFieldDescString substringToIndex:originalFieldDescString.length - 1]; //去除最后一分号
                NSArray *fieldDescArray = [fieldDescString componentsSeparatedByString:@";"];
                
                for (NSString *filterString in fieldDescArray) {
                    NSArray *filterArray = [filterString componentsSeparatedByString:@","];
                    NSString *filterKey = filterArray[0];
                    NSString *filterValue = filterArray[1];
                    
                    if ([filterKey isEqualToString:@"F4"]) {
                        self.patientNameTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F5"]) {
                        self.IDcardTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F14"]) {
                        self.orderIDTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F16"]) {
                        self.treatmentDataTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F17"]) {
                        self.treatmentTimeTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F18"]) {
                        self.departmentTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F19"]) {
                        self.doctorNameTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F20"]) {
                        self.specialistTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F21"]) {
                        self.registrationTypeTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F22"]) {
                        self.registrationFreeTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F142"]) {
                        self.orderStatusTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"CreateStafferName"]) {
                        self.createStafferNameTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"Info_CreatedDate"]) {
                        self.createdDateTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                }
                
                if ([type isEqualToString:@"dropDownRefresh"]) {
                    self.more = 0;
                    [self.orderResultItemModels removeAllObjects];
                    [self.moreUrlArray removeAllObjects];
                }
                
                [self.orderResultItemModels addObjectsFromArray:self.orderResultModel.DataList];
                
                if ([type isEqualToString:@"dropDownRefresh"]) {
                    for (NSInteger i = 2; i <= (long)ceilf((float)self.orderListModel.Count / kNumberOfItemsEachLoad); i++) {
                        
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
    if (section == self.orderResultItemModels.count - 1) {
        return 10;
    }
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    self.orderResultItemModel = self.orderResultItemModels[indexPath.section];
    
    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&OperatorID=%@&ActionType=SubmitedView", BrowseBaseUrl, self.orderResultItemModel.info_formoid, self.orderResultItemModel.Info_oid, GetOperatorID];
    
    webVC.linkUrl = url;
    
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 设置尾部控件的显示和隐藏
    self.tableView.footer.hidden = self.orderResultItemModels.count == 0;
    
    return self.orderResultItemModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.orderResultItemModel = self.orderResultItemModels[indexPath.section];
    
    OrderResultCell *orderResultCell = [tableView dequeueReusableCellWithIdentifier:@"orderResultCell" forIndexPath:indexPath];
    orderResultCell.patientNameLabel.text = self.orderResultItemModel.F4;
    orderResultCell.orderIDTipLabel.text = self.orderIDTip;
    orderResultCell.orderIDLabel.text = self.orderResultItemModel.F14;
    orderResultCell.orderStatusTipLabel.text = self.orderStatusTip;
    orderResultCell.orderStatusLabel.text = self.orderResultItemModel.F142;
    
    orderResultCell.treatmentDataTipLabel.text = self.treatmentDataTip;
    orderResultCell.treatmentDataLabel.text = self.orderResultItemModel.F16;
    orderResultCell.treatmentTimeTipLabel.text = self.treatmentTimeTip;
    orderResultCell.treatmentTimeLabel.text = self.orderResultItemModel.F17;
    orderResultCell.registrationFeeTipLabel.text = self.registrationFreeTip;
    orderResultCell.registrationFreeLabel.text = self.orderResultItemModel.F22;
    
    orderResultCell.IDcardTipLabel.text = self.IDcardTip;
    orderResultCell.IDcardLabel.text = self.orderResultItemModel.F5;
    orderResultCell.registrationTypeTipLabel.text = self.registrationTypeTip;
    orderResultCell.registrationTypeLabel.text = self.orderResultItemModel.F21;
    
    orderResultCell.specialistTipLabel.text = self.specialistTip;
    orderResultCell.specialistLabel.text = self.orderResultItemModel.F20;
    orderResultCell.departmentTipLabel.text = self.departmentTip;
    orderResultCell.departmentLabel.text = self.orderResultItemModel.F18;
    
    orderResultCell.doctorNameTipLabel.text = self.doctorNameTip;
    orderResultCell.doctorNameLabel.text = self.orderResultItemModel.F19;
    
    orderResultCell.createStafferNameTipLabel.text = self.createStafferNameTip;
    orderResultCell.createStafferNameLabel.text = self.orderResultItemModel.CreateStafferName;
    
    orderResultCell.createTimeTipLabel.text = self.createdDateTip;
    orderResultCell.createTimeLabel.text = self.orderResultItemModel.Info_CreatedDate;
    
    if ((self.limitListModel.IsModify == 0 && self.limitListModel.IsDelete == 0)) { //无相应的操作权限则动态移除操作面板
        [orderResultCell.modifyOrderButton removeFromSuperview];
        [orderResultCell.deleteOrderButton removeFromSuperview];
        
        id bottomConstraints = [NSLayoutConstraint constraintWithItem:orderResultCell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:orderResultCell.separateView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        [orderResultCell.contentView addConstraints:@[bottomConstraints]];
    } else if (self.limitListModel.IsModify == 0) {
        [orderResultCell.modifyOrderButton removeFromSuperview];
        id trailingConstraints = [NSLayoutConstraint constraintWithItem:orderResultCell.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:orderResultCell.deleteOrderButton attribute:NSLayoutAttributeTrailing multiplier:1 constant:15];
        
        [orderResultCell.contentView addConstraints:@[trailingConstraints]];
    } else if (self.limitListModel.IsDelete == 0) {
        [orderResultCell.deleteOrderButton removeFromSuperview];
    }
    
    return orderResultCell;
}

#pragma mark - button Action method

- (IBAction)orderModifyAction:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    self.orderResultItemModel = self.orderResultItemModels[selectedIndexPath.section];
    
    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&ActionType=SubmitedModify&OperatorID=%@", ModifyBaseUrl, self.orderResultItemModel.info_formoid, self.orderResultItemModel.Info_oid, GetOperatorID];
    
    webVC.linkUrl = url;
    webVC.refreshForAdd = YES;
    
    [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)orderDeleteAction:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    self.orderResultItemModel = self.orderResultItemModels[selectedIndexPath.section];
    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&OperatorID=%@", DeleteBaseUrl, self.orderResultItemModel.info_formoid, self.orderResultItemModel.Info_oid, GetOperatorID];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:KindlyRemind message:DeleteComfirmTip preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:SheetCancel style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:DeleteButtonTip style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
            AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
            
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                self.deleteResultModel = [DeleteResultModel objectWithKeyValues:responseObject];
                
                if ([self.deleteResultModel.ResultID isEqualToString:@"1"]) {
                    [self.orderResultItemModels removeObjectAtIndex:selectedIndexPath.section];
                    [SVProgressHUD showInfoWithStatus: self.deleteResultModel.ResultMessage maskType:SVProgressHUDMaskTypeNone];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
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

- (IBAction)orderAddAction:(UIBarButtonItem *)sender {
    
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    
    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=0&OperatorID=%@&ActionType=Add", ModifyBaseUrl, self.orderListModel.FormID, GetOperatorID];
    
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
