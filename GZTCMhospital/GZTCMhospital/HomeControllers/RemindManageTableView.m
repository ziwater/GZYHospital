//
//  RemindManageTableView.m
//  GZTCMhospital
//
//  Created by Chris on 16/1/7.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "RemindManageTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "UITableView+Improve.h"

#import "CheckNetWorkStatus.h"
#import "CommonWebView.h"
#import "TreatmentPlanListModel.h"
#import "TreatmentPlanModel.h"
#import "TreatmentPlanItemModel.h"
#import "LimitListModel.h"
#import "RemindManageCell.h"
#import "DeleteResultModel.h"
#import "RemindHandleCell.h"

static const CGFloat delayTime = 1.5;

#define kNumberOfItemsEachLoad 20

@interface RemindManageTableView ()

@property (nonatomic, assign) int more;

@property (nonatomic, strong) DeleteResultModel *deleteResultModel;

@property (nonatomic, strong) TreatmentPlanListModel *treatmentPlanListModel;
@property (nonatomic, strong) TreatmentPlanModel *treatmentPlanModel;
@property (nonatomic, strong) LimitListModel *limitListModel;
@property (nonatomic, strong) TreatmentPlanItemModel *treatmentPlanItemModel;

@property (nonatomic, copy) NSString *eventTip;
@property (nonatomic, copy) NSString *whetherAllDayTip;
@property (nonatomic, copy) NSString *whetherHandleTip;
@property (nonatomic, copy) NSString *remindWayTip;
@property (nonatomic, copy) NSString *remindClassifyTip;
@property (nonatomic, copy) NSString *patientNameTip;
@property (nonatomic, copy) NSString *IDCardTip;
@property (nonatomic, copy) NSString *createStafferNameTip;
@property (nonatomic, copy) NSString *createdDateTip;
@property (nonatomic, copy) NSString *modifyStafferNameTip;
@property (nonatomic, copy) NSString *modifyDateTip;

@end

@implementation RemindManageTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.more = 0;
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    //通知中心注册通知
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(showAddRemindItem:) name:@"showAddRemindItem" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshForAddRemind:) name:@"refreshForAddRemind" object:nil];
    
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

#pragma mark - NSNotificationCenter 通知方法

- (void)showAddRemindItem:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem = self.addRemindItem;
}

- (void)refreshForAddRemind:(NSNotificationCenter *)notification {
    [self setupRefresh];
}

#pragma mark - 销毁通知

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showAddRemindItem" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshForAddRemind" object:nil];
}

#pragma mark - 数组对象初始化

- (NSMutableArray *)treatmentPlanItemModels {
    if (!_treatmentPlanItemModels) {
        self.treatmentPlanItemModels = [NSMutableArray array];
    }
    return _treatmentPlanItemModels;
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
    [self loadNetworkData:self.remindUrl withType:@"dropDownRefresh"];
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
                self.treatmentPlanListModel = [TreatmentPlanListModel objectWithKeyValues:responseObject];
                self.treatmentPlanModel = self.treatmentPlanListModel.List;
                self.limitListModel = self.treatmentPlanModel.LimitList.firstObject;
                
                if (self.limitListModel.IsCreate == 1 && (![self.remindHandleIdentify isEqualToString:@"remindHandle"])) { //通知显示增加barItem
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAddRemindItem" object:nil];
                }
                
                NSString *originalFieldDescString = [self.treatmentPlanListModel.List.FieldsRemark.firstObject valueForKeyPath:@"FieldDesc"];
                NSString *fieldDescString = [originalFieldDescString substringToIndex:originalFieldDescString.length - 1]; //去除最后一分号
                NSArray *fieldDescArray = [fieldDescString componentsSeparatedByString:@";"];
                
                for (NSString *filterString in fieldDescArray) {
                    NSArray *filterArray = [filterString componentsSeparatedByString:@","];
                    NSString *filterKey = filterArray[0];
                    NSString *filterValue = filterArray[1];
                    
                    if ([filterKey isEqualToString:@"F115"]) {
                        self.eventTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F121"]) {
                        self.whetherAllDayTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F130"]) {
                        self.whetherHandleTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F135"]) {
                        self.remindWayTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F136"]) {
                        self.remindClassifyTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F150"]) {
                        self.patientNameTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F151"]) {
                        self.IDCardTip = [NSString stringWithFormat:@"%@:", filterValue];
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
                    [self.treatmentPlanItemModels removeAllObjects];
                    [self.moreUrlArray removeAllObjects];
                }
                
                [self.treatmentPlanItemModels addObjectsFromArray:self.treatmentPlanModel.DataList];
                
                if ([type isEqualToString:@"dropDownRefresh"]) {
                    for (NSInteger i = 2; i <= (long)ceilf((float)self.treatmentPlanListModel.Count / kNumberOfItemsEachLoad); i++) {
                        
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
    if (section == self.treatmentPlanItemModels.count - 1) {
        return 10;
    }
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    self.treatmentPlanItemModel = self.treatmentPlanItemModels[indexPath.section];
    
    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&OperatorID=%@&ActionType=SubmitedView", BrowseBaseUrl, self.treatmentPlanItemModel.info_formoid, self.treatmentPlanItemModel.Info_oid, GetOperatorID];
    
    webVC.linkUrl = url;
    
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 设置尾部控件的显示和隐藏
    self.tableView.footer.hidden = self.treatmentPlanItemModels.count == 0;
    
    return self.treatmentPlanItemModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.treatmentPlanItemModel = self.treatmentPlanItemModels[indexPath.section];
    
    if ([self.remindHandleIdentify isEqualToString:@"remindHandle"]) {
        RemindHandleCell *remindHandleCell = [tableView dequeueReusableCellWithIdentifier:@"remindHandleCell" forIndexPath:indexPath];
        remindHandleCell.eventTipLabel.text = self.eventTip;
        remindHandleCell.eventLabel.text = self.treatmentPlanItemModel.F115;
        remindHandleCell.whetherAllDayTipLabel.text = self.whetherAllDayTip;
        remindHandleCell.whetherAllDayLabel.text = self.treatmentPlanItemModel.F121;
        remindHandleCell.whetherHandleTipLabel.text = self.whetherHandleTip;
        remindHandleCell.whetherHandleLabel.text = self.treatmentPlanItemModel.F130;
        
        remindHandleCell.remindWayTipLabel.text = self.remindWayTip;
        remindHandleCell.remindWayLabel.text = self.treatmentPlanItemModel.F135;
        remindHandleCell.remindClassifyTipLabel.text = self.remindClassifyTip;
        remindHandleCell.remindClassifyLabel.text = self.treatmentPlanItemModel.F136;
        
        remindHandleCell.patientNameTipLabel.text = self.patientNameTip;
        remindHandleCell.patientNameLabel.text = self.treatmentPlanItemModel.F150;
        remindHandleCell.IDCardTipLabel.text = self.IDCardTip;
        remindHandleCell.IDCardLabel.text = self.treatmentPlanItemModel.F151;
        
        remindHandleCell.createStafferNameTipLabel.text = self.createStafferNameTip;
        remindHandleCell.createStafferNameLabel.text = self.treatmentPlanItemModel.CreateStafferName;
        remindHandleCell.createDateTipLabel.text = self.createdDateTip;
        remindHandleCell.createDateLabel.text = self.treatmentPlanItemModel.Info_CreatedDate;
        
        return remindHandleCell;
    } else {
        RemindManageCell *remindManageCell = [tableView dequeueReusableCellWithIdentifier:@"remindManageCell" forIndexPath:indexPath];
        remindManageCell.eventTipLabel.text = self.eventTip;
        remindManageCell.eventLabel.text = self.treatmentPlanItemModel.F115;
        remindManageCell.whetherAllDayTipLabel.text = self.whetherAllDayTip;
        remindManageCell.whetherAllDayLabel.text = self.treatmentPlanItemModel.F121;
        remindManageCell.whetherHandleTipLabel.text = self.whetherHandleTip;
        remindManageCell.whetherHandleLabel.text = self.treatmentPlanItemModel.F130;
        
        remindManageCell.remindWayTipLabel.text = self.remindWayTip;
        remindManageCell.remindWayLabel.text = self.treatmentPlanItemModel.F135;
        remindManageCell.remindClassifyTipLabel.text = self.remindClassifyTip;
        remindManageCell.remindClassifyLabel.text = self.treatmentPlanItemModel.F136;
        
        remindManageCell.patientNameTipLabel.text = self.patientNameTip;
        remindManageCell.patientNameLabel.text = self.treatmentPlanItemModel.F150;
        remindManageCell.IDCardTipLabel.text = self.IDCardTip;
        remindManageCell.IDCardLabel.text = self.treatmentPlanItemModel.F151;
        
        remindManageCell.createStafferNameTipLabel.text = self.createStafferNameTip;
        remindManageCell.createStafferNameLabel.text = self.treatmentPlanItemModel.CreateStafferName;
        remindManageCell.createDateTipLabel.text = self.createdDateTip;
        remindManageCell.createDateLabel.text = self.treatmentPlanItemModel.Info_CreatedDate;
        
        if ((self.limitListModel.IsModify == 0 && self.limitListModel.IsDelete == 0)) { //无相应的操作权限则动态移除操作面板
            [remindManageCell.modifyButton removeFromSuperview];
            [remindManageCell.deleteButton removeFromSuperview];
            id bottomConstraints = [NSLayoutConstraint constraintWithItem:remindManageCell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:remindManageCell.separateView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            
            [remindManageCell.contentView addConstraints:@[bottomConstraints]];
        } else if (self.limitListModel.IsModify == 0) {
            [remindManageCell.modifyButton removeFromSuperview];
            id trailingConstraints = [NSLayoutConstraint constraintWithItem:remindManageCell.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:remindManageCell.deleteButton attribute:NSLayoutAttributeTrailing multiplier:1 constant:15];
            
            [remindManageCell.contentView addConstraints:@[trailingConstraints]];
        } else if (self.limitListModel.IsDelete == 0) {
            [remindManageCell.deleteButton removeFromSuperview];
        }
        
        return remindManageCell;
    }
}

#pragma mark - modifyRemindAction method

- (IBAction)modifyRemindAction:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    self.treatmentPlanItemModel = self.treatmentPlanItemModels[selectedIndexPath.section];
    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&ActionType=SubmitedModify&OperatorID=%@", ModifyBaseUrl, self.treatmentPlanItemModel.info_formoid, self.treatmentPlanItemModel.Info_oid, GetOperatorID];
    
    webVC.linkUrl = url;
    webVC.refreshForAdd = YES;
    
    [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)deleteRemindAction:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    self.treatmentPlanItemModel = self.treatmentPlanItemModels[selectedIndexPath.section];
    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&OperatorID=%@", DeleteBaseUrl, self.treatmentPlanItemModel.info_formoid, self.treatmentPlanItemModel.Info_oid, GetOperatorID];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:KindlyRemind message:DeleteComfirmTip preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:SheetCancel style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:DeleteButtonTip style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
            AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
            
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                self.deleteResultModel = [DeleteResultModel objectWithKeyValues:responseObject];
                
                if ([self.deleteResultModel.ResultID isEqualToString:@"1"]) {
                    [self.treatmentPlanItemModels removeObjectAtIndex:selectedIndexPath.section];
                    
                    [SVProgressHUD showInfoWithStatus: self.deleteResultModel.ResultMessage maskType:SVProgressHUDMaskTypeNone];
                    
                    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:selectedIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                    
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

- (IBAction)addRemindAction:(UIBarButtonItem *)sender {
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    
    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=0&ActionType=Add&OperatorID=%@", ModifyBaseUrl, self.treatmentPlanListModel.FormID, GetOperatorID];
    
    webVC.linkUrl = url;
    webVC.refreshForAdd = YES;
    
    [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)knownHandleAction:(id)sender {
    [self handleRemindMethodWithSender:sender handingStatu:@"2" content:Known];
}

- (IBAction)unprocessedAction:(id)sender {
    [self handleRemindMethodWithSender:sender handingStatu:@"1" content:UnHandled];
}

- (IBAction)processedAction:(id)sender {
    [self handleRemindMethodWithSender:sender handingStatu:@"3" content:Handled];
}

- (void)handleRemindMethodWithSender:(id)sender handingStatu:(NSString *)handingStatu content:(NSString *)content {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    self.treatmentPlanItemModel = self.treatmentPlanItemModels[selectedIndexPath.section];
    
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        NSString *url = nil;
        NSString *remindInfoString = [NSString stringWithFormat:@"[{DetailID:%@,FormID:%@}]", self.treatmentPlanItemModel.Info_oid, self.treatmentPlanItemModel.info_formoid];
        NSString *handleUrl = [NSString stringWithFormat:@"%@OperatorID=%@&HandingStatu=%@&Content=%@&RemindInfo=%@", RemindHandleBaseUrl, GetOperatorID, handingStatu, content, remindInfoString];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            url = [handleUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        } else {
            url = [handleUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            self.deleteResultModel = [DeleteResultModel objectWithKeyValues:responseObject];
            
            if ([self.deleteResultModel.ResultID isEqualToString:@"1"]) {
                [self.treatmentPlanItemModels removeObjectAtIndex:selectedIndexPath.section];
                
                [SVProgressHUD showInfoWithStatus: self.deleteResultModel.ResultMessage maskType:SVProgressHUDMaskTypeNone];
                
                if ([handingStatu isEqualToString:@"2"] || [handingStatu isEqualToString:@"3"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateRemindRecordNumber" object:nil];
                    
                    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:selectedIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                    
                    [self.tableView reloadData];
                }
            }
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
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
