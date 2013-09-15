//
//  Tag+Flickr.h
//  SPoT - Assignment 6
//
//  Created by Ashley Robinson on 15/09/2013.
//  Copyright (c) 2013 Ashley Robinson. All rights reserved.
//

#import "Tag.h"

@interface Tag (Flickr)

+ (NSSet *)tagsFromFlickrInfo:(NSDictionary *)photoDictionary
      forManagedObjectContext:(NSManagedObjectContext *)context;

@end
