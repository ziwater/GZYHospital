//
//  HomeTopNewsCollectionViewCell.m
//  GZTCMhospital
//
//  Created by Chris on 15/9/1.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "HomeTopNewsCollectionViewCell.h"

#import "AdView.h"

@implementation HomeTopNewsCollectionViewCell

- (void)setAdvertisements:(NSArray *)advertisements {
    _advertisements = advertisements;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    NSMutableArray *imagesURL = [NSMutableArray array];
    NSMutableArray *titles = [NSMutableArray array];
    NSMutableArray *linkURL = [NSMutableArray array];
    
    if (_advertisements.count == 0) {
        return;
    }
    
    for (int i = 0; i < _advertisements.count; i++) {
        [imagesURL addObject:[_advertisements[i] valueForKeyPath:@"PictureMicroimageUrl"]];
        [titles addObject:[_advertisements[i] valueForKeyPath:@"Title"]];
        [linkURL addObject:[NSString stringWithFormat:@"%@FormID=%@&DetailID=%@&PageID=1&PageSize=20",InformationWebViewBaseUrl, [_advertisements[i] valueForKeyPath:@"FormID"], [_advertisements[i]valueForKeyPath:@"DetailID"]]];
    }
    
    //self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.adView = [AdView adScrollViewWithFrame:CGRectMake(0, 0, width, 192) imageLinkURL:imagesURL placeHoderImageName:@"news_pic_default" pageControlShowStyle:UIPageControlShowStyleRight];
    
    //    是否需要支持定时循环滚动，默认为YES
    //    adView.isNeedCycleRoll = YES;
    
    [self.adView setAdTitleArray:titles withShowStyle:AdTitleShowStyleLeft];
    //    设置图片滚动时间,默认3s
    //    adView.adMoveTime = 2.0;
    self.adView.adlinkURL = linkURL;
    
    [self addSubview:self.adView];
}

@end
