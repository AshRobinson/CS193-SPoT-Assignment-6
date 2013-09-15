//
//  FlickrCache.m
//  FlickrPlaces
//
//  Created by Ashley Robinson on 13/09/2013.
//  Copyright (c) 2013 Ashley Robinson. All rights reserved.
//

#import "FlickrCache.h"

@interface FlickrCache ()

@property (strong, nonatomic) NSURL *cacheFolder;
@property (strong, nonatomic) NSFileManager *fileManager;

@end

@implementation FlickrCache


- (NSURL *)cacheFolder
{
    if (!_cacheFolder) {
        _cacheFolder = [[[self.fileManager URLsForDirectory:NSCachesDirectory
                                                  inDomains:NSUserDomainMask] lastObject]
                        URLByAppendingPathComponent:FLICKRCACHE_FOLDER
                        isDirectory:YES];
        
        BOOL *isDir = NO;
        if (![self.fileManager fileExistsAtPath:[_cacheFolder path] isDirectory:isDir]){
            [self.fileManager createDirectoryAtPath:[_cacheFolder path]
                        withIntermediateDirectories:YES
                                         attributes:nil
                                              error:nil];
        }
    }
    return _cacheFolder;
}

- (NSFileManager *)fileManager
{
    if (!_fileManager) _fileManager = [[NSFileManager alloc] init];
    return _fileManager;
}

- (NSURL *)getCachedURLforURL:(NSURL *)url
{
    return [self.cacheFolder URLByAppendingPathComponent:[[url path] lastPathComponent]];
}

+ (NSURL *)cachedURLforURL:(NSURL *)url
{
    FlickrCache *cache = [[FlickrCache alloc] init];
    NSURL *cachedURL = [cache getCachedURLforURL:url];
    if ([cache fileExistsAtURL:cachedURL]){
        return cachedURL;
    }
    return nil;
}

- (BOOL)fileExistsAtURL:(NSURL *)url
{
    return [self.fileManager fileExistsAtPath:[url path]];
}

+ (void)cacheImageData:(NSData *)data forURL:(NSURL *)url
{
    if (!data) return;
    FlickrCache *cache = [[FlickrCache alloc] init];
    NSURL *cachedURL = [cache getCachedURLforURL:url];
    if([cache fileExistsAtURL:cachedURL]) {
        [cache.fileManager setAttributes:@{NSFileModificationDate: [NSDate date]}
                            ofItemAtPath:[cachedURL path]
                                   error:nil];
    } else {
        [cache.fileManager createFileAtPath:[cachedURL path]
                                   contents:data attributes:nil];
        [cache cleanupOldFiles];
    }
}

- (void)cleanupOldFiles
{
    NSDirectoryEnumerator *dirEnumerator = [self.fileManager enumeratorAtURL:self.cacheFolder
                                                  includingPropertiesForKeys:@[NSURLAttributeModificationDateKey]
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                errorHandler:nil];
    NSNumber *fileSize;
    NSDate *date;
    NSMutableArray *files = [NSMutableArray array];
    __block NSUInteger dirSize = 0;
    for (NSURL *url in dirEnumerator){
        [url getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        [url getResourceValue:&date forKey:NSURLAttributeModificationDateKey error:nil];
        dirSize += [fileSize integerValue];
        [files addObject:@{@"url":url, @"size":fileSize,@"date":date}];
    }
    int maxCacheSize = FLICKRCACHE_MAXSIZE_IPHONE;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) maxCacheSize = FLICKRCACHE_MAXSIZE_IPAD;
    if (dirSize > maxCacheSize){
        NSArray *sorted = [files sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1[@"date"] compare:obj2[@"date"]];
        }];
        [sorted enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            dirSize -= [obj[@"size"] integerValue];
            NSError *error;
            [self.fileManager removeItemAtURL:obj[@"url"] error:&error];
            *stop = error || (dirSize < maxCacheSize);
        }];
    }
}







@end
