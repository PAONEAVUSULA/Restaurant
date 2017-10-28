//
//  LiginViewController.m
//  Restaurent
//
//  Created by SAN_Technologies on 17/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginTableViewCell.h"
#import "OrdersViewController.h"
#import "RegistrationViewController.h"
#import "AppDelegate.h"
#import "RestaurentModel.h"
#import "WebServiceHandler.h"
#import "Constants.h"

@interface LoginViewController () {
    NSArray *listItems;
    AppDelegate *appDelegate;
}

@property (weak, nonatomic) IBOutlet UITableView *loginTableView;

- (IBAction)loginSelected:(id)sender;
- (IBAction)signupSelected:(id)sender;
- (void)loginUserWithDictionary:(NSDictionary *)loginDict;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *bgImage = [UIImage imageNamed:@"BG.png"];
    [self.view.layer setContents:(id)bgImage.CGImage];
    
    listItems = @[@"Phone num", @"Bot Name"];
    [self.loginTableView setBackgroundColor:[UIColor clearColor]];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoginCell" forIndexPath:indexPath];

    // Configure the cell...
    [cell.loginTextField setPlaceholder:[listItems objectAtIndex:indexPath.row]];
    UIKeyboardType keyBoardType = (indexPath.row == 0) ? UIKeyboardTypeNumberPad : UIKeyboardTypeNamePhonePad;
    [cell.loginTextField setKeyboardType:keyBoardType];
    //  =====  =====  =====  =====  =====  =====  =====  =====  =====  =====  =====  =====  =====
    /*NSString *valueString = nil;
    valueString = (indexPath.row == 0) ? @"9999898" : @"SitaraBot";
    [cell.loginTextField setText:valueString];*/
    //  =====  =====  =====  =====  =====  =====  =====  =====  =====  =====  =====  =====  =====
    return cell;
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"sitaraSegueID"]) {
//        OrdersViewController *destVC = segue.destinationViewController;
//        appDelegate.botName = @"Test";
    }
}


#pragma mark - Login service
- (void)loginUserWithDictionary:(NSDictionary *)loginDict {
    [appDelegate showActivityIndicator];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:loginDict options:0 error:&error];
    if (error) {
        [appDelegate showAlertWithTitle:@"MOXIEIT" andMessage:error.localizedDescription];
        return;
    }
    
    NSString *urlStr = [NSString stringWithFormat:LOGIN_API, SERVER_DOMAIN_NAME];
    [[WebServiceHandler sharedHandler] postData:data toURLString:urlStr callBackCompletionHandler:^(id jsonObject, NSError *error) {
        if (error) {
            [appDelegate showAlertWithTitle:@"MOXIEIT" andMessage:error.localizedDescription];
        } else {
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                NSString *status = [jsonObject objectForKey:@"status"];
                if ([status length] && [status isEqualToString:@"success"]) {
                    //Move to Orders screen.
                    RestaurentModel *restModel = [[RestaurentModel alloc] initWithRestaurentDict:jsonObject];
                    appDelegate.aRestaurant = restModel;
                    [self showOrdersViewController];
                } else {
                    [appDelegate showAlertWithTitle:@"MOXIEIT" andMessage:@"Login failed, Please check your details and enter again."];
                }
            }
        }
        [appDelegate stopActivityIndicator];
    }];
}


- (void)showOrdersViewController {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OrdersViewController *ordersVC = [storyBoard instantiateViewControllerWithIdentifier:@"OrdersVC"];
    [self.navigationController pushViewController:ordersVC animated:YES];
}

#pragma mark - IBAction -

- (IBAction)loginSelected:(id)sender {
    [self.view endEditing:YES];
    NSIndexPath *restIDIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    LoginTableViewCell *restPhoneCell = [self.loginTableView cellForRowAtIndexPath:restIDIndexPath];
    if (![restPhoneCell.loginTextField.text length]) {
        [appDelegate showAlertWithTitle:@"MOXIEIT" andMessage:@"Please enter restaurent registered Phone number."];
        return;
    }
    NSIndexPath *restPhoneIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    LoginTableViewCell *botCell = [self.loginTableView cellForRowAtIndexPath:restPhoneIndexPath];
    if (![botCell.loginTextField.text length]) {
        [appDelegate showAlertWithTitle:@"MOXIEIT" andMessage:@"Please enter restaurent bot name."];
        return;
    }
    
    NSString *phoneNumberString = restPhoneCell.loginTextField.text;
    NSString *botName = botCell.loginTextField.text;
    
//    NSString *phoneNumberString = @"5712919795";
//    NSString *botName = @"Test";

    NSDictionary *loginDict = [NSDictionary dictionaryWithObjectsAndKeys:phoneNumberString, @"phoneNo", botName, @"botName", nil];
    [self loginUserWithDictionary:loginDict];
}

- (IBAction)signupSelected:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegistrationViewController *catViewController = [storyBoard instantiateViewControllerWithIdentifier:@"RegisterVC"];
    catViewController.isNewUser = YES;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:catViewController];
    navController.navigationBarHidden = YES;
    [self presentViewController:navController animated:YES completion:^{
    }];
}

- (IBAction)gotoLoginScreen:(UIStoryboardSegue *)segue {
}

@end
