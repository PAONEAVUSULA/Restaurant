//
//  DBManager.m
//  Affiliates
//
//  Created by SAN_Technologies on 22/09/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "DBManager.h"

@implementation DBManager

+ (instancetype)sharedManager {
    static DBManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

@end
