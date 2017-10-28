//
//  OrderModel.m
//  OrderCheck
//
//  Created by SAN_Technologies on 01/06/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "OrderModel.h"
#import "FoodItemModel.h"

@implementation OrderModel

- (instancetype)initWithOrderDict:(NSDictionary *)aDict {
    if (self = [super init]) {
        self.statusString = [aDict objectForKey:@"status"];
        self.orderID = [NSString stringWithFormat:@"%@", [aDict objectForKey:@"orderId"]];
        self.orderFrom = [aDict objectForKey:@"orderFrom"];
        self.foodItemsDict = [aDict objectForKey:@"foodItems"];
        self.orderPrice = [aDict objectForKey:@"totalPrice"];
        self.orderTrackingString = [aDict objectForKey:@"orderTracking"];
        self.timeString = [aDict objectForKey:@"orderTime"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm:ss"];
        self.orderDate = [dateFormatter dateFromString:self.timeString];
        
        NSLog(@"\nself.timeString:::::::%@ \n self.orderDate:::::::%@", self.timeString, [dateFormatter stringFromDate:self.orderDate]);
    }
    return self;
}


- (NSString *)description {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm:ss"];

    return [NSString stringWithFormat:@"ID:%@, status:%@, foodItemsDict::%@ date::%@", self.orderID, self.statusString, self.foodItemsDict, [dateFormatter stringFromDate:self.orderDate]];
}

@end
