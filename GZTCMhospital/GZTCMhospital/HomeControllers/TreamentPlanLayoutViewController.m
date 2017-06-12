//
//  TreamentPlanLayoutViewController.m
//  GZTCMhospital
//
//  Created by Chris on 16/1/4.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "TreamentPlanLayoutViewController.h"

#import "HMSegmentedControl.h"

#import "TreatmentPlanTableView.h"
#import "CommonWebView.h"

#define VIEW_WIDTH  CGRectGetWidth(self.view.frame)

@interface TreamentPlanLayoutViewController ()

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, copy) NSString *planClassificationFormoid;
@property (nonatomic, copy) NSString *planTemplateFormoid;
@property (nonatomic, copy) NSString *taskManagementFormoid;
@property (nonatomic, copy) NSString *templateTaskFormoid;
@property (nonatomic, copy) NSString *patientTreatmentPlanFormoid;

@property (nonatomic, assign) NSInteger planClassificationIsCreate;
@property (nonatomic, assign) NSInteger planTemplateIsCreate;
@property (nonatomic, assign) NSInteger taskManagementIsCreate;
@property (nonatomic, assign) NSInteger templateTaskIsCreate;
@property (nonatomic, assign) NSInteger patientTreatmentPlanIsCreate;

@end

@implementation TreamentPlanLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //通知中心注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTransferInfoFormoid:) name:@"receiveTransferInfoFormoid" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTreamentPlanIsCreate:) name:@"receiveTreamentPlanIsCreate" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshForAddTreatmentPlan:) name:@"refreshForAddTreatmentPlan" object:nil];
    
    [self addController];
    
    //首次默认加载第一个子控制器
    TreatmentPlanTableView *vc = (TreatmentPlanTableView *)[self.childViewControllers firstObject];
    vc.view.frame = self.planScroll.bounds;
    
    self.currentPage = 0;
    
    [self.planScroll addSubview:vc.view];
    
    //设置下方内容courseScroll(即courseScroll)的contentSize
    CGFloat contentX = (self.childViewControllers.count) * [UIScreen mainScreen].bounds.size.width;
    self.planScroll.contentSize = CGSizeMake(contentX, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotificationCenter 通知方法

- (void)receiveTransferInfoFormoid:(NSNotification *)notification {
    if (self.currentPage == 0) {
        self.planClassificationFormoid = notification.object;
    }
    if (self.currentPage == 1) {
        self.planTemplateFormoid = notification.object;
    }
    if (self.currentPage == 2) {
        self.taskManagementFormoid = notification.object;
    }
    if (self.currentPage == 3) {
        self.templateTaskFormoid = notification.object;
    }
    if (self.currentPage == 4) {
        self.patientTreatmentPlanFormoid = notification.object;
    }
}

- (void)receiveTreamentPlanIsCreate:(NSNotification *)notification {
    if (self.currentPage == 0) {
        self.planClassificationIsCreate = [notification.object integerValue];
    }
    if (self.currentPage == 1) {
        self.planTemplateIsCreate = [notification.object integerValue];
    }
    if (self.currentPage == 2) {
        self.taskManagementIsCreate = [notification.object integerValue];
    }
    if (self.currentPage == 3) {
        self.templateTaskIsCreate = [notification.object integerValue];
    }
    if (self.currentPage == 4) {
        self.patientTreatmentPlanIsCreate = [notification.object integerValue];
    }
}

- (void)refreshForAddTreatmentPlan:(NSNotificationCenter *)notification {
    TreatmentPlanTableView *currentVC = (TreatmentPlanTableView *)self.childViewControllers[self.currentPage];
    [currentVC setupRefresh];
}

#pragma mark - 销毁通知

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receiveTransferInfoFormoid" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receiveTreamentPlanIsCreate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshForAddTreatmentPlan" object:nil];
}

#pragma mark - addController 加载子控制器

- (void)addController {
    
    //计划分类、计划模版、任务管理、模版任务、病人诊疗计划 复用此TreatmentPlanTableView
    for (NSInteger i = 0; i < 5; i++) {
        TreatmentPlanTableView *treatmentPlanTableView = [self.storyboard instantiateViewControllerWithIdentifier:@"treatmentPlanTableView"];
        treatmentPlanTableView.EditionID = self.EditionID;
        
        if (i == 0) {
            treatmentPlanTableView.type = @"planClassification";
        }
        
        if (i == 1) {
            treatmentPlanTableView.type = @"planTemplate";
        }
        
        if (i == 2) {
            treatmentPlanTableView.type = @"taskManagement";
        }
        
        if (i == 3) {
            treatmentPlanTableView.type = @"templateTask";
        }
        
        if (i == 4) {
            treatmentPlanTableView.type = @"patientTreatmentPlan";
        }
        
        [self addChildViewController:treatmentPlanTableView];
    }
    
    //设置分段控件segmentedControl
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[PlanClassification, PlanTemplate, TaskManagement, TemplateTask, PatientTreatmentPlan]];
    self.segmentedControl.verticalDividerEnabled = YES;
    self.segmentedControl.verticalDividerColor = RGBColor(216, 216, 216);
    self.segmentedControl.verticalDividerWidth = 1.0f;
    
    self.segmentedControl.frame = CGRectMake(0, 0, VIEW_WIDTH, 45);
    
    self.segmentedControl.backgroundColor = [UIColor clearColor];
    self.segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : RGBColor(70, 70, 70),NSFontAttributeName : [UIFont systemFontOfSize:15.0]};
    
    self.segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : RGBColor(0, 194, 155)};
    self.segmentedControl.selectionIndicatorHeight = 2.0f;
    self.segmentedControl.selectionIndicatorColor = RGBColor(0, 194, 155);
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    
    [self.segmentView addSubview:self.segmentedControl];
    
    __weak typeof(self) weakSelf = self;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        CGFloat offsetX = VIEW_WIDTH * index;
        CGFloat offsetY = weakSelf.planScroll.contentOffset.y;
        CGPoint offset = CGPointMake(offsetX, offsetY);
        [weakSelf.planScroll setContentOffset:offset animated:YES];
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.planScroll]) {
        
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger page = scrollView.contentOffset.x / pageWidth;
    
        self.currentPage = page;
        
        [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
        
        if (self.currentPage == 0) {
            if (self.planClassificationIsCreate == 1) { //通知显示增加barItem
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showAddTreatmentPlanItem" object:nil];
            } else if (self.planClassificationIsCreate == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAddTreatmentPlanItem" object:nil];
            }
        }
        if (self.currentPage == 1) {
            if (self.planTemplateIsCreate == 1) { //通知显示增加barItem
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showAddTreatmentPlanItem" object:nil];
            } else if (self.planTemplateIsCreate == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAddTreatmentPlanItem" object:nil];
            }
        }
        if (self.currentPage == 2) {
            if (self.taskManagementIsCreate == 1) { //通知显示增加barItem
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showAddTreatmentPlanItem" object:nil];
            } else if (self.taskManagementIsCreate == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAddTreatmentPlanItem" object:nil];
            }
        }
        if (self.currentPage == 3) {
            if (self.templateTaskIsCreate == 1) { //通知显示增加barItem
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showAddTreatmentPlanItem" object:nil];
            } else if (self.templateTaskIsCreate == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAddTreatmentPlanItem" object:nil];
            }
        }
        if (self.currentPage == 4) {
            if (self.patientTreatmentPlanIsCreate == 1) { //通知显示增加barItem
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showAddTreatmentPlanItem" object:nil];
            } else if (self.patientTreatmentPlanIsCreate == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAddTreatmentPlanItem" object:nil];
            }
        }
        
        //添加滑动后所在位置对应的子控制器
        TreatmentPlanTableView *newsVc = (TreatmentPlanTableView *)self.childViewControllers[page];
        
        if (newsVc.view.superview) return;
        
        newsVc.view.frame = scrollView.bounds;
        [self.planScroll addSubview:newsVc.view];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

#pragma mark - 增加诊疗计划量表方法

- (void)addTreatmentPlan {
    NSString *url = nil;
    if (self.currentPage == 0) {
        url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=0&ActionType=Add&OperatorID=%@", ModifyBaseUrl, self.planClassificationFormoid, GetOperatorID];
        [self webAddTreamentPlan:url];
    }
    if (self.currentPage == 1) {
        url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=0&ActionType=Add&OperatorID=%@", ModifyBaseUrl, self.planTemplateFormoid, GetOperatorID];
        [self webAddTreamentPlan:url];
    }
    if (self.currentPage == 2) {
        url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=0&ActionType=Add&OperatorID=%@", ModifyBaseUrl, self.taskManagementFormoid, GetOperatorID];
        [self webAddTreamentPlan:url];
    }
    if (self.currentPage == 3) {
        url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=0&ActionType=Add&OperatorID=%@", ModifyBaseUrl, self.templateTaskFormoid, GetOperatorID];
        [self webAddTreamentPlan:url];
    }
    if (self.currentPage == 4) {
        url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=0&ActionType=Add&OperatorID=%@", ModifyBaseUrl, self.patientTreatmentPlanFormoid, GetOperatorID];
        [self webAddTreamentPlan:url];
    }
}

- (void)webAddTreamentPlan:(NSString *)url {
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    
    webVC.linkUrl = url;
    webVC.refreshForAdd = YES;
    
    [self.navigationController pushViewController:webVC animated:YES];
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
