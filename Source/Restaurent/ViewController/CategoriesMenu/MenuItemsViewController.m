//
//  MenuItemsViewController.m
//  Categories
//
//  Created by SAN_Technologies on 19/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "MenuItemsViewController.h"
#import "CategorySectionFooterView.h"
#import "MenuItemCell.h"
#import "MenuItemModel.h"
#import "AppDelegate.h"
#import "IconDownloader.h"
#import "Constants.h"
#import "WebServiceHandler.h"

#define kExistingMenuSegmentID 0
#define kNewMenuSegmentID 1

@interface MenuItemsViewController () <UIScrollViewDelegate, MenuItemCellDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    AppDelegate *appDelegate;
    NSUInteger uploadItemIndex;
    BOOL showNoItemsRow;
    BOOL isDeleteSelected;
}

@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *itemsSegmentControl;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *topTitleLabel;

@property (strong, nonatomic) NSMutableArray *createdMenuList;
@property (strong, nonatomic) NSMutableArray *existingMenuList;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) MenuItemCell *selectedCell;
@property (strong, nonatomic) MenuItemCell *submitSelectedCell;

// the set of IconDownloader objects for each category
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

- (IBAction)addNewMenuItemsSelected:(id)sender;
- (IBAction)menuSegmentControlDidSelect:(id)sender;
- (void)postChangeInMenuItemsWithDictionary:(NSDictionary *)menuDict;
- (void)getAllMenuListforSelectedCategory;

@end

@implementation MenuItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.view.layer setContents:(id)[UIImage imageNamed:@"BG.png"].CGImage];
    [self.topTitleLabel setText:[self.selectedCategory.categoryName uppercaseString]];
    [self.itemsTableView setBackgroundColor:[UIColor clearColor]];
    [self.itemsTableView registerNib:[UINib nibWithNibName:@"CategorySectionFooterView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"CategorySectionFooterView"];
    showNoItemsRow = NO;

    self.createdMenuList = [NSMutableArray arrayWithCapacity:0];
//    self.menuSegmentControl.selectedSegmentIndex = kNewMenuSegmentID;//Add new categories
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [self menuSegmentControlDidSelect:self.itemsSegmentControl];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numOfRows = 0;
    numOfRows = (kNewMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) ? [self.createdMenuList count] : [self.existingMenuList count];
    numOfRows = showNoItemsRow ? 1 : numOfRows;
    return numOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView addNewCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddMenuCellID" forIndexPath:indexPath];
    [cell.menuTitleTextField setTag:indexPath.row];
    [cell.itemPriceTextField setTag:indexPath.row];
    MenuItemModel *aModel = [self.createdMenuList objectAtIndex:indexPath.row];
    [cell.menuTitleTextField setText:aModel.itemName];
    [cell.itemPriceTextField setText:aModel.itemPrice];
    if (!aModel.thumbnailImage) {
        [cell.picButton setBackgroundImage:[UIImage imageNamed:@"gallery.png"] forState:UIControlStateNormal];
    } else {
        [cell.picButton setBackgroundImage:aModel.thumbnailImage forState:UIControlStateNormal];
    }
    cell.delegate = self;
    return cell;
}

- (MenuItemCell *)tableView:(UITableView *)tableView showMenuItemCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExistingMenuCellID" forIndexPath:indexPath];
    MenuItemModel *aModel = [self.existingMenuList objectAtIndex:indexPath.row];
    
    NSString *imageName = [aModel.itemType isEqualToString:@"NonVeg"] ? @"red.png" : @"green.png";
    NSString *spiceString = (aModel.isSpicy) ? @"Spicy" : @"Not Spicy";
    [cell.vegImageView setImage:[UIImage imageNamed:imageName]];
    [cell.spicyLabel setText:spiceString];
    [cell.activityIndicator startAnimating];
    if (!aModel.thumbnailImage) {
        if (tableView.dragging == NO && tableView.decelerating == NO) {
            [self startIconDownload:aModel forIndexPath:indexPath];
        }
        // if a download is deferred or in progress, return a placeholder image
        [cell.picButton setBackgroundImage:[UIImage imageNamed:@"gallery.png"] forState:UIControlStateNormal];
    } else {
        [cell.activityIndicator stopAnimating];
        [cell.picButton setBackgroundImage:aModel.thumbnailImage forState:UIControlStateNormal];
    }
    return cell;
}

- (MenuItemCell *)tableView:(UITableView *)tableView showEditMenuItemCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditMenuCellID" forIndexPath:indexPath];
    MenuItemModel *aModel = [self.existingMenuList objectAtIndex:indexPath.row];
    NSInteger segIndex = [aModel.itemType isEqualToString:@"Veg"] ? 0 : 1;
    NSLog(@"aModel.itemType::%@>>>>>%tu", aModel.itemType, segIndex);
    [cell.menuTypeSegmentControl setSelectedSegmentIndex:segIndex];
    [cell.spicySwitch setOn:aModel.isSpicy];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView existingMenuItemCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuItemModel *aModel = [self.existingMenuList objectAtIndex:indexPath.row];
    MenuItemCell *cell = nil;
    if (aModel.allowEditing) {
        cell = [self tableView:tableView showEditMenuItemCellForRowAtIndexPath:indexPath];
    } else {
        cell = [self tableView:tableView showMenuItemCellForRowAtIndexPath:indexPath];
    }
    [cell.menuTitleTextField setTag:indexPath.row];
    [cell.itemPriceTextField setTag:indexPath.row];
    [cell.menuTitleTextField setText:aModel.itemName];
    [cell.itemPriceTextField setText:aModel.itemPrice];
    cell.delegate = self;

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *aCell;
    if (kNewMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {//Add New Menu Item
        aCell = [self tableView:tableView addNewCellForRowAtIndexPath:indexPath];
    } else if (kExistingMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {//Existing Menu Items
        if (0 == [self.existingMenuList count]) {
            aCell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCellID"];
            [aCell.textLabel setText:@"Don't have menu items for selected category, please add new menu items using above segment."];
        } else {
            aCell = [self tableView:tableView existingMenuItemCellForRowAtIndexPath:indexPath];
        }
    }
    [aCell setSelectionStyle:UITableViewCellSelectionStyleNone];    
    return aCell;
}

#pragma mark - Table view Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    MenuItemCell *itemCell = [tableView cellForRowAtIndexPath:indexPath];
    if (kNewMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {//Add New Menu Item
        [itemCell.menuTitleTextField becomeFirstResponder];
    } else if (kExistingMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {//Existing Menu Items
        if ([self.existingMenuList count]) {
            MenuItemModel *aModel = [self.existingMenuList objectAtIndex:indexPath.row];
            if (!aModel.allowEditing) {
                UIAlertController *alert = [UIAlertController
                                            alertControllerWithTitle:@"MOXIEIT"
                                            message:@"Would you like to edit the selected menu item?"
                                            preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelButton = [UIAlertAction
                                               actionWithTitle:@"CANCEL"
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                               }];
                
                UIAlertAction *okayButton = [UIAlertAction
                                             actionWithTitle:@"YES"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action) {
                                                 aModel.allowEditing = YES;
                                                 [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                             }];
                [alert addAction:cancelButton];
                [alert addAction:okayButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = 0.0;
    height = (kNewMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) ? 60.0 : 0.0;
    return height;
}

//- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CategorySectionFooterView *sectionFooterView = nil;
    if (kNewMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {//Add New Menu
        sectionFooterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"CategorySectionFooterView"];
        sectionFooterView.tag = section;
        [sectionFooterView.contentView setBackgroundColor:[UIColor whiteColor]];
        if (sectionFooterView == nil) {
            NSLog(@"sectionheaderViewCell is nil");
            [NSException raise:@"headerView == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
        } else {}
        /********** Add UITapGestureRecognizer to SectionView   **************/
        UITapGestureRecognizer  *footerTapGesture   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionFooterTapped:)];
        [sectionFooterView addGestureRecognizer:footerTapGesture];
        
        return sectionFooterView;
    } else if (kExistingMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {//Existing Menu
    }
    return sectionFooterView;
}// custom view for footer. will be adjusted to default or specified footer height

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */
- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    NSString *deleteTitle = (kNewMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) ? @"Confirm" : @"Delete";
    return deleteTitle;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        isDeleteSelected = YES;
        if (kNewMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {//Add New Category
            [self.createdMenuList removeObjectAtIndex:indexPath.row];
        } else if (kExistingMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {//Existing Categories
            //Create a Dict to post. for update in the server.
            MenuItemModel *deletedModel = [self.existingMenuList objectAtIndex:indexPath.row];

            NSDictionary *paramDict = [self getParamsDictForDeleteMenuItem:deletedModel];
            NSLog(@"paramDict>>>%@", paramDict);
            [self postChangeInMenuItemsWithDictionary:paramDict];
            
            [self.existingMenuList removeObjectAtIndex:indexPath.row];
        }
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */
#pragma mark - Table Footer tapped gesture

- (void)sectionFooterTapped:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"%s", __FUNCTION__);
    [self.view endEditing:YES];
    if ([self.createdMenuList count]) {
        NSIndexPath *anIndexPath = [NSIndexPath indexPathForRow:([self.createdMenuList count] - 1) inSection:0];
        MenuItemCell *itemCell = [self.itemsTableView cellForRowAtIndexPath:anIndexPath];

        if (![itemCell.menuTitleTextField.text length] && ![itemCell.itemPriceTextField.text length]) {
            NSString *message = @"Please enter details in empty fields to create new menu item.";
            [self showAlertWithTitle:@"MOXIEIT" andMessage:message];
            return;
        }
    }
    [self addOnemoreRow];
//    [self.menuItemsTableView reloadData];
    NSArray *insertsIndexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:([self.createdMenuList count] - 1) inSection:0]];
    [self.itemsTableView beginUpdates];
    [self.itemsTableView insertRowsAtIndexPaths:insertsIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
    [self.itemsTableView endUpdates];
}


#pragma mark - Webservice Handling

- (void)getAllMenuListforSelectedCategory {//To get all Menu list for a selected category.
    [appDelegate showActivityIndicator];
    NSString *urlStr = [NSString stringWithFormat:GET_ALL_MENUITEMS_API, SERVER_DOMAIN_NAME, self.selectedCategory.categoryID];
    [[WebServiceHandler sharedHandler] fetchDataforURLString:urlStr callBackCompletionHandler:^(id jsonObject, NSError *error) {
        NSString *errorMessage = nil;
        if (error) {
            errorMessage = error.localizedDescription;
        } else {
            if ([jsonObject isKindOfClass:[NSArray class]]) {
                self.existingMenuList = [NSMutableArray arrayWithArray:jsonObject];
                NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
                for (NSDictionary *aDict in self.existingMenuList) {
                    MenuItemModel *catModel = [[MenuItemModel alloc] initWithDictionary:aDict];
                    [newArray addObject:catModel];
                }
                self.existingMenuList = newArray;
                if (![self.existingMenuList count]) {
                    showNoItemsRow = YES;
                    errorMessage = @"Not yet created menu items for selected category.";
                }
            }
        }
        [appDelegate stopActivityIndicator];
        [self.itemsTableView reloadData];
        if (errorMessage) {
            [self showAlertWithTitle:@"MOXIEIT" andMessage:errorMessage];
        }
    }];
}

- (void)postChangeInMenuItemsWithDictionary:(NSDictionary *)menuDict {//Insert, Delete, Update Menu items
//    [appDelegate showActivityIndicator];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:menuDict options:0 error:&error];
    if (error) {
        [self showAlertWithTitle:@"MOXIEIT" andMessage:error.localizedDescription];
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:CHANGE_MENUITEMS_API, SERVER_DOMAIN_NAME];
    [[WebServiceHandler sharedHandler] postData:data toURLString:urlStr callBackCompletionHandler:^(id jsonObject, NSError *error) {
        NSString *errorMessage = nil;
        if (error) {
            errorMessage = error.localizedDescription;
        } else {
            NSLog(@"jsonObject11111111:::%@", jsonObject);
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                NSString *status = [jsonObject objectForKey:@"status"];
                if ([status length] && [status isEqualToString:@"success"]) {
                    NSString *message = [jsonObject objectForKey:@"message"];
                    if (self.itemsSegmentControl.selectedSegmentIndex == kNewMenuSegmentID) {//Add new categories
                        if ([self.createdMenuList count]) {//Insert new categories changes...
                            [self.createdMenuList removeAllObjects];
                            [self addOnemoreRow];
                            [self.itemsTableView reloadData];
                            
                            [self showAlertWithTitle:@"MOXIEIT" andMessage:message];
                            [appDelegate stopActivityIndicator];
                        }
                    } else if (self.itemsSegmentControl.selectedSegmentIndex == kExistingMenuSegmentID) {//Existing
                        ///Handle delete for existing categories.
                        if (self.submitSelectedCell) {
                            NSIndexPath *selectedIndexPath = [self.itemsTableView indexPathForCell:self.submitSelectedCell];
                            MenuItemModel *menuModel = [self.existingMenuList objectAtIndex:selectedIndexPath.row];
                            if (menuModel.allowEditing) {
                                [self cancelDidSelectInCell:self.submitSelectedCell];
                            }
                            self.submitSelectedCell = nil;
                        }
                        if (message) {
                            [self showAlertWithTitle:@"MOXIEIT" andMessage:message];
                        }
                        [appDelegate stopActivityIndicator];
                    }
                } else {
                    NSString *message = [jsonObject objectForKey:@"message"];
                    errorMessage = message ? message : @"Failed to upload new categories.";
                }
            }
        }
        NSLog(@"errorMessage>>>%@", errorMessage);
        if (errorMessage) {
            [appDelegate stopActivityIndicator];
            [self showAlertWithTitle:@"MOXIEIT" andMessage:errorMessage];
        }
    }];
}

- (void)uploadMenuItems {
    if (self.itemsSegmentControl.selectedSegmentIndex == kNewMenuSegmentID) {//Add new categories
        if (uploadItemIndex < [self.createdMenuList count]) {
            MenuItemModel *aModel = [self.createdMenuList objectAtIndex:uploadItemIndex];
            [self uploadImageForMenuItem:aModel];
        } else {
            NSDictionary *paramDict = [self getNewMenuItemsParamsDict];
            [self postChangeInMenuItemsWithDictionary:paramDict];
        }
    }
}

- (void)uploadImageForMenuItem:(MenuItemModel *)menuModel {
    //    [appDelegate showActivityIndicator];
    NSData *imageData = UIImageJPEGRepresentation(menuModel.thumbnailImage, 1.0);
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
                    menuModel.imageURLString = fileURLStr;
                    //Update fileURL in dictionary
                    if (self.itemsSegmentControl.selectedSegmentIndex == kExistingMenuSegmentID) {//Existing
                        NSDictionary *paramDict = [self getParamsDictForMenuUpdate:menuModel];
                        [self postChangeInMenuItemsWithDictionary:paramDict];
                    } else {
                        uploadItemIndex++;
                        [self uploadMenuItems];
                    }
                } else {
                    errorMessage = @"Image upload failed.";
                }
            } else {
                errorMessage = @"Unidetified error occured please try again.";
            }
        }
        if (errorMessage) {
            [self showAlertWithTitle:@"MOXIEIT" andMessage:errorMessage];
            [appDelegate stopActivityIndicator];
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSIndexPath *anIndexPath = [NSIndexPath indexPathForRow:textField.tag inSection:0];
    MenuItemModel *menuModel = nil;
    if (kNewMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {
        menuModel = [self.createdMenuList objectAtIndex:anIndexPath.row];
    } else if (kExistingMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {
        menuModel = [self.existingMenuList objectAtIndex:anIndexPath.row];
    }

    MenuItemCell *menuCell = [self.itemsTableView cellForRowAtIndexPath:anIndexPath];
    if ([menuCell.menuTitleTextField isEqual:textField]) {
        menuModel.itemName = textField.text;
    } else if ([menuCell.itemPriceTextField isEqual:textField]) {
        menuModel.itemPrice = textField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - MenuItemCell Delegate

- (void)menuTypeSegmentControlDidSelectInCell:(MenuItemCell*)cell {
    NSIndexPath *anIndexPath = [self.itemsTableView indexPathForCell:cell];
    MenuItemModel *menuModel = nil;
    if (kNewMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {
        menuModel = [self.createdMenuList objectAtIndex:anIndexPath.row];
    } else if (kExistingMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {
        menuModel = [self.existingMenuList objectAtIndex:anIndexPath.row];
    }
    menuModel.itemType = (0 == cell.menuTypeSegmentControl.selectedSegmentIndex) ? @"Veg" : @"NonVeg";
}

- (void)imageButtonDidSelectInCell:(MenuItemCell*)cell {
    if (kNewMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary fromButton:cell.picButton];
        self.selectedCell = cell;
    } else if (kExistingMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {
        [self existingMenuItemSelectedInCell:cell];
    }
}

- (void)existingMenuItemSelectedInCell:(MenuItemCell *)aCell {
    NSString *message = @"Would you like to change the image of the selected menu item?";
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"MOXIEIT"
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelButton = [UIAlertAction
                                   actionWithTitle:@"No"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle your yes please button action here
                                   }];
    UIAlertAction *okayButton = [UIAlertAction
                                 actionWithTitle:@"Yes"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     //Handle your yes please button action here
                                     [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary fromButton:aCell.picButton];
                                     self.selectedCell = aCell;
                                 }];
    [alert addAction:cancelButton];
    [alert addAction:okayButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)spicySwitchDidSelectInCell:(MenuItemCell*)cell {
    NSIndexPath *anIndexPath = [self.itemsTableView indexPathForCell:cell];
    MenuItemModel *menuModel = nil;
    if (kNewMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {
        menuModel = [self.createdMenuList objectAtIndex:anIndexPath.row];
    } else if (kExistingMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {
        menuModel = [self.existingMenuList objectAtIndex:anIndexPath.row];
    }
    menuModel.isSpicy = [cell.spicySwitch isOn];
}

- (void)submitDidSelectInCell:(MenuItemCell*)cell {
    [self.view endEditing:YES];
    NSIndexPath *selectedIndexPath = [self.itemsTableView indexPathForCell:cell];
    MenuItemModel *menuModel = [self.existingMenuList objectAtIndex:selectedIndexPath.row];

    NSString *message = @"Please confirm to go ahead.";
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"MOXIEIT"
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       //Handle your yes please button action here
                                   }];
    UIAlertAction *okayButton = [UIAlertAction
                                 actionWithTitle:@"Confirm"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     //Handle your yes please button action here
                                     self.submitSelectedCell = cell;
                                     NSDictionary *paramDict = [self getParamsDictForMenuUpdate:menuModel];
                                     [appDelegate showActivityIndicator];
                                     [self postChangeInMenuItemsWithDictionary:paramDict];
                                 }];
    [alert addAction:cancelButton];
    [alert addAction:okayButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)cancelDidSelectInCell:(MenuItemCell*)cell {
    NSIndexPath *indexPath = [self.itemsTableView indexPathForCell:cell];
    MenuItemModel *aModel = [self.existingMenuList objectAtIndex:indexPath.row];
    aModel.allowEditing = NO;
    [self.itemsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    self.imagePickerController = imagePickerController; // we need this for later
    [self presentViewController:self.imagePickerController animated:YES completion:^{
        //.. done presenting
    }];
}

#pragma mark - UIImagePickerControllerDelegate
// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage *imgCompressed = [self compressImage:image];
    NSIndexPath *selectedIndexPath = [self.itemsTableView indexPathForCell:self.selectedCell];
    if (kNewMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {
        MenuItemModel *menuModel = [self.createdMenuList objectAtIndex:selectedIndexPath.row];
        menuModel.thumbnailImage = imgCompressed;
        [self.selectedCell.picButton setBackgroundImage:menuModel.thumbnailImage forState:UIControlStateNormal];
    } else if (kExistingMenuSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {
        MenuItemModel *menuModel = [self.existingMenuList objectAtIndex:selectedIndexPath.row];
        menuModel.thumbnailImage = imgCompressed;
        [self.selectedCell.picButton setBackgroundImage:menuModel.thumbnailImage forState:UIControlStateNormal];
        [appDelegate showActivityIndicator];
        [self uploadImageForMenuItem:menuModel];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    self.imagePickerController = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        //.. done dismissing
    }];
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
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else{
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

#pragma mark - Table cell image support

- (void)startIconDownload:(MenuItemModel *)aModel forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
//        iconDownloader.aCategory = aModel;
        (self.imageDownloadsInProgress)[indexPath] = iconDownloader;
        [iconDownloader startImageDownloadForURL:aModel.imageURLString withDownloadCompletionHandler:^(UIImage * _Nullable image) {
            if (image && (self.itemsSegmentControl.selectedSegmentIndex == kExistingMenuSegmentID)) {
                aModel.thumbnailImage = image;
                MenuItemCell *cell = [self.itemsTableView cellForRowAtIndexPath:indexPath];
                // Display the newly loaded image
                //            cell.profilePicImageView.image = aModel.thumbnailImage;
                [cell.picButton setBackgroundImage:aModel.thumbnailImage forState:UIControlStateNormal];
                [cell.activityIndicator stopAnimating];
            }
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
        }];
//        [iconDownloader startDownload];
    }
}

// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if (self.existingMenuList.count > 0)
    {
        NSArray *visiblePaths = [self.itemsTableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            MenuItemModel *aMenuItem = (self.existingMenuList)[indexPath.row];
            
            if (!aMenuItem.thumbnailImage)
                // Avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:aMenuItem forIndexPath:indexPath];
            }
        }
    }
}


#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:scrollView
//  When scrolling stops, proceed to load the app icons that are on screen.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

#pragma mark - Private Methods
- (void)addOnemoreRow {
    NSDictionary *dataDictionary = @{@"image" : @"",
                                     @"itemName" : @"",
                                     @"price" : @"",
                                     @"itemType" : @"Veg",
                                     @"itemId" : @""};
    MenuItemModel *aModel = [[MenuItemModel alloc] initWithDictionary:dataDictionary];
    [self.createdMenuList addObject:aModel];
}

- (NSDictionary *)getNewMenuItemsParamsDict {
    NSMutableArray *menuList = [NSMutableArray arrayWithCapacity:0];
    NSDictionary *newDict = nil;
    for (MenuItemModel *menuModel in self.createdMenuList) {
        NSString *spiceString = menuModel.isSpicy ? @"true" : @"false";
        NSDictionary *menuDict = [NSDictionary dictionaryWithObjectsAndKeys:self.selectedCategory.categoryID, @"categoryId",
                                  menuModel.itemName, @"itemName",
                                  menuModel.itemPrice, @"price",
                                  spiceString, @"isSpicy",
                                  menuModel.itemType, @"itemType",
                                  menuModel.imageURLString, @"image", nil];
        [menuList addObject:menuDict];
    }
    newDict = [NSDictionary dictionaryWithObjectsAndKeys:menuList, @"menuItemsRequest", @"Insert", @"type", nil];
    return newDict;
}

- (NSDictionary *)getParamsDictForMenuUpdate:(MenuItemModel *)menuModel {
    NSDictionary *newDict = nil;
    NSMutableArray *menuList = [NSMutableArray arrayWithCapacity:0];
    NSString *spiceString = menuModel.isSpicy ? @"true" : @"false";
    NSDictionary *menuDict = [NSDictionary dictionaryWithObjectsAndKeys:self.selectedCategory.categoryID, @"categoryId",
                              menuModel.menuItemID, @"itemId",
                              menuModel.itemName, @"itemName",
                              menuModel.itemPrice, @"price",
                              spiceString, @"isSpicy",
                              menuModel.itemType, @"itemType",
                              menuModel.imageURLString, @"image", nil];
    [menuList addObject:menuDict];
    newDict = [NSDictionary dictionaryWithObjectsAndKeys:menuList, @"menuItemsRequest", @"Update", @"type", nil];
    return newDict;
}

- (NSDictionary *)getParamsDictForDeleteMenuItem:(MenuItemModel *)menuModel {
    NSDictionary *menuDict = [NSDictionary dictionaryWithObjectsAndKeys:self.selectedCategory.categoryID, @"categoryId", menuModel.menuItemID, @"itemId", nil];
    NSDictionary *newDict = [NSDictionary dictionaryWithObjectsAndKeys:@[menuDict], @"menuItemsRequest", @"Delete", @"type", nil];
    return newDict;
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
                                     //Handle your yes please button action here
                                 }];
    
    [alert addAction:okayButton];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - IBActions
- (IBAction)addNewMenuItemsSelected:(id)sender {
    [self.view endEditing:YES];
    NSLog(@"DL>>%@", self.createdMenuList);
    if ([self.createdMenuList count]) {
        BOOL hasData = YES;
        for (MenuItemModel *aModel in self.createdMenuList) {
            hasData = ([aModel.itemPrice length] && [aModel.itemName length] && (aModel.thumbnailImage)) ? YES : NO;
            if (!hasData) {
                NSString *alertMessage = (!aModel.thumbnailImage) ? @"Please select image for all Menu items." : @"Please enter the details in empty field.";
                [self showAlertWithTitle:@"MoxieIT" andMessage:alertMessage];
                return;
            }
        }
        if (hasData) {
            //First post images then on success post categoty text.....
            [appDelegate showActivityIndicator];
            isDeleteSelected = NO;
            uploadItemIndex = 0;
            [self uploadMenuItems];
        }
    } else {
        [self showAlertWithTitle:@"Title" andMessage:@"Please enter atleast one category to move into next screen"];
    }
}

- (IBAction)menuSegmentControlDidSelect:(id)sender {
    UISegmentedControl *segmentControl = sender;
    [self.view endEditing:YES];
    showNoItemsRow = NO;
    isDeleteSelected = NO;
    [self.addButton setHidden:((segmentControl.selectedSegmentIndex == kNewMenuSegmentID) ? NO : YES)];
    if (segmentControl.selectedSegmentIndex == kNewMenuSegmentID) {//Add new categories
        [self.existingMenuList removeAllObjects];
        [self addOnemoreRow];
        [self.itemsTableView setEditing:YES animated:YES];
    } else if (segmentControl.selectedSegmentIndex == kExistingMenuSegmentID) {//Existing categories
        [self.itemsTableView setEditing:NO animated:NO];
        [self.createdMenuList removeAllObjects];
        [self getAllMenuListforSelectedCategory];
    }
    [self.itemsTableView reloadData];
}

- (IBAction)gotoCategoriesVC:(UIStoryboardSegue *)aSegue {
    NSLog(@"%s", __FUNCTION__);
}

@end
