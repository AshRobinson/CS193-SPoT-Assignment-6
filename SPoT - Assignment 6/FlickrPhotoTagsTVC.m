//
//  FlickrPhotoTagsTVC.m
//  FlickrPlaces
//
//  Created by Ashley Robinson on 05/09/2013.
//  Copyright (c) 2013 Ashley Robinson. All rights reserved.
//

#import "FlickrPhotoTagsTVC.h"
#import "FlickrFetcher.h"
//#import "RecentFlickrPhotos.h"
#import "Photo+Flickr.h"
#import "Recent+Photo.h"
#import "NetworkActivityIndicator.h"
#import "SharedDocumentHandler.h"
#import "Tag+Flickr.h"  

@interface FlickrPhotoTagsTVC ()

@end

@implementation FlickrPhotoTagsTVC

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Image"]) {
                [self sendDataforIndexPath:indexPath
                          toViewController:segue.destinationViewController];
            }
        }
    }
}

- (void)setTag:(Tag *)tag
{
    _tag = tag;
    if ([tag.name isEqualToString:ALL_TAGS_STRING]) {
        self.title = @"All";
    } else {
        self.title = [tag.name capitalizedString];
    }
    [self setupFetchedResultsViewController];
}

- (void)setupFetchedResultsViewController
{
    if (self.tag.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];
        NSString *sectionNameKeyPath = @"firstLetter";
        if ([self.tag.name isEqualToString:ALL_TAGS_STRING]) {
            request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"tagsString"
                                                                      ascending:YES],
                                        [request.sortDescriptors lastObject]];
            sectionNameKeyPath = @"tagsString";
        }
        request.predicate = [NSPredicate predicateWithFormat:@"%@ in tags", self.tag];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.tag.managedObjectContext
                                                                              sectionNameKeyPath:sectionNameKeyPath
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (void)sendDataforIndexPath:(NSIndexPath *)indexPath toViewController:(UIViewController *)vc
{
    if ([vc respondsToSelector:@selector(setImageURL:)]) {
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [Recent recentPhoto:photo];
        [vc performSelector:@selector(setImageURL:) withObject:[NSURL URLWithString:photo.imageURL]];
        [vc performSelector:@selector(setTitle:) withObject:photo.title];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tags Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    cell.imageView.image = [UIImage imageWithData:photo.thumbnail];
    if (!cell.imageView.image) {
        dispatch_queue_t queue = dispatch_queue_create("get thumbnail", 0);
        dispatch_async(queue, ^{
            NSData *thumbnailData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]];
            photo.thumbnail = thumbnailData;
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell setNeedsLayout];
            });
        });
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [photo.managedObjectContext performBlock:^{
            [photo delete];
            [[SharedDocumentHandler sharedDocumentHandler] saveDocument];
        }];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self sendDataforIndexPath:indexPath
              toViewController:[self.splitViewController.viewControllers lastObject]];
}


@end
