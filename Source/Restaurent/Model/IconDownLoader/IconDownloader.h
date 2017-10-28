/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Helper object for managing the downloading of a particular app's icon.
  It uses NSURLSession/NSURLSessionDataTask to download the app's icon in the background if it does not
  yet exist and works in conjunction with the RootViewController to manage which apps need their icon.
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//@class CategoryModel;

@interface IconDownloader : NSObject

//@property (nonatomic, strong) CategoryModel *aCategory;
//@property (nonatomic, copy) void (^completionHandler)(void);

//- (void)startDownload;
- (void)cancelDownload;

- (void)startImageDownloadForURL:(NSString *_Nullable)imageURLString withDownloadCompletionHandler:(void (^_Nullable)(UIImage * _Nullable image))downLoadCompletionHandler;

@end
