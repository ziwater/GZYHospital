//
//  DownloadObject.h
//  Download
//
//  Created by Chris on 15/12/8.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WHC_ClientAccount.h"

@interface DownloadObject : NSObject

@property (nonatomic, copy) NSString * fileName;
@property (nonatomic, copy) NSString *tureFileName;
@property (nonatomic, copy) NSString * currentDownloadLen;
@property (nonatomic, copy) NSString * totalLen;
@property (nonatomic, copy) NSString * speed;
@property (nonatomic, copy) NSString * downPath;
@property (nonatomic, assign) float processValue;
@property (nonatomic, assign) DownloadState state;

@end
