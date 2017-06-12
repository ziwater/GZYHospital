//
//  MyInfoTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/9/8.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UploadPicturesModel;

@interface MyInfoTableView : UITableViewController

@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) UIImage *portraitImage;

@property (nonatomic, strong) UploadPicturesModel *upLoadPicturesModel;

@end
