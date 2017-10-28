//
//  OrderTableViewCell.m
//  OrderCheck
//
//  Created by SAN_Technologies on 26/05/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "OrderTableViewCell.h"

@implementation OrderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)recordSpeech:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(voiceOverDidSelect:)]) {
        [self.delegate voiceOverDidSelect:self];
    }
}

- (IBAction)changeOrderStatus:(id)sender {
    if ([self.delegate respondsToSelector:@selector(changeOrderStatusDidSelect:)]) {
        [self.delegate changeOrderStatusDidSelect:self];
    }
}
@end
