//
//  Recent+Photo.m
//  SPoT - Assignment 6
//
//  Created by Ashley Robinson on 15/09/2013.
//  Copyright (c) 2013 Ashley Robinson. All rights reserved.
//

#import "Recent+Photo.h"

#define RECENT_FLICKR_PHOTOS 20

@implementation Recent (Photo)


+ (Recent *)recentPhoto:(Photo *)photo
{
    Recent *recent = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recent"];
    request.predicate = [NSPredicate predicateWithFormat:@"photo = %@", photo];
    NSError *error = nil;
    NSArray *matches = [photo.managedObjectContext executeFetchRequest:request
                                                                 error:&error];
    
    if (!matches || [matches count] > 1) {
        NSLog(@"Error in NSFetchRequest");
    } else if (![matches count]) {
        recent = [NSEntityDescription insertNewObjectForEntityForName:@"Recent" inManagedObjectContext:photo.managedObjectContext];
        recent.photo = photo;
        recent.lastViewed = [NSDate date];
        request.predicate = nil;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastViewed" ascending:NO]];

        matches = [photo.managedObjectContext executeFetchRequest:request
                                                            error:&error];
        
        if ([matches count] > RECENT_FLICKR_PHOTOS) {
            [photo.managedObjectContext deleteObject:[matches lastObject]];
        }
        
    } else {
        recent = [matches lastObject];
        recent.lastViewed = [NSDate date];
    }
    
    return recent;
}

@end
