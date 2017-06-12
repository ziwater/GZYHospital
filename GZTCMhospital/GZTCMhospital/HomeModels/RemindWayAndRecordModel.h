//
//  RemindWayAndRecordModel.h
//  GZTCMhospital
//
//  Created by Chris on 16/2/25.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemindWayAndRecordModel : NSObject

@property (nonatomic, copy) NSString *PerPageNum;
@property (nonatomic, copy) NSString *MenuTitle;
@property (nonatomic, copy) NSString *classID;
@property (nonatomic, copy) NSString *PageID;
@property (nonatomic, copy) NSString *FuncConfig;
@property (nonatomic, copy) NSString *FormId;
@property (nonatomic, copy) NSString *StatuID;
@property (nonatomic, assign) NSInteger Count;
@property (nonatomic, copy) NSString *Cond;

@end
