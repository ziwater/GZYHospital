//
//  MyDeviceTableView.m
//  GZTCMhospital
//
//  Created by Chris on 15/10/8.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import "MyDeviceTableView.h"

#import "CMNCBCManager.h"

static NSString *str;

@interface MyDeviceTableView () <CMNBLEDelegate>

@property (nonatomic, strong) CMNCBCManager *bleManager;

@end

@implementation MyDeviceTableView

- (void)viewDidLoad {
    [super viewDidLoad]; 
    
    [CMNCBCManager shareInstance].delegate = self;
    self.bleManager = [CMNCBCManager shareInstance];
    [CMNCBCManager setDebugMode:YES]; // 注：默认开启debug模式
    
    self.startOrStopMeasuringButton.titleLabel.text = StartMeasuringTitle;
    
    self.statusTextView.text = nil;
    str = self.statusTextView.text;
    
    self.statusTextView.layoutManager.allowsNonContiguousLayout = NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return CGFLOAT_MIN; //取消分组静态表顶部的间隙
    return tableView.sectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1 || section  == 2) {
        return CGFLOAT_MIN;
    }
    return tableView.sectionFooterHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 230;
    } else if (indexPath.section == 3) {
        return self.tableView.frame.size.height - 360;
    }
    return 40;
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

- (void)configStatusTextView:(NSString *)text {
    str = [str stringByAppendingString:text];
    self.statusTextView.text = str;
    //滚动显示TextView，始终能显示最后一行
    [self.statusTextView scrollRangeToVisible:NSMakeRange(self.statusTextView.text.length, 1)];
}

- (IBAction)startMeasuring:(id)sender {
    if ([self.startOrStopMeasuringButton.titleLabel.text isEqualToString:StartMeasuringTitle]) {
        [self.startOrStopMeasuringButton setTitle:StopMeasuringTitle forState:UIControlStateNormal];
        
        [self configStatusTextView:StartMeasuringTip];
        
        [self.bleManager startScanDevice]; //开始搜索蓝牙设备

    } else {
        [self.startOrStopMeasuringButton setTitle:StartMeasuringTitle forState:UIControlStateNormal];
        
        [self configStatusTextView:StopMeasuredTip];
        
        [self.bleManager stopScanDevice]; //停止搜索蓝牙设备
        [self.bleManager resetDetection]; //停止测试，或者重置测试
    }
}

#pragma mark - CMNBLEDelegate Method

- (void)deviceState:(CBCentralManagerState )state {
    if (CBCentralManagerStatePoweredOn == state) {
        [self configStatusTextView:IsScanningTip];
        [self.startOrStopMeasuringButton setTitle:StopMeasuringTitle forState:UIControlStateNormal];
    } else if (CBCentralManagerStatePoweredOff == state) {
        [self configStatusTextView:BluetoothIsNotOpenTip];
        [self.startOrStopMeasuringButton setTitle:StartMeasuringTitle forState:UIControlStateNormal];
    } else {
        [self configStatusTextView:BluetoothIsNotAvailableTip];
        [self.startOrStopMeasuringButton setTitle:StartMeasuringTitle forState:UIControlStateNormal];
    }
}

- (void)periphralValueChangeMb:(int)mb withHp:(int)hp withLP:(int)lp withEr:(int)er {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    switch (er) {
        case kTestError0:
            self.hpDataLabel.text = [NSString stringWithFormat:@"%d", hp]; //高压（收缩压）SBP
            self.lpDataLabel.text = [NSString stringWithFormat:@"%d", lp]; //低压（舒张压）DBP
            self.mbDataLabel.text = [NSString stringWithFormat:@"%d", mb]; //心率
            
            [self showResultPic:[self getResultWithSBP:hp andDBP:lp]]; //显示结果图片
            
            self.measurementDateLable.text = [dateFormatter stringFromDate:[NSDate date]];
            
            [self configStatusTextView:CompleteTip];
            
            [self.startOrStopMeasuringButton setTitle:StartMeasuringTitle forState:UIControlStateNormal];
            
            break;
        case kTestError1:
            [self configStatusTextView:WindingIsNotCorrectTip];
            [self.startOrStopMeasuringButton setTitle:StartMeasuringTitle forState:UIControlStateNormal];
            break;
        case kTestError2:
            [self configStatusTextView:WrappingIsTooLooseTip];
            [self.startOrStopMeasuringButton setTitle:StartMeasuringTitle forState:UIControlStateNormal];
            break;
        case kTestError3:
            [self configStatusTextView:DoNotShakeTheArmTip];
            [self.startOrStopMeasuringButton setTitle:StartMeasuringTitle forState:UIControlStateNormal];
            break;
        case kTestError4:
            [self configStatusTextView:BatteryVoltageIsTooLowTip];
            [self.startOrStopMeasuringButton setTitle:StartMeasuringTitle forState:UIControlStateNormal];
            break;
        case kTestError5:
            [self configStatusTextView:LosingTheConnectionWithDeviceTip];
            [self.startOrStopMeasuringButton setTitle:StartMeasuringTitle forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)periphralDisconnected {
    [self configStatusTextView:ConnectionHasBeenDisconnectedTip];
    [self.startOrStopMeasuringButton setTitle:StartMeasuringTitle forState:UIControlStateNormal];
}

- (void)deviceWasFound:(KKDeviceScanResult)result {
    if (KKDeviceScanResultSuccess == result) {
        [self configStatusTextView:DeviceIsConnectedTip];
        
        [self.bleManager startDetection]; //开始测量
        
        [self configStatusTextView:MeasuringTip];
        
    } else if (KKDeviceScanResultTimeOut == result) {
        [self configStatusTextView:ScanTimeoutTip];
        [self.startOrStopMeasuringButton setTitle:StartMeasuringTitle forState:UIControlStateNormal];
    }
}

#pragma mark - 获取血压分类值 设置血压结果图片

- (NSInteger)getResultWithSBP:(int)sbp andDBP:(int)dbp {
    if (sbp < 90 && dbp < 60) {
        return BLOOD_LOW;
    }
    if (sbp < 120 && dbp < 80) {
        return BLOOD_NORMAL;
    }
    if (sbp >= 120 && sbp <=139 && dbp >=80 && dbp <=89) {
        return BLOOD_NORMAL_HIGH;
    }
    if (sbp >= 140 && dbp <90) {
        return BLOOD_DANCUN;
    }
    
    int sbpLevel = 0;
    int dbpLevel = 0;
    
    if (sbp >= 140 && sbp <= 159) {
        sbpLevel = BLOOD_HIGH_LIGHT;
    } else if (sbp >= 160 && sbp <= 179) {
        sbpLevel = BLOOD_HIGH_MEDIUM;
    } else if (sbp >= 180 ) {
        sbpLevel = BLOOD_HIGH_HEAVY;
    }
    
    if (dbp >= 90 && dbp <= 99) {
        dbpLevel = BLOOD_HIGH_LIGHT;
    } else if (dbp >= 100 && dbp <= 109) {
        dbpLevel = BLOOD_HIGH_MEDIUM;
    } else if (dbp >= 110 ) {
        dbpLevel = BLOOD_HIGH_HEAVY;
    }
    
    return sbpLevel >= dbpLevel ? sbpLevel : dbpLevel;
}

- (void)showResultPic:(KKBloodPressureResult)result {
    if (result == BLOOD_LOW) {
        self.measuredResultImage.image = [UIImage imageNamed:@"gzy_xueya_blood_mark_low"];
    } else if (result == BLOOD_NORMAL) {
        self.measuredResultImage.image = [UIImage imageNamed:@"gzy_xueya_blood_mark_normal"];
    } else if (result == BLOOD_NORMAL_HIGH) {
        self.measuredResultImage.image = [UIImage imageNamed:@"gzy_xueya_blood_mark_normalhigh"];
    } else if (result == BLOOD_HIGH_LIGHT) {
        self.measuredResultImage.image = [UIImage imageNamed:@"gzy_xueya_blood_mark_light"];
    } else if (result == BLOOD_HIGH_MEDIUM) {
        self.measuredResultImage.image = [UIImage imageNamed:@"gzy_xueya_blood_mark_medium"];
    } else if (result == BLOOD_HIGH_HEAVY) {
        self.measuredResultImage.image = [UIImage imageNamed:@"gzy_xueya_blood_mark_heavy"];
    } else if (result == BLOOD_DANCUN) {
        self.measuredResultImage.image = [UIImage imageNamed:@"gzy_xueya_blood_mark_dancun"];
    }
}

@end
