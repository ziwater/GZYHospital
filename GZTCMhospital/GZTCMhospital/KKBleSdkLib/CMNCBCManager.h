//
//  CMNCBCManager.h
//  TestBLE
//
//  Created by comoncare on 14-6-12.
//  Copyright (c) 2014年 Ant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define kComonScanTimeOut 20.0  // 扫描超时时间

// 血压仪测试错误
#define kTestError0 0       // 测试成功，数据已被手机端接收
#define kTestError1 225     // 袖带缠绕不正确,请将袖带绑紧
#define kTestError2 226     // 袖带缠绕太松,请将袖带绑紧
#define kTestError3 227     // 请不要晃动手臂,请将袖带绑紧
#define kTestError4 228     // 电池电压过低,请更换电池
#define kTestError5 229     // 与血压计失去连接(可能是血压计被手动关闭，或血压计自动关闭)

typedef NS_ENUM (NSInteger, KKDeviceScanResult){
    KKDeviceScanResultTimeOut = 0,
    KKDeviceScanResultSuccess,
};

@protocol CMNBLEDelegate <NSObject>

@optional

/**
 * 设备状态改变的回调 在初始化BLEManager之后会立即调用
 *
 */
- (void)deviceState:(CBCentralManagerState )state;

@required

/**
 * 当手机端接收到血压计发送过来的血压测量信息时或测量异常时会被调用
 * @param mb 脉搏
 * @param hp 高压
 * @param lp 低压
 *
 */
- (void)periphralValueChangeMb:(int)mb withHp:(int)hp withLP:(int)lp withEr:(int)er;

/**
 * 蓝牙设备断开连接
 *
 */
- (void)periphralDisconnected;

/**
 * 当扫描到设备或者扫描超时时会调用此方法
 *
 */
- (void)deviceWasFound:(KKDeviceScanResult)result;

@end

@interface CMNCBCManager : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>

@property id<CMNBLEDelegate> delegate;

/**
 * 是否打开调试模式，调试模式会打log
 */
+ (void)setDebugMode:(BOOL)mode;

/**
 * 初始化BLE管理类实例
 *
 */
+ (CMNCBCManager *)shareInstance;
//- (void)initBluetooth;

/**
 * 开始搜索蓝牙设备
 *
 */
- (void)startScanDevice;

/**
 * 停止搜索蓝牙设备
 *
 */
- (void)stopScanDevice;

/**
 * 开始测试
 *
 */
- (void)startDetection;

/**
 * 停止测试，或者重置测试
 *
 */
- (void)resetDetection;

/**
 * 当前状态是否连接,isConnected 标志量标志是否连接过，该方法表示当前血压仪是否休眠
 * 若已休眠则 isConnected=Yes 但是不可以测试
 *
 */
- (BOOL)canTest;

/**
 * 主动断开连接设备
 */
- (void)disConnectDevice;

/**
 * 重置扫描设备计时
 *
 */
- (void)resetTimer;

/**
 * 获取当前已连接中的设备的UUID
 */
- (NSString *)getCurrentDeviceUUID;
@end
