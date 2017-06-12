//
//  MyViewController.m
//  GZTCMhospital
//
//  Created by Chris on 16/1/12.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "MyViewController.h"

#import "MJExtension.h"
#import "UINavigationBar+Awesome.h"
#import "HFStretchableTableHeaderView.h"
#import "UIImageView+WebCache.h"

#import "MyLayoutModel.h"
#import "MyLayoutSectionModel.h"
#import "InformationTableViewController.h"

#define StretchHeaderHeight 240

@interface MyViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) HFStretchableTableHeaderView *stretchHeaderView;
@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UILabel *userInfo;

@property (nonatomic, strong) MyLayoutModel *myLayoutModel;
@property (nonatomic, strong) NSArray *myLayoutSectionModels;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
   
    [self initStretchHeader];
    
    [self loadMyLayoutData];
    
    //向通知中心注册通知 - 显示用户名
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserInfo:) name:@"showUserInfo" object:nil];
    
    //向通知中心注册通知 - 显示用户头像
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPortrait:) name:@"showPortrait" object:nil];
    
    //自动登录显示用户名
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults objectForKey:@"OperatorID"]) { //OperatorID有值则可进行自动登录
        
        //OperatorID有值，发出通知,通知”我的“页面显示用户名
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showUserInfo" object:[userDefaults objectForKey:@"StafferName"]];
        //发出通知，通知"我的"页面显示用户头像
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showPortrait" object:[userDefaults objectForKey:@"PortraitMicroimageUrl"]];
    }

    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.mineTable deselectRowAtIndexPath:[self.mineTable indexPathForSelectedRow] animated:YES];
    [self.navigationController.navigationBar lt_reset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 通知方法

- (void)showUserInfo:(NSNotification *)notification {
    self.userInfo.text = notification.object;
}

- (void)showPortrait:(NSNotification *)notification {
    [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:notification.object] placeholderImage:[UIImage imageNamed:@"loginOrRegister"]];
}

#pragma mark - loadMyLayoutData 加载我的布局data

- (void)loadMyLayoutData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"myLayoutData" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    self.myLayoutSectionModels = [MyLayoutSectionModel objectArrayWithKeyValuesArray:[dict valueForKeyPath:@"data"]];
}

- (void)initStretchHeader {
    //背景
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, StretchHeaderHeight)];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.clipsToBounds = YES;
    bgImageView.image = [UIImage imageNamed:@"loginbackground"];
    
    //背景之上的内容
    UIView *contentView = [[UIView alloc] initWithFrame:bgImageView.bounds];
    contentView.backgroundColor = [UIColor clearColor];
    
    self.portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    self.portraitImageView.image = [UIImage imageNamed:@"loginOrRegister"];
    self.portraitImageView.center = contentView.center;
    
    [self.portraitImageView.layer setCornerRadius:(self.portraitImageView.frame.size.height/2)];
    [self.portraitImageView.layer setMasksToBounds:YES];
    [self.portraitImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.portraitImageView setClipsToBounds:YES];
    self.portraitImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.portraitImageView.layer.shadowOffset = CGSizeMake(4, 4);
    self.portraitImageView.layer.shadowOpacity = 0.5;
    self.portraitImageView.layer.shadowRadius = 2.0;
    self.portraitImageView.userInteractionEnabled = YES;
    self.portraitImageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.portraitImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginOrRegisterAction:)];
    [self.portraitImageView addGestureRecognizer:singleTap];
    
    [contentView addSubview:self.portraitImageView];
    
    self.userInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    self.userInfo.text = LoginImmediately;
    self.userInfo.textColor = [UIColor whiteColor];
    self.userInfo.textAlignment = NSTextAlignmentCenter;
    self.userInfo.font = [UIFont systemFontOfSize:14.0];
    CGPoint point = CGPointMake(contentView.center.x, contentView.center.y + 65.0);
    self.userInfo.center = point;
    [contentView addSubview:self.userInfo];
    
    self.stretchHeaderView = [HFStretchableTableHeaderView new];
    [self.stretchHeaderView stretchHeaderForTableView:self.mineTable withView:bgImageView subViews:contentView];
}

#pragma mark - loginOrRegisterAction

- (void)loginOrRegisterAction:(UITapGestureRecognizer *)recognizer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"OperatorID"]) { //没有登录时
        [self performSegueWithIdentifier:@"login" sender:nil];
    } else {
        [self performSegueWithIdentifier:@"showUserInformation" sender:nil];
    }
}

#pragma mark - stretchableTable delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.stretchHeaderView scrollViewDidScroll:scrollView];
}

- (void)viewDidLayoutSubviews {
    [self.stretchHeaderView resizeView];
}

#pragma mark - 移除通知

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showUserInfo" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showPortrait" object:nil];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 8.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (indexPath.section == 0) {
        if (![userDefaults objectForKey:@"OperatorID"]) { //没有登录时
            [self performSegueWithIdentifier:@"login" sender:nil];
        } else {
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"showUserInformation" sender:nil];
            }
            if (indexPath.row == 1) {
                [self performSegueWithIdentifier:@"showMyBlogJump" sender:nil];
            }
        }
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if (![userDefaults objectForKey:@"OperatorID"]) { //没有登录时
                [self performSegueWithIdentifier:@"login" sender:nil];
            } else {
                [self performSegueWithIdentifier:@"questionAndAnswerJump" sender:nil];
            }
        }
        if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"myDocumentJump" sender:nil];
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"settingJump" sender:nil];
        }
    }
}

#pragma mark UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)[self.myLayoutSectionModels[section] valueForKeyPath:@"items"]).count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.myLayoutSectionModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    MyLayoutSectionModel *myLayoutSectionModel = self.myLayoutSectionModels[indexPath.section];
    self.myLayoutModel = myLayoutSectionModel.items[indexPath.row];
    cell.textLabel.text = self.myLayoutModel.title;
    cell.imageView.image = [UIImage imageNamed:self.myLayoutModel.icon];
    
    return cell;
}


#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showMyBlogJump"]) {
        InformationTableViewController *informationTableViewController = segue.destinationViewController;
        
        informationTableViewController.title = [NSString stringWithFormat:@"%@%@", GetStafferName, SomebodyBlog];
        NSString *urlString = [NSString stringWithFormat:@"%@StafferID=%@&OperatorID=%@&PageID=1&PageSize=20", MyBlogBaseUrl, GetStafferID, GetOperatorID];
        if ([informationTableViewController respondsToSelector:@selector(setUrl:)]) {
            [informationTableViewController setValue:urlString forKey:@"url"];
        }
        
        if ([informationTableViewController respondsToSelector:@selector(setAddIdentify:)]) {
            [informationTableViewController setValue:@"myBlogAdd" forKey:@"addIdentify"];
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
