//
//  LimitListModel.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/28.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LimitListModel : NSObject

@property (nonatomic, assign) NSInteger IsPlan;
@property (nonatomic, assign) NSInteger IsView;
@property (nonatomic, assign) NSInteger IsModify;
@property (nonatomic, assign) NSInteger IsDelete;
@property (nonatomic, assign) NSInteger IsCreate;

@end
