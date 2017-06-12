//
//  CourseFileModel.h
//  GZTCMhospital
//
//  Created by Chris on 15/12/2.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourseFileModel : NSObject

@property (nonatomic, copy) NSString *FileMD5;
@property (nonatomic, copy) NSString *FileUrl;
@property (nonatomic, copy) NSString *FileVideoUrl;
@property (nonatomic, assign) NSInteger FileSize;
@property (nonatomic, copy) NSString *FileTitle;

@end
