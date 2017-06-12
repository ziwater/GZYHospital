//
//  CourseListTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/1.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "CourseListTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "UITableView+Improve.h"

#import "CheckNetWorkStatus.h"
#import "CourseCell.h"
#import "CommonWebView.h"
#import "CourseDataModel.h"
#import "CourseListModel.h"
#import "CourseItemModel.h"
#import "LimitListModel.h"
#import "CourseLayoutViewController.h"
#import "DeleteResultModel.h"

static const CGFloat delayTime = 1.5;

#define kNumberOfItemsEachLoad 20

@interface CourseListTableView ()

@property (nonatomic, assign) int more;

@property (nonatomic, strong) DeleteResultModel *deleteResultModel;

@property (nonatomic, strong) CourseDataModel *courseDataModel;
@property (nonatomic, strong) CourseListModel *courseListModel;
@property (nonatomic, strong) CourseItemModel *courseItemModel;
@property (nonatomic, strong) LimitListModel *limitListModel;

@property (nonatomic, copy) NSString *courseNameKey;
@property (nonatomic, copy) NSString *courseSpeakerKey;
@property (nonatomic ,copy) NSString *courseTimeKey;

@property (nonatomic, copy) NSString *courseFileNameKey;
@property (nonatomic, copy) NSString *courseFileTypeKey;

@end

@implementation CourseListTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.more = 0;
    
    //通知中心注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAddCourseItem:) name:@"showAddCourseItem" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAddCourseItem:) name:@"removeAddCourseItem" object:nil];
    
    if ([self.type isEqualToString:@"courseListTableView"]) {
        self.url = [NSString stringWithFormat:@"%@OperatorID=%@&EditionID=%ld&PageID=1&PageSize=20", CourseListBaseUrl, GetOperatorID, (long)self.EditionID];
    }
    
    if ([self.type isEqualToString:@"courseContentTableView"]) {
        self.url = [NSString stringWithFormat:@"%@OperatorID=%@&EditionID=%ld&PageID=1&PageSize=20", CourseContentListBaseUrl, GetOperatorID, (long)self.EditionID];
    }
    
    if ([self.type isEqualToString:@"attendanceTableView"]) {
        self.url = [NSString stringWithFormat:@"%@OperatorID=%@&EditionID=%ld&PageID=1&PageSize=20", CourseAttendanceListBaseUrl, GetOperatorID, (long)self.EditionID];
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

#pragma mark - 数组对象初始化

- (NSMutableArray *)courseItemModels {
    if (!_courseItemModels) {
        self.courseItemModels = [NSMutableArray array];
    }
    return _courseItemModels;
}

- (NSMutableArray *)moreUrlArray {
    if (!_moreUrlArray) {
        self.moreUrlArray = [NSMutableArray array];
    }
    return _moreUrlArray;
}

#pragma mark - NSNotificationCenter 通知方法

- (void)showAddCourseItem:(NSNotification *)notification {
    self.parentViewController.navigationItem.rightBarButtonItem = self.addCourseItem;
}

- (void)removeAddCourseItem:(NSNotificationCenter *)notification {
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - 销毁通知

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showAddCourseItem" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"removeAddCourseItem" object:nil];
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
                self.courseDataModel = [CourseDataModel objectWithKeyValues:responseObject];
                self.courseListModel = self.courseDataModel.List;
                self.limitListModel = self.courseListModel.LimitList.firstObject;
                
                if (self.limitListModel.IsCreate == 1) { //通知显示增加barItem
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAddCourseItem" object:nil];
                } else if (self.limitListModel.IsCreate == 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAddCourseItem" object:nil];
                }
                
                NSString *originalFieldDescString = [self.courseDataModel.List.FieldsRemark.firstObject valueForKeyPath:@"FieldDesc"];
                NSString *fieldDescString = [originalFieldDescString substringToIndex:originalFieldDescString.length - 1]; //去除最后一分号
                NSArray *fieldDescArray = [fieldDescString componentsSeparatedByString:@";"];
                
                if ([self.type isEqualToString:@"courseListTableView"]) {
                    for (NSString *filterString in fieldDescArray) {
                        NSArray *filterArray = [filterString componentsSeparatedByString:@","];
                        NSString *filterKey = filterArray[0];
                        NSString *filterValue = filterArray[1];
                        
                        if ([filterValue isEqualToString:@"课程名称"]) {
                            self.courseNameKey = filterKey;
                            continue;
                        }
                        if ([filterValue isEqualToString:@"主讲人"]) {
                            self.courseSpeakerKey = filterKey;
                            continue;
                        }
                        if ([filterValue isEqualToString:@"开课时间"]) {
                            self.courseTimeKey = filterKey;
                            continue;
                        }
                    }
                    
                    NSArray *dataListArray = [[responseObject valueForKeyPath:@"List"] valueForKeyPath:@"DataList"];
                    for (NSInteger i = 0; i < dataListArray.count; i++) {
                        id data = dataListArray[i];
                        
                        [self.courseListModel.DataList[i] setValue:[data valueForKey:self.courseNameKey] forKeyPath:@"courseName"];
                        [self.courseListModel.DataList[i] setValue:[data valueForKey:self.courseSpeakerKey] forKeyPath:@"courseSpeaker"];
                        [self.courseListModel.DataList[i] setValue:[data valueForKey:self.courseTimeKey] forKeyPath:@"courseTime"];
                    }
                }
                
                if ([self.type isEqualToString:@"courseContentTableView"]) {
                    for (NSString *filterString in fieldDescArray) {
                        NSArray *filterArray = [filterString componentsSeparatedByString:@","];
                        NSString *filterKey = filterArray[0];
                        NSString *filterValue = filterArray[1];
                        
                        if ([filterValue isEqualToString:@"内容名称"]) {
                            self.courseFileNameKey = filterKey;
                            continue;
                        }
                        if ([filterValue isEqualToString:@"文件类型"]) {
                            self.courseFileTypeKey = filterKey;
                            continue;
                        }
                    }
                    
                    NSArray *dataListArray = [[responseObject valueForKeyPath:@"List"] valueForKeyPath:@"DataList"];
                    for (NSInteger i = 0; i < dataListArray.count; i++) {
                        id data = dataListArray[i];
                        
                        [self.courseListModel.DataList[i] setValue:[data valueForKey:self.courseFileNameKey] forKeyPath:@"courseFileName"];
                        [self.courseListModel.DataList[i] setValue:[data valueForKey:self.courseFileTypeKey] forKeyPath:@"courseFileType"];
                    }
                }
                
                if ([type isEqualToString:@"dropDownRefresh"]) {
                    self.more = 0;
                    [self.courseItemModels removeAllObjects];
                    [self.moreUrlArray removeAllObjects];
                }
                
                [self.courseItemModels addObjectsFromArray:self.courseListModel.DataList];
                
                //通知传递info_formoid至父控制器以实现增加
                [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveCourseInfoFormoid" object:self.courseDataModel.FormID];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveIsCreate" object:@(self.limitListModel.IsCreate)];
                
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
    if (section == self.courseItemModels.count - 1) {
        return 10;
    }
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    self.courseItemModel = self.courseItemModels[indexPath.section];
    NSString *url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&ActionType=SubmitedView&OperatorID=%@", CourseDetailBaseUrl,self.courseItemModel.info_formoid, self.courseItemModel.Info_oid, GetOperatorID];
    webVC.linkUrl = url;
    
    if ([self.type isEqualToString:@"courseContentTableView"]) {
        NSString *courseFileDownloadUrl = [NSString stringWithFormat:@"%@OperatorID=%@&FormID=%@&DetailID=%@", CourseFileDownloadBaseUrl, GetOperatorID, self.courseItemModel.info_formoid, self.courseItemModel.Info_oid];
        [self whetherExistFile:courseFileDownloadUrl];
    }
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //设置尾部控件的显示和隐藏
    self.tableView.footer.hidden = self.courseItemModels.count == 0;
    return self.courseItemModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    self.courseItemModel = self.courseItemModels[indexPath.section];
    
    if ([self.type isEqualToString:@"courseListTableView"]) {
        CourseCell *courseCell = [tableView dequeueReusableCellWithIdentifier:@"courseCell" forIndexPath:indexPath];
        courseCell.courseTitleTipLabel.text = CourseNameTip;
        if (![self.courseItemModel.courseName isEqual:[NSNull null]]) {
            courseCell.courseTitleLabel.text = self.courseItemModel.courseName;
        } else {
            courseCell.courseTitleLabel.text = nil;
        }
        courseCell.courseCommonTipLabel.text = SpeakerTip;
        if (![self.courseItemModel.courseSpeaker isEqual:[NSNull null]]) {
            courseCell.courseCommonLabel.text = self.courseItemModel.courseSpeaker;
        } else {
            courseCell.courseCommonLabel.text = nil;
        }
        courseCell.courseTimeTipLabel.text = CourseStartTimeTip;
        courseCell.courseTimeLabel.text = self.courseItemModel.Info_CreatedDate;
        
        [self dynamicRemoveButton:courseCell];
        return courseCell;
    } else if ([self.type isEqualToString:@"courseContentTableView"]) {
        CourseCell *courseCell = [tableView dequeueReusableCellWithIdentifier:@"courseCell" forIndexPath:indexPath];
        courseCell.courseTitleTipLabel.text = CourseContentTip;
        if (![self.courseItemModel.courseFileName isEqual:[NSNull null]]) {
            courseCell.courseTitleLabel.text = self.courseItemModel.courseFileName;
        } else {
            courseCell.courseTitleLabel.text = nil;
        }
        courseCell.courseCommonTipLabel.text = CourseFileTypeTip;
        if (![self.courseItemModel.courseFileType isEqual:[NSNull null]]) {
            courseCell.courseCommonLabel.text = self.courseItemModel.courseFileType;
        } else {
            courseCell.courseTimeTipLabel.text = nil;
        }
        courseCell.courseTimeTipLabel.text = CreateTimeTip;
        courseCell.courseTimeLabel.text = self.courseItemModel.Info_CreatedDate;
        
        [self dynamicRemoveButton:courseCell];
        return courseCell;
    } else  if ([self.type isEqualToString:@"attendanceTableView"]){
        CourseCell *courseCell = [tableView dequeueReusableCellWithIdentifier:@"courseCell" forIndexPath:indexPath];
        courseCell.courseTitleTipLabel.text = PropagandaCourseTip;
        courseCell.courseTitleLabel.text = self.courseItemModel.F116;
        courseCell.courseCommonTipLabel.text = PatientNameTip;
        courseCell.courseCommonLabel.text = self.courseItemModel.F118;
        courseCell.courseTimeTipLabel.text = CompletedDate;
        courseCell.courseTimeLabel.text = self.courseItemModel.F120;
        
        [self dynamicRemoveButton:courseCell];
        return courseCell;
    } else {
        return nil;
    }
}

#pragma mark - whetherExistFile method

- (void)whetherExistFile:(NSString *)url {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject valueForKeyPath:@"List"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showDownloadFileItem" object:url];
            }
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
}

#pragma mark - 动态移除操作按钮

- (void)dynamicRemoveButton:(CourseCell *)courseCell {
    
    if ((self.limitListModel.IsModify == 0 && self.limitListModel.IsDelete == 0)) { //无相应的操作权限则动态移除操作面板
        [courseCell.modifyCourseButton removeFromSuperview];
        [courseCell.deleteCourseButton removeFromSuperview];
        id bottomConstraints = [NSLayoutConstraint constraintWithItem:courseCell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:courseCell.separateView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        
        [courseCell.contentView addConstraints:@[bottomConstraints]];
    } else if (self.limitListModel.IsModify == 0) {
        [courseCell.modifyCourseButton removeFromSuperview];
        id trailingConstraints = [NSLayoutConstraint constraintWithItem:courseCell.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:courseCell.deleteCourseButton attribute:NSLayoutAttributeTrailing multiplier:1 constant:15];
        
        [courseCell.contentView addConstraints:@[trailingConstraints]];
    } else if (self.limitListModel.IsDelete == 0) {
        [courseCell.deleteCourseButton removeFromSuperview];
    }
}

#pragma mark - Action method

- (IBAction)addCourseAction:(UIBarButtonItem *)sender {
    [(CourseLayoutViewController *)self.parentViewController addCourse];
}

- (IBAction)deleteCourseAction:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    self.courseItemModel = self.courseItemModels[selectedIndexPath.section];
    
    NSString *url = nil;
    url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&OperatorID=%@", DeleteBaseUrl, self.courseItemModel.info_formoid, self.courseItemModel.Info_oid, GetOperatorID];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:KindlyRemind message:DeleteComfirmTip preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:SheetCancel style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:DeleteButtonTip style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
            AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
            
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                self.deleteResultModel = [DeleteResultModel objectWithKeyValues:responseObject];
                
                if ([self.deleteResultModel.ResultID isEqualToString:@"1"]) {
                    [self.courseItemModels removeObjectAtIndex:selectedIndexPath.section];
                    
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

- (IBAction)modifyCourseAction:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    self.courseItemModel = self.courseItemModels[selectedIndexPath.section];
    
    NSString *url = nil;
    url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&ActionType=SubmitedModify&OperatorID=%@", ModifyBaseUrl, self.courseItemModel.info_formoid, self.courseItemModel.Info_oid, GetOperatorID];
    
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
