//
//  SettingsTableViewCell.h
//  Restaurent
//
//  Created by SAN_Technologies on 17/08/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsTableViewCellDelegate;

@interface SettingsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *accountSwitch;
@property (nonatomic, assign) id<SettingsTableViewCellDelegate> delegate;

- (IBAction)accountSwitchValueChanged:(id)sender;

@end

@protocol SettingsTableViewCellDelegate <NSObject>

@optional
- (void)switchDidSelectInCell:(SettingsTableViewCell *)aCell;

@end
