//
//  CommentViewController.h
//  GZTCMhospital
//
//  Created by Chris on 15/9/10.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InformationModel;
@class ResultModel;
@class MailModel;

@interface CommentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (nonatomic, strong) id delegate;

@property (nonatomic, strong) MailModel *mailModel;
@property (nonatomic, copy) NSString *mailIdentifier;

@property (nonatomic, strong) InformationModel *informationModel;
@property (nonatomic ,strong) ResultModel *resultModel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *commentBarButtonItem;

- (IBAction)cancelCommentAction:(UIBarButtonItem *)sender;
- (IBAction)sendCommentAction:(UIBarButtonItem *)sender;

@end

