//
//  OrderPopOverViewController.h
//  OrderCheck
//
//  Created by SAN_Technologies on 10/06/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderModel.h"

@interface OrderPopOverViewController : UIViewController

@property (nonatomic, strong) OrderModel *selectedOrder;
@property (weak, nonatomic) IBOutlet UILabel *orderTitleLabel;

@end
