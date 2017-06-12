//
//  InformationTableViewController.m
//  GZTCMhospital
//
//  Created by Chris on 15/8/26.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "InformationTableViewController.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "UITableView+Improve.h"

#import "InformationItemModel.h"
#import "InformationModel.h"
#import "InformationCell.h"
#import "NoImageInformationCell.h"
#import "BlogCell.h"
#import "InformationWebView.h"
#import "CheckNetWorkStatus.h"
#import "ReportStateViewController.h"
#import "InformationChannelModel.h"
#import "BlogChannelModel.h"

static const CGFloat delayTime = 1.0;

#define kNewsCellHeight 80
#define kNumberOfItemsEachLoad 20

@interface InformationTableViewController ()

@property (nonatomic, assign) int more;

@property (nonatomic, strong) NSArray *blogChannelModels;
@property (nonatomic, strong) NSMutableArray *tempInformationChannelModels;
@property (nonatomic, strong) NSArray *blogChannelModelsToTransfer;

@end

@implementation InformationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.more = 0;
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    //注册新增论坛、我的博客刷新tableView的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshForAddForumOrMyBlog:) name:@"refreshForAddForumOrMyBlog" object:nil];
    
    //加载我的博客-频道列表
    if ([self.addIdentify isEqualToString:@"myBlogAdd"]) {
        [self loadBlogClassification];
    }
    
    //论坛-根据传递来的informationChannelModels发出通知显示增加
    if ([self.addIdentify isEqualToString:@"forumAdd"]) {
        if (self.informationChannelModels.count) {
            self.navigationItem.rightBarButtonItem = self.addForumBarItem;
        }
    }
    
    [self setupRefresh]; //集成刷新控件
    
    
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

//初始化_newsArray（懒加载模式）
- (NSMutableArray *)newsArray {
    if (!_newsArray) {
        self.newsArray = [NSMutableArray array];
    }
    return _newsArray;
}

//初始化_moreUrlArray（懒加载模式）
- (NSMutableArray *)moreUrlArray {
    if (!_moreUrlArray) {
        self.moreUrlArray = [NSMutableArray array];
    }
    return _moreUrlArray;
}

- (NSMutableArray *)tempInformationChannelModels {
    if (!_tempInformationChannelModels) {
        self.tempInformationChannelModels = [NSMutableArray array];
    }
    return _tempInformationChannelModels;
}

#pragma mark - NSNotificationCenter 通知方法

- (void)refreshForAddForumOrMyBlog:(NSNotificationCenter *)notification {
    [self loadNewData];
}

#pragma mark - 销毁通知

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshForAddForumOrMyBlog" object:nil];
}

#pragma mark - loadBlogClassification 加载我的博客分类信息

- (void)loadBlogClassification {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        [manager GET:ChronicDiseaseBlogUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            self.blogChannelModels = [BlogChannelModel objectArrayWithKeyValuesArray:[responseObject valueForKeyPath:@"List"]];
            
            for (BlogChannelModel *blogChannelModel in self.blogChannelModels) {
                InformationChannelModel *tempInformationChannelModel = [[InformationChannelModel alloc] init];
                tempInformationChannelModel.EditionID = blogChannelModel.FatherClassID;
                tempInformationChannelModel.FormID = blogChannelModel.ClassID;
                tempInformationChannelModel.FormName = blogChannelModel.ClassName;
                [self.tempInformationChannelModels addObject:tempInformationChannelModel];
            }
            
            self.blogChannelModelsToTransfer = self.tempInformationChannelModels;
            
            //我的博客-根据转换的blogChannelModelsToTransfer发出通知显示增加
            if ([self.addIdentify isEqualToString:@"myBlogAdd"]) {
                if (self.blogChannelModelsToTransfer.count) {
                    self.navigationItem.rightBarButtonItem = self.addForumBarItem;
                }
            }
            
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
    //集成下拉刷新控件
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadNewData];
    }];
    
    // 马上进入刷新状态
    [self.tableView.header beginRefreshing];
    
    //集成上拉加载更多控件
    //设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData];
    }];
    
    // 默认先隐藏footer
    self.tableView.footer.hidden = YES;
}

- (void)loadNewData { //下拉刷新数据
    [self loadNetworkData:self.url withType:@"dropDownRefresh"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
        [self.tableView reloadData];
        
    });
}

- (void)loadMoreData { //上拉加载更多数据;
    if (self.moreUrlArray.count) {
        if (_more < self.moreUrlArray.count) {
            self.moreURL = self.moreUrlArray[_more];
            [self loadNetworkData:self.moreURL withType:@"pullToRefresh"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 刷新表格
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

#pragma mark - loadNetworkData: 加载资讯页网络数据

- (void)loadNetworkData:(NSString *) url withType:(NSString *) type {
    if (url) {
        
        [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
            AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
            
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([type isEqualToString:@"dropDownRefresh"]) {
                    self.more = 0;
                    [self.newsArray removeAllObjects];
                    [self.moreUrlArray removeAllObjects];
                }
                
                self.informationItemModel = [InformationItemModel objectWithKeyValues:responseObject];
                
                [self.newsArray addObjectsFromArray:self.informationItemModel.List];
                
                if ([type isEqualToString:@"dropDownRefresh"]) {
                    for (NSInteger i = 2; i <= (long)ceilf((float)self.informationItemModel.Count / kNumberOfItemsEachLoad); i++) {
                        
                        NSString *newPageID = [NSString stringWithFormat:@"PageID=%ld", (long)i];
                        self.moreURL = [url stringByReplacingOccurrencesOfString:@"PageID=1" withString:newPageID];
                        [self.moreUrlArray addObject:self.moreURL];
                    }
                }
                [self.tableView reloadData];
                
                // 拿到当前的下拉刷新控件，结束刷新状态
                [self.tableView.header endRefreshing];
                // 拿到当前的上拉刷新控件，结束刷新状态
                [self.tableView.footer endRefreshing];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                [self.tableView.header endRefreshing];
                [self.tableView.footer endRefreshing];
                [SVProgressHUD showInfoWithStatus:DataLoadFailureTip maskType:SVProgressHUDMaskTypeNone];
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
    return kNewsCellHeight;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 设置尾部控件的显示和隐藏
    self.tableView.footer.hidden = self.newsArray.count == 0;
    
    return self.newsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InformationCell *informationCell = nil;
    
    if (self.newsArray.count) {
        InformationModel *informationModel = self.newsArray[indexPath.row];
        
        if (informationModel.PortraitMicroimageUrl.length) {
            
            BlogCell *blogCell = [tableView dequeueReusableCellWithIdentifier:@"blogCell" forIndexPath:indexPath];
            [blogCell.portraitImage sd_setImageWithURL:[NSURL URLWithString:informationModel.PortraitMicroimageUrl] placeholderImage:[UIImage imageNamed:@"news_item_default"]];
            blogCell.blogTitle.text = informationModel.Title;
            blogCell.publisher.text = informationModel.StafferName;
            blogCell.newsPubdate.text = [informationModel.ModifyDateTime substringToIndex:10];
            blogCell.commentNumber.text = [NSString stringWithFormat:@"%ld", (long)informationModel.CommentNumber];
            return blogCell;
            
        } else if (informationModel.PictureMicroimageUrl.length) {
            informationCell = [tableView dequeueReusableCellWithIdentifier:@"newsCell" forIndexPath:indexPath];
            
            [informationCell.newsImage sd_setImageWithURL:[NSURL URLWithString:informationModel.PictureMicroimageUrl] placeholderImage:[UIImage imageNamed:@"news_item_default"]];
            informationCell.newsTitle.text = informationModel.Title;
            informationCell.newsPubdate.text = [informationModel.ModifyDateTime substringToIndex:10];
            informationCell.commentNumber.text = [NSString stringWithFormat:@"%ld", (long)informationModel.CommentNumber];
            
            return informationCell;
        } else {
            NoImageInformationCell *noInformationCell = [tableView dequeueReusableCellWithIdentifier:@"noImageNewsCell" forIndexPath:indexPath];
            
            noInformationCell.newsTitle.text = informationModel.Title;
            noInformationCell.newsPubdate.text = [informationModel.ModifyDateTime substringToIndex:10];
            noInformationCell.commentNumber.text = [NSString stringWithFormat:@"%ld", (long)informationModel.CommentNumber];
            
            return noInformationCell;
        }
    } else {
        informationCell = [tableView dequeueReusableCellWithIdentifier:@"newsCell" forIndexPath:indexPath];
        return informationCell;
    }
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"newsLink"] || [segue.identifier isEqualToString:@"noImageNewsLink"] || [segue.identifier isEqualToString:@"blogLink"]) {
        InformationWebView *destination = segue.destinationViewController;
        if ([destination respondsToSelector:@selector(setInformationModel:)]) {
            NSIndexPath *selectIndexPath = [self.tableView indexPathForSelectedRow];
            if (self.newsArray.count > 0) {
                InformationModel *informationModel = self.newsArray[selectIndexPath.row];
                [destination setValue:informationModel forKey:@"informationModel"];
            }
        }
    }
    
    if ([segue.identifier isEqualToString:@"addNewForumOrMyBlogJump"]) {  //论坛、我的博客发布执行此跳转
        ReportStateViewController *reportStateViewController = segue.destinationViewController;
        if ([reportStateViewController respondsToSelector:@selector(setForumChannelModels:)]) {
            
            if ([self.addIdentify isEqualToString:@"forumAdd"]) { //论坛传递informationChannelModels
                [reportStateViewController setValue:self.informationChannelModels forKey:@"forumChannelModels"];
            }
            
            if ([self.addIdentify isEqualToString:@"myBlogAdd"]) { //我的博客传递blogChannelModelsToTransfer
                [reportStateViewController setValue:self.blogChannelModelsToTransfer forKey:@"forumChannelModels"];
            }
        }
        
        if ([reportStateViewController respondsToSelector:@selector(setAddIdentify:)]) {
            [reportStateViewController setValue:self.addIdentify forKey:@"addIdentify"];
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
