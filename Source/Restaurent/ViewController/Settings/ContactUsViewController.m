//
//  ContactUsViewController.m
//  Restaurent
//
//  Created by SAN_Technologies on 18/08/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "ContactUsViewController.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface ContactUsViewController () {
    AppDelegate *appDelegate;
}

@property (weak, nonatomic) IBOutlet UILabel *topTitleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *contactUsWebView;

@end

@implementation ContactUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.topTitleLabel setText:[self.setModel.title uppercaseString]];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSURL *websiteUrl = [NSURL URLWithString:CONTACT_US_API];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    [self.contactUsWebView loadRequest:urlRequest];
    [appDelegate showActivityIndicator];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [appDelegate stopActivityIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [appDelegate stopActivityIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [appDelegate stopActivityIndicator];
    [appDelegate showAlertWithTitle:@"MOXIEIT" andMessage:error.description];
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
