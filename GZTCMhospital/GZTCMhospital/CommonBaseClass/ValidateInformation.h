//
//  ValidateInformation.h
//  GZTCMhospital
//
//  Created by Chris on 15/9/8.
//  Copyright (c) 2015年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ValidateInformation : NSObject

+ (BOOL)validateIDCardNumber:(NSString *)value;
+ (BOOL)validateMobile:(NSString *)mobileNum;
+ (BOOL)validatePassword:(NSString *)password;
+ (BOOL)validateName:(NSString *)name;

@end
