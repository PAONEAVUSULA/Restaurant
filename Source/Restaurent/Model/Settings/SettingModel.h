//
//  SettingModel.h
//  Restaurent
//
//  Created by SAN_Technologies on 17/08/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageIconName;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, assign) BOOL showSwitch;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
