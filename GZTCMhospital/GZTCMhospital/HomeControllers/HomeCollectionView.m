//
//  HomeCollectionView.m
//  GZTCMhospital
//
//  Created by Chris on 15/8/31.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "HomeCollectionView.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "AdView.h"
#import "QRViewController.h"
#import "SVProgressHUD.h"
#import "WZLBadgeImport.h"

#import "HomeTopNewsCollectionViewCell.h"
#import "HomeCollectionViewCell.h"
#import "HomeHeaderSupplementaryView.h"
#import "InformationModel.h"
#import "HomeModel.h"
#import "HomeSectionModel.h"
#import "HomeItemModel.h"
#import "CheckNetWorkStatus.h"
#import "InformationWebView.h"
#import "CommonWebView.h"
#import "InformationViewController.h"
#import "DiseaseListTableView.h"
#import "DoctorListTableView.h"
#import "RemindFunctionTableView.h"

#define EachRowNumberOfCell 3
#define MinSpacingForCells  0
#define HeightForTopNews 193
#define HeightForHomeHeaderSupplementary 44

@interface HomeCollectionView ()

@property (nonatomic, weak) UIImageView *imageViewForBadge;
@property (nonatomic, copy) NSString *whetherShowRemindBadge;

@end

@implementation HomeCollectionView

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //通知中心注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBadgeForItem:) name:@"showBadgeForItem" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanBadgeForItem:) name:@"cleanBadgeForItem" object:nil];
    
    [self setupRefresh];
    
    [self loadHomeModuleData];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotificationCenter 通知方法

- (void)showBadgeForItem:(NSNotification *)notification {
    [self.imageViewForBadge showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
    self.whetherShowRemindBadge = @"showNewRemindBadge";
}

- (void)cleanBadgeForItem:(NSNotification *)notificaton {
    [self.imageViewForBadge clearBadge];
    self.whetherShowRemindBadge = nil;
}

#pragma mark - 移除通知

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showBadgeForItem" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cleanBadgeForItem" object:nil];
}

#pragma mark - setupRefresh 集成下拉刷新

- (void)setupRefresh {
    self.collectionView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [self loadHomeTopNewsData];
    }];
    [self.collectionView.header beginRefreshing];
}

#pragma mark - loadHomeTopNewsData 加载首页topNews数据

- (void)loadHomeTopNewsData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        [manager GET:HomeTopNewsUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.homeTopNewsModels = [InformationModel objectArrayWithKeyValuesArray:[responseObject valueForKeyPath:@"List"]];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            
            [self.collectionView.header endRefreshing]; // 结束刷新
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showInfoWithStatus:DataLoadFailureTip maskType:SVProgressHUDMaskTypeNone];
            [self.collectionView.header endRefreshing]; // 结束刷新
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
        [self.collectionView.header endRefreshing]; // 结束刷新
    }];
}

#pragma mark - loadHomeModuleData 加载首页功能模块数据

- (void)loadHomeModuleData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"homeModuleData" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    HomeModel *homeModel = [HomeModel objectWithKeyValues:dict];
    self.homeSectionModels = homeModel.data;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    self.homeSectionModel = self.homeSectionModels[section - 1];
    return self.homeSectionModel.moduleItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *homeTopNewsCellReuseIdentifier = @"homeTopNewsCell";
    static NSString *homeCellReuseIdentifier = @"homeCell";
    
    if (indexPath.section == 0) {
        HomeTopNewsCollectionViewCell *homeTopNewsCell = [collectionView dequeueReusableCellWithReuseIdentifier:homeTopNewsCellReuseIdentifier forIndexPath:indexPath];
        
        homeTopNewsCell.advertisements = self.homeTopNewsModels;
        
        //图片被点击后回调的方法
        homeTopNewsCell.adView.callBack = ^(NSInteger index,NSString * adlinkURL)
        {
            InformationWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"informationWebView"];
            
            InformationModel *temp = [[InformationModel alloc] init];
            temp.Title = [self.homeTopNewsModels[index] valueForKeyPath:@"Title"];
            temp.FormID = [self.homeTopNewsModels[index] valueForKeyPath:@"FormID"];
            temp.DetailID = [self.homeTopNewsModels[index] valueForKeyPath:@"DetailID"];
            temp.PictureMicroimageUrl = [self.homeTopNewsModels[index] valueForKeyPath:@"PictureMicroimageUrl"];
            temp.ModifyDateTime = [self.homeTopNewsModels[index] valueForKeyPath:@"ModifyDateTime"];
            temp.CommentNumber = [[self.homeTopNewsModels[index] valueForKeyPath:@"CommentNumber"] integerValue];
            temp.ContentSummary = [self.homeTopNewsModels[index] valueForKeyPath:@"ContentSummary"];
            
            webVC.informationModel = temp;
            
            //InformationTableView作为子控制器被add到InformationController中，而InformationController是具体有navigationController的，故InformationTableView也具有navigationController（指向同一个Navi）
            [self.navigationController pushViewController:webVC animated:YES];
        };
        return homeTopNewsCell;
        
    } else {
        HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:homeCellReuseIdentifier forIndexPath:indexPath];
        self.homeSectionModel = self.homeSectionModels[indexPath.section - 1];
        self.homeItemModel = self.homeSectionModel.moduleItems[indexPath.item];
        
        cell.homeFunctionModuleImageView.image = [UIImage imageNamed:self.homeItemModel.moduleImage];
        cell.homeFunctionModuleLabel.text = self.homeItemModel.moduleName;
        
        if (indexPath.section == 1) {
            if (indexPath.item == 6) {
                self.imageViewForBadge = cell.homeFunctionModuleImageView;
            }
        }
        
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    static NSString *homeHeaderSupplementaryReuseIdentifier = @"homeHeader";
    HomeHeaderSupplementaryView *homeHeaderSupplementaryView = nil;
    
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        homeHeaderSupplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:homeHeaderSupplementaryReuseIdentifier forIndexPath:indexPath];
        if (indexPath.section != 0) {
            self.homeSectionModel = self.homeSectionModels[indexPath.section - 1];
            homeHeaderSupplementaryView.homeSectionHeaderLabel.text = self.homeSectionModel.moduleHeaderTitle;
        }
    }
    return homeHeaderSupplementaryView;
}

//动态设置collectionCell的size，以适应不同屏幕尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return CGSizeMake(self.collectionView.frame.size.width, HeightForTopNews);
    }
    
    CGSize cellSize;
    cellSize.width = self.collectionView.frame.size.width / EachRowNumberOfCell;
    cellSize.width = cellSize.width - MinSpacingForCells;
    cellSize = CGSizeMake(cellSize.width, (self.collectionView.frame.size.width / 3));
    return cellSize;
}

//设置Header的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeZero; //取消topnews的Header
    }
    return CGSizeMake(self.collectionView.frame.size.width, HeightForHomeHeaderSupplementary);
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //预约管理
        if (indexPath.item == 0) {
            if (![userDefaults objectForKey:@"OperatorID"]) { //没有登录时
                [self performSegueWithIdentifier:@"homeLogin" sender:nil];
            } else {
                [self performSegueWithIdentifier:@"showMyOrderFunctionJump" sender:MyOrder];
            }
        }
        //识别与评估
        if (indexPath.item == 1) {
            if (![userDefaults objectForKey:@"OperatorID"]) { //没有登录时
                [self performSegueWithIdentifier:@"homeLogin" sender:nil];
            } else {
                [self performSegueWithIdentifier:@"identifyAndEvaluateJump" sender:IdentifyAndEvaluate];
            }
        }
        //诊疗计划
        if (indexPath.item == 2) {
            if (![userDefaults objectForKey:@"OperatorID"]) { //没有登录时
                [self performSegueWithIdentifier:@"homeLogin" sender:nil];
            } else {
                [self performSegueWithIdentifier:@"identifyAndEvaluateJump" sender:TreatmentPlan];
            }
        }
        //日程管理
        if (indexPath.item == 3) {
            if (![userDefaults objectForKey:@"OperatorID"]) { //没有登录时
                [self performSegueWithIdentifier:@"homeLogin" sender:nil];
            } else {
                [self performSegueWithIdentifier:@"scheduleJump" sender:nil];
            }
        }
        //慢病宣教
        if (indexPath.item == 4) {
            if (![userDefaults objectForKey:@"OperatorID"]) { //没有登录时
                [self performSegueWithIdentifier:@"homeLogin" sender:nil];
            } else {
                [self performSegueWithIdentifier:@"identifyAndEvaluateJump" sender:SlowDiseaseCourse];
            }
        }
        //我的设备
        if (indexPath.item == 5) {
            [self performSegueWithIdentifier:@"myDeviceJump" sender:nil];
        }
        //提醒管理
        if (indexPath.item == 6) {
            if (![userDefaults objectForKey:@"OperatorID"]) { //没有登录时
                [self performSegueWithIdentifier:@"homeLogin" sender:nil];
            } else {
                [self performSegueWithIdentifier:@"remindJump" sender:RemindManagement];
            }
        }
        //统计分析
        if (indexPath.item == 7) {
            if (![userDefaults objectForKey:@"OperatorID"]) { //没有登录时
                [self performSegueWithIdentifier:@"homeLogin" sender:nil];
            } else {
                CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
                
                webVC.linkUrl = [NSString stringWithFormat:@"%@OperatorID=%@", StatisticalAnalysisBaseUrl, GetOperatorID];
                [self.navigationController pushViewController:webVC animated:YES];
            }
        }
        //备忘录
        if (indexPath.item == 8) {
            if (![userDefaults objectForKey:@"OperatorID"]) { //没有登录时
                [self performSegueWithIdentifier:@"homeLogin" sender:nil];
            } else {
                [self performSegueWithIdentifier:@"memorandumJump" sender:nil];
            }
        }
    }
    
    if (indexPath.section == 2) {
        //官方动态
        if (indexPath.item == 0) {
            [self performSegueWithIdentifier:@"officialDynamicJump" sender:nil];
        }
        //你问我答
        if (indexPath.item == 1) {
            [self performSegueWithIdentifier:@"forumJump" sender:nil];
        }
        //慢病博客
        if (indexPath.item == 2) {
            [self performSegueWithIdentifier:@"blogJump" sender:nil];
        }
    }
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"blogOrForumJump"]) {
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        UIViewController *informationViewController = segue.destinationViewController;
        
        self.homeSectionModel = self.homeSectionModels[selectedIndexPath.section - 1];
        self.homeItemModel = self.homeSectionModel.moduleItems[selectedIndexPath.item];
        
        informationViewController.title = self.homeItemModel.moduleName;
        
        if ([informationViewController respondsToSelector:@selector(setType:)]) {
            if (selectedIndexPath.item == 2) {
                [informationViewController setValue:@"blog" forKey:@"type"];
                
                //设置rightBarButtonItem(搜索)
                UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:informationViewController action:@selector(startSearch)];
                informationViewController.navigationItem.rightBarButtonItem = searchItem;
            } else if (selectedIndexPath.item == 1) {
                [informationViewController setValue:@"forum" forKey:@"type"];
                
                //设置rightBarButtonItem(搜索、加号)
                UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:informationViewController action:@selector(addForum)];
                addItem.enabled = NO;
                UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:informationViewController action:@selector(startSearch)];
                NSArray *barButtonArray = @[addItem, searchItem];
                informationViewController.navigationItem.rightBarButtonItems = barButtonArray;
            }
        }
        if ([informationViewController respondsToSelector:@selector(setEditionID:)]) {
            if (selectedIndexPath.item == 1) {
                [informationViewController setValue:@"909" forKey:@"editionID"];  //慢病论坛
            }
        }
    }
    
    if ([segue.identifier isEqualToString:@"identifyAndEvaluateJump"]) {
        UIViewController *diseaseListTableView = segue.destinationViewController;
        
        if ([sender isEqual:MyOrder]) {
            diseaseListTableView.title = sender;
            if ([diseaseListTableView respondsToSelector:@selector(setIdentifier:)]) {
                [diseaseListTableView setValue:@"myOrder" forKey:@"identifier"];
            }
        }
        if ([sender isEqual:IdentifyAndEvaluate]) {
            diseaseListTableView.title = sender;
            if ([diseaseListTableView respondsToSelector:@selector(setIdentifier:)]) {
                [diseaseListTableView setValue:@"identifyAndEvaluate" forKey:@"identifier"];
            }
        }
        if ([sender isEqual:SlowDiseaseCourse]) {
            diseaseListTableView.title = sender;
            if ([diseaseListTableView respondsToSelector:@selector(setIdentifier:)]) {
                [diseaseListTableView setValue:@"slowDiseaseCourse" forKey:@"identifier"];
            }
        }
        if ([sender isEqual:TreatmentPlan]) {
            diseaseListTableView.title = sender;
            if ([diseaseListTableView respondsToSelector:@selector(setIdentifier:)]) {
                [diseaseListTableView setValue:@"treatmentPlan" forKey:@"identifier"];
            }
        }
        if ([sender isEqual:RemindManagement]) {
            diseaseListTableView.title = sender;
            if ([diseaseListTableView respondsToSelector:@selector(setIdentifier:)]) {
                [diseaseListTableView setValue:@"remindManagement" forKey:@"identifier"];
            }
        }
    }
    
    if ([segue.identifier isEqualToString:@"remindJump"]) {
        RemindFunctionTableView *remindFunctionTableView = segue.destinationViewController;
        if ([remindFunctionTableView respondsToSelector:@selector(setShowNewRemindBadge:)]) {
            if (self.whetherShowRemindBadge) {
                [remindFunctionTableView setValue:self.whetherShowRemindBadge forKey:@"showNewRemindBadge"];
            }
        }
    }
}

#pragma mark - QrScan 二维码扫描

- (IBAction)QrScan:(UIBarButtonItem *)sender {
    if ([self validateCamera]) {
        
        [self showQRViewController];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:KindlyRemind message:CameraAlertMessage delegate:self cancelButtonTitle:CameraAlertCancel otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (BOOL)validateCamera {
    
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
    [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (void)showQRViewController {
    
    QRViewController *qrVC = [[QRViewController alloc] init];
    qrVC.hidesBottomBarWhenPushed = YES;
    qrVC.delegate = self;
    
    [self.navigationController pushViewController:qrVC animated:YES];
}

- (void)showScanResult:(NSString *)url {
    //二维码扫描结果处理
    CommonWebView *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commonWebView"];
    webVC.linkUrl = url;
    [self.navigationController pushViewController:webVC animated:YES];
}

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
 return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
 return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
 
 }
 */

@end
