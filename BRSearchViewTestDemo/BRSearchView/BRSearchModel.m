//
//  BRSearchModel.m
//  BRSearchViewTestDemo
//
//  Created by Bruce on 16/1/11.
//  Copyright © 2016年 Bruce. All rights reserved.
//

#import "BRSearchModel.h"

@implementation BRSearchModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

@end
