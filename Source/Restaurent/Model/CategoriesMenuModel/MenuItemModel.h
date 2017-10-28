//
//  MenuItemModel.h
//  Categories
//
//  Created by SAN_Technologies on 19/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MenuItemModel : NSObject

@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, strong) NSString *itemPrice;
@property (nonatomic, strong) NSString *itemType;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *menuItemID;
@property (nonatomic) BOOL isSpicy;
@property (nonatomic) BOOL allowEditing;
@property (nonatomic, strong) UIImage *thumbnailImage;

- (instancetype)initWithDictionary:(NSDictionary *)aDict;

@end
