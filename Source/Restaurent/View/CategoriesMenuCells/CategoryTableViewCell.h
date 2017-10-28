//
//  ItemTableViewCell.h
//  Categories
//
//  Created by SAN_Technologies on 18/07/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CategoryTableViewCellDelegate;

@interface CategoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UITextField *itemTextField;
@property (weak, nonatomic) IBOutlet UILabel *categoryTitleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) id<CategoryTableViewCellDelegate> delegate;

- (IBAction)categoryDisclosureDidSelect:(id)sender;
- (IBAction)imageButtonSelected:(id)sender;
- (IBAction)existingCategoryImageButtonSelected:(id)sender;

@end

@protocol CategoryTableViewCellDelegate <NSObject>

@optional
- (void)existingCategoryDisclosureDidSelect:(CategoryTableViewCell *)aCell;
- (void)imageButtonDidSelectInCell:(CategoryTableViewCell *)aCell;
- (void)existingCategoryImageButtonDidSelectInCell:(CategoryTableViewCell *)aCell;

@end
