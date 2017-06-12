//
//  CourseLayoutViewController.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/1.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "CourseLayoutViewController.h"

#import "HMSegmentedControl.h"

#import "CourseListTableView.h"
#import "CourseProgressTableView.h"
#import "CommonWebView.h"

#define VIEW_WIDTH  CGRectGetWidth(self.view.frame)

@interface CourseLayoutViewController () <UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, copy) NSString *courseListFormoid;
@property (nonatomic, copy) NSString *courseContentFormoid;
@property (nonatomic, copy) NSString *attendanceFormoid;
@property (nonatomic, copy) NSString *progressFormoid;

@property (nonatomic, assign) NSInteger courseListIsCreate;
@property (nonatomic, assign) NSInteger courseContentIsCreate;
@property (nonatomic, assign) NSInteger attendanceIsCreate;
@property (nonatomic, assign) NSInteger progressIsCreate;

@end

@implementation CourseLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //通知中心注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCourseInfoFormoid:) name:@"receiveCourseInfoFormoid" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveIsCreate:) name:@"receiveIsCreate" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshForAddCourse:) name:@"refreshForAddCourse" object:nil];
    
    [self addController];
    
    //首次默认加载第一个子控制器
    UIViewController *vc = [self.childViewControllers firstObject];
    vc.view.frame = self.courseScroll.bounds;
    
    self.currentPage = 0;
    
    [self.courseScroll addSubview:vc.view];
    
    //设置下方内容courseScroll(即courseScroll)的contentSize
    CGFloat contentX = (self.childViewControllers.count) * [UIScreen mainScreen].bounds.size.width;
    self.courseScroll.contentSize = CGSizeMake(contentX, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotificationCenter 通知方法

- (void)receiveCourseInfoFormoid:(NSNotification *)notification {
    if (self.currentPage == 0) {
        self.courseListFormoid = notification.object;
    }
    if (self.currentPage == 1) {
        self.courseContentFormoid = notification.object;
    }
    if (self.currentPage == 2) {
        self.attendanceFormoid = notification.object;
    }
    if (self.currentPage == 3) {
        self.progressFormoid = notification.object;
    }
}

- (void)receiveIsCreate:(NSNotification *)notification {
    if (self.currentPage == 0) {
        self.courseListIsCreate = [notification.object integerValue];
    }
    if (self.currentPage == 1) {
        self.courseContentIsCreate = [notification.object integerValue];
    }
    if (self.currentPage == 2) {
        self.attendanceIsCreate = [notification.object integerValue];
    }
    if (self.currentPage == 3) {
        self.progressIsCreate = [notification.object integerValue];
    }
}

- (void)refreshForAddCourse:(NSNotificationCenter *)notification {
    CourseListTableView *currentVC = (CourseListTableView *)self.childViewControllers[self.currentPage];
    [currentVC setupRefresh];
}

#pragma mark - 销毁通知

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receiveCourseInfoFormoid" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receiveIsCreate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshForAddCourse" object:nil];
}

#pragma mark - addController 加载子控制器

- (void)addController {
    
    //宣教课程列表、宣教内容列表、考勤列表复用CourseListTableView
    for (NSInteger i = 0; i < 3; i++) {
        CourseListTableView *courseListTableView = [self.storyboard instantiateViewControllerWithIdentifier:@"courseListTableView"];
        courseListTableView.EditionID = self.EditionID;
        
        if (i == 0) {
            courseListTableView.type = @"courseListTableView";
        }
        
        if (i == 1) {
            courseListTableView.type = @"courseContentTableView";
        }
        
        if (i == 2) {
            courseListTableView.type = @"attendanceTableView";
        }
        
        [self addChildViewController:courseListTableView];
    }
    
    CourseProgressTableView *courseProgressTableView = [self.storyboard instantiateViewControllerWithIdentifier:@"courseProgressTableView"];
    courseProgressTableView.EditionID = self.EditionID;
    [self addChildViewController:courseProgressTableView];
    
    //设置分段控件segmentedControl
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[CourseList, CourseContent, AttendanceList, CourseProgressList]];
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
        CGFloat offsetY = weakSelf.courseScroll.contentOffset.y;
        CGPoint offset = CGPointMake(offsetX, offsetY);
        [weakSelf.courseScroll setContentOffset:offset animated:YES];
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.courseScroll]) {
        
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger page = scrollView.contentOffset.x / pageWidth;
        
        self.currentPage = page;
        
        [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
        
        if (self.currentPage == 0) {
            if (self.courseListIsCreate == 1) { //通知显示增加barItem
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showAddCourseItem" object:nil];
            } else if (self.courseListIsCreate == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAddCourseItem" object:nil];
            }
        }
        if (self.currentPage == 1) {
            if (self.courseContentIsCreate == 1) { //通知显示增加barItem
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showAddCourseItem" object:nil];
            } else if (self.courseContentIsCreate == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAddCourseItem" object:nil];
            }
        }
        if (self.currentPage == 2) {
            if (self.attendanceIsCreate == 1) { //通知显示增加barItem
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showAddCourseItem" object:nil];
            } else if (self.attendanceIsCreate == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAddCourseItem" object:nil];
            }
        }
        if (self.currentPage == 3) {
            if (self.progressIsCreate == 1) { //通知显示增加barItem
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showAddCourseItem" object:nil];
            } else if (self.progressIsCreate == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAddCourseItem" object:nil];
            }
        }
        
        //添加滑动后所在位置对应的子控制器
        UIViewController *newsVc = self.childViewControllers[page];
        if (newsVc.view.superview) return;
        
        newsVc.view.frame = scrollView.bounds;
        [self.courseScroll addSubview:newsVc.view];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

#pragma mark - 增加课程量表方法

- (void)addCourse {
    NSString *url = nil;
    if (self.currentPage == 0) {
        url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=0&ActionType=Add&OperatorID=%@", ModifyBaseUrl, self.courseListFormoid, GetOperatorID];
        [self webAddCourse:url];
    }
    if (self.currentPage == 1) {
        url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=0&ActionType=Add&OperatorID=%@", ModifyBaseUrl, self.courseContentFormoid, GetOperatorID];
        [self webAddCourse:url];
    }
    if (self.currentPage == 2) {
        url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=0&ActionType=Add&OperatorID=%@", ModifyBaseUrl, self.attendanceFormoid, GetOperatorID];
        [self webAddCourse:url];
    }
    if (self.currentPage == 3) {
        url = [NSString stringWithFormat:@"%@FormID=%@&DetailID=0&ActionType=Add&OperatorID=%@", ModifyBaseUrl, self.progressFormoid, GetOperatorID];
        [self webAddCourse:url];
    }
}

- (void)webAddCourse:(NSString *)url {
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
