//
//  OrderLayoutViewController.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/23.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "OrderLayoutViewController.h"

#import "HMSegmentedControl.h"
#import "AFHTTPRequestOperationManager.h"
#import "CheckNetWorkStatus.h"
#import "SVProgressHUD.h"
#import "MJExtension.h"

#import "OrderResultTableView.h"
#import "OrderStatusModel.h"

#define VIEW_WIDTH  CGRectGetWidth(self.view.frame)

@interface OrderLayoutViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *orderStatusModels;

@end

@implementation OrderLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadOrderStatusData];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loadOrderStatusData 加载预约状态数据

- (void)loadOrderStatusData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        NSString *url = [NSString stringWithFormat:@"%@OperatorID=%@&PageID=1&PageSize=20", OrderStatusBaseUrl, GetOperatorID];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.orderStatusModels = [OrderStatusModel objectArrayWithKeyValuesArray:[responseObject valueForKeyPath:@"List"]];
            
            [self addController];
            
            //首次默认加载第一个子控制器
            UIViewController *vc = [self.childViewControllers firstObject];
            vc.view.frame = self.orderScroll.bounds;
            [self.orderScroll addSubview:vc.view];
            
            //设置下方内容courseScroll(即courseScroll)的contentSize
            CGFloat contentX = (self.childViewControllers.count) * [UIScreen mainScreen].bounds.size.width;
            self.orderScroll.contentSize = CGSizeMake(contentX, 0);

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showInfoWithStatus:DataLoadFailureTip maskType:SVProgressHUDMaskTypeNone];
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
}

#pragma mark - addController 加载子控制器

- (void)addController {
    //预约结果列表（不能就诊，按时就诊）
    NSMutableArray *sectiontitles = [NSMutableArray array];
    
    for (OrderStatusModel *orderStatusModel in self.orderStatusModels) {
        OrderResultTableView *orderResultTableView = [self.storyboard instantiateViewControllerWithIdentifier:@"orderResultTableView"];
        
        orderResultTableView.orderResultUrl = [NSString stringWithFormat:@"%@OperatorID=%@&SyscodeId=%@&PageID=1&PageSize=20", OrderResultBaseUrl, GetOperatorID, orderStatusModel.syscodeID];
        
        orderResultTableView.addDepartmentOrderIdentify = @"addDepartmentOrderIdentify";
        
        [self addChildViewController:orderResultTableView];
        
        [sectiontitles addObject:orderStatusModel.syscodeName];
    }
    
    //设置分段控件segmentedControl
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:sectiontitles];
    self.segmentedControl.verticalDividerEnabled = YES;
    self.segmentedControl.verticalDividerColor = RGBColor(216, 216, 216);
    self.segmentedControl.verticalDividerWidth = 1.0f;
    
    self.segmentedControl.frame = CGRectMake(0, 0, VIEW_WIDTH, 45);
    
    self.segmentedControl.backgroundColor = [UIColor clearColor];
    self.segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : RGBColor(0, 194, 155),NSFontAttributeName : [UIFont systemFontOfSize:15.0]};
    
    self.segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : RGBColor(0, 194, 155)};
    
    self.segmentedControl.selectionIndicatorHeight = 5.0f;
    self.segmentedControl.selectionIndicatorColor = RGBColor(0, 194, 155);
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleArrow;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    
    [self.segmentView addSubview:self.segmentedControl];
    
    __weak typeof(self) weakSelf = self;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        CGFloat offsetX = VIEW_WIDTH * index;
        CGFloat offsetY = weakSelf.orderScroll.contentOffset.y;
        CGPoint offset = CGPointMake(offsetX, offsetY);
        [weakSelf.orderScroll setContentOffset:offset animated:YES];
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.orderScroll]) {
        
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger page = scrollView.contentOffset.x / pageWidth;
        
        [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
        
        //添加滑动后所在位置对应的子控制器
        UIViewController *newsVc = self.childViewControllers[page];
        if (newsVc.view.superview) return;
        
        newsVc.view.frame = scrollView.bounds;
        [self.orderScroll addSubview:newsVc.view];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
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
