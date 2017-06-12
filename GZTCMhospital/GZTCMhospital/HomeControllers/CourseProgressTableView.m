//
//  CourseProgressTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/2.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "CourseProgressTableView.h"

#import "SVProgressHUD.h"
#import "UITableView+Improve.h"
#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"

#import "PlanListModel.h"
#import "CourseProgressListModel.h"
#import "CheckNetWorkStatus.h"
#import "CourseProgressCell.h"
#import "CourseProgressDetailTableView.h"

@interface CourseProgressTableView ()

@property (nonatomic, strong) PlanListModel *planListModel;

@end

@implementation CourseProgressTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveIsCreate" object:@0];
    
    [self loadCourseProgressData];
    
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

- (NSMutableArray *)planListModels {
    if (!_planListModels) {
        self.planListModels = [NSMutableArray array];
    }
    return _planListModels;
}

- (NSMutableArray *)courseProgressListModels {
    if (!_courseProgressListModels) {
        self.courseProgressListModels = [NSMutableArray array];
    }
    return _courseProgressListModels;
}

#pragma mark - loadCourseProgressData 加载课程进度列表

- (void)loadCourseProgressData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        NSString *url = [NSString stringWithFormat:@"%@OperatorID=%@&EditionID=%ld&PageID=1&PageSize=20", CourseProgressBaseUrl, GetOperatorID, (long)self.EditionID];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            self.planListModels = [PlanListModel objectArrayWithKeyValuesArray:[[responseObject valueForKeyPath:@"List"] valueForKeyPath:@"PlanList"]];
            self.courseProgressListModels = [CourseProgressListModel objectArrayWithKeyValuesArray:[[responseObject valueForKeyPath:@"List"] valueForKeyPath:@"CourseList"]];
            
            [self.tableView reloadData];
            
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.planListModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    CourseProgressCell *courseProgressCell = [tableView dequeueReusableCellWithIdentifier:@"courseProgressCell" forIndexPath:indexPath];
    self.planListModel = self.planListModels[indexPath.row];
    courseProgressCell.learningPersonLabel.text = self.planListModel.StaticsName;
    
    courseProgressCell.courseProgress.transform = CGAffineTransformMakeScale(1.0f,2.5f);
    
    UIImage *progressImage = [UIImage imageNamed:@"progressImage"];
    UIImage *trackImage = [UIImage imageNamed:@"trackImage"];
    //不让图片拉伸变形
    CGFloat top = 0; // 顶端盖高度
    CGFloat bottom = 0 ; // 底端盖高度
    CGFloat left = 20; // 左端盖宽度
    CGFloat right = 20; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    progressImage = [progressImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    trackImage = [trackImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    
    courseProgressCell.courseProgress.trackImage = trackImage;
    courseProgressCell.courseProgress.progressImage = progressImage;

    courseProgressCell.courseProgress.progress = self.planListModel.FinishedNum * 1.0 / self.planListModel.AllNum;
    courseProgressCell.percentLabel.text = self.planListModel.Percent;
    
    return courseProgressCell;
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showCourseProgressDetailJump"]) {
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        self.planListModel = self.planListModels[selectedIndexPath.row];
        
        CourseProgressDetailTableView *courseProgressDetailTableView = (CourseProgressDetailTableView *)segue.destinationViewController;
        if ([courseProgressDetailTableView respondsToSelector:@selector(setCourseProgressListModels:)]) {
            [courseProgressDetailTableView setValue:self.courseProgressListModels forKey:@"courseProgressListModels"];
        }
        
        if ([courseProgressDetailTableView respondsToSelector:@selector(setCompletedCourseSysCodeID:)]) {
            [courseProgressDetailTableView setValue:self.planListModel.SelectSyscodeIDValue forKey:@"completedCourseSysCodeID"];
        }
        
        if ([courseProgressDetailTableView respondsToSelector:@selector(setTableViewTitle:)]) {
            [courseProgressDetailTableView setValue:self.planListModel.StaticsName forKey:@"tableViewTitle"];
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
