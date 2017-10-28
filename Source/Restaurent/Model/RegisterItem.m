//
//  RegisterItem.m
//  Restaurent
//
//  Created by SAN_Technologies on 12/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "RegisterItem.h"

@implementation RegisterItem

- (instancetype)initWithDictionary:(NSDictionary *)aDict
{
    if (self = [super init]) {
        self.placeHolder = [aDict objectForKey:@"PlaceHolder"];
        self.value = [aDict objectForKey:@"Value"];
        self.keyBoardType = [[aDict objectForKey:@"KeyBoardType"] integerValue];
        self.serKey = [aDict objectForKey:@"SerKey"];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"title::%@ kbType::%zd value:::%@", self.placeHolder, self.keyBoardType, self.value];
}

@end
