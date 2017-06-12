//
//  DownloadingCell.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/7.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "DownloadingCell.h"

#import "WHC_DownloadFileCenter.h"
#import "WHC_ClientAccount.h"
#import "UIView+WHC_Loading.h"
#import "UIView+WHC_ViewProperty.h"
#import "UIView+WHC_Toast.h"

#import "DownloadObject.h"

#define kFontSize (13.0)

@interface DownloadingCell () <WHCDownloadDelegate>

@property(nonatomic, strong) UIImageView  *downloadingArrowV;  //下载动画箭头
@property(nonatomic, strong) DownloadObject *downloadObject;   //下载对象

@property (nonatomic, strong) UIImage *arrowImage;
@property (nonatomic, copy) NSString *plistPath;

@end

@implementation DownloadingCell

- (void)awakeFromNib {
    // Initialization code
    _plistPath = Account.videoFileRecordPath;
    [self.pauseOrContinueButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.contentView sendSubviewToBack:self.pauseOrContinueButton];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIImage *)makeDownloadArrowImage {
    UIImage *arrowImage = nil;
    UIGraphicsBeginImageContext(CGSizeMake(kFontSize, kFontSize));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.pauseOrContinueButton.backgroundColor.CGColor);
    NSString *arrow = @"↓";
    [arrow drawInRect:CGRectMake(0, 0, kFontSize, kFontSize) withAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:kFontSize]}];
    arrowImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return arrowImage;
}

- (void)addAnimation {
    if (_downloadingArrowV) {
        __weak  typeof(self) sf = self;
        [UIView animateWithDuration:1.2 animations:^{
            _downloadingArrowV.y = _pauseOrContinueButton.maxY;
        } completion:^(BOOL finished) {
            _downloadingArrowV.y = _pauseOrContinueButton.y - _downloadingArrowV.height;
            [sf addAnimation];
        }];
    }
}

- (void)addDownloadAnimation {
    if (_downloadingArrowV == nil) {
        if (_arrowImage == nil) {
            _arrowImage = [self makeDownloadArrowImage];
        }
        _downloadingArrowV = [[UIImageView alloc]initWithImage:_arrowImage];
        _downloadingArrowV.size = _arrowImage.size;
        _downloadingArrowV.xy = CGPointMake(_pauseOrContinueButton.x + (_pauseOrContinueButton.width - kFontSize) / 2.0, _pauseOrContinueButton.y - _arrowImage.size.height);
        [_pauseOrContinueButton setTitle:@"" forState:UIControlStateNormal];
        [self.contentView addSubview:_downloadingArrowV];
        [self.contentView sendSubviewToBack:_downloadingArrowV];
        [self addAnimation];
    }
}
- (void)removeDownloadAnimation {
    if (_downloadingArrowV) {
        [_downloadingArrowV removeFromSuperview];
        _downloadingArrowV = nil;
    }
}

- (void)displayCell:(DownloadObject *)object {
    _pauseOrContinueButton.enabled = YES;
    _downloadObject = object;
    _downloadFileTitleLabel.text = object.tureFileName;
    _percentLabel.text = [NSString stringWithFormat:@"%d%%", (int)(object.processValue * 100)];
    _downloadingSizeLabel.text = [NSString stringWithFormat:@"%@/%@",object.currentDownloadLen,object.totalLen];
    _fileDownloadProgress.progress = object.processValue;
    if (object.state == Downloading) {
        [self addDownloadAnimation];
    } else {
        [self removeDownloadAnimation];
    }
    switch (object.state) {
        case Downloading:
            _statusLabel.text = DownloadingTitle;
            break;
        case DownloadCompleted:
            _statusLabel.text = CompleteStatus;
            _pauseOrContinueButton.enabled = NO;
            [_pauseOrContinueButton setTitle:@"▶" forState:UIControlStateNormal];
            break;
        case DownloadUncompleted:
            _statusLabel.text = SuspendStatus;
            [_pauseOrContinueButton setTitle:@"■" forState:UIControlStateNormal];
            break;
        case DownloadWaitting:
            _statusLabel.text = WaitingStatus;
            [_pauseOrContinueButton setTitle:@"🕘" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (DownloadObject *)currentDownloadObjectFileName:(NSString *)fileName {
    for (DownloadObject *tempObject in _fileObjectArr) {
        if ([tempObject.fileName isEqualToString:fileName]) {
            return tempObject;
        }
    }
    return nil;
}

#pragma mark - WHCDownloadDelegate

//得到第一响应并判断要下载的文件是否已经完整下载了
- (void)WHCDownload:(WHC_Download *)download filePath:(NSString *)filePath hasACompleteDownload:(BOOL)has {
    
}

//接受下载数据处理下载显示进度和网速
- (void)WHCDownload:(WHC_Download *)download didReceivedLen:(uint64_t)receivedLen totalLen:(uint64_t)totalLen networkSpeed:(NSString *)networkSpeed {
    
    NSMutableDictionary *downloadRecordDict = [NSMutableDictionary dictionaryWithContentsOfFile:_plistPath];
    for (NSInteger i = 0; i < downloadRecordDict.count; i++) {
        NSMutableDictionary *tempDict = downloadRecordDict[download.saveFileName];
        if (tempDict == nil) {
            [downloadRecordDict setObject:@{@"fileName":download.saveFileName,
                                            @"tureFileName":download.tureFileName,
                                            @"currentDownloadLen":[NSString stringWithFormat:@"%.1fMB",((CGFloat)(download.downloadLen) / kWHC_1MB)],
                                            @"totalLen":[NSString stringWithFormat:@"%.1fMB",((CGFloat)(download.totalLen) / kWHC_1MB)],
                                            @"speed":@"0KB/S",
                                            @"processValue":@(((CGFloat)receivedLen / totalLen * 100.0) / 100.0),
                                            @"downPath":download.downPath,
                                            @"state":@(Downloading)}.mutableCopy forKey:download.saveFileName];
            [downloadRecordDict writeToFile:_plistPath atomically:YES];
        } else {
            if ([tempDict[@"downPath"] isEqualToString:@""]) {
                [tempDict setObject:download.downPath forKey:@"downPath"];
            WHC:
                [downloadRecordDict setObject:tempDict forKey:download.saveFileName];
                [downloadRecordDict writeToFile:_plistPath atomically:YES];
            } else if ([tempDict[@"state"] integerValue] == DownloadWaitting) {
                [tempDict setObject:@(Downloading) forKey:@"state"];
                goto WHC;
            }
        }
    }
    
    DownloadObject *object = [self currentDownloadObjectFileName:download.saveFileName];
    if (object) {
        CGFloat percent = (CGFloat)receivedLen / totalLen * 100.0;
        object.processValue = percent / 100.0;
        object.currentDownloadLen = [NSString stringWithFormat:@"%.1fMB",((CGFloat)receivedLen / kWHC_1MB)];
        object.totalLen = [NSString stringWithFormat:@"%.1fMB",((CGFloat)totalLen / kWHC_1MB)];
        object.speed = networkSpeed;
        object.state = Downloading;
        object.downPath = download.downPath;
        [self displayCell:object];
    }
}

//下载出错
- (void)WHCDownload:(WHC_Download *)download error:(NSError *)error {
    _downloadObject.state = DownloadUncompleted;
    NSMutableDictionary *downloadRecordDict = [NSMutableDictionary dictionaryWithContentsOfFile:_plistPath];
    NSMutableDictionary *dict = downloadRecordDict[download.saveFileName];
    if (dict) {
        [dict setObject:@(DownloadUncompleted) forKey:@"state"];
        [downloadRecordDict setObject:dict forKey:download.saveFileName];
        [downloadRecordDict writeToFile:_plistPath atomically:YES];
    }
    [self.superview toast:[NSString stringWithFormat:@"%@%@%@",download.tureFileName, DownloadFailure, error]];
    [self displayCell:_downloadObject];
}

//下载结束
- (void)WHCDownload:(WHC_Download *)download filePath:(NSString *)filePath isSuccess:(BOOL)success {
    DownloadObject *object = [self currentDownloadObjectFileName:download.saveFileName];
    if (success) {
        NSMutableDictionary *downloadRecordDict = [NSMutableDictionary dictionaryWithContentsOfFile:_plistPath];
        for (NSInteger i = 0; i < downloadRecordDict.count; i++) {
            NSMutableDictionary *tempDict = downloadRecordDict[download.saveFileName];
            if (tempDict) {
                [tempDict setObject:((NSString *)tempDict[@"totalLen"]).copy forKey:@"currentDownloadLen"];
                [tempDict setObject:@(1.0) forKey:@"processValue"];
                [tempDict setObject:@(DownloadCompleted) forKey:@"state"];
                if ([tempDict[@"downPath"] isEqualToString:@""]) {
                    [tempDict setObject:download.downPath forKey:@"downPath"];
                }
                [downloadRecordDict setObject:tempDict forKey:download.saveFileName];
                [downloadRecordDict writeToFile:_plistPath atomically:YES];
                break;
            }
        }
        NSMutableDictionary *dict = downloadRecordDict[download.saveFileName];
        if (dict == nil) {
            [downloadRecordDict setObject:@{@"fileName":download.saveFileName,
                                            @"currentDownloadLen":[NSString stringWithFormat:@"%.1fMB",((CGFloat)(download.downloadLen) / kWHC_1MB)],
                                            @"totalLen":[NSString stringWithFormat:@"%.1fMB",((CGFloat)(download.totalLen) / kWHC_1MB)],
                                            @"speed":@"0KB/S",
                                            @"processValue":@(1.0),
                                            @"downPath":download.downPath,
                                            @"state":@(DownloadCompleted)}.mutableCopy forKey:download.saveFileName];
            [downloadRecordDict writeToFile:_plistPath atomically:YES];
        } else {
            [dict setObject:([NSString stringWithFormat:@"%.1fMB",((CGFloat)(download.downloadLen) / kWHC_1MB)]).copy forKey:@"currentDownloadLen"];
            [dict setObject:[NSString stringWithFormat:@"%.1fMB",((CGFloat)(download.totalLen) / kWHC_1MB)] forKey:@"totalLen"];
            [dict setObject:@(1.0) forKey:@"processValue"];
            [dict setObject:@(DownloadCompleted) forKey:@"state"];
            if([dict[@"downPath"] isEqualToString:@""]){
                [dict setObject:download.downPath forKey:@"downPath"];
            }
            [downloadRecordDict setObject:dict forKey:download.saveFileName];
            [downloadRecordDict writeToFile:_plistPath atomically:YES];
        }
        if (object) {
            object.processValue = 1.0;
            object.currentDownloadLen = object.totalLen;
            object.state = DownloadCompleted;
            object.speed = CompleteStatus;
        }
        //发出通知，更新DownloadingTableView的UI为“已下载”状态
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDownLoadStatus" object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeDownloadedCell" object:self];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"queryAgainAndRefresh" object:nil];
    }
    if (object) {
        [self displayCell:object];
    }
}

- (IBAction)clickButtonAction:(id)sender {
    switch (_downloadObject.state) {
        case Downloading:{ //暂停操作
            WHC_Download *download = [WHCDownloadCenter downloadWithFileName:_downloadObject.fileName];
            _downloadObject.state = DownloadUncompleted;
            if (download) {
                NSMutableDictionary *downloadRecordDict = [NSMutableDictionary dictionaryWithContentsOfFile:_plistPath];
                NSMutableDictionary *dict = downloadRecordDict[download.saveFileName];
                CGFloat percent = (CGFloat)(download.downloadLen) / download.totalLen * 100.0;
                if (dict == nil) {
                    [downloadRecordDict setObject:@{@"fileName":download.saveFileName,
                                                    @"currentDownloadLen":[NSString stringWithFormat:@"%.1fMB",((CGFloat)(download.downloadLen) / kWHC_1MB)],
                                                    @"totalLen":[NSString stringWithFormat:@"%.1fMB",((CGFloat)(download.totalLen) / kWHC_1MB)],
                                                    @"speed":@"0KB/S",
                                                    @"processValue":@(percent / 100.0),
                                                    @"downPath":download.downPath,
                                                    @"state":@(DownloadUncompleted)}.mutableCopy forKey:download.saveFileName];
                    [downloadRecordDict writeToFile:_plistPath atomically:YES];
                } else {
                    [dict setObject:([NSString stringWithFormat:@"%.1fMB",((CGFloat)(download.downloadLen) / kWHC_1MB)]).copy forKey:@"currentDownloadLen"];
                    [dict setObject:[NSString stringWithFormat:@"%.1fMB",((CGFloat)(download.totalLen) / kWHC_1MB)] forKey:@"totalLen"];
                    [dict setObject:@(percent / 100.0) forKey:@"processValue"];
                    [dict setObject:@(DownloadUncompleted) forKey:@"state"];
                    if ([dict[@"downPath"] isEqualToString:@""]) {
                        [dict setObject:download.downPath forKey:@"downPath"];
                    }
                    [downloadRecordDict setObject:dict forKey:download.saveFileName];
                    [downloadRecordDict writeToFile:_plistPath atomically:YES];
                }
            }
            [WHCDownloadCenter cancelDownloadWithFileName:_downloadObject.fileName delFile:NO];
        }
            break;
        case DownloadCompleted: //播放操作
            break;
        case DownloadUncompleted:{ //继续下载操作
            if ([WHCDownloadCenter existCancelDownload]) {
                [WHCDownloadCenter recoverDownloadWithName:_downloadObject.fileName delegate:self];
            } else {
                [WHCDownloadCenter startDownloadWithURL:[NSURL URLWithString:_downloadObject.downPath] savePath:Account.docFileFolder savefileName:_downloadObject.fileName tureFileName: _downloadObject.tureFileName delegate:self];
            }
            _downloadObject.state = DownloadWaitting;
            WHC_Download *download = [WHCDownloadCenter downloadWithFileName:_downloadObject.fileName];
            NSMutableDictionary *downloadRecordDict = [NSMutableDictionary dictionaryWithContentsOfFile:_plistPath];
            NSMutableDictionary *dict = downloadRecordDict[download.saveFileName];
            if (dict) {
                [dict setObject:@(DownloadWaitting) forKey:@"state"];
                [downloadRecordDict setObject:dict forKey:download.saveFileName];
                [downloadRecordDict writeToFile:_plistPath atomically:YES];
            }
        }
            break;
        case DownloadWaitting: //忽略
            break;
        default:
            break;
    }
    [self displayCell:_downloadObject];
}

@end
