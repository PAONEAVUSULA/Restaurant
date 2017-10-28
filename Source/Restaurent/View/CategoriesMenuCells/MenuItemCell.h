//
//  MenuItemCell.h
//  Restaurent
//
//  Created by SAN_Technologies on 28/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuItemCellDelegate;

@interface MenuItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *picButton;
@property (weak, nonatomic) IBOutlet UITextField *menuTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *itemPriceTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *menuTypeSegmentControl;
@property (weak, nonatomic) IBOutlet UISwitch *spicySwitch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

/*  ##########  ##########  Existing MenuItems  ##########  ##########  */
@property (weak, nonatomic) IBOutlet UILabel *spicyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *vegImageView;//Indicator Veg/Non-veg through green and red images.
/*  ##########  ##########  ##########  ##########  ##########  */


@property (weak, nonatomic) id <MenuItemCellDelegate>delegate;


- (IBAction)imageButtonSelected:(id)sender;
- (IBAction)foodTypeValueChanged:(id)sender;
- (IBAction)spicySwitchSelected:(id)sender;

- (IBAction)submitSelected:(id)sender;
- (IBAction)cancelSelected:(id)sender;

@end

@protocol MenuItemCellDelegate <NSObject>

@optional
- (void)menuTypeSegmentControlDidSelectInCell:(MenuItemCell*)cell;
- (void)imageButtonDidSelectInCell:(MenuItemCell*)cell;
- (void)spicySwitchDidSelectInCell:(MenuItemCell*)cell;
- (void)submitDidSelectInCell:(MenuItemCell*)cell;
- (void)cancelDidSelectInCell:(MenuItemCell*)cell;

@end
