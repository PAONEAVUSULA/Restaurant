//
//  WebServiceHandler.h
//  Affiliates
//
//  Created by SAN_Technologies on 19/09/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServiceHandler : NSObject

+ (instancetype)sharedHandler;

- (void)fetchDataforURLString:(NSString *)urlString callBackCompletionHandler:(void (^)(id jsonObject, NSError *error))handler;
- (void)postData:(NSData *)data toURLString:(NSString *)urlString callBackCompletionHandler:(void (^)(id jsonObject, NSError *error))handler;

@end
