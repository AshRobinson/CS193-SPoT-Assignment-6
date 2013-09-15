//
//  ViewController.m
//  SPoT - Assignment 6
//
//  Created by Ashley Robinson on 15/09/2013.
//  Copyright (c) 2013 Ashley Robinson. All rights reserved.
//

#import "ViewController.h"
#import "FlickrFetcher.h"
#import "SharedDocumentHandler.h"
#import "Photo+Flickr.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SharedDocumentHandler *sh = [SharedDocumentHandler sharedDocumentHandler];
    [sh useDocumentWithOperation:NULL];
    
    dispatch_queue_t queue = dispatch_queue_create("Flickr Downloader", NULL);
    dispatch_async(queue, ^{
        NSArray *photos = [FlickrFetcher stanfordPhotos];
        //NSLog(@"%@", photos);
        [sh.managedObjectContext performBlock:^{
            for (NSDictionary *photo in photos) {
                [Photo photoWithFlickrInfo:photo inManagedObjectContecxt:sh.managedObjectContext];
            }
        }];
    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
