//
//  ReportStateViewController.h
//  Demo0819
//
//  Created by Chris on 15/8/19.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UploadPicturesModel;
@class ResultModel;

@interface ReportStateViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *imagePickerArray; //imagePicker队列
@property (nonatomic, strong) NSMutableArray *imageDataArray; //存放image的NSData对象数组

@property (nonatomic, strong) UIActionSheet *myActionSheet;

@property (nonatomic, copy) NSString *addIdentify; //论坛、我的博客、慢病博客增加标识

@property (nonatomic, copy) NSString *formID;
@property (nonatomic, strong) NSArray *forumChannelModels; //慢病论坛频道InformationChannelModel模型数组

@property (nonatomic, strong) UploadPicturesModel *upLoadPicturesModel;
@property (nonatomic, strong) ResultModel *resultModel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendPostsBarButtonItem;

- (IBAction)sendPostsAction:(UIBarButtonItem *)sender;

- (void)takePhoto;
- (void)localPhoto;

@end
