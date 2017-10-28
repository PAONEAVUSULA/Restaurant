//
//  ItemTableViewCell.m
//  Categories
//
//  Created by SAN_Technologies on 18/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "CategoryTableViewCell.h"

@implementation CategoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)categoryDisclosureDidSelect:(id)sender {
    if ([self.delegate respondsToSelector:@selector(existingCategoryDisclosureDidSelect:)]) {
        [self.delegate existingCategoryDisclosureDidSelect:self];
    }
}

- (IBAction)imageButtonSelected:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imageButtonDidSelectInCell:)]) {
        [self.delegate imageButtonDidSelectInCell:self];
    }
}

- (IBAction)existingCategoryImageButtonSelected:(id)sender {
    if ([self.delegate respondsToSelector:@selector(existingCategoryImageButtonDidSelectInCell:)]) {
        [self.delegate existingCategoryImageButtonDidSelectInCell:self];
    }
}

@end
