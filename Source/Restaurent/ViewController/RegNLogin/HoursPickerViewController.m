//
//  HoursPickerViewController.m
//  Restaurent
//
//  Created by SAN_Technologies on 13/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "HoursPickerViewController.h"

#define kDays @"Days"
#define kHours @"Hours"

@interface HoursPickerViewController () {
    
}

@property (nonatomic) NSDictionary *dataDict;

@end

@implementation HoursPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WorkHours" ofType:@"plist"];
    self.dataDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    [self.hoursPickerView.layer setBorderColor:[UIColor whiteColor].CGColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    for (int i = 0; i < 4; i++) {
        [self.hoursPickerView selectRow:(i + 3) inComponent:i animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPickerViewDataSource -

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return [[self.dataDict allKeys] count] * 2;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0://Days Component
        case 1://Days Component
            return [[self.dataDict objectForKey:kDays] count];
            break;
        case 2://Hours Component
        case 3://Hours Component
            return [[self.dataDict objectForKey:kHours] count];
            break;
    }
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    switch (component) {
        case 0://Days Component
        case 1://Days Component
            return 80.0;
            break;
        case 2://Hours Component
        case 3://Hours Component
            return 150.0;
            break;
    }
    return 0;
}


- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *aKey;
    switch (component) {
        case 0://Days Component
        case 1://Days Component
        aKey = kDays;
        break;
        case 2://Hours Component
        case 3://Hours Component
        aKey = kHours;
        break;
    }
    NSArray *selectedList = [self.dataDict objectForKey:aKey];
    NSString *title = [selectedList objectAtIndex:row];
    return title;//Or, your suitable title; like Choice-a, etc.
}

/*
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString *aKey;
    switch (component) {
        case 0://Leagues Component
            aKey = kLeagues;
            break;
        case 1://Markets Component
            aKey = kMarkets;
            break;
    }
    NSArray *selectedList = [self.leaguesMarketsDict objectForKey:aKey];
    SportModel *selectedModel = [selectedList objectAtIndex:row];
    
    UILabel* tView = (UILabel*)view;
    if (!tView)
    {
        tView = [[UILabel alloc] init];
        [tView setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        [tView setNumberOfLines:0];
        [tView setTextAlignment:NSTextAlignmentCenter];
        [tView setLineBreakMode:NSLineBreakByWordWrapping];
    }
    // Fill the label text here
    tView.text = selectedModel.title;
    return tView;
}
*/
#pragma mark - UIPickerViewDelegate -

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 44.0;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    //Here, like the table view you can get the each section of each row if you've multiple sections
    NSLog(@"Selected row: %zd", row);
    
    //Now, if you want to navigate then;
    // Say, OtherViewController is the controller, where you want to navigate:
    //    OtherViewController *objOtherViewController = [OtherViewController new];
    //    [self.navigationController pushViewController:objOtherViewController animated:YES];
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
    NSMutableString *hoursString = [NSMutableString stringWithCapacity:0];
    for (int i = 0; i < 4; i++) {
        NSInteger selectedRow = [self.hoursPickerView selectedRowInComponent:i];
        NSString *aKey;
        switch (i) {
            case 0://Days Component
            case 1://Days Component
            {
                NSString *appendStr = (i == 0) ? @"" : @" - ";
                [hoursString appendString:appendStr];
                aKey = kDays;
            }
                break;
            case 2://Hours Component
            case 3://Hours Component
            {
                NSString *appendStr = (i == 2) ? @" : " : @" - ";
                [hoursString appendString:appendStr];
                aKey = kHours;
            }
                break;
        }
        NSString *selectedStr = [[self.dataDict objectForKey:aKey] objectAtIndex:selectedRow];
        [hoursString appendString:selectedStr];
    }
    
    
    if ([self.delegate respondsToSelector:@selector(doneButtonSelectedInViewController:AndWorkHours:)]) {
        [self.delegate doneButtonSelectedInViewController:self AndWorkHours:hoursString];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}
@end
