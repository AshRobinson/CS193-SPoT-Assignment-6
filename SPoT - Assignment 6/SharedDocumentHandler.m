//
//  SharedDocumentHandler.m
//  SPoT - Assignment 6
//
//  Created by Ashley Robinson on 15/09/2013.
//  Copyright (c) 2013 Ashley Robinson. All rights reserved.
//

#import "SharedDocumentHandler.h"

@implementation SharedDocumentHandler

+ (SharedDocumentHandler *)sharedDocumentHandler
{
    static dispatch_once_t pred = 0;
    __strong static SharedDocumentHandler *_sharedDocumentHandler =nil;
    dispatch_once(&pred, ^{
        _sharedDocumentHandler = [[self alloc] init];
    });
    return _sharedDocumentHandler;
}

- (void)useDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"SPOTDocument"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              self.managedObjectContext = document.managedObjectContext;
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            self.managedObjectContext = document.managedObjectContext;
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
    }
}

@end
