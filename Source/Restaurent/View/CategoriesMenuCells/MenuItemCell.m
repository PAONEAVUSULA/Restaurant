//
//  MenuItemCell.m
//  Restaurent
//
//  Created by SAN_Technologies on 28/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "MenuItemCell.h"

@implementation MenuItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)imageButtonSelected:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imageButtonDidSelectInCell:)]) {
        [self.delegate imageButtonDidSelectInCell:self];
    }
}

- (IBAction)foodTypeValueChanged:(id)sender {
    if ([self.delegate respondsToSelector:@selector(menuTypeSegmentControlDidSelectInCell:)]) {
        [self.delegate menuTypeSegmentControlDidSelectInCell:self];
    }
}

- (IBAction)spicySwitchSelected:(id)sender {
    if ([self.delegate respondsToSelector:@selector(spicySwitchDidSelectInCell:)]) {
        [self.delegate spicySwitchDidSelectInCell:self];
    }
}

- (IBAction)submitSelected:(id)sender {
    if ([self.delegate respondsToSelector:@selector(submitDidSelectInCell:)]) {
        [self.delegate submitDidSelectInCell:self];
    }
}

- (IBAction)cancelSelected:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cancelDidSelectInCell:)]) {
        [self.delegate cancelDidSelectInCell:self];
    }
}

@end
