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
#import "Photo.h"
#import "Recent+Photo.h"

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
    self.title = tag.name;
    [self setupFetchedResultsViewController];
}

- (void)setupFetchedResultsViewController
{
    if (self.tag.managedObjectContext){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"%@ in tags", self.tag];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.tag.managedObjectContext
                                                                              sectionNameKeyPath:nil
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
    
    
    return cell;
}



@end
