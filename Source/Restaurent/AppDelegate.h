//
//  AppDelegate.h
//  Restaurent
//
//  Created by SAN_Technologies on 11/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestaurentModel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RestaurentModel *aRestaurant;

- (void)showActivityIndicator;
- (void)stopActivityIndicator;
- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)aMessage;

@end

