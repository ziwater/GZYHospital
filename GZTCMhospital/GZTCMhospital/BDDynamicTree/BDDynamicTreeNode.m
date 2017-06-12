//
//  BDDynamicTreeNode.m
//  TreeTableViewDemo
//
//  Created by Chris on 16/2/19.
//  Copyright © 2016年 Chris. All rights reserved.
//

#import "BDDynamicTreeNode.h"

@implementation BDDynamicTreeNode

- (instancetype)initWithOriginX:(CGFloat)originX NotLeaf:(BOOL)NotLeaf fatherNodeId:(NSString *)fatherNodeId nodeId:(NSString *)nodeId name:(NSString *)name data:(NSDictionary *)data lever:(NSInteger)lever {
    self = [self init];
    if (self) {
        self.originX = originX;
        self.NotLeaf = NotLeaf;
        self.fatherNodeId = fatherNodeId;
        self.nodeId = nodeId;
        self.name = name;
        self.data = data;
        self.lever = lever;
    }
    return self;
}

- (BOOL)isRoot {
    return self.lever == 1;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"name:%@",self.name];
}

@end
