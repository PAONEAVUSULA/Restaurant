//
//  FoodItemModel.h
//  OrderCheck
//
//  Created by SAN_Technologies on 09/06/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FoodItemModel : NSObject

@property (strong, nonatomic) NSString *itemID;
@property (strong, nonatomic) NSString *itemName;
@property (strong, nonatomic) NSString *itemQuantity;
@property (strong, nonatomic) NSString *spicyLevel;

- (instancetype)initWithFoodDict:(NSDictionary *)aDict;

@end
