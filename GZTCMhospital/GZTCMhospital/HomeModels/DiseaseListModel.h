//
//  DiseaseListModel.h
//  
//
//  Created by Chris on 15/10/12.
//
//

#import <Foundation/Foundation.h>

@interface DiseaseListModel : NSObject

@property (nonatomic, copy) NSString *FatherID;
@property (nonatomic, copy) NSString *Name;
@property (nonatomic, copy) NSString *Order;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, assign) NSInteger Lever;
@property (nonatomic, copy) NSString *Image;

@property (nonatomic, strong) NSNumber *NotLeaf;

@end
