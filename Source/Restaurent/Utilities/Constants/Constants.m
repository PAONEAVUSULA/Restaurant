//
//  Constants.m
//  Affiliates
//
//  Created by SAN_Technologies on 28/09/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "Constants.h"

NSString *const SERVER_DOMAIN_NAME = @"https://izzad1rdrh.execute-api.us-east-1.amazonaws.com/dev";//Dev
//NSString *const SERVER_DOMAIN_NAME = @"https://vhnnifn9o0.execute-api.us-east-1.amazonaws.com/Lexpayment";//Production

/* ##########  Login Constants  ########## */
NSString *const LOGIN_API = @"%@/applogin";

/* ##########   ##########  Registration Constants  ##########  ########## */
NSString *const REGISTRATION_API = @"%@/restaurantdetails";
NSString *const IMAGE_UPLOAD_API = @"%@/uploadimage";

/* ##########   ##########  Bank Info Constants  ##########  ########## */
NSString *const POST_BANK_DETAILS_API = @"%@/lexbankaccountdetails";
NSString *const GET_BANK_DETAILS_API = @"%@/getbankacountdetails?botName=%@";

/* ##########   ##########  CATEGORY MENU Constants  ##########  ########## */
NSString *const GET_CATEGORIES_API = @"%@/getallmenucategory?botName=%@";
NSString *const CHANGE_CATEGORIES_API = @"%@/menucategory";

/* ##########   ##########  MENU Constants  ##########  ########## */
NSString *const GET_ALL_MENUITEMS_API = @"%@/menuitemsbycategoryid?categoryId=%@";
NSString *const CHANGE_MENUITEMS_API = @"%@/menuitems";

/* ##########   ##########  CONTACT US  ##########  ########## */
NSString *const CONTACT_US_API = @"http://moxieit.com/contactus.html";

/* ##########   ##########  SETTINGS Constants  ##########  ########## */
NSString *const FB_CONNECT_API = @"%@/fblogin";

/* ##########   ##########  ORDERS SCREEN Constants  ##########  ########## */
NSString *const SPEECH_POST_API = @"%@/putstatus";
NSString *const ORDERS_API = @"%@/getorders?botName=%@";
NSString *const ORDERS_HISTORY_API = @"%@/orderhistory";

@implementation Constants

@end
