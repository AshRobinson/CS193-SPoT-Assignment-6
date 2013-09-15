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

- (void)useDocumentWithOperation:(void (^)(BOOL))block
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                         inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"SPoTDocument"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    //NSLog(@"%@", url);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        //NSLog(@"create document");
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              self.managedObjectContext = document.managedObjectContext;
              block(success);
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        //NSLog(@"open document");
        [document openWithCompletionHandler:^(BOOL success) {
            self.managedObjectContext = document.managedObjectContext;
            block(success);
        }];
    } else {
        //NSLog(@"use document");
        self.managedObjectContext = document.managedObjectContext;
        BOOL success = YES;
        block(success);
    }
}

@end
