//
//  RestaurentModel.m
//  OrderCheck
//
//  Created by SAN_Technologies on 09/06/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "RestaurentModel.h"

@implementation RestaurentModel

- (instancetype)initWithRestaurentDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.restaurentID = [dict objectForKey:@"restaurantId"] ? [dict objectForKey:@"restaurantId"] : @"";
        self.restaurentName = [dict objectForKey:@"restaurantName"] ? [dict objectForKey:@"restaurantName"] : @"";
        self.botName = [dict objectForKey:@"botName"] ? [dict objectForKey:@"botName"] : @"";
        self.pageName = [dict objectForKey:@"pageName"] ? [dict objectForKey:@"pageName"] : @"";
        self.phoneNumStr = [dict objectForKey:@"phone_no"] ? [dict objectForKey:@"phone_no"] : @"";
        self.street = [dict objectForKey:@"street_1"] ? [dict objectForKey:@"street_1"] : @"";
        self.city = [dict objectForKey:@"city"] ? [dict objectForKey:@"city"] : @"";
        self.state = [dict objectForKey:@"state"] ? [dict objectForKey:@"state"] : @"";
        self.country = [dict objectForKey:@"country"] ? [dict objectForKey:@"country"] : @"";
        self.zipCode = [dict objectForKey:@"zipCode"] ? [dict objectForKey:@"zipCode"] : @"";
        
        self.monToFriHours = [dict objectForKey:@"monToFriHours"] ? [dict objectForKey:@"monToFriHours"] : @"";
        self.satToSunHours = [dict objectForKey:@"satToSunHours"] ? [dict objectForKey:@"satToSunHours"] : @"";

        self.imageURLString = [dict objectForKey:@"image"] ? [dict objectForKey:@"image"] : @"";
        self.emailString = [dict objectForKey:@"emailId"] ? [dict objectForKey:@"emailId"] : @"";
    }
    return self;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"ID:%@, Name:%@, botname::%@", self.restaurentID, self.restaurentName, self.botName];
}

@end
