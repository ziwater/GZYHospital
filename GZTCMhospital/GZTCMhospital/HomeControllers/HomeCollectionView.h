//
//  HomeCollectionView.h
//  GZTCMhospital
//
//  Created by Chris on 15/8/31.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeSectionModel;
@class HomeItemModel;

@interface HomeCollectionView : UICollectionViewController

//存放InformationModel对象的数组(可共用InformationModel数据模型)
@property (nonatomic, strong) NSArray *homeTopNewsModels;
@property (nonatomic, strong) NSArray *homeSectionModels; //存放HomeSectionModel对象的数组

@property (nonatomic, strong) HomeSectionModel *homeSectionModel;
@property (nonatomic, strong) HomeItemModel *homeItemModel;

- (IBAction)QrScan:(UIBarButtonItem *)sender;

- (void)showScanResult:(NSString *)url;

@end
