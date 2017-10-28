//
//  SettingModel.m
//  Restaurent
//
//  Created by SAN_Technologies on 17/08/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "SettingModel.h"

@implementation SettingModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.title = [dict objectForKey:@"Title"];
        self.imageIconName = [dict objectForKey:@"Image_Icon"];
        self.isOn = [[dict objectForKey:@"isOn"] boolValue];
        self.showSwitch = [[dict objectForKey:@"ShowSwitch"] boolValue];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"T:%@ IMg:%@", self.title, self.imageIconName];
}

@end
