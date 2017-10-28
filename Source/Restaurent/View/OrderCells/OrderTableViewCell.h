//
//  OrderTableViewCell.h
//  OrderCheck
//
//  Created by SAN_Technologies on 26/05/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OrderCellDelegate;

@interface OrderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *appetizerLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainCourseLabel;
@property (weak, nonatomic) IBOutlet UILabel *dessertLabel;
@property (weak, nonatomic) IBOutlet UILabel *customerMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;
@property (weak, nonatomic) IBOutlet UIButton *voiceOverButton;
@property (weak, nonatomic) IBOutlet UIButton *orderStatusButton;
@property (weak, nonatomic) IBOutlet UILabel *billLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderFromLabel;


@property (weak, nonatomic) id<OrderCellDelegate> delegate;

- (IBAction)recordSpeech:(id)sender;
- (IBAction)changeOrderStatus:(id)sender;

@end


@protocol OrderCellDelegate <NSObject>

@optional
- (void)voiceOverDidSelect:(OrderTableViewCell *)orderCell;
- (void)changeOrderStatusDidSelect:(OrderTableViewCell *)orderCell;

@end
