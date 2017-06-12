//
//  BlogLayoutViewController.m
//  GZTCMhospital
//
//  Created by Chris on 16/1/19.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "BlogLayoutViewController.h"

#import "HMSegmentedControl.h"
#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"

#import "CheckNetWorkStatus.h"
#import "BlogClassificationModel.h"
#import "InformationTableViewController.h"
#import "ReportStateViewController.h"

#define VIEW_WIDTH  CGRectGetWidth(self.view.frame)
#define WIDTH [UIScreen mainScreen].bounds.size.width

@interface BlogLayoutViewController ()

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) NSArray *blogClassificationModels;
@property (nonatomic, strong) NSMutableArray *modulesTitles;

@end

@implementation BlogLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshForAddBlog:) name:@"refreshForAddBlog" object:nil];
    
    [self loadBlogChannelData];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)modulesTitles {
    if (!_modulesTitles) {
        self.modulesTitles = [NSMutableArray array];
    }
    return _modulesTitles;
}

#pragma mark - NSNotificationCenter 通知方法

- (void)refreshForAddBlog:(NSNotificationCenter *)notification {
    InformationTableViewController *currentVC = (InformationTableViewController *)self.childViewControllers[self.currentPage];
    [currentVC setupRefresh];
}

#pragma mark - 销毁通知

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshForAddBlog" object:nil];
}

#pragma mark - loadBlogChannelData 加载慢病博客频道数据

- (void)loadBlogChannelData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        [manager GET:BlogChannelBaseUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.blogClassificationModels = [BlogClassificationModel objectArrayWithKeyValuesArray:[responseObject valueForKey:@"List"]];
            for (BlogClassificationModel *blogClassificationModel in self.blogClassificationModels) {
                [self.modulesTitles addObject:blogClassificationModel.ModeName];
            }
            
            [self addInformationChannelSegmented];
            [self addController];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showInfoWithStatus:DataLoadFailureTip maskType:SVProgressHUDMaskTypeNone];
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
}

- (void)addInformationChannelSegmented {
    //设置分段控件segmentedControl
    
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:self.modulesTitles];
    
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
        CGFloat offsetY = weakSelf.blogScroll.contentOffset.y;
        CGPoint offset = CGPointMake(offsetX, offsetY);
        [weakSelf.blogScroll setContentOffset:offset animated:YES];
    }];
}

#pragma mark - addController 加载子控制器

- (void)addController {
    
    InformationTableViewController *informationTableView = nil;
    
    for (BlogClassificationModel *blogClassificationModel in self.blogClassificationModels) {
        informationTableView = [self.storyboard instantiateViewControllerWithIdentifier:@"informationTableView"];
        //拼接生成某频道的url
        informationTableView.url = [NSString stringWithFormat:@"%@ClassID=%@&ModeID=%@&PageID=1&PageSize=20", BlogBaseUrl, self.ClassID, blogClassificationModel.ModeID];
        
        [self addChildViewController:informationTableView];
    }
    
    //首次默认加载第一个子控制器
    InformationTableViewController *firstInformationVC = [self.childViewControllers firstObject];
    firstInformationVC.view.frame = self.blogScroll.bounds;
    [self.blogScroll addSubview:firstInformationVC.view];
    
    self.currentPage = 0;
    
    //设置下方内容scrollView(即serviceScroll)的contentSize
    CGFloat contentX = (self.childViewControllers.count) * WIDTH;
    self.blogScroll.contentSize = CGSizeMake(contentX, 0);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.blogScroll]) {
        
        CGFloat pageWidth = scrollView.frame.size.width;
        NSInteger page = scrollView.contentOffset.x / pageWidth;
        
        self.currentPage = page;
        
        [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
        
        //添加滑动后所在位置对应的子控制器
        UIViewController *newsVc = self.childViewControllers[page];
        if (newsVc.view.superview) return;
        
        newsVc.view.frame = scrollView.bounds;
        [self.blogScroll addSubview:newsVc.view];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addCommonBlogJump"]) {  //普通博客发布执行此跳转
        ReportStateViewController *reportStateViewController = segue.destinationViewController;
        if ([reportStateViewController respondsToSelector:@selector(setForumChannelModels:)]) {
            
            [reportStateViewController setValue:self.informationChannelModels forKey:@"forumChannelModels"];
        }
        
        if ([reportStateViewController respondsToSelector:@selector(setAddIdentify:)]) {
            [reportStateViewController setValue:@"commonBlogAdd" forKey:@"addIdentify"];
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
