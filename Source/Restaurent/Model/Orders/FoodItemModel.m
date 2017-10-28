//
//  FoodItemModel.m
//  OrderCheck
//
//  Created by SAN_Technologies on 09/06/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "FoodItemModel.h"

@implementation FoodItemModel

- (instancetype)initWithFoodDict:(NSDictionary *)aDict {
    if (self = [super init]) {
        self.itemID = [aDict objectForKey:@"menuItemId"];
        self.itemName = [aDict objectForKey:@"name"];
        self.itemQuantity = [aDict objectForKey:@"quantity"];
        self.spicyLevel = [aDict objectForKey:@"spiceyLevel"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"ID:%@, Name:%@", self.itemID, self.itemName];
}

@end
