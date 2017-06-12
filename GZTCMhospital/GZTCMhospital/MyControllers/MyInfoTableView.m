//
//  MyInfoTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/9/8.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "MyInfoTableView.h"
#import "VPImageCropperViewController.h"
#import "UIImageView+WebCache.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AFHTTPRequestOperationManager.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"

#import "UploadPortraitCell.h"
#import "UploadPicturesModel.h"
#import "CheckNetWorkStatus.h"
#import "LoginOrRegisterModel.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface MyInfoTableView () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate>

@property (nonatomic, strong) LoginOrRegisterModel *loginOrRegisterModel;
@property (nonatomic, strong) NSArray *tipArray;
@property (nonatomic, strong) NSArray *propertyArray;

@end

@implementation MyInfoTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.tipArray = @[StafferNameTip, GenderTip, OrganizationNameTip, DutyNameTip, StafferIDTip, CityTip, StafferIDCardTip, MailTip];
    
    [self loadPersonalInformationData];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loadPersonalInformationData 加载个人信息数据

- (void)loadPersonalInformationData {
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
        
        NSString *url = [NSString stringWithFormat:@"%@OperatorID=%@", PersonalInformationBaseUrl, GetOperatorID];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (responseObject) {
                self.loginOrRegisterModel = [LoginOrRegisterModel objectWithKeyValues:responseObject];
                
                if ([self.loginOrRegisterModel.Gender isEqualToString:@"1"]) {
                    self.loginOrRegisterModel.Gender = MaleDefine;
                } else if ([self.loginOrRegisterModel.Gender isEqualToString:@"2"]) {
                    self.loginOrRegisterModel.Gender = FemaleDefine;
                }
                
                self.propertyArray = @[self.loginOrRegisterModel.StafferName, self.loginOrRegisterModel.Gender, self.loginOrRegisterModel.OrganizationName, self.loginOrRegisterModel.DutyName, self.loginOrRegisterModel.LoginID, self.loginOrRegisterModel.City, self.loginOrRegisterModel.StafferCard, self.loginOrRegisterModel.StafferMail];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showInfoWithStatus:DataLoadFailureTip maskType:SVProgressHUDMaskTypeNone];
            NSLog(@"Error: %@", error);
        }];
    } andWithFaildBlokc:^{
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 85;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; //取消头像cell的灰色选中效果
        
        UIActionSheet *portraitChoiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                         delegate:self
                                                                cancelButtonTitle:SheetCancel
                                                           destructiveButtonTitle:nil
                                                                otherButtonTitles:PortraitTakePhotos, PortraitSelectFromAlbum, nil];
        portraitChoiceSheet.tag = 100;
        [portraitChoiceSheet showInView:self.view];
    }
    if (indexPath.section == 2) { //注销当前用户时，删除保存的用户信息sessionID等
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; //取消注销cell的灰色选中效果
        UIActionSheet *logoutSheet = [[UIActionSheet alloc] initWithTitle:LogoutTitle delegate:self cancelButtonTitle:SheetCancel destructiveButtonTitle:LogoutDestructive otherButtonTitles:nil];
        
        logoutSheet.tag = 101;
        [logoutSheet showInView:self.view];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0 || section == 2) {
        return 1;
    }
    return self.tipArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UploadPortraitCell *uploadPortraitCell = [tableView dequeueReusableCellWithIdentifier:@"uploadPortraitCell" forIndexPath:indexPath];
        
        [uploadPortraitCell.portraitImageView sd_setImageWithURL:[NSURL URLWithString:[self.userDefaults objectForKey:@"PortraitMicroimageUrl"]] placeholderImage:[UIImage imageNamed:@"loginOrRegister"]];
        
        return uploadPortraitCell;
    } else if (indexPath.section == 1) {
        UITableViewCell *personalInformationCell = [tableView dequeueReusableCellWithIdentifier:@"personalInformationCell" forIndexPath:indexPath];
        
        personalInformationCell.textLabel.text = self.tipArray[indexPath.row];
        personalInformationCell.detailTextLabel.text = self.propertyArray[indexPath.row];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [personalInformationCell layoutSubviews];
        }
        return personalInformationCell;
        
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"logoutCell" forIndexPath:indexPath];
        return cell;
    }
}

#pragma mark VPImageCropperDelegate

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    self.portraitImage = editedImage;
    
    [self upLoadPortraitImage];
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // To Do
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - upLoadPortraitImage

- (void)upLoadPortraitImage {
    
    [CheckNetWorkStatus checkNewWorking:TestUrl WithSucessBlock:^{
        if (self.portraitImage) {
            [SVProgressHUD showWithStatus:UpLoadingPortraitTip maskType:SVProgressHUDMaskTypeNone];
            AFHTTPRequestOperationManager *manager = [CheckNetWorkStatus shareManager];
            
            NSDictionary *parameters = @{@"OperatorID": [self.userDefaults objectForKey:@"OperatorID"]};
            
            [manager POST:PortraitUploadBaseUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                NSData *data;
                
                if (UIImageJPEGRepresentation(self.portraitImage, 0.5) == nil) {
                    data = UIImagePNGRepresentation(self.portraitImage);
                } else {
                    data = UIImageJPEGRepresentation(self.portraitImage, 0.5);
                }
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
                NSString *portraitImageName = [NSString stringWithFormat:@"%@.png", currentDateStr];
                
                [formData appendPartWithFileData:data name:@"Image" fileName:portraitImageName mimeType:@"image/png"];
                
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                self.upLoadPicturesModel = [UploadPicturesModel objectWithKeyValues:responseObject];
                
                //更新保存的用户头像信息
                [self.userDefaults setObject:self.upLoadPicturesModel.ResultHttpUrl forKey:@"PortraitMicroimageUrl"];
                
                [self.userDefaults synchronize];
                
                //发出通知，通知"我的"页面显示用户头像
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showPortrait" object:[self.userDefaults objectForKey:@"PortraitMicroimageUrl"]];
                
                if (self.upLoadPicturesModel.ResultID == 1) {
                    [SVProgressHUD showSuccessWithStatus:self.upLoadPicturesModel.ResultMessage maskType:SVProgressHUDMaskTypeNone];
                    NSIndexSet * indexSet = [[NSIndexSet alloc]initWithIndex:0]; //刷新头像section
                    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
                } else {
                    [SVProgressHUD showInfoWithStatus:self.upLoadPicturesModel.ResultMessage maskType:SVProgressHUDMaskTypeNone];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD showInfoWithStatus:UpLoadPortraitFailureTip maskType:SVProgressHUDMaskTypeNone];
                NSLog(@"error = %@",error);
            }];
        }
    } andWithFaildBlokc:^{
        self.portraitImage = nil;
        [SVProgressHUD showErrorWithStatus:NetworkError maskType:SVProgressHUDMaskTypeNone];
    }];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100) {
        if (buttonIndex == 0) {
            // 拍照
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([self isRearCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                 }];
            }
            
        } else if (buttonIndex == 1) {
            // 从相册中选取
            if ([self isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                 }];
            }
        }
    }
    if (actionSheet.tag == 101) {  //注销登录
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            
            [self.userDefaults removeObjectForKey:@"OperatorID"];
            [self.userDefaults removeObjectForKey:@"StafferID"];
            [self.userDefaults removeObjectForKey:@"StafferName"];
            [self.userDefaults removeObjectForKey:@"PortraitMicroimageUrl"];
            [self.userDefaults removeObjectForKey:@"StafferCard"];
            
            //注销后,发出通知,通知”我的“页面显示"立即登录"字样
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showUserInfo" object:LoginImmediately];
            
            //发出通知，通知"我的"页面显示默认头像
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showPortrait" object:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            // To Do
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - Image Scale Utility

- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Camera Utility

- (BOOL)isCameraAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL)isRearCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL)isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL)doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL)isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL)canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL)canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

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
