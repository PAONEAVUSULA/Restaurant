//
//  CategoryModel.h
//  Categories
//
//  Created by SAN_Technologies on 19/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CategoryModel : NSObject

@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, strong) UIImage *thumbnailImage;

- (instancetype)initWithDictionary:(NSDictionary *)aDict;

@end
