//
//  OrderListModel.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/23.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OrderResultModel;

@interface OrderListModel : NSObject

@property (nonatomic, strong) OrderResultModel *List;
@property (nonatomic, assign) NSInteger Count;
@property (nonatomic, copy) NSString *FormID;

@end
