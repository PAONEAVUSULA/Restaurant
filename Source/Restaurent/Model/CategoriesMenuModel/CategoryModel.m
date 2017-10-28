//
//  CategoryModel.m
//  Categories
//
//  Created by SAN_Technologies on 19/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "CategoryModel.h"

@implementation CategoryModel

- (instancetype)initWithDictionary:(NSDictionary *)aDict
{
    if (self = [super init]) {
        self.categoryName = [aDict objectForKey:@"categoryName"];
        self.imageURLString = [aDict objectForKey:@"image"];
        self.categoryID = [aDict objectForKey:@"categoryId"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"CN:%@, IMN:%@", self.categoryName, self.imageURLString];
}

@end
