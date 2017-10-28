//
//  BankAccountViewController.m
//  Restaurent
//
//  Created by SAN_Technologies on 11/08/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "BankAccountViewController.h"
#import "RegisterTFTableViewCell.h"
#import "BankDetailsTableViewCell.h"
#import "AppDelegate.h"
#import "RegisterItem.h"
#import "OptionsTableViewCell.h"
#import "WebServiceHandler.h"
#import "Constants.h"

typedef NS_ENUM(NSUInteger, BankAccountFields) {
    kAccountHolderNameRowID = 0,
    kAccountTypeRowID,
    kAccountNumberRowID,
    kCountryRowID,
    kCurrencyRowID,
    kEmailRowID,
    kRoutingNumRowID
};

@interface BankAccountViewController () {
    AppDelegate *appDelegate;
    BOOL isEditingMode;
}

@property (nonatomic, strong) NSArray *accountInfoArray;
@property (nonatomic, strong) NSDictionary *existingAccDict;
@property (weak, nonatomic) IBOutlet UITableView *bankAccountInfoTableView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

- (IBAction)submitSelected:(id)sender;
- (IBAction)backButtonSelected:(id)sender;

@end

@implementation BankAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *bgImage = [UIImage imageNamed:@"BG.png"];
    [self.view.layer setContents:(id)bgImage.CGImage];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.bankAccountInfoTableView setBackgroundColor:[UIColor clearColor]];
    if (self.isNewUser) {
        [self modelBankInfoPlistDetails];
        [self.backButton setTitle:@"" forState:UIControlStateNormal];
        [self.backButton setUserInteractionEnabled:NO];
        [self.backButton setBackgroundColor:[UIColor clearColor]];
        isEditingMode = YES;
    } else {
        [self.submitButton setTitle:@"EDIT" forState:UIControlStateNormal];
//        [self.backButton setTitle:@"BACK" forState:UIControlStateNormal];
        isEditingMode = NO;
        [self getBankAccountDetails];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self registerKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)modelBankInfoPlistDetails
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"BankInformation" ofType:@"plist"];
    self.accountInfoArray = [NSArray arrayWithContentsOfFile:filePath];
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *aDict in self.accountInfoArray) {
        RegisterItem *anItem = [[RegisterItem alloc] initWithDictionary:aDict];
        if (!self.isNewUser) {
            [self appendValuesToAnExistingUserForItem:anItem];
        }
        [newArray addObject:anItem];
    }
    self.accountInfoArray = newArray;
    NSLog(@"self.registerArray>>%@", self.accountInfoArray);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    NSInteger rows = 0;
    rows = ((self.isNewUser) || isEditingMode) ? [self.accountInfoArray count] : 1;
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView tfCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RegisterTFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textFieldCellID" forIndexPath:indexPath];
//     Configure the cell...
    RegisterItem *anItem = [self.accountInfoArray objectAtIndex:indexPath.row];
    [cell.regTextField setPlaceholder:anItem.placeHolder];
    NSString *value = [anItem.value isEqualToString:@""] ? @"" : anItem.value;
    [cell.regTextField setText:value];
    [cell.regTextField setKeyboardType:anItem.keyBoardType];
    [cell.regTextField setTag:indexPath.row];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView optionsCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OptionsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MultiOptionCell" forIndexPath:indexPath];
    RegisterItem *anItem = [self.accountInfoArray objectAtIndex:indexPath.row];
    [cell.optionPlaceHolderLabel setText:anItem.placeHolder];
    [cell.optionTitleLabel setText:anItem.value];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForExistingUserRowAtIndexPath:(NSIndexPath *)indexPath {
    BankDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BankDetailsCell" forIndexPath:indexPath];
    // Configure the cell...
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if ((self.isNewUser) || isEditingMode) {
        switch (indexPath.row) {
            case kAccountTypeRowID:
            case kCountryRowID:
            case kCurrencyRowID:
                cell = [self tableView:tableView optionsCellForRowAtIndexPath:indexPath];
                break;
                
            default:
                cell = [self tableView:tableView tfCellForRowAtIndexPath:indexPath];
                break;
        }
    } else {//Handle code for existing Account info.
        cell = [self tableView:tableView cellForExistingUserRowAtIndexPath:indexPath];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ((self.isNewUser) || isEditingMode) {
        UITableViewCell *aCell = [tableView cellForRowAtIndexPath:indexPath];
        NSArray *optionsArray = nil;
        switch (indexPath.row) {
            case kAccountTypeRowID:
            {
                optionsArray = @[@"Individual", @"Company"];
                [self showPopOverAtView:(OptionsTableViewCell *)aCell WithOptionsList:optionsArray];
            }
                break;
            case kCountryRowID:
            case kCurrencyRowID:
                break;
                
            default:
                [((RegisterTFTableViewCell *)aCell).regTextField becomeFirstResponder];
                break;
        }
    } else {//Handle code for existing Account holder
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = ((self.isNewUser) || isEditingMode) ? 80.0 : 300.0;
    return cellHeight;
}

#pragma mark - UITextFieldDelegate -
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //    NSLog(@">>>%@", textField);
    RegisterItem *regItem = [self.accountInfoArray objectAtIndex:textField.tag];
    regItem.value = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - KeyBoard Handling -

- (void)registerKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        id obj = [note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardFrame = CGRectNull;
        if ([obj respondsToSelector:@selector(getValue:)]) [obj getValue:&keyboardFrame];
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.bankAccountInfoTableView setContentInset:UIEdgeInsetsMake(0.f, 0.f, keyboardFrame.size.height, 0.f)];
        } completion:^(BOOL finished) {}];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.bankAccountInfoTableView setContentInset:UIEdgeInsetsZero];
        } completion:^(BOOL finished) {}];
    }];
}

- (void)validateBankAccountDetails {
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithCapacity:0];
    for (RegisterItem *anItem in self.accountInfoArray) {
        if ([anItem.value length] == 0) {
            NSString *message = [NSString stringWithFormat:@"Please enter %@.", anItem.placeHolder];
            [self showAlertWithTitle:@"MOXIEIT" andMessage:message];
            return;
        }
        BOOL isValid = YES;
        if ([anItem.placeHolder isEqualToString:@"Email"]) {
            isValid = [self validateEmailWithString:anItem.value];
        } else if ([anItem.placeHolder isEqualToString:@"Routing Number"] || [anItem.placeHolder isEqualToString:@"Account Number"]) {
            isValid = [self validateNumberValue:anItem.value];
        }
        if (!isValid) {
            NSString *message = [NSString stringWithFormat:@"Please enter a valid %@.", anItem.placeHolder];
            [self showAlertWithTitle:@"MOXIEIT" andMessage:message];
            return;
        }
        [paramsDict setObject:anItem.value forKey:anItem.serKey];
    }
    [paramsDict setObject:(self.isNewUser) ? @"Insert" : @"Update" forKey:@"type"];
    [paramsDict setObject:appDelegate.aRestaurant.botName forKey:@"botName"];
    NSLog(@"paramsDict>>%@", paramsDict);
    [self postBankAccountDetailsDictionary:paramsDict];
}

- (BOOL)validateEmailWithString:(NSString*)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (BOOL)validatePhone:(NSString *)phoneNumber {
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phoneNumber];
}

- (BOOL)validateNumberValue:(NSString *)aNumber {
    NSString *numberRegx = @"[0-9]*";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegx];
    return [numberTest evaluateWithObject:aNumber];
}

- (BOOL)validateName:(NSString *)aNumber {
    NSString *alphabetsRegx = @"[a-zA-Z ]*";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", alphabetsRegx];
    BOOL val = [numberTest evaluateWithObject:aNumber];
    return val;
}

#pragma mark - Handle Web service -

- (void)postBankAccountDetailsDictionary:(NSDictionary *)accountInfoDict {
    [appDelegate showActivityIndicator];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:accountInfoDict options:0 error:&error];
    if (error) {
        [self showAlertWithTitle:@"MOXIEIT" andMessage:error.localizedDescription];
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:POST_BANK_DETAILS_API, SERVER_DOMAIN_NAME];
    [[WebServiceHandler sharedHandler] postData:data toURLString:urlStr callBackCompletionHandler:^(id jsonObject, NSError *error) {
        NSString *errorMessage = nil;
        if (error) {
            errorMessage = error.localizedDescription;
        } else {
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                NSString *status = [jsonObject objectForKey:@"status"];
                if ([status length] && [status isEqualToString:@"success"]) {
                    [self ShowModificationsSuccessfullAlert];
                } else {
                    NSString *message = [jsonObject objectForKey:@"message"];
                    errorMessage = message ? message : @"Failed, Please check your details and enter again.";
                }
            }
        }
        [appDelegate stopActivityIndicator];
        if (errorMessage) {
            [self showAlertWithTitle:@"MOXIEIT" andMessage:errorMessage];
        }
    }];
}

- (void)getBankAccountDetails {
    [appDelegate showActivityIndicator];
    NSString *urlStr = [NSString stringWithFormat:GET_BANK_DETAILS_API, SERVER_DOMAIN_NAME, appDelegate.aRestaurant.botName];
    [[WebServiceHandler sharedHandler] fetchDataforURLString:urlStr callBackCompletionHandler:^(id jsonObject, NSError *error) {
        NSString *errorMessage = nil;
        if (error) {
            errorMessage = error.localizedDescription;
        } else {
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                NSString *status = [jsonObject objectForKey:@"status"];
                if ([status length]) {
                    if ([status isEqualToString:@"success"]) {
                        self.existingAccDict = [NSDictionary dictionaryWithDictionary:jsonObject];
                        [self modelBankInfoPlistDetails];
                        [self showExistingAccountDetails];
                    } else {
                        NSString *message = [jsonObject objectForKey:@"message"];
                        errorMessage = message ? message : @"Failed, Please check your details and enter again.";
                    }
                }
            }
        }
        [appDelegate stopActivityIndicator];
        if (errorMessage) {
            [self showAlertWithTitle:@"MOXIEIT" andMessage:errorMessage];
        }
    }];
}

- (void)ShowModificationsSuccessfullAlert {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"MOXIEIT"
                                message:@"Modifications made successful."
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okayButton = [UIAlertAction
                                 actionWithTitle:@"OKAY"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     //Handle your yes please button action here on register completion
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                 }];
    [alert addAction:okayButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)aMessage
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:aMessage
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okayButton = [UIAlertAction
                                 actionWithTitle:@"OKAY"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     //Handle your yes please button action here on register completion
                                     
                                 }];
    [alert addAction:okayButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showPopOverAtView:(OptionsTableViewCell *)optionsCell WithOptionsList:(NSArray *)optionsList
{
    NSIndexPath *indexPath = [self.bankAccountInfoTableView indexPathForCell:optionsCell];
    RegisterItem *aModel = [self.accountInfoArray objectAtIndex:indexPath.row];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelAction];
    
    for (NSString *aStatus in optionsList) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:aStatus style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"SelectedxTitle::%@", action.title);
            aModel.value = action.title;
            [optionsCell.optionTitleLabel setText:aModel.value];
//            [self.bankAccountInfoTableView reloadData];
        }];
        [alertController addAction:alertAction];
    }
    UIPopoverPresentationController *popPresenter = [alertController
                                                     popoverPresentationController];
    popPresenter.sourceView = optionsCell.optionPlaceHolderLabel;
    popPresenter.sourceRect = optionsCell.optionPlaceHolderLabel.bounds;
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showExistingAccountDetails {
    NSIndexPath *existingCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    BankDetailsTableViewCell *bankCell = [self.bankAccountInfoTableView cellForRowAtIndexPath:existingCellIndexPath];
    
    if ([[self.existingAccDict allKeys] count] != 10) {
        [self showAlertWithTitle:@"MOXIEIT" andMessage:@"Don't have bank account details for the user please select edit to enter details."];
    } else {
        NSString *name = [self.existingAccDict objectForKey:@"account_holder_name"] ? [self.existingAccDict objectForKey:@"account_holder_name"] : @"";
        NSString *acctType = [self.existingAccDict objectForKey:@"account_holder_type"] ? [self.existingAccDict objectForKey:@"account_holder_type"] : @"";//country, currency, accttype
        NSString *currency = [self.existingAccDict objectForKey:@"currency"] ? [self.existingAccDict objectForKey:@"currency"] : @"";
        NSString *country = [self.existingAccDict objectForKey:@"country"] ? [self.existingAccDict objectForKey:@"country"] : @"";
        NSString *acctNumb = [self.existingAccDict objectForKey:@"account_number"] ? [self.existingAccDict objectForKey:@"account_number"] : @"";
        NSString *routingNumb = [self.existingAccDict objectForKey:@"routing_number"] ? [self.existingAccDict objectForKey:@"routing_number"] : @"";
        NSString *email = [self.existingAccDict objectForKey:@"emailId"] ? [self.existingAccDict objectForKey:@"emailId"] : @"";
        
        NSString *typeStr = [NSString stringWithFormat:@"Country : %@\nCurrency :%@\nAccount Type :%@\n", country, currency, acctType];
        NSString *acctNum = [NSString stringWithFormat:@"Account Number :%@\nRouting Number :%@\nEmail :%@\n", acctNumb, routingNumb, email];
        [bankCell.accHolderNameLabel setText:name];
        [bankCell.accTypeLabel setText:typeStr];
        [bankCell.accNumLabel setText:acctNum];
    }
}

- (void)appendValuesToAnExistingUserForItem:(RegisterItem *)regItem {
    if ([regItem.serKey isEqualToString:@"account_holder_name"]) {
        regItem.value = [self.existingAccDict objectForKey:@"account_holder_name"];
    } else if ([regItem.serKey isEqualToString:@"account_holder_type"]) {
        regItem.value = [self.existingAccDict objectForKey:@"account_holder_type"];
    } else if ([regItem.serKey isEqualToString:@"account_number"]) {
        regItem.value = [self.existingAccDict objectForKey:@"account_number"];
    } else if ([regItem.serKey isEqualToString:@"emailId"]) {
        regItem.value = [self.existingAccDict objectForKey:@"emailId"];
    } else if ([regItem.serKey isEqualToString:@"routing_number"]) {
        regItem.value = [self.existingAccDict objectForKey:@"routing_number"];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)submitSelected:(id)sender {
    [self.view endEditing:YES];
    if ((self.isNewUser) || isEditingMode) {
        [self validateBankAccountDetails];
    } else {
        isEditingMode = YES;
        [self modelBankInfoPlistDetails];
        [self.submitButton setTitle:@"SUBMIT" forState:UIControlStateNormal];
        [self.bankAccountInfoTableView reloadData];
    }
}

- (IBAction)backButtonSelected:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
