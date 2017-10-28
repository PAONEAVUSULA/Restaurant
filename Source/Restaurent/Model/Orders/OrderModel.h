//
//  OrderModel.h
//  OrderCheck
//
//  Created by SAN_Technologies on 01/06/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderModel : NSObject

@property (nonatomic, strong) NSString *timeString;
@property (nonatomic, strong) NSString *orderID;
@property (nonatomic, strong) NSString *orderFrom;
@property (nonatomic, strong) NSString *statusString;
@property (nonatomic, strong) NSString *customerMsgString;
@property (nonatomic, strong) NSString *orderTrackingString;
@property (nonatomic, strong) NSNumber *orderPrice;
@property (nonatomic, strong) NSDate *orderDate;

@property (nonatomic, strong) NSDictionary *foodItemsDict;


- (instancetype)initWithOrderDict:(NSDictionary *)aDict;

@end
