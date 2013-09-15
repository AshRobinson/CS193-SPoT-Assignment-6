//
//  FlickrCache.h
//  FlickrPlaces
//
//  Created by Ashley Robinson on 13/09/2013.
//  Copyright (c) 2013 Ashley Robinson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrCache : NSObject

#define FLICKRCACHE_MAXSIZE_IPHONE 1024*1024*3
#define FLICKRCACHE_MAXSIZE_IPAD 1024*1024*10
#define FLICKRCACHE_FOLDER @"flickrPhotos"

+ (NSURL *)cachedURLforURL:(NSURL *)url;
+ (void)cacheImageData:(NSData *)data forURL:(NSURL *)url;

@end
