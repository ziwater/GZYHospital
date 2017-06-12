//
//  MailModel.h
//  GZTCMhospital
//
//  Created by Chris on 16/3/1.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MailModel : NSObject

@property (nonatomic, copy) NSString *FormID;
@property (nonatomic, copy) NSString *TypeID;
@property (nonatomic, copy) NSString *Sender;
@property (nonatomic, copy) NSString *InfoID;
@property (nonatomic, copy) NSString *Title;
@property (nonatomic, copy) NSString *MessageID;
@property (nonatomic, copy) NSString *SendTime;
@property (nonatomic, copy) NSString *Receiver;
@property (nonatomic, copy) NSString *Content;

@end
