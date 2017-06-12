//
//  HomeTopNewsCollectionViewCell.h
//  GZTCMhospital
//
//  Created by Chris on 15/9/1.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AdView;

@interface HomeTopNewsCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) NSArray *advertisements;
@property (strong, nonatomic) AdView *adView;

@end
