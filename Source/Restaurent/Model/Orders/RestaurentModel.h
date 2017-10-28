//
//  RestaurentModel.h
//  OrderCheck
//
//  Created by SAN_Technologies on 09/06/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RestaurentModel : NSObject

@property (nonatomic, strong) NSString *restaurentID;
@property (nonatomic, strong) NSString *restaurentName;
@property (nonatomic, strong) NSString *botName;
@property (nonatomic, strong) NSString *pageName;
@property (nonatomic, strong) NSString *phoneNumStr;
@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *zipCode;
@property (nonatomic, strong) NSString *monToFriHours;
@property (nonatomic, strong) NSString *satToSunHours;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *emailString;


//@property (nonatomic, strong) NSArray *ordersList;

- (instancetype)initWithRestaurentDict:(NSDictionary *)dict;

@end
