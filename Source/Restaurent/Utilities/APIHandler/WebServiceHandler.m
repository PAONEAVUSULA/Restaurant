//
//  WebServiceHandler.m
//  Affiliates
//
//  Created by SAN_Technologies on 19/09/17.
//  Copyright © 2017 San Technologies. All rights reserved.
//

#import "WebServiceHandler.h"

@implementation WebServiceHandler

+ (instancetype)sharedHandler {
    static WebServiceHandler *sharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHandler = [[self alloc] init];
    });
    return sharedHandler;
}

- (void)fetchDataforURLString:(NSString *)urlString callBackCompletionHandler:(void (^)(id jsonObject, NSError *error))handler {
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(aQueue, ^{
        NSURL *aURL = [NSURL URLWithString:urlString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:aURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:200.0];
        NSURLSession *urlSession = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                NSError *aError;
                id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&aError];
//                NSLog(@"jsonObject>>>Dict>>%@", jsonObject);
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(jsonObject, aError);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(nil, error);
                });
            }
        }];
        [dataTask resume];
    });
}

- (void)postData:(NSData *)data toURLString:(NSString *)urlString callBackCompletionHandler:(void (^)(id jsonObject, NSError *error))handler {
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(aQueue, ^{
        NSURL *aURL = [NSURL URLWithString:urlString];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:aURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:200.0];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setHTTPBody:data];
        NSURLSession *urlSession = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                NSError *aError;
                id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&aError];
//                NSLog(@"jsonObject>>>Dict>>%@", jsonObject);
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(jsonObject, aError);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(nil, error);
                });
            }
        }];
        [dataTask resume];
    });
}

@end
