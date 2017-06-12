//
//  InformationListCollectionView.m
//  GZTCMhospital
//
//  Created by Chris on 15/8/27.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "InformationListCollectionView.h"

#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"

#import "InformationListModel.h"
#import "InformationCollectionViewCell.h"
#import "InformationSupplementaryView.h"
#import "CheckNetWorkStatus.h"
#import "InformationViewController.h"

#define EachRowNumberOfCell 3
#define MinSpacingForCells  0

@interface InformationListCollectionView ()

@end

@implementation InformationListCollectionView

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadInformationListData];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loadInformationListData 加载资讯九宫格数据

- (void)loadInformationListData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        [manager GET:InformationListUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.informationListModels = [InformationListModel objectArrayWithKeyValuesArray:[responseObject valueForKeyPath:@"List"]];
            self.informationListTopImageUrl = [responseObject valueForKeyPath:@"TopImageUrl"];
            [self.collectionView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showInfoWithStatus:DataLoadFailureTip maskType:SVProgressHUDMaskTypeNone];
            NSLog(@"Error: %@", error);
        }];
        
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
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
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.informationListModels.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *collectionCell = @"informationListCell";
    InformationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCell forIndexPath:indexPath];
    
    self.informationListModel = self.informationListModels[indexPath.item];
    cell.informationListLabel.text = self.informationListModel.EditionName;
    [cell.informationListImageView sd_setImageWithURL:[NSURL URLWithString:self.informationListModel.IconUrl] placeholderImage:[UIImage imageNamed:@"news_item_default"]];
    
    //为collectionView绘制网格线
    //添加水平分隔线
    UIView *horizontalSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y + cell.frame.size.height, cell.frame.size.width, 0.4)];
    
    //添加垂直分隔线
    UIView *verticalSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.origin.x + cell.frame.size.width, cell.frame.origin.y, 0.4, cell.frame.size.height)];
    
    horizontalSeparatorView.backgroundColor = RGBColor(221, 221, 221);
    verticalSeparatorView.backgroundColor = RGBColor(221, 221, 221);
    
    
    [collectionView addSubview:horizontalSeparatorView];
    [collectionView addSubview:verticalSeparatorView];
    
    [collectionView bringSubviewToFront:horizontalSeparatorView];
    [collectionView bringSubviewToFront:verticalSeparatorView];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusableHeader = @"informationListHeader";
    InformationSupplementaryView *header = nil;
    
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reusableHeader forIndexPath:indexPath];
        [header.informationListHeaderImageView sd_setImageWithURL:[NSURL URLWithString:self.informationListTopImageUrl] placeholderImage:[UIImage imageNamed:@"news_pic_default"]];
    }
    return header;
}

//动态设置collectionCell的size，以适应不同屏幕尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize cellSize;
    cellSize.width = self.collectionView.frame.size.width / EachRowNumberOfCell;
    cellSize.width = cellSize.width - MinSpacingForCells;
    cellSize = CGSizeMake(cellSize.width, (self.collectionView.frame.size.width / 4));
    return cellSize;
}

#pragma mark - prepareForSegue 数据传递

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"informationJump"]) {
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        
        UIViewController *informationViewController = segue.destinationViewController;
        self.informationListModel  = self.informationListModels[selectedIndexPath.item];
        informationViewController.title = self.informationListModel.EditionName;
        
        //设置rightBarButtonItem(搜索)
        UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:informationViewController action:@selector(startSearch)];
        informationViewController.navigationItem.rightBarButtonItem = searchItem;
        
        if ([informationViewController respondsToSelector:@selector(setEditionID:)]) {
            [informationViewController setValue: self.informationListModel.EditionID forKey:@"editionID"];
        }
        if ([informationViewController respondsToSelector:@selector(setType:)]) {
             [informationViewController setValue:@"information" forKey:@"type"];
        }
    }
}

#pragma mark <UICollectionViewDelegate>

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
