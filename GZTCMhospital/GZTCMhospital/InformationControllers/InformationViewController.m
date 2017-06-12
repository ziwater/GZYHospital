//
//  InformationViewController.m
//  GZTCMhospital
//
//  Created by Chris on 15/8/26.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "InformationViewController.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "HMSegmentedControl.h"
#import "SVProgressHUD.h"

#import "InformationChannelModel.h"
#import "BlogChannelModel.h"
#import "InformationTableViewController.h"
#import "CheckNetWorkStatus.h"
#import "ReportStateViewController.h"

#define VIEW_WIDTH  CGRectGetWidth(self.view.frame)
#define WIDTH [UIScreen mainScreen].bounds.size.width

@interface InformationViewController ()

@end

@implementation InformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(setEnableAddItem) name:@"setEnableAddItem" object:nil];
    
    if ([self.type isEqualToString:@"blog"]) {
        [self loadBlogChannelData];
    }
    if ([self.type isEqualToString:@"forum"]) {
        [self loadInformationChannelDataWithType:self.type];
    }
    if ([self.type isEqualToString:@"information"]) {
        [self loadInformationChannelDataWithType:self.type];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotificationCenter 通知方法

- (void)setEnableAddItem {
    [self.navigationItem.rightBarButtonItems.firstObject setEnabled:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"setEnableAddItem" object:nil];
}

#pragma mark - UIBarButtonItem Action method

- (void)startSearch {
    [self performSegueWithIdentifier:@"secondSearch" sender:nil];
}

- (void)addForum {
    [self performSegueWithIdentifier:@"addForum" sender:nil];
}

#pragma mark - loadBlogChannelData: 加载首页慢病博客 频道切换导航栏数据

- (void)loadBlogChannelData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        [manager GET:ChronicDiseaseBlogUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.blogChannelModels = [BlogChannelModel objectArrayWithKeyValuesArray:[responseObject valueForKey:@"List"]];
            
            [self addInformationChannelSegmentedWithTpye:self.type]; //加载首页慢病博客/论坛频道切换segment
            [self addControllerWithType:self.type]; //添加子控制器
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showInfoWithStatus:DataLoadFailureTip maskType:SVProgressHUDMaskTypeNone];
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
}

#pragma mark - loadInformationChannelDataWithType: 加载资讯/慢病论坛 频道切换导航栏数据

- (void)loadInformationChannelDataWithType:(NSString *)type {
    
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        NSString *urlString = [NSString stringWithFormat:@"%@EditionID=%@",InformatonChannelBaseUrl, self.editionID];
        [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.informationChannelModels = [InformationChannelModel objectArrayWithKeyValuesArray:[responseObject valueForKey:@"List"]];
            
            [self addInformationChannelSegmentedWithTpye:type]; //加载资讯频道切换segment
            [self addControllerWithType:self.type]; //添加子控制器
            
            //发出通知，变加号可用
            if ([type isEqualToString:@"forum"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setEnableAddItem" object:nil];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showInfoWithStatus:DataLoadFailureTip maskType:SVProgressHUDMaskTypeNone];
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
}

- (void)addInformationChannelSegmentedWithTpye:(NSString *)type {
    NSMutableArray *modules = [NSMutableArray array];
    if ([type isEqualToString:@"blog"]) {
        for (BlogChannelModel *blogChannelModel in self.blogChannelModels) {
            [modules addObject:blogChannelModel.ClassName];
        }
    }
    if ([type isEqualToString:@"information"] || [type isEqualToString:@"forum"]) {
        for (InformationChannelModel *informationChannelModel in self.informationChannelModels) {
            [modules addObject:informationChannelModel.FormName];
        }
    }
    
    //设置分段控件segmentedControl
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, VIEW_WIDTH, 40)];
    self.segmentedControl.sectionTitles = modules;
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segmentedControl.backgroundColor = [UIColor clearColor];
    self.segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor],NSFontAttributeName : [UIFont systemFontOfSize:15.0]};
    
    self.segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:0.5 green:0.8 blue:1 alpha:1]};
    self.segmentedControl.selectionIndicatorHeight = 2.0f;
    self.segmentedControl.selectionIndicatorColor = [UIColor colorWithRed:0.5 green:0.8 blue:1 alpha:1];
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    
    [self.segmentView addSubview:self.segmentedControl];
    
    __weak typeof(self) weakSelf = self;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        CGFloat offsetX = VIEW_WIDTH * index;
        CGFloat offsetY = weakSelf.serviceScroll.contentOffset.y;
        CGPoint offset = CGPointMake(offsetX, offsetY);
        [weakSelf.serviceScroll setContentOffset:offset animated:YES];
    }];
}

- (void)addControllerWithType:(NSString *)type {
    
    InformationTableViewController *informationTableView = nil;
    
    if ([type isEqualToString:@"blog"]) {
        for (BlogChannelModel *blogChannelModel in self.blogChannelModels) {
            informationTableView = [self.storyboard instantiateViewControllerWithIdentifier:@"informationTableView"];
            
            //拼接生成某频道的url
            informationTableView.url = [NSString stringWithFormat:@"%@ClassID=%@&PageID=1&PageSize=20",BlogBaseUrl, blogChannelModel.ClassID];
            
            [self addChildViewController:informationTableView];
        }
    }
    
    if ([type isEqualToString:@"information"] || [type isEqualToString:@"forum"]) {
        for (InformationChannelModel *informationChannelModel in self.informationChannelModels) {
            informationTableView = [self.storyboard instantiateViewControllerWithIdentifier:@"informationTableView"];
            
            //拼接生成某频道的url
            informationTableView.url = [NSString stringWithFormat:@"%@FormID=%@&PageID=1&PageSize=20", InformationBaseUrl, informationChannelModel.FormID];
            
            [self addChildViewController:informationTableView];
        }
    }
    
    //首次默认加载第一个子控制器
    InformationTableViewController *firstInformationVC = [self.childViewControllers firstObject];
    firstInformationVC.view.frame = self.serviceScroll.bounds;
    [self.serviceScroll addSubview:firstInformationVC.view];
    
    InformationChannelModel *informationChannelModel = self.informationChannelModels.firstObject;
    self.formID = informationChannelModel.FormID; //用于prepareForSegue传值，用于搜索及发帖
    
    //设置下方内容scrollView(即serviceScroll)的contentSize
    CGFloat contentX = (self.childViewControllers.count) * WIDTH;
    self.serviceScroll.contentSize = CGSizeMake(contentX, 0);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = scrollView.contentOffset.x / pageWidth;
    
    [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
    
    InformationChannelModel *informationChannelModel = self.informationChannelModels[page];
    self.formID = informationChannelModel.FormID; //用于prepareForSegue传值，用于搜索及发帖
    
    //添加滑动后所在位置对应的子控制器
    InformationTableViewController *newsVc = self.childViewControllers[page];
    if (newsVc.view.superview) return;
    
    newsVc.view.frame = scrollView.bounds;
    [self.serviceScroll addSubview:newsVc.view];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

#pragma mark - prepareForSegue 数据传递 - 搜索/发帖

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"secondSearch"]) {
        
        UIViewController *searchViewController = segue.destinationViewController;
        if ([searchViewController respondsToSelector:@selector(setEditionID:)]) {
            [searchViewController setValue:self.editionID forKey:@"editionID"];
        }
        if ([searchViewController respondsToSelector:@selector(setFormID:)]) {
            [searchViewController setValue:self.formID forKey:@"formID"];
        }
    }
    if ([segue.identifier isEqualToString:@"addForum"]) {
        UIViewController *reportStateViewController = segue.destinationViewController;
        if ([reportStateViewController respondsToSelector:@selector(setForumChannelModels:)]) {
            [reportStateViewController setValue:self.informationChannelModels forKey:@"forumChannelModels"];
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
