//
//  SharedDocumentHandler.m
//  SPoT - Assignment 6
//
//  Created by Ashley Robinson on 15/09/2013.
//  Copyright (c) 2013 Ashley Robinson. All rights reserved.
//

#import "SharedDocumentHandler.h"

@interface SharedDocumentHandler ()

@property (strong, nonatomic) UIManagedDocument *document;

@end

@implementation SharedDocumentHandler

- (void)saveDocument
{
    [self.document saveToURL:self.document.fileURL
            forSaveOperation:UIDocumentSaveForCreating
           completionHandler:NULL];
}

- (UIDocument *)document
{
    if (!_document){
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                         inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"SPoTDocument"];
        _document = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    return _document;
}

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
    UIManagedDocument *document = self.document;
    //NSLog(@"%@", url);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[document.fileURL path]]) {
        //NSLog(@"create document");
        [document saveToURL:document.fileURL
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
