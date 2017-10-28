//
//  STActivityIndicatorView.m
//  OrderCheck
//
//  Created by SAN_Technologies on 13/03/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "STActivityIndicatorView.h"

@implementation STActivityIndicatorView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)showActivity
{
    [self.activityIndicatorView startAnimating];
}

- (void)stopActivity
{
    [self.activityIndicatorView stopAnimating];
}


@end
