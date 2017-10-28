//
//  HoursPickerViewController.h
//  Restaurent
//
//  Created by SAN_Technologies on 13/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HoursPickerViewControllerDelegate;

@interface HoursPickerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIPickerView *hoursPickerView;
@property (nonatomic) NSInteger rowNumber;
@property (nonatomic, weak) id<HoursPickerViewControllerDelegate> delegate;
- (IBAction)doneSelected:(id)sender;

@end

@protocol HoursPickerViewControllerDelegate <NSObject>

@required
- (void)doneButtonSelectedInViewController:(HoursPickerViewController *)pickerVC AndWorkHours:(NSString *)workHours;

@end
