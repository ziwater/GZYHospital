//
//  InformationChannelModel.h
//  GZTCMhospital
//
//  Created by Chris on 15/8/26.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InformationChannelModel : NSObject

//资讯类与慢病论坛可共用此Model
@property (nonatomic, copy) NSString *EditionID;
@property (nonatomic, copy) NSString *FormID;
@property (nonatomic, copy) NSString *FormName;

@end
