//
//  DatePickViewController.h
//  OrderCheck
//
//  Created by SAN_Technologies on 22/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickViewControllerDelegate;

@interface DatePickViewController : UIViewController

@property (weak, nonatomic) id<DatePickViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIDatePicker *historyDatePicker;

- (IBAction)doneSelected:(id)sender;
- (IBAction)datePickerValueChanged:(id)sender;
- (IBAction)cancelButtonSelected:(id)sender;

@end

@protocol DatePickViewControllerDelegate <NSObject>

@required
- (void)didSelectDoneinViewController:(DatePickViewController *)pickVC withDate:(NSString *)dateString;
- (void)cancelButtonDidSelectInViewController:(DatePickViewController *)pickVC;

@end
