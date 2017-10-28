/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Helper object for managing the downloading of a particular app's icon.
  It uses NSURLSession/NSURLSessionDataTask to download the app's icon in the background if it does not
  yet exist and works in conjunction with the RootViewController to manage which apps need their icon.
 */

#import "IconDownloader.h"
#import "CategoryModel.h"

#define kAppIconSize 80


@interface IconDownloader ()

@property (nonatomic, strong) NSURLSessionDataTask *sessionTask;

@end


#pragma mark -

@implementation IconDownloader
/*
// -------------------------------------------------------------------------------
//	startDownload
// -------------------------------------------------------------------------------
- (void)startDownload
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.aCategory.imageName]];

    // create an session data task to obtain and download the app icon
    _sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // in case we want to know the response status code
        //NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];

        if (error != nil)
        {
            if ([error code] == NSURLErrorAppTransportSecurityRequiresSecureConnection)
            {
                // if you get error NSURLErrorAppTransportSecurityRequiresSecureConnection (-1022),
                // then your Info.plist has not been properly configured to match the target server.
                //
                abort();
            }
        }
                                                       
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
            
            // Set appIcon and clear temporary data/image
            UIImage *image = [[UIImage alloc] initWithData:data];
            
            if (image.size.width != kAppIconSize || image.size.height != kAppIconSize)
            {
                CGSize itemSize = CGSizeMake(kAppIconSize, kAppIconSize);
                UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
                CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                [image drawInRect:imageRect];
                self.aCategory.thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            else
            {
                self.aCategory.thumbnailImage = image;
            }
            
            // call our completion handler to tell our client that our icon is ready for display
            if (self.completionHandler != nil)
            {
                self.completionHandler();
            }
        }];
    }];
    
    [self.sessionTask resume];
}
*/

- (void)startImageDownloadForURL:(NSString *)imageURLString withDownloadCompletionHandler:(void (^)(UIImage * _Nullable))downLoadCompletionHandler {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]];
    
    // create an session data task to obtain and download the app icon
    _sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
                                                       
       // in case we want to know the response status code
       //NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
       
       if (error != nil)
       {
           if ([error code] == NSURLErrorAppTransportSecurityRequiresSecureConnection)
           {
               // if you get error NSURLErrorAppTransportSecurityRequiresSecureConnection (-1022),
               // then your Info.plist has not been properly configured to match the target server.
               //
               abort();
           }
       }
        
       [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
           UIImage *tnImage = nil;
           // Set appIcon and clear temporary data/image
           UIImage *image = [[UIImage alloc] initWithData:data];
           if (image) {
               if (image.size.width != kAppIconSize || image.size.height != kAppIconSize)
               {
                   CGSize itemSize = CGSizeMake(kAppIconSize, kAppIconSize);
                   UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
                   CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                   [image drawInRect:imageRect];
                   tnImage = UIGraphicsGetImageFromCurrentImageContext();
                   UIGraphicsEndImageContext();
               }
               else
               {
                   tnImage = image;
               }
           }
           
           
           // call our completion handler to tell our client that our icon is ready for display
//           if (self.completionHandler != nil)
//           {
//               self.completionHandler();
//           }
           downLoadCompletionHandler(tnImage);
       }];
   }];
    
    [self.sessionTask resume];
}

// -------------------------------------------------------------------------------
//	cancelDownload
// -------------------------------------------------------------------------------
- (void)cancelDownload
{
    [self.sessionTask cancel];
    _sessionTask = nil;
}

@end

