//
//  InformationModel.h
//  GZTCMhospital
//
//  Created by Chris on 15/8/27.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InformationModel : NSObject
//资讯类与慢病博客、慢病论坛可共用此Model
//资讯类、慢病论坛Model
@property (nonatomic, copy) NSString *Title;
@property (nonatomic, copy) NSString *FormID;
@property (nonatomic, copy) NSString *DetailID;
@property (nonatomic, copy) NSString *PictureMicroimageUrl;
@property (nonatomic, copy) NSString *ModifyDateTime;
@property (nonatomic, assign) NSInteger CommentNumber;
@property (nonatomic, assign) NSInteger ClickNumber;
@property (nonatomic, copy) NSString *ContentSummary;

//慢病博客增加字段
@property (nonatomic, copy) NSString *StafferID;
@property (nonatomic, copy) NSString *OperatorID;
@property (nonatomic, copy) NSString *StafferName;
@property (nonatomic, copy) NSString *PortraitMicroimageUrl;

@end
