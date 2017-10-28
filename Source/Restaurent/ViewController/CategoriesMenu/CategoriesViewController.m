//
//  ViewController.m
//  Categories
//
//  Created by SAN_Technologies on 18/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "CategoriesViewController.h"
#import "CategoryTableViewCell.h"
#import "CategorySectionFooterView.h"
#import "MenuItemsViewController.h"
#import "CategoryModel.h"
#import "AppDelegate.h"
#import "IconDownloader.h"
#import "WebServiceHandler.h"
#import "Constants.h"

#define kExistingCategoriesSegmentID 0
#define kNewCategoriesSegmentID 1

@interface CategoriesViewController () <CategoryTableViewCellDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    AppDelegate *appDelegate;
    NSUInteger uploadItemIndex;
    BOOL showNoItemsRow;
    BOOL isDeleteSelected;
}

@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *itemsSegmentControl;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) NSMutableArray *createdItemsList;
@property (strong, nonatomic) NSMutableArray *existingItemsList;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) CategoryTableViewCell *selectedCell;
// the set of IconDownloader objects for each category
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

- (IBAction)addNewCategoriesSelected:(id)sender;
- (IBAction)categoriesSegmentControlDidSelect:(id)sender;
- (void)postCategoriesDict:(NSDictionary *)paramDict;
- (void)getAllMenuCategories;

@end

@implementation CategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.itemsTableView setBackgroundColor:[UIColor clearColor]];
    [self.view.layer setContents:(id)[UIImage imageNamed:@"BG.png"].CGImage];
    [self.itemsTableView registerNib:[UINib nibWithNibName:@"CategorySectionFooterView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"CategorySectionFooterView"];
    showNoItemsRow = NO;
    
    self.createdItemsList = [NSMutableArray arrayWithCapacity:0];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [self categoriesSegmentControlDidSelect:self.itemsSegmentControl];
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
    numOfRows = (kNewCategoriesSegmentID == self.itemsSegmentControl.selectedSegmentIndex) ? [self.createdItemsList count] : [self.existingItemsList count];
    numOfRows = showNoItemsRow ? 1 : numOfRows;
    return numOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView addNewCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddCategoryCellID" forIndexPath:indexPath];
    [cell.itemTextField setTag:indexPath.row];
    CategoryModel *aModel = [self.createdItemsList objectAtIndex:indexPath.row];
    [cell.itemTextField setText:aModel.categoryName];
    if (!aModel.thumbnailImage) {
        [cell.imageButton setBackgroundImage:[UIImage imageNamed:@"gallery.png"] forState:UIControlStateNormal];
    } else {
        [cell.imageButton setBackgroundImage:aModel.thumbnailImage forState:UIControlStateNormal];
    }
    cell.delegate = self;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView existingCategoryCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExisitingCategoryCellID" forIndexPath:indexPath];
    CategoryModel *aModel = [self.existingItemsList objectAtIndex:indexPath.row];
    [cell.categoryTitleLabel setText:aModel.categoryName];
    [cell.activityIndicator startAnimating];
    // Only load cached images; defer new downloads until scrolling ends
    if (!aModel.thumbnailImage) {
        if (tableView.dragging == NO && tableView.decelerating == NO)
        {
            [self startIconDownload:aModel forIndexPath:indexPath];
        }
        // if a download is deferred or in progress, return a placeholder image
        [cell.imageButton setBackgroundImage:[UIImage imageNamed:@"gallery.png"] forState:UIControlStateNormal];
    } else {
        [cell.activityIndicator stopAnimating];
        [cell.imageButton setBackgroundImage:aModel.thumbnailImage forState:UIControlStateNormal];
    }
    
    cell.delegate = self;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *aCell;
    if (kNewCategoriesSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {//Add New Category
        aCell = [self tableView:tableView addNewCellForRowAtIndexPath:indexPath];
    } else if (kExistingCategoriesSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {//Existing Categories
        if (0 == [self.existingItemsList count]) {
            aCell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCellID"];
            [aCell.textLabel setText:@"Don't have categories for your restaurant please add new categories using above segment."];
        } else {
            aCell = [self tableView:tableView existingCategoryCellForRowAtIndexPath:indexPath];
        }
    }
    
    // Configure the cell...
//    [aCell setBackgroundColor:[UIColor clearColor]];
    [aCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return aCell;
}

#pragma mark - Table view Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    CategoryTableViewCell *itemCell = [tableView cellForRowAtIndexPath:indexPath];
    if (kNewCategoriesSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {//Add New Category
        [itemCell.itemTextField becomeFirstResponder];
    } else if (kExistingCategoriesSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {//Existing Categories
        if ([self.existingItemsList count]) {
            [self showAlertWithCategoryNameTextFieldForCell:itemCell];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = 0.0;
    height = (kNewCategoriesSegmentID == self.itemsSegmentControl.selectedSegmentIndex) ? 60.0 : 0.0;
    return height;
}

//- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;   // custom view for header. will be adjusted to default or specified header height
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CategorySectionFooterView *sectionFooterView = nil;
    if (kNewCategoriesSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {//Add New Category
        sectionFooterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"CategorySectionFooterView"];
        sectionFooterView.tag = section;
        [sectionFooterView.contentView setBackgroundColor:[UIColor whiteColor]];
        if (sectionFooterView == nil) {
            NSLog(@"sectionheaderViewCell is nil");
            [NSException raise:@"headerView == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
        } else {
        }
        /********** Add UITapGestureRecognizer to SectionView   **************/
        UITapGestureRecognizer  *footerTapGesture   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionFooterTapped:)];
        [sectionFooterView addGestureRecognizer:footerTapGesture];
        
        return sectionFooterView;
    } else if (kExistingCategoriesSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {//Existing Categories
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
    NSString *deleteTitle = (kNewCategoriesSegmentID == self.itemsSegmentControl.selectedSegmentIndex) ? @"Confirm" : @"Delete";
    return deleteTitle;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        isDeleteSelected = YES;
        if (kNewCategoriesSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {//Add New Category
            [self.createdItemsList removeObjectAtIndex:indexPath.row];
        } else if (kExistingCategoriesSegmentID == self.itemsSegmentControl.selectedSegmentIndex) {//Existing Categories
            //Create a Dict to post. for update in the server.
            CategoryModel *deletedModel = [self.existingItemsList objectAtIndex:indexPath.row];
            NSDictionary *paramDict = [self getParamsDictForDeleteCategory:deletedModel];
            NSLog(@"paramDict>>>%@", paramDict);
            [self postCategoriesDict:paramDict];
            
            [self.existingItemsList removeObjectAtIndex:indexPath.row];
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
    if ([self.createdItemsList count]) {
        NSIndexPath *anIndexPath = [NSIndexPath indexPathForRow:([self.createdItemsList count] - 1) inSection:0];
        CategoryTableViewCell *itemCell = [self.itemsTableView cellForRowAtIndexPath:anIndexPath];
        if (![itemCell.itemTextField.text length]) {
            NSString *message = @"Please enter category name in empty field to create new category.";
            [self showAlertWithTitle:@"MOXIEIT" andMessage:message];
            return;
        }
    }
    [self addOnemoreRow];
    NSArray *insertsIndexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:([self.createdItemsList count] - 1) inSection:0]];
    [self.itemsTableView beginUpdates];
    [self.itemsTableView insertRowsAtIndexPaths:insertsIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
    [self.itemsTableView endUpdates];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    NSLog(@">>>%@", textField);
    CategoryModel *aModel = [self.createdItemsList objectAtIndex:textField.tag];
    aModel.categoryName = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Webservice Handling

- (void)getAllMenuCategories {//To get all Categories for restaurent
    [appDelegate showActivityIndicator];
    NSString *urlStr = [NSString stringWithFormat:GET_CATEGORIES_API, SERVER_DOMAIN_NAME, appDelegate.aRestaurant.botName];
    [[WebServiceHandler sharedHandler] fetchDataforURLString:urlStr callBackCompletionHandler:^(id jsonObject, NSError *error) {
        NSString *errorMessage = nil;
        if (error) {
            errorMessage = error.localizedDescription;
        } else {
            if ([jsonObject isKindOfClass:[NSArray class]]) {
                self.existingItemsList = [NSMutableArray arrayWithArray:jsonObject];
                NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
                for (NSDictionary *aDict in self.existingItemsList) {
                    CategoryModel *catModel = [[CategoryModel alloc] initWithDictionary:aDict];
                    [newArray addObject:catModel];
                }
                self.existingItemsList = newArray;
                if (![self.existingItemsList count]) {
                    showNoItemsRow = YES;
                    errorMessage = @"Not yet created categories for your restaurant.";
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
- (void)postCategoriesDict:(NSDictionary *)paramDict {//Insert, Delete, Update Categories
//    [appDelegate showActivityIndicator];
//    NSDictionary *paramDict = [self createPostCategoryDictForCategory:catModel];
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:paramDict options:0 error:&error];
    if (error) {
        [self showAlertWithTitle:@"MOXIEIT" andMessage:error.localizedDescription];
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:CHANGE_CATEGORIES_API, SERVER_DOMAIN_NAME];
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
                    if (self.itemsSegmentControl.selectedSegmentIndex == kNewCategoriesSegmentID) {//Add new categories
                        if ([self.createdItemsList count]) {//Insert new categories changes...
                            [self.createdItemsList removeAllObjects];
                            [self addOnemoreRow];
                            [self.itemsTableView reloadData];
                            
                            [self showAlertWithTitle:@"MOXIEIT" andMessage:message];
                            [appDelegate stopActivityIndicator];
                        }
                    } else if (self.itemsSegmentControl.selectedSegmentIndex == kExistingCategoriesSegmentID) {//Existing
                        ///Handle delete for existing categories.
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

- (void)uploadMenuCategories {
    if (self.itemsSegmentControl.selectedSegmentIndex == kNewCategoriesSegmentID) {//Add new categories
        if (uploadItemIndex < [self.createdItemsList count]) {
            CategoryModel *catModel = [self.createdItemsList objectAtIndex:uploadItemIndex];
            [self uploadImageForMenuCategory:catModel];
        } else {
            NSDictionary *paramDict = [self getNewCategoriesParamsDict];
            [self postCategoriesDict:paramDict];
        }
    }
}

- (void)uploadImageForMenuCategory:(CategoryModel *)catModel {
//    [appDelegate showActivityIndicator];
    NSLog(@"11111catModel::%@ thumbnailImage>>>%@", catModel, catModel.thumbnailImage);
    NSData *imageData = UIImageJPEGRepresentation(catModel.thumbnailImage, 1.0);
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
                    catModel.imageURLString = fileURLStr;
                    //Update fileURL in dictionary
                    NSLog(@"2222catModel::%@ thumbnailImage>>>%@jsonObject>>%@", catModel, catModel.thumbnailImage, jsonObject);
                    if (self.itemsSegmentControl.selectedSegmentIndex == kExistingCategoriesSegmentID) {//Existing
                        NSDictionary *paramDict = [self getParamsDictForCategoryUpdate:catModel];
                        [self postCategoriesDict:paramDict];
                    } else {
                        uploadItemIndex++;
                        [self uploadMenuCategories];
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


#pragma mark - CategoryTableViewCell Delegate
- (void)existingCategoryDisclosureDidSelect:(CategoryTableViewCell *)aCell {
    NSIndexPath *selectedIndexPath =  [self.itemsTableView indexPathForCell:aCell];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MenuItemsViewController *menuItemsVC = [storyBoard instantiateViewControllerWithIdentifier:@"MenuItemsVC"];
    menuItemsVC.selectedCategory = [self.existingItemsList objectAtIndex:selectedIndexPath.row];
    [self.navigationController pushViewController:menuItemsVC animated:YES];
}

- (void)imageButtonDidSelectInCell:(CategoryTableViewCell *)aCell {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary fromButton:aCell.imageButton];
    self.selectedCell = aCell;
}

- (void)existingCategoryImageButtonDidSelectInCell:(CategoryTableViewCell *)aCell {
    NSString *message = @"Would you like to change the image of the selected category?";
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
                                     [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary fromButton:aCell.imageButton];
                                     self.selectedCell = aCell;
                                 }];
    [alert addAction:cancelButton];
    [alert addAction:okayButton];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - UIImagePickerController
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
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage *imgCompressed = [self compressImage:image];

    NSIndexPath *selectedIndexPath = [self.itemsTableView indexPathForCell:self.selectedCell];
    if (self.itemsSegmentControl.selectedSegmentIndex == kNewCategoriesSegmentID) {//Add new categories
        CategoryModel *catModel = [self.createdItemsList objectAtIndex:selectedIndexPath.row];
        catModel.thumbnailImage = imgCompressed;
        [self.selectedCell.imageButton setBackgroundImage:catModel.thumbnailImage forState:UIControlStateNormal];
    } else if (self.itemsSegmentControl.selectedSegmentIndex == kExistingCategoriesSegmentID) {//Existing
        CategoryModel *catModel = [self.existingItemsList objectAtIndex:selectedIndexPath.row];
        catModel.thumbnailImage = imgCompressed;
        [self.selectedCell.imageButton setBackgroundImage:catModel.thumbnailImage forState:UIControlStateNormal];
        [appDelegate showActivityIndicator];
        [self uploadImageForMenuCategory:catModel];
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

- (void)startIconDownload:(CategoryModel *)aModel forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
//        iconDownloader.aCategory = aModel;
        (self.imageDownloadsInProgress)[indexPath] = iconDownloader;
        [iconDownloader startImageDownloadForURL:aModel.imageURLString withDownloadCompletionHandler:^(UIImage * _Nullable image) {
            if (image && (self.itemsSegmentControl.selectedSegmentIndex == kExistingCategoriesSegmentID)) {
                aModel.thumbnailImage = image;
                
                CategoryTableViewCell *cell = [self.itemsTableView cellForRowAtIndexPath:indexPath];
                // Display the newly loaded image
                [cell.imageButton setBackgroundImage:aModel.thumbnailImage forState:UIControlStateNormal];

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
    if (self.existingItemsList.count > 0)
    {
        NSArray *visiblePaths = [self.itemsTableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            CategoryModel *aCategory = (self.existingItemsList)[indexPath.row];
            
            if (!aCategory.thumbnailImage)
                // Avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:aCategory forIndexPath:indexPath];
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
                                     @"categoryName" : @"",
                                     @"categoryId" : @""};
    CategoryModel *aModel = [[CategoryModel alloc] initWithDictionary:dataDictionary];
    [self.createdItemsList addObject:aModel];
}

- (void)showAlertWithCategoryNameTextFieldForCell:(CategoryTableViewCell *)cell {
    NSIndexPath *selectedIndexPath = [self.itemsTableView indexPathForCell:cell];
    CategoryModel *catModel = [self.existingItemsList objectAtIndex:selectedIndexPath.row];

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:appDelegate.aRestaurant.restaurentName
                                message:@"To change menu category name for selected item, enter new value."
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                               }];
    
    UIAlertAction *okayButton = [UIAlertAction
                                 actionWithTitle:@"Submit"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     //Handle your yes please button action here
                                     UITextField *catTextField = alert.textFields.firstObject;
                                     
                                     NSComparisonResult result = [catModel.categoryName compare:catTextField.text options:NSCaseInsensitiveSearch];
                                     if (NSOrderedSame == result) {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         [self performSelector:@selector(showSameTextAlert) withObject:nil afterDelay:0.1];
                                     } else {
                                         [appDelegate showActivityIndicator];
                                         catModel.categoryName = catTextField.text;
                                         [self.itemsTableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                         NSDictionary *paramDict = [self getParamsDictForCategoryUpdate:catModel];
                                         [self postCategoriesDict:paramDict];
                                     }
                                 }];
    [alert addAction:noButton];
    [alert addAction:okayButton];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        [textField setBackgroundColor:[UIColor colorWithRed:20.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0]];
        textField.placeholder = catModel.categoryName;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        [textField setTextColor:[UIColor colorWithRed:20.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0]];
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showSameTextAlert {
    [self showAlertWithTitle:@"MOXIEIT" andMessage:@"Your new category name is matching with old name, and both are same."];
}

- (NSDictionary *)getNewCategoriesParamsDict {
    NSMutableArray *categoriesList = [NSMutableArray arrayWithCapacity:0];
    NSDictionary *newDict = nil;
    for (CategoryModel *aModel in self.createdItemsList) {
        NSDictionary *categoryDict = [NSDictionary dictionaryWithObjectsAndKeys:aModel.categoryName, @"categoryName", aModel.imageURLString, @"image", nil];
        [categoriesList addObject:categoryDict];
    }
    newDict = [NSDictionary dictionaryWithObjectsAndKeys:categoriesList, @"menuCategoriesRequest", @"Insert", @"type", appDelegate.aRestaurant.botName, @"botName", nil];
    return newDict;
}

- (NSDictionary *)getParamsDictForCategoryUpdate:(CategoryModel *)aModel {
    NSDictionary *newDict = nil;
    NSDictionary *categoryDict = [NSDictionary dictionaryWithObjectsAndKeys:aModel.categoryName, @"categoryName", aModel.categoryID, @"categoryId", aModel.imageURLString, @"image", nil];
    newDict = [NSDictionary dictionaryWithObjectsAndKeys:@[categoryDict], @"menuCategoriesRequest", @"Update", @"type", appDelegate.aRestaurant.botName, @"botName", nil];
    return newDict;
}

- (NSDictionary *)getParamsDictForDeleteCategory:(CategoryModel *)aModel {
    NSDictionary *newDict = nil;
    newDict = [NSDictionary dictionaryWithObjectsAndKeys:@[aModel.categoryID], @"categoryIds", @"Delete", @"type", appDelegate.aRestaurant.botName, @"botName", nil];
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

#pragma mark - IBAction

- (IBAction)addNewCategoriesSelected:(id)sender {
    [self.view endEditing:YES];
    NSLog(@"DL>>%@", self.createdItemsList);
    if ([self.createdItemsList count]) {
        BOOL hasData = YES;
        for (CategoryModel *aModel in self.createdItemsList) {
            hasData = ([aModel.categoryName length] && (aModel.thumbnailImage)) ? YES : NO;
            if (!hasData) {
                NSString *alertMessage = (!aModel.thumbnailImage) ? @"Please select image for all categories." : @"Please enter the details in empty field.";
                [self showAlertWithTitle:@"MoxieIT" andMessage:alertMessage];
                return;
            }
        }
        if (hasData) {
            //First post images then on success post categoty text.....
            [appDelegate showActivityIndicator];
            isDeleteSelected = NO;
            uploadItemIndex = 0;
            [self uploadMenuCategories];
        }
    } else {
        [self showAlertWithTitle:@"Title" andMessage:@"Please enter atleast one category to move into next screen"];
    }
}

- (IBAction)categoriesSegmentControlDidSelect:(id)sender {
    UISegmentedControl *segmentControl = sender;
    [self.view endEditing:YES];
    showNoItemsRow = NO;
    isDeleteSelected = NO;
    [self.addButton setHidden:((segmentControl.selectedSegmentIndex == kNewCategoriesSegmentID) ? NO : YES)];
    if (segmentControl.selectedSegmentIndex == kNewCategoriesSegmentID) {//Add new categories
        [self.existingItemsList removeAllObjects];
        [self.createdItemsList removeAllObjects];
        [self addOnemoreRow];
        [self.itemsTableView setEditing:YES animated:YES];
    } else if (segmentControl.selectedSegmentIndex == kExistingCategoriesSegmentID) {//Existing categories
        [self.itemsTableView setEditing:NO animated:NO];
        [self.createdItemsList removeAllObjects];
        [self getAllMenuCategories];
    }
    [self.itemsTableView reloadData];
}

- (IBAction)gotoCategoriesVC:(UIStoryboardSegue *)aSegue {
    NSLog(@"%s", __FUNCTION__);
}

@end
