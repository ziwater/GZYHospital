//
//  BloodPressureModel.h
//  
//
//  Created by Chris on 15/10/10.
//
//

#import <Foundation/Foundation.h>

@interface BloodPressureModel : NSObject

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, assign) NSInteger sbp;
@property (nonatomic, assign) NSInteger dbp;
@property (nonatomic, assign) NSInteger pulse;
@property (nonatomic, copy) NSString *measureType;
@property (nonatomic, assign) NSInteger risk;

@end
