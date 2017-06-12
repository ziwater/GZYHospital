//
//  MD5Method.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/14.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "MD5Method.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MD5Method

+ (NSString *)md5: (NSString *)md5String {
    const char *cStr = [md5String UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end
