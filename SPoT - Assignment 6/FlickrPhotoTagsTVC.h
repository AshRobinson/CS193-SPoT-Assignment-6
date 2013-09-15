//
//  FlickrPhotoTagsTVC.h
//  FlickrPlaces
//
//  Created by Ashley Robinson on 05/09/2013.
//  Copyright (c) 2013 Ashley Robinson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Tag.h"

@interface FlickrPhotoTagsTVC : CoreDataTableViewController

@property (nonatomic, strong) Tag *tag;

@end
