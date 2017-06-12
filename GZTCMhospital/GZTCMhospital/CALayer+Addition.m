//
//  CALayer+Addition.m
//  GZTCMhospital
//
//  Created by Chris on 15/12/10.
//  Copyright © 2015年 Chris. All rights reserved.
//

#import "CALayer+Addition.h"
#import <UIKit/UIKit.h>

@implementation CALayer (Addition)

- (void)setBorderColorFromUIColor:(UIColor *)color {
    self.borderColor = color.CGColor;
}

@end
