//
//  PatientListTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/22.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "PatientListTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "CheckNetWorkStatus.h"
#import "SVProgressHUD.h"
#import "MJExtension.h"
#import "UITableView+Improve.h"
#import "MJRefresh.h"

#import "PatientListCell.h"
#import "OrderResultTableView.h"
#import "CalendarViewController.h"
#import "RemindManageTableView.h"
#import "PatientSearchTableView.h"
#import "FormListTableView.h"

#import "PatientModel.h"
#import "PatientSecondModel.h"
#import "PatientItemModel.h"
#import "LimitListModel.h"

static const CGFloat delayTime = 1.5;

#define kNumberOfItemsEachLoad 20

@interface PatientListTableView ()

@property (nonatomic, assign) int more;

@property (nonatomic, strong) PatientModel *patientModel;
@property (nonatomic, strong) PatientSecondModel *patientSecondModel;
@property (nonatomic, strong) PatientItemModel *patientItemModel;
@property (nonatomic, strong) LimitListModel *limitListModel;

@property (nonatomic, strong) UIView *tipView;
@property (nonatomic, strong) UILabel *currentPage;
@property (nonatomic, strong) UILabel *totalNumberLabel;

@property (nonatomic, assign) NSInteger currentPageNumber;

@end

@implementation PatientListTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.more = 0;
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    [self setupRefresh]; //集成刷新控件
    
    self.tipView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 20)];
    self.tipView.backgroundColor = RGBColorWithAlpha(245, 245, 245, 0.8);
    
    self.totalNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 20)];
    self.totalNumberLabel.textColor = RGBColor(0, 194, 155);
    self.totalNumberLabel.font = [UIFont systemFontOfSize:13.0];
    self.totalNumberLabel.textAlignment = NSTextAlignmentLeft;
    
    self.currentPage = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 120, 0, 100, 20)];
    self.currentPage.textColor = RGBColor(0, 194, 155);
    self.currentPage.font = [UIFont systemFontOfSize:13.0];
    self.currentPage.textAlignment = NSTextAlignmentRight;
    
    self.tipView.tag = 1001;
    
    [self.tipView addSubview:self.totalNumberLabel];
    [self.tipView addSubview:self.currentPage];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.parentViewController.view addSubview:self.tipView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    for (UIView *subviews in [self.parentViewController.view subviews]) {
        if (subviews.tag == 1001) {
            [subviews removeFromSuperview];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 数组对象初始化

- (NSMutableArray *)patientItemModels {
    if (!_patientItemModels) {
        self.patientItemModels = [NSMutableArray array];
    }
    return _patientItemModels;
}

- (NSMutableArray *)moreUrlArray {
    if (!_moreUrlArray) {
        self.moreUrlArray = [NSMutableArray array];
    }
    return _moreUrlArray;
}

#pragma mark - loadPatientListData 加载所有病人列表数据

- (void)loadPatientListData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        [manager GET:self.patientUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //  self.patientModel = [PatientModel objectWithKeyValues:responseObject];
            //  self.patientSecondModel = self.patientModel.List;
            //  self.limitListModel = self.patientSecondModel.LimitList.firstObject;
            
            //  [self.patientItemModels addObjectsFromArray:self.patientSecondModel.DataList];
            self.patientItemModels = [PatientItemModel objectArrayWithKeyValuesArray:[responseObject valueForKey:@"List"]];
            
            //其他模块暂时无修改、删除权限，置1强制隐藏操作栏
            self.limitListModel = [[LimitListModel alloc] init];
            self.limitListModel.IsModify = 1;
            self.limitListModel.IsDelete = 1;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showInfoWithStatus:DataLoadFailureTip maskType:SVProgressHUDMaskTypeNone];
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
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
    [self loadNetworkData:self.patientUrl withType:@"dropDownRefresh"];
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
                self.patientModel = [PatientModel objectWithKeyValues:responseObject];
                self.patientSecondModel = self.patientModel.List;
                self.limitListModel = self.patientSecondModel.LimitList.firstObject;
                
                //设置总页数
                self.totalNumberLabel.text = [NSString stringWithFormat:@"%@%ld", IdentifyAndEvaluatePatientTotalNumber, (long)self.patientModel.Count];
                
                //    if (self.limitListModel.IsCreate == 1) { //通知显示增加barItem
                //         [[NSNotificationCenter defaultCenter] postNotificationName:@"" object:nil];
                //     }
                
                if ([type isEqualToString:@"dropDownRefresh"]) {
                    self.more = 0;
                    [self.patientItemModels removeAllObjects];
                    [self.moreUrlArray removeAllObjects];
                }
                
                [self.patientItemModels addObjectsFromArray:self.patientSecondModel.DataList];
                
                if ([type isEqualToString:@"dropDownRefresh"]) {
                    for (NSInteger i = 2; i <= (long)ceilf((float)self.patientModel.Count / kNumberOfItemsEachLoad); i++) {
                        
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
        return 31;
    }
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == self.patientItemModels.count - 1) {
        return 10;
    }
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.patientListIdentify isEqualToString:@"orderPatientListJump"]) {
        [self performSegueWithIdentifier:@"showPatientOrderListJump" sender:nil];
    }
    
    if ([self.patientListIdentify isEqualToString:@"remindPatientListJump"]) {
        [self performSegueWithIdentifier:@"showpPatientRemindJump" sender:nil];
    }
    //此处要根据identify 跳转
    if ([self.patientListIdentify isEqualToString:@"orderDepartmentSelectIdentifier"]) {
        [self performSegueWithIdentifier:@"showPatientOrderJump" sender:nil];
    }
    
    if ([self.patientListIdentify isEqualToString:@"schedulePatientDepartmentSelectIdentifier"]) {
        [self performSegueWithIdentifier:@"showScheduleCalendarJump" sender:nil];
    }
    
    if ([self.patientListIdentify isEqualToString:@"remindPatientDepartmentSelectIdentifier"]) {
        [self performSegueWithIdentifier:@"showpPatientRemindJump" sender:nil];
    }
    if ([self.patientListIdentify isEqualToString:@"identifyAndEvaluate"]) {
        [self performSegueWithIdentifier:@"showPersonalFormListJump" sender:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 设置尾部控件的显示和隐藏
    self.tableView.footer.hidden = self.patientItemModels.count == 0;
    
    return self.patientItemModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.patientItemModels.count > 0) {
        self.patientItemModel = self.patientItemModels[indexPath.section];
        
        //设置当前页数
        if (((long)ceilf((float)indexPath.section / kNumberOfItemsEachLoad)) == 0) {
            self.currentPageNumber = 1;
        } else {
            self.currentPageNumber = ((long)ceilf((float)indexPath.section / kNumberOfItemsEachLoad));
        }
        self.currentPage.text = [NSString stringWithFormat:@"%ld/%ld", (long)self.currentPageNumber, (long)ceilf((float)self.patientModel.Count / kNumberOfItemsEachLoad)];
        
        PatientListCell *patientListCell = [tableView dequeueReusableCellWithIdentifier:@"patientListCell" forIndexPath:indexPath];
        patientListCell.patientNameLabel.text = self.patientItemModel.PatientName;
        patientListCell.hospitalNumberLabel.text = self.patientItemModel.Mzhzyh;
        patientListCell.sexLabel.text = self.patientItemModel.Sex;
        patientListCell.telLabel.text = self.patientItemModel.Tel;
        patientListCell.cardIdLabel.text = self.patientItemModel.CardId;
        patientListCell.doctorLabel.text = self.patientItemModel.Doctor;
        patientListCell.addressLabel.text = self.patientItemModel.Address;
        
        if ((self.limitListModel.IsModify == 1 && self.limitListModel.IsDelete == 1)) { //无相应的操作权限则动态移除操作面板 //注意：此处为测试改为1，实际应全为0
            [patientListCell.modifyPatientButton removeFromSuperview];
            [patientListCell.deletePatientButton removeFromSuperview];
            
            id bottomConstraints = [NSLayoutConstraint constraintWithItem:patientListCell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:patientListCell.separateView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            
            [patientListCell.contentView addConstraints:@[bottomConstraints]];
        } else if (self.limitListModel.IsModify == 0) {
            [patientListCell.modifyPatientButton removeFromSuperview];
            id trailingConstraints = [NSLayoutConstraint constraintWithItem:patientListCell.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:patientListCell.deletePatientButton attribute:NSLayoutAttributeTrailing multiplier:1 constant:15];
            
            [patientListCell.contentView addConstraints:@[trailingConstraints]];
        } else if (self.limitListModel.IsDelete == 0) {
            [patientListCell.deletePatientButton removeFromSuperview];
        }
        
        return patientListCell;
    } else {
        return nil;
    }
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    self.patientItemModel = self.patientItemModels[selectedIndexPath.section];
    
    if ([segue.identifier isEqualToString:@"showPatientOrderJump"]) {
        OrderResultTableView *orderResultTableView = segue.destinationViewController;
        orderResultTableView.title = [NSString stringWithFormat:@"%@%@", self.patientItemModel.PatientName, SomebodyOrderResultTip];
        
        if ([orderResultTableView respondsToSelector:@selector(setOrderResultUrl:)]) {
            NSString *urlString = [NSString stringWithFormat:@"%@OperatorID=%@&CardID=%@&PageID=1&PageSize=20", OrderPatientBaseUrl, GetOperatorID, self.patientItemModel.CardId];
            [orderResultTableView setValue:urlString forKey:@"orderResultUrl"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"showScheduleCalendarJump"]) {
        CalendarViewController *calendarViewController = segue.destinationViewController;
        if ([calendarViewController respondsToSelector:@selector(setSyscodeId:)]) {
            [calendarViewController setValue:self.patientItemModel.CardId forKey:@"SyscodeId"];
        }
        if ([calendarViewController respondsToSelector:@selector(setCalendarIdentify:)]) {
            [calendarViewController setValue:@"scheduleCalendar" forKey:@"calendarIdentify"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"showpPatientRemindJump"]) {
        RemindManageTableView *remindManageTableView = segue.destinationViewController;
        
        remindManageTableView.title = [NSString stringWithFormat:@"%@%@", self.patientItemModel.PatientName, SomebodyRemindTip];
        
        if ([remindManageTableView respondsToSelector:@selector(setRemindUrl:)]) {
            NSString *urlString = [NSString stringWithFormat:@"%@OperatorID=%@&CardID=%@&PageID=1&PageSize=20", PatientRemindBaseUrl, GetOperatorID, self.patientItemModel.CardId];
            [remindManageTableView setValue:urlString forKey:@"remindUrl"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"showPersonalFormListJump"]) {
        FormListTableView *formListTableView = segue.destinationViewController;
        formListTableView.title = self.patientItemModel.PatientName;
        if ([formListTableView respondsToSelector:@selector(setPersonID:)]) {
            [formListTableView setValue:self.patientItemModel.Info_oid forKey:@"PersonID"];
        }
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
