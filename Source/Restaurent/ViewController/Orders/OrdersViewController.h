//
//  OrdersViewController.h
//  OrderCheck
//
//  Created by SAN_Technologies on 26/05/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrdersViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *ordersTableView;
@property (weak, nonatomic) IBOutlet UILabel *restNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *restAddressLabel;

- (IBAction)refreshOrders:(id)sender;
- (IBAction)gotoOrdersViewController:(UIStoryboardSegue *)sbSegue;

@end
