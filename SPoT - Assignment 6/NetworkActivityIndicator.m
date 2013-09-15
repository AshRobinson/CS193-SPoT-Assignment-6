//
//  NetworkActivityIndicator.m
//  FlickrPlaces
//
//  Created by Ashley Robinson on 12/09/2013.
//  Copyright (c) 2013 Ashley Robinson. All rights reserved.
//

#import "NetworkActivityIndicator.h"

@implementation NetworkActivityIndicator

+ (void)start
{
    [self counterChange:1];
}

+ (void)stop
{
    [self counterChange:-1];
}

+ (void)counterChange:(NSUInteger)change
{
    static NSUInteger counter = 0;
    static dispatch_queue_t queue;
    if (!queue) {
        queue = dispatch_queue_create("NetworkActivityIndicator Queue", NULL);
    }
    dispatch_sync(queue, ^{
        if (counter + change <= 0) {
            counter = 0;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        } else {
            counter += change;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
    });
}

@end
