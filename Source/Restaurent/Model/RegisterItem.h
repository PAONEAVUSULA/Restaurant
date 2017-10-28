//
//  RegisterItem.h
//  Restaurent
//
//  Created by SAN_Technologies on 12/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegisterItem : NSObject

@property (nonatomic, strong) NSString *placeHolder;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *serKey;
@property (nonatomic) NSInteger keyBoardType;

- (instancetype)initWithDictionary:(NSDictionary *)aDict;

@end
