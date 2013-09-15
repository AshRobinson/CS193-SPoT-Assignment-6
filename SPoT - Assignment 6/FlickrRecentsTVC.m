//
//  FlickrRecentsTVC.m
//  FlickrPlaces
//
//  Created by Ashley Robinson on 08/09/2013.
//  Copyright (c) 2013 Ashley Robinson. All rights reserved.
//

#import "FlickrRecentsTVC.h"
#import "SharedDocumentHandler.h"

@interface FlickrRecentsTVC ()

@property (strong, nonatomic) SharedDocumentHandler *sh;

@end

@implementation FlickrRecentsTVC

- (SharedDocumentHandler *)sh
{
    if (!_sh) _sh = [SharedDocumentHandler sharedDocumentHandler];
    return _sh;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.sh useDocumentWithOperation:^(BOOL success) {
        [self setupFetchedResultsViewController];
    }];
}

- (void) setupFetchedResultsViewController
{
    if (self.sh.managedObjectContext){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"recent.lastViewed" ascending:NO]];
        request.predicate = [NSPredicate predicateWithFormat:@"recent != nil"];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.sh.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}
     
     
@end
