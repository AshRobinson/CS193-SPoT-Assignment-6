//
//  SharedDocumentHandler.h
//  SPoT - Assignment 6
//
//  Created by Ashley Robinson on 15/09/2013.
//  Copyright (c) 2013 Ashley Robinson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedDocumentHandler : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

+ (SharedDocumentHandler *)sharedDocumentHandler;

- (void)useDocument;


@end
