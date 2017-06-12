//
//  DiseaseListTableView.m
//  GZTCMhospital
//
//  Created by Chris on 16/2/22.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "DiseaseListTableView.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "BDDynamicTreeNode.h"
#import "BDDynamicTree.h"

#import "CheckNetWorkStatus.h"
#import "DiseaseListModel.h"
#import "FormListTableView.h"
#import "PatientSearchTableView.h"
#import "RemindManageTableView.h"
#import "CalendarViewController.h"

@interface DiseaseListTableView () <BDDynamicTreeDelegate>

@property (nonatomic, strong) BDDynamicTree *dynamicTree;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSArray *diseaseListModels;
@property (nonatomic, assign) CGFloat originX;
@property (nonatomic, strong) BDDynamicTreeNode *treeNode;

@end

@implementation DiseaseListTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self generateData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        self.dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 加载树状科室列表数据

- (void)generateData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        [SVProgressHUD showWithStatus:NetworkDataLoadingTip maskType:SVProgressHUDMaskTypeNone];
        
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        NSString *url = [NSString stringWithFormat:@"%@OperatorID=%@", DiseaseListBaseUrl, GetOperatorID];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.diseaseListModels = [DiseaseListModel objectArrayWithKeyValuesArray:[responseObject valueForKeyPath:@"List"]];
            
            for (NSInteger i = 0; i < self.diseaseListModels.count; i++) {
                NSInteger j;
                for (j = i + 1; j < self.diseaseListModels.count; j++) {
                    if ([[self.diseaseListModels[i] valueForKey:@"ID"] isEqualToString:[self.diseaseListModels[j] valueForKey:@"FatherID"]]) {
                        [self.diseaseListModels[i] setValue:@YES forKey:@"NotLeaf"];
                        break; //非叶子结点
                    }
                }
                if (j == self.diseaseListModels.count) {
                    [self.diseaseListModels[i] setValue:@NO forKey:@"NotLeaf"];
                }
            }
            
            for (DiseaseListModel *diseaseListModel in self.diseaseListModels) {
                if (diseaseListModel.Lever == 1 || diseaseListModel.Lever == 2) {
                    self.originX = 20.0f;
                } else {
                    self.originX = 0;
                }
                BDDynamicTreeNode *node = [[BDDynamicTreeNode alloc] initWithOriginX:self.originX NotLeaf:[diseaseListModel.NotLeaf boolValue] fatherNodeId:diseaseListModel.FatherID nodeId:diseaseListModel.ID name:diseaseListModel.Name data:[NSDictionary dictionary] lever:diseaseListModel.Lever];
                [self.dataArray addObject:node];
            }
            
            self.dynamicTree = [[BDDynamicTree alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height - 20) nodes:self.dataArray];
            self.dynamicTree.delegate = self;
            [self.view addSubview:self.dynamicTree];
            
            [SVProgressHUD dismiss];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showInfoWithStatus:DataLoadFailureTip maskType:SVProgressHUDMaskTypeNone];
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
}

#pragma mark - BDDynamicTreeDelegate method

- (void)dynamicTree:(BDDynamicTree *)dynamicTree didSelectedRowWithNode:(BDDynamicTreeNode *)node {
    if (!node.NotLeaf) {
        self.treeNode = node;
        [self performDifferentJump];
    }
}

- (void)dynamicTree:(BDDynamicTree *)dynamicTree didSelectedRowWithAccessoryButton:(BDDynamicTreeNode *)node {
    self.treeNode = node;
    [self performDifferentJump];
}

#pragma mark - performDifferentJump method

- (void)performDifferentJump {
    if ([self.identifier isEqualToString:@"orderDepartmentSelectIdentifier"] || [self.identifier isEqualToString:@"schedulePatientDepartmentSelectIdentifier"] || [self.identifier isEqualToString:@"remindPatientDepartmentSelectIdentifier"] || [self.identifier isEqualToString:@"identifyAndEvaluate"]) {
        [self performSegueWithIdentifier:@"orderPatientSearch" sender:nil];
    }
    if ([self.identifier isEqualToString:@"slowDiseaseCourse"]) {
        [self performSegueWithIdentifier:@"showCourseListJump" sender:nil];
    }
    if ([self.identifier isEqualToString:@"treatmentPlan"]) {
        [self performSegueWithIdentifier:@"showTreatmentPlanJump" sender:nil];
    }
    if ([self.identifier isEqualToString:@"scheduleDepartmentSelectIdentifier"]) {
        [self performSegueWithIdentifier:@"scheduleDepartmentSearch" sender:nil];
    }
    if ([self.identifier isEqualToString:@"remindDepartmentSelectIdentifier"]) {
        [self performSegueWithIdentifier:@"showDepartmentRemindJump" sender:nil];
    }
    if ([self.identifier isEqualToString:@"orderCalendar"]) {
        [self performSegueWithIdentifier:@"showOrderCalenderJump" sender:nil];
    }
}
#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showMyOrderJump"] || [segue.identifier isEqualToString:@"showCourseListJump"] || [segue.identifier isEqualToString:@"showTreatmentPlanJump"] || [segue.identifier isEqualToString:@"showRemindManageJump"] || [segue.identifier isEqualToString:@"orderPatientSearch"] || [segue.identifier isEqualToString:@"scheduleDepartmentSearch"]) {
        UIViewController *viewController = segue.destinationViewController;
        
        viewController.title = self.treeNode.name;
        
        if ([viewController respondsToSelector:@selector(setEditionID:)]) {
            [viewController setValue:@([self.treeNode.nodeId integerValue]) forKey:@"EditionID"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"orderPatientSearch"]) {
        PatientSearchTableView *patientSearchTableView = segue.destinationViewController;
        if ([patientSearchTableView respondsToSelector:@selector(setPatientSearchIdentify:)]) {
            [patientSearchTableView setValue:self.identifier forKey:@"patientSearchIdentify"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"showDepartmentRemindJump"]) {
        RemindManageTableView *remindManageTableView = segue.destinationViewController;
        remindManageTableView.title = DepartmentRemindTip;
        
        if ([remindManageTableView respondsToSelector:@selector(setRemindUrl:)]) {
            NSString *url = [NSString stringWithFormat:@"%@OperatorID=%@&EditionID=%@&PageID=1&PageSize=20", DepartmentRemindBaseUrl, GetOperatorID, self.treeNode.nodeId];
            [remindManageTableView setValue:url forKey:@"remindUrl"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"showOrderCalenderJump"]) {
        CalendarViewController *calendarViewController = segue.destinationViewController;
        if ([calendarViewController respondsToSelector:@selector(setSyscodeId:)]) {
            [calendarViewController setValue:self.treeNode.nodeId forKey:@"SyscodeId"];
        }
        if ([calendarViewController respondsToSelector:@selector(setCalendarIdentify:)]) {
            [calendarViewController setValue:self.identifier forKey:@"calendarIdentify"];
        }
    }
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
