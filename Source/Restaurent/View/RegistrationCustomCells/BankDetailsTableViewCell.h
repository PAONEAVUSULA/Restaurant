//
//  BankDetailsTableViewCell.h
//  Restaurent
//
//  Created by SAN_Technologies on 21/08/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BankDetailsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *accHolderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *accNumLabel;

@end
