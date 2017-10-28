//
//  FoodTableViewCell.h
//  OrderCheck
//
//  Created by SAN_Technologies on 13/06/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *foodItemLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *spiceLabel;

@end
