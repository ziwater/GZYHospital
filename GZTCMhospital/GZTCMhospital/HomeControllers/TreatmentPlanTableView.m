//
//  TreatmentPlanTableView.m
//  GZTCMhospital
//
//  Created by Chris on 16/1/4.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "TreatmentPlanTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "UITableView+Improve.h"

#import "CheckNetWorkStatus.h"
#import "TreatmentPlanListModel.h"
#import "TreatmentPlanModel.h"
#import "LimitListModel.h"
#import "TreatmentPlanItemModel.h"
#import "CommonWebView.h"
#import "PlanClassificationCell.h"
#import "PlanTemplateCell.h"
#import "TaskManageCell.h"
#import "TemplateTaskCell.h"
#import "PatientTreatmentPlanCell.h"
#import "DeleteResultModel.h"
#import "TreamentPlanLayoutViewController.h"

static const CGFloat delayTime = 0.0;

#define kNumberOfItemsEachLoad 20

@interface TreatmentPlanTableView ()

@property (nonatomic, assign) int more;

@property (nonatomic, strong) DeleteResultModel *deleteResultModel;

@property (nonatomic, strong) TreatmentPlanListModel *treatmentPlanListModel;
@property (nonatomic, strong) TreatmentPlanModel *treatmentPlanModel;
@property (nonatomic, strong) LimitListModel *limitListModel;
@property (nonatomic, strong) TreatmentPlanItemModel *treatmentPlanItemModel;

@property (nonatomic, copy) NSString *classifyNameTip;
@property (nonatomic, copy) NSString *templateNameTip;
@property (nonatomic, copy) NSString *planClassifyTip;
@property (nonatomic, copy) NSString *cycleTip;
@property (nonatomic, copy) NSString *remindWayTip;
@property (nonatomic, copy) NSString *remindClassifyTip;
@property (nonatomic, copy) NSString *timeIntervalTip;
@property (nonatomic, copy) NSString *createStafferNameTip;
@property (nonatomic, copy) NSString *createdDateTip;
@property (nonatomic, copy) NSString *modifyStafferNameTip;
@property (nonatomic, copy) NSString *modifyDateTip;
@property (nonatomic, copy) NSString *planTaskTip;
@property (nonatomic, copy) NSString *templateDescriptionTip;
@property (nonatomic, copy) NSString *IDCardTip;
@property (nonatomic, copy) NSString *treatmentPlanClassifyTip;

@end

@implementation TreatmentPlanTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.more = 0;
    
    //通知中心注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAddTreatmentPlanItem:) name:@"showAddTreatmentPlanItem" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAddTreatmentPlanItem:) name:@"removeAddTreatmentPlanItem" object:nil];
    
    if ([self.type isEqualToString:@"planClassification"]) {
        self.url = [NSString stringWithFormat:@"%@OperatorID=%@&EditionID=%ld&PageID=1&PageSize=20",PlanClassificationBaseUrl, GetOperatorID, (long)self.EditionID];
    }
    if ([self.type isEqualToString:@"planTemplate"]) {
        self.url = [NSString stringWithFormat:@"%@OperatorID=%@&EditionID=%ld&PageID=1&PageSize=20", PlanTemplateBaseUrl, GetOperatorID, (long)self.EditionID];
    }
    if ([self.type isEqualToString:@"taskManagement"]) {
        self.url = [NSString stringWithFormat:@"%@OperatorID=%@&EditionID=%ld&PageID=1&PageSize=20", TaskManagementBaseUrl, GetOperatorID, (long)self.EditionID];
    }
    if ([self.type isEqualToString:@"templateTask"]) {
        self.url = [NSString stringWithFormat:@"%@OperatorID=%@&EditionID=%ld&PageID=1&PageSize=20", TemplateTaskBaseUrl, GetOperatorID, (long)self.EditionID];
    }
    if ([self.type isEqualToString:@"patientTreatmentPlan"]) {
        self.url = [NSString stringWithFormat:@"%@OperatorID=%@&EditionID=%ld&PageID=1&PageSize=20", PatientTreatmentPlanBaseUrl, GetOperatorID, (long)self.EditionID];
    }
    
    [self setupRefresh]; //集成刷新控件
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
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

- (void)showAddTreatmentPlanItem:(NSNotification *)notification {
    self.parentViewController.navigationItem.rightBarButtonItem = self.addTreatmenPlanItem;
}

- (void)removeAddTreatmentPlanItem:(NSNotificationCenter *)notification {
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - 销毁通知

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showAddTreatmentPlanItem" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeAddTreatmentPlanItem" object:nil];
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
    [self loadNetworkData:self.url withType:@"dropDownRefresh"];
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
                
                if (self.limitListModel.IsCreate == 1) { //通知显示增加barItem
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAddTreatmentPlanItem" object:nil];
                } else if (self.limitListModel.IsCreate == 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAddTreatmentPlanItem" object:nil];
                }
                
                NSString *originalFieldDescString = [self.treatmentPlanListModel.List.FieldsRemark.firstObject valueForKeyPath:@"FieldDesc"];
                NSString *fieldDescString = [originalFieldDescString substringToIndex:originalFieldDescString.length - 1]; //去除最后一分号
                NSArray *fieldDescArray = [fieldDescString componentsSeparatedByString:@";"];
                
                for (NSString *filterString in fieldDescArray) {
                    NSArray *filterArray = [filterString componentsSeparatedByString:@","];
                    NSString *filterKey = filterArray[0];
                    NSString *filterValue = filterArray[1];
                    
                    if ([filterKey isEqualToString:@"F116"]) {
                        self.classifyNameTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F115"]) {
                        self.templateNameTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F120"]) {
                        self.planClassifyTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F121"]) {
                        self.cycleTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F122"]) {
                        self.remindWayTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F123"]) {
                        self.remindClassifyTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F124"]) {
                        self.timeIntervalTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F118"]) {
                        self.planTaskTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F119"]) {
                        self.templateDescriptionTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F117"]) {
                        self.IDCardTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"F133"]) {
                        self.treatmentPlanClassifyTip = [NSString stringWithFormat:@"%@:", filterValue];
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
                    if ([filterKey isEqualToString:@"ModifyStafferName"]) {
                        self.modifyStafferNameTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                    if ([filterKey isEqualToString:@"Info_ModifyDate"]) {
                        self.modifyDateTip = [NSString stringWithFormat:@"%@:", filterValue];
                        continue;
                    }
                }
                
                if ([type isEqualToString:@"dropDownRefresh"]) {
                    self.more = 0;
                    [self.treatmentPlanItemModels removeAllObjects];
                    [self.moreUrlArray removeAllObjects];
                }
                
                [self.treatmentPlanItemModels addObjectsFromArray:self.treatmentPlanModel.DataList];
                
                //通知传递info_formoid至父控制器以实现增加
                [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveTransferInfoFormoid" object:self.treatmentPlanListModel.FormID];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveTreamentPlanIsCreate" object:@(self.limitListModel.IsCreate)];
                
                if ([type isEqualToString:@"dropDownRefresh"]) {
                    for (NSInteger i = 2; i <= (long)ceilf((float)self.treatmentPlanListModel.Count / kNumberOfItemsEachLoad); i++) {
                        
                        NSString *newPageID = [NSString stringWithFormat:@"PageID=%ld", (long)i];
                        self.moreURL = [url stringByReplacingOccurrencesOfString:@"PageID=1" withString:newPageID];
                        [self.moreUrlArray addObject:self.moreURL];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.treatmentPlanItemModels.count) {
                        [self.tableView reloadData];
                    }
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
    
    NSString *url = nil;
    url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&OperatorID=%@&ActionType=SubmitedView", BrowseBaseUrl, self.treatmentPlanItemModel.info_formoid, self.treatmentPlanItemModel.Info_oid, GetOperatorID];
    
    if ([self.type isEqualToString:@"patientTreatmentPlan"]) {
        url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&OperatorID=%@&ActionType=SubmitedView", BrowseBaseUrl, self.treatmentPlanItemModel.info_formoid, self.treatmentPlanItemModel.Info_oid, GetOperatorID];
    }
    
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
    
    if ([self.type isEqualToString:@"planClassification"]) {
        PlanClassificationCell *planClassificationCell = [tableView dequeueReusableCellWithIdentifier:@"planClassificationCell" forIndexPath:indexPath];
        planClassificationCell.classifyNameTipLabel.text = self.classifyNameTip;
        planClassificationCell.classifyNameLabel.text = self.treatmentPlanItemModel.F116;
        
        planClassificationCell.createStafferNameTipLabel.text = self.createStafferNameTip;
        planClassificationCell.createStafferNameLabel.text = self.treatmentPlanItemModel.CreateStafferName;
        planClassificationCell.createDateTipLabel.text = self.createdDateTip;
        planClassificationCell.createDateLabel.text = self.treatmentPlanItemModel.Info_CreatedDate;
        
        planClassificationCell.modifyStafferNameTipLabel.text = self.modifyStafferNameTip;
        planClassificationCell.modifyStafferNameLabel.text = self.treatmentPlanItemModel.ModifyStafferName;
        planClassificationCell.modifyDateTipLabel.text = self.modifyDateTip;
        planClassificationCell.modifyDateLabel.text = self.treatmentPlanItemModel.Info_ModifyDate;
        
        //当IsModify == 0 && IsDelete == 0时，动态修改separateView的bottom与cell contentView的bottom之间的约束
        if (self.limitListModel.IsModify == 0 && self.limitListModel.IsDelete == 0) {
            [planClassificationCell.modifyPlanClassificationButton removeFromSuperview]; //动态移除修改按钮
            [planClassificationCell.deletePlanClassificationButton removeFromSuperview];
            
            id bottomConstraints = [NSLayoutConstraint constraintWithItem:planClassificationCell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:planClassificationCell.separateView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            
            [planClassificationCell.contentView addConstraints:@[bottomConstraints]];
        } else if (self.limitListModel.IsModify == 0) {
            [planClassificationCell.modifyPlanClassificationButton removeFromSuperview];
            id trailingConstraints = [NSLayoutConstraint constraintWithItem:planClassificationCell.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:planClassificationCell.deletePlanClassificationButton attribute:NSLayoutAttributeTrailing multiplier:1 constant:15];
            
            [planClassificationCell.contentView addConstraints:@[trailingConstraints]];
            
        } else if (self.limitListModel.IsDelete == 0) {
            [planClassificationCell.deletePlanClassificationButton removeFromSuperview];
        } else {
            
        }
        
        return planClassificationCell;
    }
    
    if ([self.type isEqualToString:@"planTemplate"]) {
        PlanTemplateCell *planTemplateCell = [tableView dequeueReusableCellWithIdentifier:@"planTemplateCell"];
        planTemplateCell.templateNameTipLabel.text = self.templateNameTip;
        planTemplateCell.templateNameLabel.text = self.treatmentPlanItemModel.F115;
        
        planTemplateCell.planClassifyTipLabel.text = self.planClassifyTip;
        planTemplateCell.planClassifyLabel.text = self.treatmentPlanItemModel.F120;
        
        planTemplateCell.cycleTipLabel.text = self.cycleTip;
        planTemplateCell.cycleLabel.text = self.treatmentPlanItemModel.F121;
        
        planTemplateCell.createStafferNameTipLabel.text = self.createStafferNameTip;
        planTemplateCell.createStafferNameLabel.text = self.treatmentPlanItemModel.CreateStafferName;
        planTemplateCell.createDateTipLabel.text = self.createdDateTip;
        planTemplateCell.createDateLabel.text = self.treatmentPlanItemModel.Info_CreatedDate;
        
        planTemplateCell.modifyStafferNameTipLabel.text = self.modifyStafferNameTip;
        planTemplateCell.modifyStafferNameLabel.text = self.treatmentPlanItemModel.ModifyStafferName;
        planTemplateCell.modifyDateTipLabel.text = self.modifyDateTip;
        planTemplateCell.modifyDateLabel.text = self.treatmentPlanItemModel.Info_ModifyDate;
        
        if (self.limitListModel.IsModify == 0 && self.limitListModel.IsDelete == 0) {
            [planTemplateCell.modifyPlanTemplateButton removeFromSuperview];
            [planTemplateCell.deletePlanTemplateButton removeFromSuperview];
            
            id bottomConstraints = [NSLayoutConstraint constraintWithItem:planTemplateCell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:planTemplateCell.separateView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            
            [planTemplateCell.contentView addConstraints:@[bottomConstraints]];
        } else if (self.limitListModel.IsModify == 0) {
            [planTemplateCell.modifyPlanTemplateButton removeFromSuperview];
            id trailingConstraints = [NSLayoutConstraint constraintWithItem:planTemplateCell.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:planTemplateCell.deletePlanTemplateButton attribute:NSLayoutAttributeTrailing multiplier:1 constant:15];
            
            [planTemplateCell.contentView addConstraints:@[trailingConstraints]];
        } else if (self.limitListModel.IsDelete == 0) {
            [planTemplateCell.deletePlanTemplateButton removeFromSuperview];
        } else {
            
        }
        
        return planTemplateCell;
    }
    
    if ([self.type isEqualToString:@"taskManagement"]) {
        TaskManageCell *taskManageCell = [tableView dequeueReusableCellWithIdentifier:@"taskManageCell" forIndexPath:indexPath];
        taskManageCell.taskNameTipLabel.text = self.templateNameTip;
        taskManageCell.taskNameLabel.text = self.treatmentPlanItemModel.F115;
        
        taskManageCell.wetherRemindTipLabel.text = self.cycleTip;
        taskManageCell.wetherRemindLabel.text = self.treatmentPlanItemModel.F121;
        
        taskManageCell.remindWayTipLabel.text = self.remindWayTip;
        taskManageCell.remindWayLabel.text = self.treatmentPlanItemModel.F122;
        
        taskManageCell.RemindClassifyTipLabel.text = self.remindClassifyTip;
        taskManageCell.RemindClassifyLabel.text = self.treatmentPlanItemModel.F123;
        
        taskManageCell.timeIntervalTipLabel.text = self.timeIntervalTip;
        taskManageCell.timeIntervalLabel.text = self.treatmentPlanItemModel.F124;
        
        taskManageCell.createStafferNameTipLabel.text = self.createStafferNameTip;
        taskManageCell.createStafferNameLabel.text = self.treatmentPlanItemModel.CreateStafferName;
        taskManageCell.createDateTipLabel.text = self.createdDateTip;
        taskManageCell.createDateLabel.text = self.treatmentPlanItemModel.Info_CreatedDate;
        
        taskManageCell.modifyStafferNameTipLabel.text = self.modifyStafferNameTip;
        taskManageCell.modifyStafferNameLabel.text = self.treatmentPlanItemModel.ModifyStafferName;
        taskManageCell.modifyDateTipLabel.text = self.modifyDateTip;
        taskManageCell.modifyDateLabel.text = self.treatmentPlanItemModel.Info_ModifyDate;
        
        if (self.limitListModel.IsModify == 0 && self.limitListModel.IsDelete == 0) {
            [taskManageCell.modifyTaskManageButton removeFromSuperview];
            [taskManageCell.deleteTaskManageButton removeFromSuperview];
            
            id bottomConstraints = [NSLayoutConstraint constraintWithItem:taskManageCell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:taskManageCell.separateView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            
            [taskManageCell.contentView addConstraints:@[bottomConstraints]];
        } else if (self.limitListModel.IsModify == 0) {
            [taskManageCell.modifyTaskManageButton removeFromSuperview];
            id trailingConstraints = [NSLayoutConstraint constraintWithItem:taskManageCell.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:taskManageCell.deleteTaskManageButton attribute:NSLayoutAttributeTrailing multiplier:1 constant:15];
            
            [taskManageCell.contentView addConstraints:@[trailingConstraints]];
        } else if (self.limitListModel.IsDelete == 0) {
            [taskManageCell.deleteTaskManageButton removeFromSuperview];
        } else {
            
        }
        
        return taskManageCell;
    }
    
    if ([self.type isEqualToString:@"templateTask"]) {
        TemplateTaskCell *templateTaskCell = [tableView dequeueReusableCellWithIdentifier:@"templateTaskCell" forIndexPath:indexPath];
        templateTaskCell.templateTipLabel.text = self.templateNameTip;
        templateTaskCell.templateLabel.text = self.treatmentPlanItemModel.F115;
        
        templateTaskCell.planClassifyTipLabel.text = self.planClassifyTip;
        templateTaskCell.planClassifyLabel.text = self.treatmentPlanItemModel.F120;
        
        templateTaskCell.diseaseDepartmentTipLabel.text = self.classifyNameTip;
        templateTaskCell.diseaseDepartmentLabel.text = [self.treatmentPlanItemModel.F116 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        templateTaskCell.planTaskTipLabel.text = self.planTaskTip;
        templateTaskCell.planTaskLabel.text = self.treatmentPlanItemModel.F118;
        
        templateTaskCell.templateDescriptionTipLabel.text = self.templateDescriptionTip;
        templateTaskCell.templateDescriptionLabel.text = self.treatmentPlanItemModel.F119;
        
        templateTaskCell.createStafferNameTipLabel.text = self.createStafferNameTip;
        templateTaskCell.createStafferNameLabel.text = self.treatmentPlanItemModel.CreateStafferName;
        templateTaskCell.createDateTipLabel.text = self.createdDateTip;
        templateTaskCell.createDateLabel.text = self.treatmentPlanItemModel.Info_CreatedDate;
        
        templateTaskCell.modifyStafferNameTipLabel.text = self.modifyStafferNameTip;
        templateTaskCell.modifyStafferNameLabel.text = self.treatmentPlanItemModel.ModifyStafferName;
        templateTaskCell.modifyDateTipLabel.text = self.modifyDateTip;
        templateTaskCell.modifyDateLabel.text = self.treatmentPlanItemModel.Info_ModifyDate;
        
        if (self.limitListModel.IsModify == 0 && self.limitListModel.IsDelete == 0) {
            [templateTaskCell.modifyTemplateTaskButton removeFromSuperview];
            [templateTaskCell.deleteTemplateTaskButton removeFromSuperview];
            
            id bottomConstraints = [NSLayoutConstraint constraintWithItem:templateTaskCell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:templateTaskCell.separateView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            
            [templateTaskCell.contentView addConstraints:@[bottomConstraints]];
        } else if (self.limitListModel.IsModify == 0) {
            [templateTaskCell.modifyTemplateTaskButton removeFromSuperview];
            id trailingConstraints = [NSLayoutConstraint constraintWithItem:templateTaskCell.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:templateTaskCell.deleteTemplateTaskButton attribute:NSLayoutAttributeTrailing multiplier:1 constant:15];
            
            [templateTaskCell.contentView addConstraints:@[trailingConstraints]];
        } else if (self.limitListModel.IsDelete == 0) {
            [templateTaskCell.deleteTemplateTaskButton removeFromSuperview];
        } else {
            
        }
        
        return templateTaskCell;
    }
    
    if ([self.type isEqualToString:@"patientTreatmentPlan"]) {
        PatientTreatmentPlanCell *patientTreatmentPlanCell = [tableView dequeueReusableCellWithIdentifier:@"patientTreatmentPlanCell" forIndexPath:indexPath];
        patientTreatmentPlanCell.patientNameTipLabel.text = self.classifyNameTip;
        patientTreatmentPlanCell.patientNameLabel.text = self.treatmentPlanItemModel.F116;
        
        patientTreatmentPlanCell.IDCardTipLabel.text = self.IDCardTip;
        patientTreatmentPlanCell.IDCardLabel.text = self.treatmentPlanItemModel.F117;
        
        patientTreatmentPlanCell.treatmentPlanTemplateTipLabel.text = self.templateDescriptionTip;
        patientTreatmentPlanCell.treatmentPlanTemplateLabel.text = self.treatmentPlanItemModel.F119;
        
        patientTreatmentPlanCell.treatmentPlanClassifyTipLabel.text = self.treatmentPlanClassifyTip;
        patientTreatmentPlanCell.treatmentPlanClassifyLabel.text = self.treatmentPlanItemModel.F133;
        
        patientTreatmentPlanCell.createStafferNameTipLabel.text = self.createStafferNameTip;
        patientTreatmentPlanCell.createStafferNameLabel.text = self.treatmentPlanItemModel.CreateStafferName;
        patientTreatmentPlanCell.createDateTipLabel.text = self.createdDateTip;
        patientTreatmentPlanCell.createDateLabel.text = self.treatmentPlanItemModel.Info_CreatedDate;
        
        patientTreatmentPlanCell.modifyStafferNameTipLabel.text = self.modifyStafferNameTip;
        patientTreatmentPlanCell.modifyStafferNameLabel.text = self.treatmentPlanItemModel.ModifyStafferName;
        patientTreatmentPlanCell.modifyDateTipLabel.text = self.modifyDateTip;
        patientTreatmentPlanCell.modifyDateLabel.text = self.treatmentPlanItemModel.Info_ModifyDate;
        
        if (self.limitListModel.IsModify == 0 && self.limitListModel.IsDelete == 0) {
            [patientTreatmentPlanCell.modifyPatientTreatmentPlanButton removeFromSuperview];
            [patientTreatmentPlanCell.deletePatientTreatmentPlanButton removeFromSuperview];
            
            id bottomConstraints = [NSLayoutConstraint constraintWithItem:patientTreatmentPlanCell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:patientTreatmentPlanCell.separateView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
            
            [patientTreatmentPlanCell.contentView addConstraints:@[bottomConstraints]];
        } else if (self.limitListModel.IsModify == 0) {
            [patientTreatmentPlanCell.modifyPatientTreatmentPlanButton removeFromSuperview];
            id trailingConstraints = [NSLayoutConstraint constraintWithItem:patientTreatmentPlanCell.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:patientTreatmentPlanCell.deletePatientTreatmentPlanButton attribute:NSLayoutAttributeTrailing multiplier:1 constant:15];
            
            [patientTreatmentPlanCell.contentView addConstraints:@[trailingConstraints]];
        } else if (self.limitListModel.IsDelete == 0) {
            [patientTreatmentPlanCell.deletePatientTreatmentPlanButton removeFromSuperview];
        } else {
            
        }
        
        return patientTreatmentPlanCell;
    }
    
    return nil;
}

#pragma mark - Action method

- (IBAction)modifyTreatmentPlanAction:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    self.treatmentPlanItemModel = self.treatmentPlanItemModels[selectedIndexPath.section];
    
    NSString *url = nil;
    url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&ActionType=SubmitedModify&OperatorID=%@", ModifyBaseUrl, self.treatmentPlanItemModel.info_formoid, self.treatmentPlanItemModel.Info_oid, GetOperatorID];
    
    if ([self.type isEqualToString:@"patientTreatmentPlan"]) {
        url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&ActionType=SubmitedModify&OperatorID=%@", ModifyBaseUrl, self.treatmentPlanItemModel.info_formoid, self.treatmentPlanItemModel.Info_oid, GetOperatorID];
    }
    
    webVC.linkUrl = url;
    webVC.refreshForAdd = YES;
    
    [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)deleteTreatmentPlanAction:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    self.treatmentPlanItemModel = self.treatmentPlanItemModels[selectedIndexPath.section];
    
    NSString *url = nil;
    url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&OperatorID=%@", DeleteBaseUrl, self.treatmentPlanItemModel.info_formoid, self.treatmentPlanItemModel.Info_oid, GetOperatorID];
    
    if ([self.type isEqualToString:@"patientTreatmentPlan"]) {
        url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&ActionType=SubmitedModify&OperatorID=%@", ModifyBaseUrl, self.treatmentPlanItemModel.info_formoid, self.treatmentPlanItemModel.Info_oid, GetOperatorID];
    }
    
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

- (IBAction)addTreatmentPlanAction:(UIBarButtonItem *)sender {
    [(TreamentPlanLayoutViewController *)self.parentViewController addTreatmentPlan];
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
