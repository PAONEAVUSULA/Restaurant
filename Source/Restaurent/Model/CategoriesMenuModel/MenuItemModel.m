//
//  MenuItemModel.m
//  Categories
//
//  Created by SAN_Technologies on 19/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "MenuItemModel.h"

@implementation MenuItemModel

- (instancetype)initWithDictionary:(NSDictionary *)aDict {
    if (self = [super init]) {
        self.itemName = [aDict objectForKey:@"itemName"];
        self.itemPrice = [NSString stringWithFormat:@"%@", [aDict objectForKey:@"price"]];
        self.itemType = [aDict objectForKey:@"itemType"];
        self.imageURLString = [aDict objectForKey:@"image"];
        self.menuItemID = [aDict objectForKey:@"itemId"];
        NSString *spiceString = [aDict objectForKey:@"isSpicy"];
        self.isSpicy = [spiceString isEqualToString:@"true"] ? YES : NO;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"CN:%@, itemPrice:%@", self.itemName, self.itemPrice];
}

@end
