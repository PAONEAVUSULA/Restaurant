//
//  OrdersViewController.m
//  OrderCheck
//
//  Created by SAN_Technologies on 26/05/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <Speech/Speech.h>
#import "OrdersViewController.h"
#import "OrderPopOverViewController.h"
#import "OrderTableViewCell.h"
#import "RestaurentModel.h"
#import "OrderModel.h"
#import "FoodItemModel.h"
#import "DatePickViewController.h"
#import "CategoriesViewController.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "WebServiceHandler.h"

//#import <AFNetworking.h>

#define kCurrentOrdersSegmentID 0
#define kOrderHistorySegmentID 1

static const CGFloat kTableViewCellEstimatedRowHeight = 150.0;
#define kStatusCompleted @"Dispatched"

@interface OrdersViewController () <OrderCellDelegate, SFSpeechRecognizerDelegate, UIPopoverPresentationControllerDelegate, DatePickViewControllerDelegate> {
    NSArray *dataList;
    AppDelegate *appdelegate;
    NSTimer *ordersTimer;
    
    SFSpeechRecognizer *speechRecgn;
    SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
    SFSpeechRecognitionTask *recognitionTask;
    AVAudioEngine *audioEngine;
}

@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ordersSegmentControl;
@property (nonatomic, strong) UITextField *speechTextField;
//@property (nonatomic, strong) RestaurentModel *restaurentModel;
@property (nonatomic, strong) NSArray *currentOrdersList;
@property (nonatomic, strong) NSArray *historyOrdersList;

- (void)initializeAndAuthorizeSpeechRecognizer;
- (void)startListening;

- (void)getAllOrdersForBot;
- (void)postSpokenText:(NSString *)speech forOrderID:(NSString *)orderID;
- (void)validateTimerForOrders;
- (void)invalidatTimerForOrders;
- (IBAction)ordersSegmentValueChanged:(id)sender;
- (IBAction)addMenuSelected:(id)sender;
- (IBAction)dateButtonSelected:(id)sender;
- (IBAction)settingsSelected:(id)sender;

@end

@implementation OrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view.layer setContents:(id)[UIImage imageNamed:@"BG.png"].CGImage];
    appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [self.restNameLabel setText:[appdelegate.aRestaurant.restaurentName uppercaseString]];
//    NSString *addressString = [self.restaurentModel.restaurentAddress stringByReplacingOccurrencesOfString:@"\n" withString:@"  "];
    NSString *addressString = [NSString stringWithFormat:@"%@, %@, %@", appdelegate.aRestaurant.street, appdelegate.aRestaurant.city, appdelegate.aRestaurant.state];
    [self.restAddressLabel setText:addressString];

    
    [self.ordersTableView setEstimatedRowHeight:kTableViewCellEstimatedRowHeight];
    [self.ordersTableView setRowHeight:UITableViewAutomaticDimension];
    [self.ordersTableView setBackgroundColor:[UIColor clearColor]];
    
    [self initializeAndAuthorizeSpeechRecognizer];
//    [self fetchDataWithAFNetwork];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.ordersSegmentControl setSelectedSegmentIndex:kCurrentOrdersSegmentID];
    [self validateTimerForOrders];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //Cancel webservices fetching data............
    [self invalidatTimerForOrders];
}

- (void)validateTimerForOrders {
    [self refreshOrders:nil];
    [self.dateButton setHidden:YES];
    ordersTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(refreshOrders:) userInfo:nil repeats:YES];
}

- (void)invalidatTimerForOrders {
    [ordersTimer invalidate];
    ordersTimer = nil;
}

/*
- (void)fetchDataWithAFNetwork {
    NSURL *URL = [NSURL URLWithString:OrdersURL];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
*/
    
- (void)initializeAndAuthorizeSpeechRecognizer
{
    speechRecgn = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    speechRecgn.delegate = self;
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                NSLog(@"Authorized");
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
                NSLog(@"Denied");
                break;
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                NSLog(@"Not Determined");
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                NSLog(@"Restricted");
                break;
            default:
                break;
        }
    }];
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
    NSInteger numOfRows = 0;
    numOfRows = (kCurrentOrdersSegmentID == self.ordersSegmentControl.selectedSegmentIndex) ? [self.currentOrdersList count] : [self.historyOrdersList count];
    return numOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView currentOrdersCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderTableViewCell *orderCell = (OrderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"orderCellIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    OrderModel *aModel = [self.currentOrdersList objectAtIndex:indexPath.row];
    [orderCell.orderStatusButton setTitle:aModel.orderTrackingString forState:UIControlStateNormal];
//    [orderCell.timeLabel setText:aModel.timeString];
    orderCell.orderNameLabel.text = [NSString stringWithFormat:@"ID: %@", aModel.orderID];
    orderCell.billLabel.text = [NSString stringWithFormat:@"$%@", aModel.orderPrice];
    [self arrangeFoodItemsForCell:orderCell withOrderModel:aModel];
    [orderCell.orderFromLabel setText:[aModel.orderFrom substringToIndex:1]];
//    [orderCell.statusButton setSelected:[aModel.orderTrackingString isEqualToString:kStatusCompleted]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm:ss"];
    [orderCell.timeLabel setText:[dateFormatter stringFromDate:aModel.orderDate]];

    orderCell.delegate = self;
    [orderCell setBackgroundColor:[UIColor clearColor]];
    [orderCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return orderCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView historyOrdersCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderTableViewCell *orderCell = (OrderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"historyCellIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    OrderModel *aModel = [self.historyOrdersList objectAtIndex:indexPath.row];
//    [orderCell.timeLabel setText:aModel.timeString];
    [orderCell.orderStatusButton setTitle:aModel.orderTrackingString forState:UIControlStateNormal];
    orderCell.orderNameLabel.text = [NSString stringWithFormat:@"ID: %@", aModel.orderID];
    orderCell.billLabel.text = [NSString stringWithFormat:@"$%@", aModel.orderPrice];
    [self arrangeFoodItemsForCell:orderCell withOrderModel:aModel];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm:ss"];
    [orderCell.timeLabel setText:[dateFormatter stringFromDate:aModel.orderDate]];

    orderCell.delegate = self;
    [orderCell setBackgroundColor:[UIColor clearColor]];
    [orderCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return orderCell;
}

- (void)arrangeFoodItemsForCell:(OrderTableViewCell *)orderCell withOrderModel:(OrderModel *)aModel {
    [orderCell.appetizerLabel setText:@""];
    [orderCell.mainCourseLabel setText:@""];
    [orderCell.dessertLabel setText:@""];
    NSArray *keysList = [aModel.foodItemsDict allKeys];
    for (NSString *aKey in keysList) {
        NSArray *itemsList = [aModel.foodItemsDict objectForKey:aKey];
        NSMutableString *itemsString = [NSMutableString stringWithCapacity:0];
        for (FoodItemModel *aFoodItem in itemsList) {
            [itemsString appendFormat:@"\n%@ %@ (%@)", aFoodItem.itemQuantity, aFoodItem.itemName, aFoodItem.spicyLevel];
        }
        NSUInteger index = [keysList indexOfObject:aKey];
        NSAttributedString *newString = [self getNewStringForKey:aKey withFoodString:itemsString];
        switch (index) {
            case 0:
                orderCell.appetizerLabel.attributedText = newString;
                break;
            case 1:
                orderCell.mainCourseLabel.attributedText = newString;
                break;
            case 2:
                orderCell.dessertLabel.attributedText = newString;
                break;
                
            default:
                break;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *aCell = nil;
    if (kCurrentOrdersSegmentID == self.ordersSegmentControl.selectedSegmentIndex) {
        aCell = [self tableView:tableView currentOrdersCellForRowAtIndexPath:indexPath];
    } else if (kOrderHistorySegmentID == self.ordersSegmentControl.selectedSegmentIndex) {
        aCell = [self tableView:tableView historyOrdersCellForRowAtIndexPath:indexPath];
    }
    return aCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    OrderTableViewCell *aCell = (OrderTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    OrderModel *aModel;

    if (kCurrentOrdersSegmentID == self.ordersSegmentControl.selectedSegmentIndex) {
        if ([self.currentOrdersList count]) {
            aModel = [self.currentOrdersList objectAtIndex:indexPath.row];
        }
    } else if (kOrderHistorySegmentID == self.ordersSegmentControl.selectedSegmentIndex) {
        if ([self.historyOrdersList count]) {
            aModel = [self.historyOrdersList objectAtIndex:indexPath.row];
        }
    }


    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    OrderPopOverViewController *popOverVC = [storyBoard instantiateViewControllerWithIdentifier:@"OrderPopOverVC"];
    popOverVC.selectedOrder = aModel;
    popOverVC.preferredContentSize = CGSizeMake(500.0, 480.0);
    popOverVC.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *aPopVC = popOverVC.popoverPresentationController;
    aPopVC.sourceView = aCell.orderNameLabel;
    aPopVC.sourceRect = aCell.orderNameLabel.bounds;
    aPopVC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    aPopVC.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:165.0/255.0 blue:135.0/255.0 alpha:1.0];
    aPopVC.delegate = self;
    [self presentViewController:popOverVC animated:YES completion:nil];
}

- (NSMutableAttributedString *)getNewStringForKey:(NSString *)key withFoodString:(NSString *)food {
    NSRange range = NSMakeRange(0, key.length);
    NSMutableAttributedString *headAttrString = [[NSMutableAttributedString alloc] initWithString:key];
    [headAttrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:18.0] range:range];
    [headAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    NSAttributedString *itemsString = [[NSAttributedString alloc] initWithString:food];
    [headAttrString appendAttributedString:itemsString];
    return headAttrString;
}

#pragma mark - OrderCellDelegate -

- (void)changeOrderStatusDidSelect:(OrderTableViewCell *)orderCell
{
    NSIndexPath *indexPath = [self.ordersTableView indexPathForCell:orderCell];
    OrderModel *aModel = [self.currentOrdersList objectAtIndex:indexPath.row];
    
    NSArray *statusList = @[@"Cooking in progress", @"Cooked and Packed", @"Dispatched"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelAction];
    
    for (NSString *aStatus in statusList) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:aStatus style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            aModel.orderTrackingString = action.title;
            [orderCell.orderStatusButton setTitle:aModel.orderTrackingString forState:UIControlStateNormal];
            [self postSpokenText:action.title forOrderID:aModel.orderID];
        }];
        [alertController addAction:alertAction];
    }
    UIPopoverPresentationController *popPresenter = [alertController
                                                     popoverPresentationController];
    popPresenter.sourceView = orderCell.orderStatusButton;
    popPresenter.sourceRect = orderCell.orderStatusButton.bounds;
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)voiceOverDidSelect:(OrderTableViewCell *)orderCell
{
    NSIndexPath *indexPath = [self.ordersTableView indexPathForCell:orderCell];
    OrderModel *aModel = [self.currentOrdersList objectAtIndex:indexPath.row];
    [self showAlertWithSpeechForOder:aModel];
    
    if (audioEngine.isRunning) {
        [audioEngine stop];
        [recognitionRequest endAudio];
    } else {
        audioEngine = nil;
        [self startListening];
    }
}

/*!
 * @brief Starts listening and recognizing user input through the phone's microphone
 */
#pragma mark - Speech Recog Methods

- (void)startListening
{
    audioEngine = [[AVAudioEngine alloc] init]; // Initialize the AVAudioEngine
    
    // Make sure there's not a recognition task already running
    if (recognitionTask) {
        NSLog(@"Another Speech Recognition Task is running, Now cancel it.......");
        [recognitionTask cancel];
        recognitionTask = nil;
    }
    
    // Starts an AVAudio Session
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    
    // Starts a recognition process, in the block it logs the input or stops the audio
    // process if there's an error.
    recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    AVAudioInputNode *inputNode = audioEngine.inputNode;
    recognitionRequest.shouldReportPartialResults = YES;
    recognitionTask = [speechRecgn recognitionTaskWithRequest:recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        if (result) {
            // Whatever you say in the mic after pressing the button should be being logged
            // in the console.
            NSLog(@"RESULT:%@",result.bestTranscription.formattedString);
            [self.speechTextField setText:result.bestTranscription.formattedString];
            isFinal = !result.isFinal;
        }
        if (error) {
            NSLog(@"error>>>>%@", error);
            [audioEngine stop];
            [inputNode removeTapOnBus:0];
            recognitionRequest = nil;
            recognitionTask = nil;
        }
    }];
    
    // Sets the recording format
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        NSLog(@"inputNode>>%@", inputNode);
        [recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    // Starts the audio engine, i.e. it starts listening.
    [audioEngine prepare];
    [audioEngine startAndReturnError:&error];
    NSLog(@"Say Something, I'm listening");
}

- (void)showAlertWithSpeechForOder:(OrderModel *)anOrder
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:appdelegate.aRestaurant.restaurentName
                                message:@"Please speak out the selected order status and submit."
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okayButton = [UIAlertAction
                                 actionWithTitle:@"Yes, please"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     //Handle your yes please button action here
                                     // If Success Send The Speech to Server
                                     [appdelegate showActivityIndicator];
//                                     [self postSpokenText];
                                     [self postSpokenText:self.speechTextField.text forOrderID:anOrder.orderID];
                                     if (audioEngine.isRunning) {
                                         [audioEngine stop];
                                         [recognitionRequest endAudio];
                                     }
                                 }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"No, thanks"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                                   // If No....Do Nothing..........
                                   if (audioEngine.isRunning) {
                                       [audioEngine stop];
                                       [recognitionRequest endAudio];
                                   }
                               }];
    
    
    [alert addAction:okayButton];
    [alert addAction:noButton];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        if (nil != self.speechTextField) {
            self.speechTextField = nil;
        }
        self.speechTextField = textField;
        textField.placeholder = @"Say Something, I'm listening ";
        textField.borderStyle = UITextBorderStyleNone;
        textField.backgroundColor = [UIColor clearColor];
        [textField setUserInteractionEnabled:NO];
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - SFSpeechRecognizer Delegate Methods

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    NSLog(@"Availability:%d speechRecognizer>>%@", available, speechRecognizer);
}

#pragma mark - DatePickViewController Delegate Methods
- (void)didSelectDoneinViewController:(DatePickViewController *)pickVC withDate:(NSString *)dateString {
    NSLog(@"dateString>>%@", dateString);
    [self getOrdersHistoryforDate:dateString];
    [self.dateButton setHidden:NO];
}
- (void)cancelButtonDidSelectInViewController:(DatePickViewController *)pickVC {
    if ([self.dateButton isHidden]) {
        [self.ordersSegmentControl setSelectedSegmentIndex:kCurrentOrdersSegmentID];
    }
}
#pragma mark - Handling Webservices

- (void)getOrdersHistoryforDate:(NSString *)dateString {
    [appdelegate showActivityIndicator];
    NSDictionary *dict = @{ @"botName": appdelegate.aRestaurant.botName,
                            @"date": dateString };
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (error) {
        [appdelegate showAlertWithTitle:@"MOXIEIT" andMessage:error.localizedDescription];
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:ORDERS_HISTORY_API, SERVER_DOMAIN_NAME];
    [[WebServiceHandler sharedHandler] postData:data toURLString:urlStr callBackCompletionHandler:^(id jsonObject, NSError *error) {
        NSString *errorMessage = nil;
        if (error) {
            errorMessage = error.localizedDescription;
        } else {
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                NSArray *ordersArray = [jsonObject objectForKey:@"orders"];
                if ([ordersArray count]) {
                    self.historyOrdersList = [self modelOrdersList:ordersArray];
                } else {                 //Handle No Orders
                    self.historyOrdersList = nil;
                    errorMessage = @"No data available for selected date.";
                }
            }
        }
        [appdelegate stopActivityIndicator];
        [self.ordersTableView reloadData];
        if (errorMessage) {
            [appdelegate showAlertWithTitle:@"MOXIEIT" andMessage:errorMessage];
        }
    }];
}

- (void)postSpokenText:(NSString *)speech forOrderID:(NSString *)orderID
{
    [appdelegate showActivityIndicator];
    NSDictionary *dict = @{ @"uuid": orderID,
                            @"orderStatus": speech };
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (error) {
        [appdelegate showAlertWithTitle:@"MOXIEIT" andMessage:error.localizedDescription];
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:SPEECH_POST_API, SERVER_DOMAIN_NAME];
    [[WebServiceHandler sharedHandler] postData:data toURLString:urlStr callBackCompletionHandler:^(id jsonObject, NSError *error) {
        NSString *errorMessage = nil;
        if (error) {
            errorMessage = error.localizedDescription;
        } else {
            NSString *status = [jsonObject objectForKey:@"status"];
            if ([status length] && [status isEqualToString:@"success"]) {
                errorMessage = @"Updated the status successfully.";
            } else {
                errorMessage = @"Failed to post status.";
            }
        }
        [appdelegate stopActivityIndicator];
        if (errorMessage) {
            [appdelegate showAlertWithTitle:@"MOXIEIT" andMessage:errorMessage];
        }
    }];
}

- (void)getAllOrdersForBot
{
    [appdelegate showActivityIndicator];
    NSString *urlStr = [NSString stringWithFormat:ORDERS_API, SERVER_DOMAIN_NAME, appdelegate.aRestaurant.botName];
    [[WebServiceHandler sharedHandler] fetchDataforURLString:urlStr callBackCompletionHandler:^(id jsonObject, NSError *error) {
        NSString *errorMessage = nil;
        if (error) {
            errorMessage = error.localizedDescription;
        } else {
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                NSLog(@"jsonObject>>>Dict>>%@", jsonObject);
                NSArray *ordersArray = [jsonObject objectForKey:@"orders"];
                if ([ordersArray count]) {
                    self.currentOrdersList = [self modelOrdersList:ordersArray];
                } else {                 //Handle No Orders
                    errorMessage = [jsonObject objectForKey:@"message"];
                    if (!errorMessage) {
                        errorMessage = @"Don't have orders right now.";
                    }
                }
            }
        }
        [appdelegate stopActivityIndicator];
        [self.ordersTableView reloadData];
        if (errorMessage) {
            [appdelegate showAlertWithTitle:@"MOXIEIT" andMessage:errorMessage];
        }
    }];
}

- (NSArray *)modelOrdersList:(NSArray *)orders {
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderTime" ascending:NO];
    NSArray *orderedArray = [orders sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
    
    for (NSDictionary *orderDict in orderedArray) {
        OrderModel *aModel = [[OrderModel alloc] initWithOrderDict:orderDict];
        
        NSMutableDictionary *newDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        for (NSString *aKey in [aModel.foodItemsDict allKeys]) {
            NSArray *foodList = [aModel.foodItemsDict objectForKey:aKey];
            NSMutableArray *itemsList = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *itemDict in foodList) {
                FoodItemModel *foodModel = [[FoodItemModel alloc] initWithFoodDict:itemDict];
                [itemsList addObject:foodModel];
            }
            [newDictionary setObject:itemsList forKey:aKey];
        }
        aModel.foodItemsDict = [NSDictionary dictionaryWithDictionary:newDictionary];
        
        [newArray addObject:aModel];
    }
    return newArray;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PopOver"] && segue.destinationViewController.popoverPresentationController) {
        UIPopoverPresentationController *popController = segue.destinationViewController.popoverPresentationController;
//        popController.preferredContentSize = CGSizeMake(400, 400);
        popController.sourceView = sender;
        popController.delegate = self;
        // if you need to pass data you can access the index path for the cell the button was pressed by saying the following
//        CGPoint location = [self.ordersTableView convertPoint:sender.bounds.origin fromView:sender];
//        NSIndexPath *indexPath = [self.ordersTableView indexPathForRowAtPoint:location];
        // do something with the indexPath
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationOverFullScreen;
}

- (void)showDatePicker:(UISegmentedControl *)sender {
//    NSIndexPath *indexPath = [self.regTableView indexPathForCell:sender];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DatePickViewController *datePickerVC = [storyBoard instantiateViewControllerWithIdentifier:@"datePickerVC"];
//    hoursPickerVC.rowNumber = indexPath.row;
    datePickerVC.delegate = self;
    datePickerVC.preferredContentSize = CGSizeMake(500.0, 320.0);
    datePickerVC.modalPresentationStyle = UIModalPresentationPopover;
    datePickerVC.modalInPopover = YES;
    
    UIPopoverPresentationController *aPopVC = datePickerVC.popoverPresentationController;
    aPopVC.sourceView = sender;
    aPopVC.sourceRect = sender.bounds;
    aPopVC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    aPopVC.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:165.0/255.0 blue:135.0/255.0 alpha:1.0];
//    aPopVC.delegate = self;
    aPopVC.passthroughViews = nil;
    
    [self presentViewController:datePickerVC animated:YES completion:^{
    }];
}

#pragma mark - IBActions
- (IBAction)prepareForUnwindToOrdersScreen:(UIStoryboardSegue *)segue {
    NSLog(@"Orders Screen");
}

- (IBAction)refreshOrders:(id)sender {
    [self getAllOrdersForBot];
}

- (IBAction)ordersSegmentValueChanged:(id)sender {
    if (kCurrentOrdersSegmentID == [self.ordersSegmentControl selectedSegmentIndex]) {
        [self validateTimerForOrders];
    } else if (kOrderHistorySegmentID == [self.ordersSegmentControl selectedSegmentIndex]) {
        [self invalidatTimerForOrders];
        [self showDatePicker:sender];
    }
}

- (IBAction)addMenuSelected:(id)sender {
    if (self.historyOrdersList) {
        self.historyOrdersList = nil;
        [self.ordersTableView reloadData];
    }
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CategoriesViewController *catViewController = [storyBoard instantiateViewControllerWithIdentifier:@"CategoriesVC"];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:catViewController];
    navController.navigationBarHidden = YES;
    [self presentViewController:navController animated:YES completion:^{
    }];
}

- (IBAction)dateButtonSelected:(id)sender {
    [self showDatePicker:sender];
}

- (IBAction)settingsSelected:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingsViewController *settingsVC = [storyBoard instantiateViewControllerWithIdentifier:@"SettingsVC"];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (IBAction)gotoOrdersViewController:(UIStoryboardSegue *)sbSegue {
    NSLog(@"%s", __FUNCTION__);
}

@end


/*
 //    NSSortDescriptor
 NSArray *sortedArray = [newArray sortedArrayUsingComparator:^NSComparisonResult(OrderModel *orderA, OrderModel *orderB) {
 //        NSLog(@"A::%@   B:%@", orderA.orderDate, orderB.orderDate);
 //        return [orderB.orderDate compare:orderA.orderDate];
 return [orderA.orderDate compare:orderB.orderDate];
 }];
 NSLog(@"sortedArray::%@", sortedArray);
 */
