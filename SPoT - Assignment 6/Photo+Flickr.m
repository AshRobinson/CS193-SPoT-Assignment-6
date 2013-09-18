//
//  Photo+Flickr.m
//  SPoT - Assignment 6
//
//  Created by Ashley Robinson on 15/09/2013.
//  Copyright (c) 2013 Ashley Robinson. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Tag+Flickr.h"
#import "Recent.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContecxt:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@",
                         [photoDictionary[FLICKR_PHOTO_ID] description]];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || ([matches count] > 1) || error) {
        NSLog(@"Error in photoWithFlickrInfo: %@ %@", matches, error);
    } else if (![matches count]) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];
        photo.unique = [photoDictionary[FLICKR_PHOTO_ID] description];
        photo.title = [photoDictionary[FLICKR_PHOTO_TITLE] description];
        photo.firstLetter = [photo.title substringToIndex:1];
        photo.subtitle = [[photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
        photo.imageURL = [[FlickrFetcher urlForPhoto:photoDictionary
                                              format:([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? FlickrPhotoFormatOriginal : FlickrPhotoFormatLarge] absoluteString];
        photo.thumbnailURL = [[FlickrFetcher urlForPhoto:photoDictionary
                                                  format:FlickrPhotoFormatSquare] absoluteString];
        
        photo.tags = [Tag tagsFromFlickrInfo:photoDictionary forManagedObjectContext:context];
        
        NSArray *tags = [[photo.tags allObjects] sortedArrayUsingComparator:^NSComparisonResult(Tag *tag1, Tag *tag2) {
            return [tag1.name compare:tag2.name];
        }];
        photo.tagsString = [((Tag *)tags[1]).name capitalizedString];
    } else {
        photo = [matches lastObject];
    }
    
    return photo;
}
- (void)delete
{
    for (Tag *tag in self.tags) {
        if ([tag.photos count] == 1) [self.managedObjectContext deleteObject:tag];
    }
    self.tags = nil;
    if (self.recent) [self.managedObjectContext deleteObject:self.recent];
}



@end
