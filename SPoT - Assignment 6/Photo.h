//
//  Photo.h
//  SPoT - Assignment 6
//
//  Created by Ashley Robinson on 18/09/2013.
//  Copyright (c) 2013 Ashley Robinson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Recent, Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * firstLetter;
@property (nonatomic, retain) NSString * tagsString;
@property (nonatomic, retain) Recent *recent;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
