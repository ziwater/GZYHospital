//
//  QRViewController.h
//  SmartCity
//
//  Created by Chris on 15/8/24.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^QRUrlBlock)(NSString *url);

@interface QRViewController : UIViewController

@property (nonatomic, copy) QRUrlBlock qrUrlBlock;
@property (nonatomic, strong) id delegate;
@property (nonatomic, copy) NSString *stringValue;

@end
