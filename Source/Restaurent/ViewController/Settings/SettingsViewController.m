//
//  SettingsViewController.m
//  Restaurent
//
//  Created by SAN_Technologies on 17/08/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsTableViewCell.h"
#import "RegistrationViewController.h"
#import "BankAccountViewController.h"
#import "ContactUsViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AppDelegate.h"
#import "SettingModel.h"
#import "Constants.h"
#import "WebServiceHandler.h"

typedef NS_ENUM(NSUInteger, SettingFields) {
    kUserSettingsID,
    kAppDetailsID
};

@interface SettingsViewController () <SettingsTableViewCellDelegate>{
    AppDelegate *appDelegate;
    FBSDKLoginManager *loginManager;
}

@property (nonatomic, strong) NSDictionary *dataDict;
@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self modelSettingsPlistData];
    UIImage *bgImage = [UIImage imageNamed:@"BG.png"];
    [self.view.layer setContents:(id)bgImage.CGImage];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.settingsTableView setBackgroundColor:[UIColor clearColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)modelSettingsPlistData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
    NSDictionary *dataDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    NSMutableDictionary *newDataDict = [NSMutableDictionary dictionaryWithCapacity:0];
    for (NSString *aKey in [dataDict allKeys]) {
        NSArray *itemsList = [dataDict objectForKey:aKey];
        NSMutableArray *newList = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *itemDict in itemsList) {
            SettingModel *aModel = [[SettingModel alloc] initWithDictionary:itemDict];
            [newList addObject:aModel];
        }
        [newDataDict setObject:newList forKey:aKey];
    }
    self.dataDict = [NSDictionary dictionaryWithDictionary:newDataDict];
}

- (NSString *)getKeyForSection:(NSInteger)section {
    NSString *aKey = nil;
    switch (section) {
        case kUserSettingsID:
            aKey = @"USER SETTINGS";
            break;
        case kAppDetailsID:
            aKey = @"APP DETAILS";
            break;
            
        default:
            break;
    }
    return aKey;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *keysList = [self.dataDict allKeys];
    return [keysList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    NSString *sectionKey = [self getKeyForSection:section];
    NSArray *dataList = [self.dataDict objectForKey:sectionKey];
    rows = [dataList count];
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionKey = [self getKeyForSection:indexPath.section];
    NSArray *dataList = [self.dataDict objectForKey:sectionKey];
    SettingModel *aModel = [dataList objectAtIndex:indexPath.row];

    SettingsTableViewCell *aCell = nil;
    if (!aModel.showSwitch) {
        aCell = [tableView dequeueReusableCellWithIdentifier:@"SettingsDiscIndicatorCell" forIndexPath:indexPath];
    } else {
        aCell = [tableView dequeueReusableCellWithIdentifier:@"SettingsSwitchCell" forIndexPath:indexPath];
        [aCell.accountSwitch setOn:aModel.isOn];
        aCell.delegate = self;
    }
    [aCell.titleLabel setText:aModel.title];
    [aCell.iconImageView setImage:[UIImage imageNamed:aModel.imageIconName]];
    [aCell setBackgroundColor:[UIColor clearColor]];
    [aCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return aCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSelectorForSelectedIndexPath:indexPath];
}

#pragma mark - SettingsTableViewCellDelegate
- (void)switchDidSelectInCell:(SettingsTableViewCell *)aCell {
    NSIndexPath *selectedIndexPath =  [self.settingsTableView indexPathForCell:aCell];
    switch (selectedIndexPath.section) {
        case 0://User Details Section
        {
            if (selectedIndexPath.row == 2) {
                if (![aCell.accountSwitch isOn]) {//Signout of current loggedin restaurant.
                    UIAlertController *alert = [UIAlertController
                                                alertControllerWithTitle:@"MOXIEIT"
                                                message:@"Are you sure, would you like to signout of your restaurant account?"
                                                preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelButton = [UIAlertAction
                                                 actionWithTitle:@"No"
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                     [aCell.accountSwitch setOn:YES];
                                                 }];
                    
                    UIAlertAction *okayButton = [UIAlertAction
                                                 actionWithTitle:@"Yes"
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                     [self performSelector:@selector(logoutSelected) withObject:nil afterDelay:0.1];
                                                 }];
                    [alert addAction:cancelButton];
                    [alert addAction:okayButton];
                    [self presentViewController:alert animated:YES completion:nil];
                } else {
                    [loginManager logOut];
                }
            }
        }
        default:
            break;
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

#pragma mark - Handle Web service -

- (void)postFaceBookAccountDetailsDictionary:(NSDictionary *)accountInfoDict {
    [appDelegate showActivityIndicator];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:accountInfoDict options:0 error:&error];
    if (error) {
        [appDelegate showAlertWithTitle:@"MOXIEIT" andMessage:error.localizedDescription];
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:FB_CONNECT_API, SERVER_DOMAIN_NAME];
    [[WebServiceHandler sharedHandler] postData:data toURLString:urlStr callBackCompletionHandler:^(id jsonObject, NSError *error) {
        NSString *errorMessage = nil;
        if (error) {
            errorMessage = error.localizedDescription;
        } else {
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                NSString *status = [jsonObject objectForKey:@"status"];
                if ([status length] && [status isEqualToString:@"success"]) {
                    errorMessage = @"Linking facebook page and bot is successful.";
                } else {
                    NSString *message = [jsonObject objectForKey:@"message"];
                    errorMessage = message ? message : @"Failed to link facebook page with bot.";
                }
            }
        }
        [appDelegate stopActivityIndicator];
        if (errorMessage) {
            [appDelegate showAlertWithTitle:@"MOXIEIT" andMessage:error.localizedDescription];
        }
    }];
}

#pragma mark - Private methods

- (void)performSelectorForSelectedIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0://User Details Section
        {
            switch (indexPath.row) {
                case 0://User Details
                    [self showRegistrationScreen];
                    break;
                case 1://Bank Details
                    [self showBankInfoScreen];
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            NSArray *dataList = [self.dataDict objectForKey:@"APP DETAILS"];
            SettingModel *aModel = [dataList objectAtIndex:indexPath.row];

            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ContactUsViewController *contactUsVC = [storyBoard instantiateViewControllerWithIdentifier:@"ContactUsVC"];
            contactUsVC.setModel = aModel;
            [self.navigationController pushViewController:contactUsVC animated:YES];

        }
//            [self performSegueWithIdentifier:@"ContactUsSegue" sender:self];
            break;
            
        default:
            break;
    }
}

- (void)logoutSelected {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showBankInfoScreen {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BankAccountViewController *bankViewController = [storyBoard instantiateViewControllerWithIdentifier:@"BankInfoVC"];
    bankViewController.isNewUser = NO;
    [self.navigationController pushViewController:bankViewController animated:YES];
}

- (void)showRegistrationScreen {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RegistrationViewController *catViewController = [storyBoard instantiateViewControllerWithIdentifier:@"RegisterVC"];
    catViewController.isNewUser = NO;
    [self.navigationController pushViewController:catViewController animated:YES];
}


#pragma mark - FaceBook Handling methods
- (void)loginFacebook {
    loginManager = [[FBSDKLoginManager alloc] init];
    
    [loginManager logInWithReadPermissions:@[@"public_profile", @"pages_show_list", @"pages_messaging"]//@"publish_actions"
                 fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                if (error) {
                                    NSLog(@"Process error");
                                } else if (result.isCancelled) {
                                    NSLog(@"Cancelled");
                                } else {
                                    NSLog(@"Logged in");
                                    UIAlertController *alert = [UIAlertController
                                                                alertControllerWithTitle:@"MOXIEIT"
                                                                message:@"You are successfully logged in. To link your facebook page with bot continue!!!"
                                                                preferredStyle:UIAlertControllerStyleAlert];
                                    
                                    UIAlertAction *okayButton = [UIAlertAction
                                                                 actionWithTitle:@"CONTINUE"
                                                                 style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [self performSelector:@selector(appendPublishPermissions) withObject:nil afterDelay:0.1];
                                                                 }];
                                    [alert addAction:okayButton];
                                    [self presentViewController:alert animated:YES completion:nil];
                                }
                            }];
}

- (void)appendPublishPermissions {
    [loginManager logInWithPublishPermissions:@[@"manage_pages", @"publish_pages"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {//@"publish_actions"
        if (error) {
            NSLog(@"Process error");
        } else if (result.isCancelled) {
            NSLog(@"Cancelled");
        } else {
            NSLog(@"Logged in");//[FBSDKAccessToken currentAccessToken].tokenString
            [self getPagesForTheUser];
        }
    }];
}

- (void)getPagesForTheUser {
    NSString *graphPath = [NSString stringWithFormat:@"/me/accounts"];
    NSDictionary *params = @{
                             @"fields": @"name"
                             };
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:graphPath
                                  parameters:params
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        // Handle the result
        if (error) {
            NSLog(@"Process error");
        } else {
            NSLog(@"result>>>%@ error>>%@", result, error);//Send the page accesstoken and page/Bot name to server
            if (result) {
                NSArray *pagesList = [result objectForKey:@"data"];
                NSString *linkedPageName = nil;
                for (NSDictionary *pageDict in pagesList) {
                    NSString *pageName = [pageDict objectForKey:@"name"];
                    NSComparisonResult result = [pageName compare:appDelegate.aRestaurant.botName options:NSCaseInsensitiveSearch];
                    if (NSOrderedSame == result) {
                        linkedPageName = pageName;
                    }
                }
                if (linkedPageName) {
//                    NSString *token = [FBSDKAccessToken currentAccessToken].tokenString;
//                    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:linkedPageName, @"botName", token, @"userAccessToken", nil];
                    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:linkedPageName, @"botName", nil];
                    [self postFaceBookAccountDetailsDictionary:infoDict];

                } else {
                    NSIndexPath *fbIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    SettingsTableViewCell *cell = [self.settingsTableView cellForRowAtIndexPath:fbIndexPath];
                    [cell.accountSwitch setOn:NO];
                    [appDelegate showAlertWithTitle:@"MOXIEIT" andMessage:@"Bot name specified at app registration and Facebook page name are not matching, Please check the details and login into facebook again."];
                }
            }
        }
    }];
}

- (IBAction)gotoSettingsScreen:(UIStoryboardSegue *)segue {
    
}

@end
