//
//  BDDynamicTreeNode.h
//  TreeTableViewDemo
//
//  Created by Chris on 16/2/19.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BDDynamicTreeNode : NSObject

@property (nonatomic, assign) CGFloat       originX;            //坐标x
@property (nonatomic, strong) NSString      *name;              //名称
@property (nonatomic, strong) NSDictionary  *data;              //节点详细
@property (nonatomic, strong) NSArray       *subNodes;          //子节点
@property (nonatomic, strong) NSString      *fatherNodeId;      //父节点的id
@property (nonatomic, strong) NSString      *nodeId;            //当前节点id
@property (nonatomic, assign) BOOL          NotLeaf;             //是否叶子结点
@property (nonatomic, assign) NSInteger     lever;               //结点所在层级
@property (nonatomic, assign) BOOL          isOpen;             //是否展开的

//检查是否根节点
- (BOOL)isRoot;

//快速实例化该对象模型
- (instancetype)initWithOriginX:(CGFloat)originX NotLeaf:(BOOL)NotLeaf fatherNodeId:(NSString *)fatherNodeId nodeId:(NSString *)nodeId name:(NSString *)name data:(NSDictionary *)data lever:(NSInteger)lever;

@end
