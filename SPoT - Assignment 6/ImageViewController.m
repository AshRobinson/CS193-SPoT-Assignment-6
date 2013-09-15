//
//  ImageViewController.m
//  FlickrPlaces
//
//  Created by Ashley Robinson on 05/09/2013.
//  Copyright (c) 2013 Ashley Robinson. All rights reserved.
//

#import "ImageViewController.h"
#import "NetworkActivityIndicator.h"
#import "FlickrCache.h"

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonTitle;
@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ImageViewController

-(void) awakeFromNib
{
    self.splitViewController.delegate = self;
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.splitViewBarButtonItem = nil;
}

-(void)splitViewController:(UISplitViewController *)svc
    willHideViewController:(UIViewController *)aViewController
         withBarButtonItem:(UIBarButtonItem *)barButtonItem
      forPopoverController:(UIPopoverController *)pc
{
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:barButtonItem.target action:barButtonItem.action];
    
    barButtonItem = barButton;
    self.splitViewBarButtonItem = barButton;
    
}

-(void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *barButtonItems = [self.toolBar.items mutableCopy];
    if (_splitViewBarButtonItem){
        [barButtonItems removeObject:_splitViewBarButtonItem];
    }
    if (splitViewBarButtonItem) {
        [barButtonItems insertObject:splitViewBarButtonItem atIndex:0];
    }
    self.toolBar.items = barButtonItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

- (void)setTitle:(NSString *)title
{
    super.title = title;
    self.barButtonTitle.title= title;
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        
        
        if (!self.imageURL) return;
        [self.spinner startAnimating];
        NSURL *imageURL = self.imageURL;
        dispatch_queue_t queue = dispatch_queue_create("Get Photo", NULL);
        dispatch_async(queue, ^{
            NSData *imageData;
            NSURL *cachedURL = [FlickrCache cachedURLforURL:imageURL];
            if (cachedURL){
                imageData = [[NSData alloc] initWithContentsOfURL:cachedURL];
            } else {
                [NetworkActivityIndicator start];
                imageData = [[NSData alloc] initWithContentsOfURL:self.imageURL];
                [NetworkActivityIndicator stop];
            }
            [FlickrCache cacheImageData:imageData forURL:self.imageURL];

            if (self.imageURL == imageURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [[UIImage alloc] initWithData:imageData];
                    if (image) {
                        [self setZoomScaleToFillScreen];
                        self.scrollView.contentSize = image.size;
                        self.imageView.image = image;
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                    }
                    [self.spinner stopAnimating];
                });
            }
        });
    }
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _imageView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    self.barButtonTitle.title = self.title;
    [self handleSplitViewBarButtonItem:self.splitViewBarButtonItem];
    //[self resetImage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resetImage];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.imageView.image = nil;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self setZoomScaleToFillScreen];
}

- (void)setZoomScaleToFillScreen
{
    double wScale = self.scrollView.bounds.size.width / self.imageView.image.size.width;
    double hScale = self.scrollView.bounds.size.height / self.imageView.image.size.height;
    if (wScale > hScale) self.scrollView.zoomScale = wScale;
    else self.scrollView.zoomScale = hScale;
}

@end
