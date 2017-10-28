//
//  OrderPopOverViewController.m
//  OrderCheck
//
//  Created by SAN_Technologies on 10/06/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "OrderPopOverViewController.h"
#import "FoodTableViewCell.h"
#import "FoodItemModel.h"

@interface OrderPopOverViewController () {
    NSArray *sectionTitlesList;
}

@end

@implementation OrderPopOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"self.anOrder>>>%@", self.selectedOrder);
    sectionTitlesList = [self.selectedOrder.foodItemsDict allKeys];
    [self.orderTitleLabel setText:[NSString stringWithFormat:@"Order %@", self.selectedOrder.orderID]];
//    self.preferredContentSize = CGSizeMake(500.0, 500.0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%s", __FUNCTION__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    return [sectionTitlesList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    //    return [self.restaurentModel.ordersList count];
    NSString *aKey = [sectionTitlesList objectAtIndex:section];
    NSArray *foodList = [self.selectedOrder.foodItemsDict objectForKey:aKey];
    
    return [foodList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionTitlesList objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FoodTableViewCell *foodCell = [tableView dequeueReusableCellWithIdentifier:@"FoodCellID" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *aKey = [sectionTitlesList objectAtIndex:indexPath.section];
    NSArray *foodList = [self.selectedOrder.foodItemsDict objectForKey:aKey];
    FoodItemModel *foodModel = [foodList objectAtIndex:indexPath.row];
    NSLog(@"aKey>>>%@ foodList>>>%@.......%@", aKey, foodList, foodModel.itemQuantity);
    foodCell.foodItemLabel.text = foodModel.itemName;
    foodCell.quantityLabel.text = [NSString stringWithFormat:@"%@", foodModel.itemQuantity];
    foodCell.spiceLabel.text = foodModel.spicyLevel;
    
    return foodCell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
