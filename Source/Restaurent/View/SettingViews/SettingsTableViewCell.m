//
//  SettingsTableViewCell.m
//  Restaurent
//
//  Created by SAN_Technologies on 17/08/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "SettingsTableViewCell.h"

@implementation SettingsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)accountSwitchValueChanged:(id)sender {
    if ([self.delegate respondsToSelector:@selector(switchDidSelectInCell:)]) {
        [self.delegate switchDidSelectInCell:self];
    }
}
@end
