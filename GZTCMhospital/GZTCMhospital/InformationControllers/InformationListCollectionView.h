//
//  InformationListCollectionView.h
//  GZTCMhospital
//
//  Created by Chris on 15/8/27.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InformationListModel;

@interface InformationListCollectionView : UICollectionViewController

@property (nonatomic, strong) NSArray *informationListModels; //存放InformationListModel对象的数组
@property (nonatomic, strong) InformationListModel *informationListModel;

@property (nonatomic, copy) NSString *informationListTopImageUrl;

@end
