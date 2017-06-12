//
//  MyDeviceTableView.h
//  GZTCMhospital
//
//  Created by Chris on 15/10/8.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyDeviceTableView : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *hpDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *lpDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *mbDataLabel;
@property (weak, nonatomic) IBOutlet UIButton *startOrStopMeasuringButton;
@property (weak, nonatomic) IBOutlet UITextView *statusTextView;
@property (weak, nonatomic) IBOutlet UIImageView *measuredResultImage;
@property (weak, nonatomic) IBOutlet UILabel *measurementDateLable;

- (IBAction)startMeasuring:(id)sender;

typedef NS_ENUM (NSInteger, KKBloodPressureResult) {
    BLOOD_LOW = 0,
    BLOOD_NORMAL,
    BLOOD_NORMAL_HIGH,
    BLOOD_HIGH_LIGHT,
    BLOOD_HIGH_MEDIUM,
    BLOOD_HIGH_HEAVY,
    BLOOD_DANCUN,
};

@end
