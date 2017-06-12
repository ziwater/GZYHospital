//
//  ReportStateViewController.m
//  Demo0819
//
//  Created by Chris on 15/8/19.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "ReportStateViewController.h"

#import "UITableView+Improve.h"
#import "AGImagePickerController.h"
#import "SVProgressHUD.h"
#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "UIImageView+WebCache.h"

#import "ShowImageViewController.h"
#import "CheckNetWorkStatus.h"
#import "UploadPicturesModel.h"
#import "ResultModel.h"
#import "InformationChannelModel.h"

#define textViewHeight 150
#define fieldViewHeight 30
#define pictureHW (screenWidth - 5 * padding) / 4
#define MaxImageCount 9
#define deleImageWH 35

#define padding 10
#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height
#define imageTag 2000

@interface ReportStateViewController ()  <UITextViewDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UITextField *postsTitleTextField;
@property (nonatomic, strong) UITextView *reportStateTextView;
@property (nonatomic, strong) UITextField *placeholderTextField;
@property (nonatomic, strong) UIButton *addPictureButton;

@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIView *sampleView;
@property (nonatomic, strong) UIView *addOrDeleteImagesView;

@property (nonatomic, strong) AGImagePickerController *imagePicker;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@property (nonatomic, strong) UIButton *pickerChannelButton;
@property (nonatomic, strong) UITextField *pickerViewTextField;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSMutableArray *pickerForumChannelData; //频道名称数组
@property (nonatomic, copy) NSString *pickerForumChannelName;

@property (nonatomic, strong) NSMutableArray *sampleImageArray;

@end

@implementation ReportStateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(textChanged) name:UITextViewTextDidChangeNotification object:nil];
    [center addObserver:self selector:@selector(textChanged) name:UITextFieldTextDidChangeNotification object:nil];
    
    [self.tableView improveTableView]; //删除多余的行和防止分割线显示不全
    
    //根据不同identifier设置标题
    if ([self.addIdentify isEqualToString:@"addMail"]) {
        self.title = WriteMailTip;
    } else if ([self.addIdentify isEqualToString:@"myBlogAdd"]|| [self.addIdentify isEqualToString:@"commonBlogAdd"]) {
        self.title = WriteBlogTip;
    } else {
        self.title = PostTip;
    }
    
    if (self.forumChannelModels.count) { //防止数组访问越界
        [self configPickerView];
    }
    
    [self initPostsTitleAndContentView];
    
    [self redrawHeadViewAfterAddOrDeleteImages];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPickerView 配置方法

- (void)configPickerView {
    
    InformationChannelModel *channelModel = self.forumChannelModels[0];
    self.formID = channelModel.FormID;
    if (channelModel.FormName) {
        self.pickerForumChannelName = channelModel.FormName;
    }
    
    for (InformationChannelModel *channelModel in self.forumChannelModels) {
        if (channelModel.FormName) {
            [self.pickerForumChannelData addObject:channelModel.FormName];
        }
    }
    
    self.pickerViewTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.pickerViewTextField];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.backgroundColor = [UIColor whiteColor];
    
    // set change the inputView (default is keyboard) to UIPickerView
    self.pickerViewTextField.inputView = self.pickerView;
    
    // add a toolbar with Cancel & Done button
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
    UIBarButtonItem *flexibleSpaceItem =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar.items = @[cancelItem, flexibleSpaceItem, doneItem];
    
    self.pickerViewTextField.inputAccessoryView = toolBar;
}

- (void)cancelTouched:(UIBarButtonItem *)sender {
    // hide the picker view
    [self.pickerViewTextField resignFirstResponder];
}

- (void)doneTouched:(UIBarButtonItem *)sender {
    // hide the picker view
    [self.pickerViewTextField resignFirstResponder];
    
    // perform some action
    if (self.pickerForumChannelData.count) {
        NSInteger row = [self.pickerView selectedRowInComponent:0];
        NSString *selectedForumChannel = [self.pickerForumChannelData objectAtIndex:row];
        self.pickerForumChannelName = selectedForumChannel;
        [self.pickerChannelButton setTitle:selectedForumChannel forState:UIControlStateNormal];
    } else {
        [self.pickerViewTextField resignFirstResponder];
    }
}

- (void)pickerChannelAction:(UIButton *)sender {
    [self.pickerViewTextField becomeFirstResponder];
}

#pragma mark - NSNotificationCenter 通知方法

- (void)textChanged {
    self.sendPostsBarButtonItem.enabled = (self.postsTitleTextField.text.length > 0 && self.postsTitleTextField.text.length <= 100 && self.reportStateTextView.text.length > 0 && self.reportStateTextView.text.length <= 400);
}

#pragma mark - 对象数组初始化

- (NSMutableArray *)imagePickerArray {
    if (!_imagePickerArray) {
        _imagePickerArray = [[NSMutableArray alloc] init];
    }
    return _imagePickerArray;
}

- (NSMutableArray *)imageDataArray {
    if (!_imageDataArray) {
        _imageDataArray = [NSMutableArray array];
    }
    return _imageDataArray;
}

- (NSMutableArray *)pickerForumChannelData {
    if (!_pickerForumChannelData) {
        _pickerForumChannelData = [NSMutableArray array];
    }
    return _pickerForumChannelData;
}

- (NSMutableArray *)sampleImageArray {
    if (!_sampleImageArray) {
        _sampleImageArray = [NSMutableArray array];
    }
    return _sampleImageArray;
}

#pragma mark - headView设置(帖子标题、帖子内容控件)

- (void)initPostsTitleAndContentView {
    self.headView = [[UIView alloc]initWithFrame:CGRectZero];
    
    self.postsTitleTextField = [[UITextField alloc] initWithFrame:CGRectMake(padding, padding * 2, screenWidth - 2 * padding, fieldViewHeight)];
    self.postsTitleTextField.font = [UIFont systemFontOfSize:15];
    self.postsTitleTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.postsTitleTextField.placeholder = PostsTitlePlaceHolder;
    [self.headView addSubview:self.postsTitleTextField];
    
    self.reportStateTextView = [[UITextView alloc]initWithFrame:CGRectMake(padding, 3 * padding + fieldViewHeight, screenWidth - 2 * padding, textViewHeight)];
    self.reportStateTextView.font = [UIFont systemFontOfSize:15];
    self.reportStateTextView.delegate = self;
    
    //为UITextView添加边框
    self.reportStateTextView.layer.borderColor = [RGBColor(215.0, 215.0, 215.0) CGColor];
    self.reportStateTextView.layer.borderWidth = 0.6f;
    self.reportStateTextView.layer.cornerRadius = 6.0f;
    [self.headView addSubview:self.reportStateTextView];
    
    self.placeholderTextField = [[UITextField alloc]initWithFrame:CGRectMake(padding + 7, 3 * padding + fieldViewHeight + 5, screenWidth - 2 * padding - 14, 21)];
    self.placeholderTextField.enabled = NO;
    self.placeholderTextField.font = [UIFont systemFontOfSize:15];
    self.placeholderTextField.borderStyle = UITextBorderStyleNone;
    self.placeholderTextField.placeholder = PostsContentPlaceHolder;
    [self.headView addSubview:self.placeholderTextField];
    
}
#pragma mark - addOrDeleteImageView(添加或删除图片后重新布局)

- (void)redrawHeadViewAfterAddOrDeleteImages {
    
    [self.addOrDeleteImagesView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.addOrDeleteImagesView = [[UIView alloc] initWithFrame:CGRectZero]; //包含+按钮、图片控件、选择频道标签、选择频道按钮
    NSInteger imageCount = [self.imagePickerArray count];
    for (NSInteger i = 0; i < imageCount; i++) {
        UIImageView *pictureImageView = [[UIImageView alloc]initWithFrame:CGRectMake(padding + (i % 4) * (pictureHW + padding), padding + (i /4 ) * (pictureHW + padding), pictureHW, pictureHW)];
        
        //设置删除按钮
        UIButton *dele = [UIButton buttonWithType:UIButtonTypeCustom];
        dele.frame = CGRectMake(pictureHW - deleImageWH + 10, -10, deleImageWH, deleImageWH);
        [dele setImage:[UIImage imageNamed:@"deletePhoto"] forState:UIControlStateNormal];
        [dele addTarget:self action:@selector(deletePic:) forControlEvents:UIControlEventTouchUpInside];
        [pictureImageView addSubview:dele];
        
        pictureImageView.tag = imageTag + i;
        pictureImageView.userInteractionEnabled = YES;
        if ([self.imagePickerArray[i] isKindOfClass:[ALAsset class]]) {
            pictureImageView.image = [UIImage imageWithCGImage:((ALAsset *)[self.imagePickerArray objectAtIndex:i]).thumbnail];
        } else {
            pictureImageView.image = self.imagePickerArray[i];
        }
        
        //添加图片ImageView
        [self.addOrDeleteImagesView addSubview:pictureImageView];
        
    }
    //添加增加按钮
    if (imageCount < MaxImageCount) {
        self.addPictureButton = [[UIButton alloc] initWithFrame:CGRectMake(padding + (imageCount % 4) * (pictureHW + padding), padding + (imageCount / 4) * (pictureHW + padding), pictureHW, pictureHW)];
        [self.addPictureButton setBackgroundImage:[UIImage imageNamed:@"addPictures"] forState:UIControlStateNormal];
        [self.addPictureButton addTarget:self action:@selector(addPicture) forControlEvents:UIControlEventTouchUpInside];
        [self.addOrDeleteImagesView addSubview:self.addPictureButton];
    }
    
    //选择频道标签
    UILabel *pickerChannelLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 2 * padding + (imageCount / 4) * (pictureHW + padding) + pictureHW, 70, 30)];
    pickerChannelLabel.font = [UIFont systemFontOfSize:14.0];
    pickerChannelLabel.text = PickerChannelTip;
    
    //频道选择器按钮
    self.pickerChannelButton = [[UIButton alloc] initWithFrame:CGRectMake(pickerChannelLabel.frame.origin.x +pickerChannelLabel.frame.size.width + padding, 2 * padding + (imageCount / 4) * (pictureHW + padding) + pictureHW, 200, 30)];
    [self.pickerChannelButton setTitle:self.pickerForumChannelName forState:UIControlStateNormal];
    self.pickerChannelButton.layer.cornerRadius = 5.0f;
    self.pickerChannelButton.layer.borderWidth = 0.3f;
    self.pickerChannelButton.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.pickerChannelButton.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.pickerChannelButton setTitleColor:RGBColor(0, 194, 155) forState:UIControlStateNormal];
    [self.pickerChannelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.pickerChannelButton setImage:[UIImage imageNamed:@"gzy_xueya_btn_bg"] forState:UIControlStateHighlighted];
    [self.pickerChannelButton addTarget:self action:@selector(pickerChannelAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.addOrDeleteImagesView addSubview:pickerChannelLabel];
    [self.addOrDeleteImagesView addSubview:self.pickerChannelButton];
    
    NSInteger postsTitleAndContentViewHeight = padding * 5 + textViewHeight + fieldViewHeight;
    NSInteger addOrDeleteImagesViewHeight = (padding + pictureHW) * ([self.imagePickerArray count] / 4 + 1) + 50;
    self.addOrDeleteImagesView.frame = CGRectMake(0, postsTitleAndContentViewHeight, screenWidth, addOrDeleteImagesViewHeight);
    [self.headView addSubview:self.addOrDeleteImagesView];
    
    NSInteger headViewHeight = postsTitleAndContentViewHeight + addOrDeleteImagesViewHeight;
    self.headView.frame = CGRectMake(0, 0, screenWidth, headViewHeight);
    self.tableView.tableHeaderView = self.headView;
    
    //    NSInteger postsTitleAndContentViewHeight = padding * 4 + textViewHeight + fieldViewHeight;
    //    NSInteger sampleViewHeight = self.sampleView.frame.size.height;
    //    NSInteger addOrDeleteImagesViewHeight = (padding + pictureHW) * ([self.imagePickerArray count] / 4 + 1) + 50;
    //    self.addOrDeleteImagesView.frame = CGRectMake(0, postsTitleAndContentViewHeight + sampleViewHeight, screenWidth, addOrDeleteImagesViewHeight);
    //    [self.headView addSubview:self.addOrDeleteImagesView];
    //
    //    NSInteger headViewHeight = postsTitleAndContentViewHeight + sampleViewHeight + addOrDeleteImagesViewHeight;
    //    self.headView.frame = CGRectMake(0, 0, screenWidth, headViewHeight);
    //    self.tableView.tableHeaderView = self.headView;
}

#pragma mark - addPicture

- (void)addPicture {
    if ([self.reportStateTextView isFirstResponder]) {
        [self.reportStateTextView resignFirstResponder];
    }
    if ([self.postsTitleTextField isFirstResponder]) {
        [self.postsTitleTextField resignFirstResponder];
    }
    
    self.myActionSheet = [[UIActionSheet alloc]
                          initWithTitle:nil
                          delegate:self
                          cancelButtonTitle:SheetCancel
                          destructiveButtonTitle:nil
                          otherButtonTitles:PortraitTakePhotos, PortraitSelectFromAlbum, nil];
    [self.myActionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            [self takePhoto];
            break;
            
        case 1:
            [self localPhoto];
            break;
        default:
            break;
    }
}

#pragma mark - gesture method 点击图片放大显示

- (void)tapImageView:(UITapGestureRecognizer *)tap {
    self.navigationController.navigationBarHidden = YES;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ShowImageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"showImage"];
    vc.clickTag = tap.view.tag;
    vc.imageViews = self.sampleImageArray;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - deletePic method 删除图片

- (void)deletePic:(UIButton *)btn {
    if ([(UIButton *)btn.superview isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)(UIButton *)btn.superview;
        [self.imagePickerArray removeObjectAtIndex:(imageView.tag - imageTag)];
        [self redrawHeadViewAfterAddOrDeleteImages];
    }
}

#pragma mark - UIGesture Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

#pragma mark - Text View Delegate

-(void)textViewDidChange:(UITextView *)textView {
    self.placeholderTextField.hidden = [textView.text length];
}

#pragma mark - takePhoto 从相机获取

- (void)takePhoto {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"Test on real device, camera is not available in simulator" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
    [self.imagePickerController takePicture];
}

#pragma mark - localPhoto 从相片库获取

- (void)localPhoto {
    self.imagePicker = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error) {
        
        if (error == nil) {
            [self dismissViewControllerAnimated:YES completion:^{}];
        } else {
            NSLog(@"Error: %@", error);
            
            // Wait for the view controller to show first and hide it after that
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self dismissViewControllerAnimated:YES completion:^{}];
            });
        }
        
    } andSuccessBlock:^(NSArray *info) {
        [self.imagePickerArray addObjectsFromArray:info];
        [self dismissViewControllerAnimated:YES completion:^{}];
        [self redrawHeadViewAfterAddOrDeleteImages];
    }];
    
    self.imagePicker.maximumNumberOfPhotosToBeSelected = MaxImageCount - [self.imagePickerArray count];
    
    [self presentViewController:self.imagePicker animated:YES completion:^{}];
    
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [self.imagePickerArray addObject:chosenImage];
    [self redrawHeadViewAfterAddOrDeleteImages];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}

#pragma mark - 发布帖子 Action

- (IBAction)sendPostsAction:(UIBarButtonItem *)sender {
    
    if (![_userDefaults objectForKey:@"OperatorID"]) { //没有登录时
        [self performSegueWithIdentifier:@"postsLogin" sender:nil];
    } else { //已经登录
        [SVProgressHUD showWithStatus:UpLoadingPostsTip maskType:SVProgressHUDMaskTypeNone];
        [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
            if (self.imagePickerArray.count) { //有图发帖
                [self imageProcessing];
                [self upLoadPostsPictures]; //上传发帖图片
            } else { //无图发帖
                [self upLoadPosts];
            }
        } andWithFaildBlokc:^{
            [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
        }];
    }
}

#pragma mark - Image Processing 图片处理

- (void)imageProcessing {
    NSMutableArray *postsImages = [NSMutableArray array];
    
    //将self.imagePickerArray存的数据转换成UIImage对象并存入postsImages数组中
    for (NSInteger i = 0; i < self.imagePickerArray.count; i++) {
        if ([self.imagePickerArray[i] isKindOfClass:[ALAsset class]]) {
            ALAsset *asset = (ALAsset *)[self.imagePickerArray objectAtIndex:i];
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            
            //NSLog(@"dimensions = %@", NSStringFromCGSize([representation dimensions]));
            //NSLog(@"原始size = %lld", [representation size]);
            
            [postsImages addObject:[UIImage imageWithCGImage:[representation fullResolutionImage] scale:1.0 orientation:UIImageOrientationUp]];
        } else {
            [postsImages addObject:self.imagePickerArray[i]];
        }
    }
    
    for (UIImage *image in postsImages) {  //UIImage --> NSData
        if (UIImageJPEGRepresentation(image, 0.01) == nil) {
            [self.imageDataArray addObject:UIImagePNGRepresentation(image)];
        } else {
            [self.imageDataArray addObject:UIImageJPEGRepresentation(image, 0.01)];
        }
    }
}

#pragma mark - upLoadPostsPictures 上传发帖图片

- (void)upLoadPostsPictures {
    
    AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
    
    NSDictionary *parameters = @{@"OperatorID": [_userDefaults objectForKey:@"OperatorID"],
                                 @"FormID": self.formID};
    
    [manager POST:PostsPicturesUploadBaseUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        for (NSInteger i = 0; i < self.imageDataArray.count; i++) {
            NSData *data = [self.imageDataArray objectAtIndex:i];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
            NSString *pictureName = [NSString stringWithFormat:@"%@.png", currentDateStr];
            
            [formData appendPartWithFileData:data name:@"Image" fileName:pictureName mimeType:@"image/png"];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.upLoadPicturesModel = [UploadPicturesModel objectWithKeyValues:responseObject];
        
        if (self.upLoadPicturesModel.ResultID == 1) { //图片上传成功
            [self upLoadPosts];
        } else {
            [SVProgressHUD showInfoWithStatus:SendPostsFailureTip maskType:SVProgressHUDMaskTypeNone];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showInfoWithStatus:SendPostsFailureTip maskType:SVProgressHUDMaskTypeNone];
        NSLog(@"Error = %@",error);
    }];
}

#pragma mark - upLoadPosts 上传发帖

- (void)upLoadPosts {
    AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
    
    NSDictionary *parameters = nil;
    NSString *sendUrl = nil;
    
    //我的博客/普通博客 - 发布博客url参数
    if ([self.addIdentify isEqualToString:@"myBlogAdd"] || [self.addIdentify isEqualToString:@"commonBlogAdd"]) {
        if (self.upLoadPicturesModel.ResultHttpUrl) {
            parameters = @{@"OperatorID": [_userDefaults objectForKey:@"OperatorID"],
                           @"ClassID": self.formID,
                           @"Title": self.postsTitleTextField.text,
                           @"Content": self.reportStateTextView.text,
                           @"PictureURL": self.upLoadPicturesModel.ResultHttpUrl};
        } else {
            parameters = @{@"OperatorID": [_userDefaults objectForKey:@"OperatorID"],
                           @"ClassID": self.formID,
                           @"Title": self.postsTitleTextField.text,
                           @"Content": self.reportStateTextView.text
                           };
        }
        sendUrl = BlogUploadBaseUrl;
    } else {  //论坛 - 发布论坛url参数
        if (self.upLoadPicturesModel.ResultHttpUrl) {
            parameters = @{@"OperatorID": [_userDefaults objectForKey:@"OperatorID"],
                           @"FormID": self.formID,
                           @"Title": self.postsTitleTextField.text,
                           @"Content": self.reportStateTextView.text,
                           @"PictureURL": self.upLoadPicturesModel.ResultHttpUrl};
        } else {
            parameters = @{@"OperatorID": [_userDefaults objectForKey:@"OperatorID"],
                           @"FormID": self.formID,
                           @"Title": self.postsTitleTextField.text,
                           @"Content": self.reportStateTextView.text
                           };
        }
        sendUrl = PostsUploadBaseUrl;
    }
    
    [manager POST:sendUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.resultModel = [ResultModel objectWithKeyValues:responseObject];
        
        if (self.resultModel.ResultID == 1) { //发帖成功
            [SVProgressHUD showSuccessWithStatus:self.resultModel.ResultMessage maskType:SVProgressHUDMaskTypeNone];
            
            if ([self.addIdentify isEqualToString:@"commonBlogAdd"]) {
                //发出通知，慢病博客刷新tableView
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshForAddBlog" object:nil];
            } else {
                //发出通知，论坛、我的博客刷新tableView
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshForAddForumOrMyBlog" object:nil];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [SVProgressHUD showInfoWithStatus:self.resultModel.ResultMessage maskType:SVProgressHUDMaskTypeNone];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showInfoWithStatus:SendPostsFailureTip maskType:SVProgressHUDMaskTypeNone];
        NSLog(@"Error = %@",error);
    }];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerForumChannelData.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.pickerForumChannelData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    InformationChannelModel *channelModel = self.forumChannelModels[row];
    self.formID = channelModel.FormID;
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
