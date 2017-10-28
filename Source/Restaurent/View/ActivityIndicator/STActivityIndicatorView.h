//
//  STActivityIndicatorView.h
//  OrderCheck
//
//  Created by SAN_Technologies on 13/03/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STActivityIndicatorView : UIView

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

- (void)showActivity;
- (void)stopActivity;

@end
