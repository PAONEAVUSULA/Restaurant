//
//  RegistrationViewController.m
//  Restaurent
//
//  Created by SAN_Technologies on 11/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "RegistrationViewController.h"
#import "BankAccountViewController.h"
#import "RegisterTFTableViewCell.h"
#import "WorkingHoursTableViewCell.h"
#import "ProfilePicTableViewCell.h"
#import "HoursPickerViewController.h"
#import "RegDetailsTableViewCell.h"
#import "AppDelegate.h"
#import "RegisterItem.h"
#import "Constants.h"
#import "WebServiceHandler.h"

typedef NS_ENUM(NSUInteger, RegistrationFields) {
    kProfilePicRowID = 0,
    kRestaurantRowID,
    kBotRowID,
    kAccessTokenRowID,
    kEmailRowID,
    kPhoneNumberRowID,
    kStreetRowID,
    kCityRowID,
    kStateRowID,
    kCountryRowID,
    kZipCodeRowID,
    kWorkingHours1RowID,
    kWorkingHours2RowID,
};

@interface RegistrationViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, HoursPickerViewControllerDelegate>{
//    CGRect tableViewOriginalRect;
    AppDelegate *appDelegate;
    UIImage *profilePic;
    BOOL isEditingMode;
}

@property (nonatomic) NSArray *registerArray;
@property (weak, nonatomic) IBOutlet UITableView *regTableView;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (void)modelRegistrationPlistDetails;
- (void)postRegistrationDetailsDictionary:(NSDictionary *)regDict;
- (IBAction)submitSelected:(id)sender;
- (IBAction)CancelDidSelect:(id)sender;

@end


@implementation RegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    tableViewOriginalRect = self.regTableView.frame;
    UIImage *bgImage = [UIImage imageNamed:@"BG.png"];
    [self.view.layer setContents:(id)bgImage.CGImage];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.regTableView setBackgroundColor:[UIColor clearColor]];
    if (self.isNewUser) {
        isEditingMode = YES;
    } else {
        [self.submitButton setTitle:@"EDIT" forState:UIControlStateNormal];
        [self.cancelButton setTitle:@"BACK" forState:UIControlStateNormal];
        isEditingMode = NO;
        [self downloadProfilePicImage];
    }
    [self modelRegistrationPlistDetails];
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
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

- (void)modelRegistrationPlistDetails
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"RegDetails" ofType:@"plist"];
    self.registerArray = [NSArray arrayWithContentsOfFile:filePath];
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *aDict in self.registerArray) {
        RegisterItem *anItem = [[RegisterItem alloc] initWithDictionary:aDict];
        if (!self.isNewUser) {
            [self appendValuesToAnExistingUserForItem:anItem];
        }
        [newArray addObject:anItem];
    }
    self.registerArray = newArray;
    NSLog(@"self.registerArray>>%@", self.registerArray);
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
    rows = ((self.isNewUser) || isEditingMode) ? [self.registerArray count] : 1;
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView profilePicCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProfilePicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    if (profilePic) {
        [cell.profilePicImageView setImage:profilePic];
    }
//    [cell.layer setContents:(id)[UIImage imageNamed:@"Add.png"].CGImage];
    // Configure the cell...
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView tfCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RegisterTFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textFieldCellID" forIndexPath:indexPath];
//     Configure the cell...
    RegisterItem *anItem = [self.registerArray objectAtIndex:indexPath.row];
    [cell.regTextField setPlaceholder:anItem.placeHolder];
    NSString *value = [anItem.value isEqualToString:@""] ? @"" : anItem.value;
    [cell.regTextField setText:value];
    [cell.regTextField setKeyboardType:anItem.keyBoardType];
    [cell.regTextField setTag:indexPath.row];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView hoursCellForRowAtIndexPath:(NSIndexPath *)indexPath {
     WorkingHoursTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hoursCellID" forIndexPath:indexPath];
    
// Configure the cell...
    RegisterItem *anItem = [self.registerArray objectAtIndex:indexPath.row];
    if ([anItem.value length]) {
        [cell.hoursTextField setText:anItem.value];
    } else {
        [cell.hoursTextField setPlaceholder:anItem.placeHolder];
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView buttonCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCellID" forIndexPath:indexPath];
// Configure the cell...
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForExistingUserRowAtIndexPath:(NSIndexPath *)indexPath {
    RegDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RegDetailsCell" forIndexPath:indexPath];
    // Configure the cell...
//    RegisterItem *anItem = [self.registerArray objectAtIndex:indexPath.row];
    NSString *contactString = [NSString stringWithFormat:@"Phone : %@ \nEmail :%@ \nWorning Hours : %@ \n%@", appDelegate.aRestaurant.phoneNumStr, appDelegate.aRestaurant.emailString, appDelegate.aRestaurant.monToFriHours, appDelegate.aRestaurant.satToSunHours];
    NSString *addressString = [NSString stringWithFormat:@"%@, %@, %@, %@", appDelegate.aRestaurant.street, appDelegate.aRestaurant.city, appDelegate.aRestaurant.state, appDelegate.aRestaurant.country];

    [cell.restTitleLabel setText:[appDelegate.aRestaurant.restaurentName uppercaseString]];
    [cell.contactLabel setText:contactString];
    [cell.addressLabel setText:addressString];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if ((self.isNewUser) || isEditingMode) {
        switch (indexPath.row) {
            case kProfilePicRowID://Profile Pic cell
                cell = [self tableView:tableView profilePicCellForRowAtIndexPath:indexPath];
                break;
            case kWorkingHours1RowID://Working Hours Row
            case kWorkingHours2RowID:
                cell = [self tableView:tableView hoursCellForRowAtIndexPath:indexPath];
                break;
                
            default:
                cell = [self tableView:tableView tfCellForRowAtIndexPath:indexPath];
                break;
        }
    } else {//Handle code for existing user
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
        switch (indexPath.row) {
            case kProfilePicRowID://Handle ImagePicker
            {
                [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary fromButton:(ProfilePicTableViewCell *)aCell];
            }
                break;
            case kWorkingHours1RowID://Handle Hours selection(Show Picker)
            case kWorkingHours2RowID:
                [self showWorkingHoursPicker:aCell];
                break;
                
            default:
                [((RegisterTFTableViewCell *)aCell).regTextField becomeFirstResponder];
                break;
        }
    } else {//Handle code for existing user
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0.0;
    if ((self.isNewUser) || isEditingMode) {
        switch (indexPath.row) {
            case kProfilePicRowID:
                return 230.0;
                break;
            default:
                return 80.0;
                break;
        }
    } else {//Handle code for existing user
        cellHeight = 300.0;
    }
    
    return cellHeight;
}

#pragma mark - UITextFieldDelegate -
- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    NSLog(@">>>%@", textField);
    RegisterItem *regItem = [self.registerArray objectAtIndex:textField.tag];
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
            [self.regTableView setContentInset:UIEdgeInsetsMake(0.f, 0.f, keyboardFrame.size.height, 0.f)];
        } completion:^(BOOL finished) {}];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.regTableView setContentInset:UIEdgeInsetsZero];
        } completion:^(BOOL finished) {}];
    }];
}

- (void)validateRegistrationDetails {
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithCapacity:0];
    for (RegisterItem *anItem in self.registerArray) {
        if ([anItem.value length] == 0) {
            NSString *message = [NSString stringWithFormat:@"Please enter %@.", anItem.placeHolder];
            [self showAlertWithTitle:@"MOXIEIT" andMessage:message];
            return;
        }
        BOOL isValid = YES;
        if ([anItem.placeHolder isEqualToString:@"Email"]) {
            isValid = [self validateEmailWithString:anItem.value];
        } else if ([anItem.placeHolder isEqualToString:@"Phone"]) {
//            isValid = [self validatePhone:anItem.value];
        } else if ([anItem.serKey isEqualToString:@"botName"]) {
            isValid = [self validateName:anItem.value];
        }
        if (!isValid) {
            NSString *message = [NSString stringWithFormat:@"Please enter a valid %@.", anItem.placeHolder];
            [self showAlertWithTitle:@"MOXIEIT" andMessage:message];
            return;
        }
        [paramsDict setObject:anItem.value forKey:anItem.serKey];
    }
    [paramsDict setObject:(self.isNewUser) ? @"Insert" : @"Update" forKey:@"type"];
    
    //----- ----- ----- ----- ----- Hours Key Value Handling ----- ----- ----- ----- ----- -----
/*    NSString *hours1Str = [paramsDict objectForKey:@"hours1"];
    NSString *hours2Str = [paramsDict objectForKey:@"hours2"];
    NSString *newHoursStr = [NSString stringWithFormat:@"%@ %@", hours1Str, hours2Str];
    [paramsDict removeObjectsForKeys:@[@"hours1", @"hours2"]];
    [paramsDict setObject:newHoursStr forKey:@"hours"];*/
    //----- ----- ----- ----- -----  ----- ----- ----- ----- ----- ----- ----- ----- -----
    
    NSLog(@"paramsDict>>%@", paramsDict);
//    NSDictionary *paramsDict = [NSDictionary dictionary];
    if (profilePic) {
        [self uploadProfilePicImage:paramsDict];
    } else {
        [self showAlertWithTitle:@"MOXIEIT" andMessage:@"Please select a profile pic for your restaurant."];
    }
    //First Upload profilePic, on success upload registration detail.
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
//NSString *regEx = @"^[a-zA-Z0-9]*$";

- (BOOL)validateName:(NSString *)aNumber {
    NSString *alphabetsRegx = @"[a-zA-Z ?_]*";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", alphabetsRegx];
    BOOL val = [numberTest evaluateWithObject:aNumber];
    return val;
}

- (void)showWorkingHoursPicker:(UITableViewCell *)sender {
    [self.view endEditing:YES];
    NSIndexPath *indexPath = [self.regTableView indexPathForCell:sender];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HoursPickerViewController *hoursPickerVC = [storyBoard instantiateViewControllerWithIdentifier:@"HoursPickerVC"];
    hoursPickerVC.rowNumber = indexPath.row;
    hoursPickerVC.delegate = self;
    hoursPickerVC.preferredContentSize = CGSizeMake(500.0, 320.0);
    hoursPickerVC.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *aPopVC = hoursPickerVC.popoverPresentationController;
    aPopVC.sourceView = sender;
    aPopVC.sourceRect = sender.bounds;
    aPopVC.permittedArrowDirections = UIPopoverArrowDirectionAny;
//    aPopVC.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:165.0/255.0 blue:135.0/255.0 alpha:1.0];
//    aPopVC.delegate = self;
     
    [self presentViewController:hoursPickerVC animated:YES completion:^{
    }];
}

#pragma mark - UIImagePickerController -
- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType fromButton:(UIView *)button {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    imagePickerController.modalPresentationStyle =
    (sourceType == UIImagePickerControllerSourceTypeCamera) ? UIModalPresentationFullScreen : UIModalPresentationPopover;
    
    UIPopoverPresentationController *presentationController = imagePickerController.popoverPresentationController;
//    presentationController.barButtonItem = button;  // display popover from the UIBarButtonItem as an anchor
    presentationController.sourceView = button;
    presentationController.sourceRect = button.bounds;
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
/*    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        // The user wants to use the camera interface. Set up our custom overlay view for the camera.
        imagePickerController.showsCameraControls = NO;
*/
        /*
         Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view, and set self's reference to the view to nil.
         */
/*        [[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil];
        self.overlayView.frame = imagePickerController.cameraOverlayView.frame;
        imagePickerController.cameraOverlayView = self.overlayView;
        self.overlayView = nil;
    }
*/
    self.imagePickerController = imagePickerController; // we need this for later
    
    [self presentViewController:self.imagePickerController animated:YES completion:^{
        //.. done presenting
    }];
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
//    NSData *imgData = UIImageJPEGRepresentation(image, 1); //1 it represents the quality of the image.
    UIImage *imgCompressed = [self compressImage:image];
    NSData *imgData = UIImagePNGRepresentation(imgCompressed);
    
    NSUInteger dataLength = [imgData length];
    
    NSLog(@"size of image in KB::%tu", dataLength / 1024);
    profilePic = imgCompressed;
    [self dismissViewControllerAnimated:YES completion:nil];
    self.imagePickerController = nil;
    [self.regTableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        //.. done dismissing
    }];
}

#pragma mark - HoursPickerViewControllerDelegate
- (void)doneButtonSelectedInViewController:(HoursPickerViewController *)pickerVC AndWorkHours:(NSString *)workHours {
    RegisterItem *anItem = [self.registerArray objectAtIndex:pickerVC.rowNumber];
    anItem.value = workHours;
    [self.regTableView reloadData];
}

#pragma mark - Handle Web service -

- (void)downloadProfilePicImage {
    /*[[WebServiceHandler sharedHandler] fetchDataforURLString:appDelegate.aRestaurant.imageURLString callBackCompletionHandler:^(id jsonObject, NSError *error) {
        if (error) {
            [appDelegate showAlertWithTitle:@"MOXIEIT" andMessage:error.localizedDescription];
        } else {
            UIImage *anImage = [[UIImage alloc] initWithData:jsonObject];
            profilePic = anImage;
            [self.regTableView reloadData];
        }
    }];*/
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(aQueue, ^{
        NSURL *url = [NSURL URLWithString:appDelegate.aRestaurant.imageURLString];
        NSURLRequest *urlReq = [NSURLRequest requestWithURL:url];
        NSURLSession *urlSession = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *anImage = [[UIImage alloc] initWithData:data];
                    profilePic = anImage;
                    [self.regTableView reloadData];
                });
            } else {
                
            }
        }];
        [dataTask resume];
    });
}

- (void)uploadProfilePicImage:(NSDictionary *)paramsDictionary {
    [appDelegate showActivityIndicator];
    NSData *imageData = UIImageJPEGRepresentation(profilePic, 1.0);
    NSString *base64String = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:base64String, @"file", nil];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:postDict options:0 error:&error];
    if (error) {
        [self showAlertWithTitle:@"MOXIEIT" andMessage:error.localizedDescription];
        return;
    }
    
    NSString *urlStr = [NSString stringWithFormat:IMAGE_UPLOAD_API, SERVER_DOMAIN_NAME];
    [[WebServiceHandler sharedHandler] postData:data toURLString:urlStr callBackCompletionHandler:^(id jsonObject, NSError *error) {
        NSString *errorMessage = nil;
        if (error) {
            errorMessage = error.localizedDescription;
        } else {
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                NSString *fileURLStr = [jsonObject objectForKey:@"fileUrl"];
                if ([fileURLStr length]) {
                    NSMutableDictionary *newParamDict = [NSMutableDictionary dictionaryWithCapacity:0];
                    [newParamDict addEntriesFromDictionary:paramsDictionary];
                    [newParamDict setObject:fileURLStr forKey:@"image"];
                    [self postRegistrationDetailsDictionary:newParamDict];
                    
                } else {errorMessage = @"Image upload failed and couldn't register details, please try again.";}
            } else {errorMessage = @"Unidetified error occured please try again.";
            }
        }
        [appDelegate stopActivityIndicator];
        if (errorMessage) {
            [self showAlertWithTitle:@"MOXIEIT" andMessage:errorMessage];
        }
    }];
}

- (void)postRegistrationDetailsDictionary:(NSDictionary *)regDict {
    [appDelegate showActivityIndicator];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:regDict options:0 error:&error];
    if (error) {
        [self showAlertWithTitle:@"MOXIEIT" andMessage:error.localizedDescription];
        return;
    }
    
    NSString *urlStr = [NSString stringWithFormat:REGISTRATION_API, SERVER_DOMAIN_NAME];
    [[WebServiceHandler sharedHandler] postData:data toURLString:urlStr callBackCompletionHandler:^(id jsonObject, NSError *error) {
        NSString *errorMessage = nil;
        if (error) {
            errorMessage = error.localizedDescription;
        } else {
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                NSString *status = [jsonObject objectForKey:@"status"];
                if ([status length]) {
                    if ([status isEqualToString:@"success"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.isNewUser) {
                                [self ShowRegistrationSuccessfullAlert];
                            } else {
                                [self showModificationsSuccesfulAlertWithMessage:@"Modifications made successfully."];
                            }
                            RestaurentModel *restModel = [[RestaurentModel alloc] initWithRestaurentDict:regDict];
                            appDelegate.aRestaurant = restModel;
                        });
                    } else {
                        NSString *message = [jsonObject objectForKey:@"message"];
                        errorMessage = message ? message : @"Registration failed, Please check your details and enter again.";
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

- (void)showBankInfoScreen {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BankAccountViewController *bankViewController = [storyBoard instantiateViewControllerWithIdentifier:@"BankInfoVC"];
    bankViewController.isNewUser = YES;
    [self.navigationController pushViewController:bankViewController animated:YES];
}

- (void)ShowRegistrationSuccessfullAlert {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"MOXIEIT"
                                message:@"Registration is successful, please press okay to login."
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okayButton = [UIAlertAction
                                 actionWithTitle:@"Continue"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     //Handle your yes please button action here on register completion
                                     [self showBankInfoScreen];
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

- (void)showModificationsSuccesfulAlertWithMessage:(NSString *)aMessage
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"MOXIEIT"
                                message:aMessage
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okayButton = [UIAlertAction
                                 actionWithTitle:@"OKAY"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     //Handle your yes please button action here on register completion
                                     [self.navigationController popViewControllerAnimated:YES];
                                 }];
    [alert addAction:okayButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (UIImage *)compressImage:(UIImage *)image {
    
    NSData *imgData = UIImageJPEGRepresentation(image, 1); //1 it represents the quality of the image.
    NSLog(@"Size of Image(bytes):%ld",(unsigned long)[imgData length]);
    
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 600.0;
    float maxWidth = 800.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.5;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth) {
        if (imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if (imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        } else {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    NSLog(@"Size of Image(bytes):%ld",(unsigned long)[imageData length]);
    
    return [UIImage imageWithData:imageData];
}

- (void)appendValuesToAnExistingUserForItem:(RegisterItem *)regItem {
    if ([regItem.serKey isEqualToString:@"image"]) {
        regItem.value = appDelegate.aRestaurant.imageURLString;
    } else if ([regItem.serKey isEqualToString:@"restaurantName"]) {
        regItem.value = appDelegate.aRestaurant.restaurentName;
    } else if ([regItem.serKey isEqualToString:@"botName"]) {
        regItem.value = appDelegate.aRestaurant.botName;
    } else if ([regItem.serKey isEqualToString:@"pageName"]) {
        regItem.value = appDelegate.aRestaurant.pageName;
    } else if ([regItem.serKey isEqualToString:@"emailId"]) {
        regItem.value = appDelegate.aRestaurant.emailString;
    } else if ([regItem.serKey isEqualToString:@"phone_no"]) {
        regItem.value = appDelegate.aRestaurant.phoneNumStr;
    } else if ([regItem.serKey isEqualToString:@"street_1"]) {
        regItem.value = appDelegate.aRestaurant.street;
    } else if ([regItem.serKey isEqualToString:@"city"]) {
        regItem.value = appDelegate.aRestaurant.city;
    } else if ([regItem.serKey isEqualToString:@"state"]) {
        regItem.value = appDelegate.aRestaurant.state;
    } else if ([regItem.serKey isEqualToString:@"country"]) {
        regItem.value = appDelegate.aRestaurant.country;
    } else if ([regItem.serKey isEqualToString:@"zipCode"]) {
        regItem.value = appDelegate.aRestaurant.zipCode;
    } else if ([regItem.serKey isEqualToString:@"monToFriHours"]) {
        regItem.value = appDelegate.aRestaurant.monToFriHours;
    } else if ([regItem.serKey isEqualToString:@"satToSunHours"]) {
        regItem.value = appDelegate.aRestaurant.satToSunHours;
    }
}

#pragma mark - IBAction - 

- (IBAction)showImagePickerForPhotoPicker:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary fromButton:sender];
}

- (IBAction)submitSelected:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [self.view endEditing:YES];
    if ((self.isNewUser) || isEditingMode) {
        [self validateRegistrationDetails];
//        [self showBankInfoScreen];
    } else {
        isEditingMode = YES;
        [self modelRegistrationPlistDetails];
        [self.submitButton setTitle:@"SUBMIT" forState:UIControlStateNormal];
        [self.regTableView reloadData];
    }
}

- (IBAction)CancelDidSelect:(id)sender {
    if (self.isNewUser) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)gotoRigisterScreen:(UIStoryboardSegue *)segue {
    
}

@end

/*
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(keyboardWasShown:)
 name:UIKeyboardDidShowNotification object:nil];
 
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(keyboardWillBeHidden:)
 name:UIKeyboardWillHideNotification object:nil];*/


/*
 // Called when the UIKeyboardDidShowNotification is sent.
 
 - (void)keyboardWasShown:(NSNotification*)aNotification {
 NSDictionary *info = [aNotification userInfo];
 CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
 
 CGRect modifiedRect = tableViewOriginalRect;
 modifiedRect.size.height -= kbSize.height;
 [self.regTableView setFrame:modifiedRect];
 //    [scrollView setContentOffset:CGPointMake(0.0, activeField.frame.origin.y-kbSize.height) animated:YES];
 }
 
 // Called when the UIKeyboardWillHideNotification is sent
 - (void)keyboardWillBeHidden:(NSNotification*)aNotification
 {
 [self.regTableView setFrame:tableViewOriginalRect];
 //    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
 //    scrollView.contentInset = contentInsets;
 //    scrollView.scrollIndicatorInsets = contentInsets;
 }
 
 - (void)keyboardWasShown:(NSNotification*)aNotification
 {
 NSDictionary* info = [aNotification userInfo];
 CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
 
 UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
 scrollView.contentInset = contentInsets;
 scrollView.scrollIndicatorInsets = contentInsets;
 
 // If active text field is hidden by keyboard, scroll it so it's visible
 // Your app might not need or want this behavior.
 CGRect aRect = self.view.frame;
 aRect.size.height -= kbSize.height;
 if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
 [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
 }
 }
 */
