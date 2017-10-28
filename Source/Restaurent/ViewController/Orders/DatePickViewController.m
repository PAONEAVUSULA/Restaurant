//
//  DatePickViewController.m
//  OrderCheck
//
//  Created by SAN_Technologies on 22/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "DatePickViewController.h"

@interface DatePickViewController () {
    NSDateFormatter *dateFormatter;
}

@end

@implementation DatePickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doneSelected:(id)sender {
    NSString *dateString = [dateFormatter stringFromDate:self.historyDatePicker.date];
    NSLog(@"DS::%@", dateString);
    if ([self.delegate respondsToSelector:@selector(didSelectDoneinViewController:withDate:)]) {
        [self.delegate didSelectDoneinViewController:self withDate:dateString];
    }
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)datePickerValueChanged:(id)sender {
}

- (IBAction)cancelButtonSelected:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cancelButtonDidSelectInViewController:)]) {
        [self.delegate cancelButtonDidSelectInViewController:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
