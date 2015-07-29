//
//  FacebookShareViewController.m
//  Tap'n'Share
//
//  Created by Nikhil Wali on 28/07/15.
//  Copyright (c) 2015 Nikhil Wali. All rights reserved.
//

#import <Social/Social.h>
#import <CoreLocation/CoreLocation.h>

#import "SocialNetworkShareViewController.h"
#import "Location.h"

NSString * const FACEBOOK_TITLE = @"Via FB";
NSString * const TWITTER_TITLE = @"Via Tweet";

NSString * const FACEBOOK_BACKGROUND_IMAGE_NAME = @"fb";
NSString * const TWITTER_BACKGROUND_IMAGE_NAME = @"twitter_birds";

NSString * const FACEBOOK_POST_BUTTON_TITLE = @"via Wall";
NSString * const TWITTER_POST_BUTTON_TITLE = @"via Tweet";

NSString * const IMAGE_ALERT_MESSAGE = @"Pick one";

NSString * const GALLERY_TITLE = @"Gallery";
NSString * const CAMERA_TITLE = @"Camera";
NSString * const CANCEL_TITLE = @"Cancel";

NSString * const PLACEHOLDER_IMAGE = @"placeholder";

@interface SocialNetworkShareViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate> {
    
    BOOL _isImagePresent;
    
}

@property (nonatomic, weak) IBOutlet UIImageView *previewImageView;

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, weak) IBOutlet UIButton *clearButton;
@property (nonatomic, weak) IBOutlet UIButton *postButton;

@property (nonatomic, strong) SLComposeViewController *slComposeViewController;

@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation SocialNetworkShareViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.appDelegate = [Utility appDelegateInstance];
    
    [self displayUI];
    
}

#pragma mark - Business logic

- (void)displayUI {
    
    self.clearButton.enabled = NO;
    _isImagePresent = NO;
    
    NSString *backgroundImageString;
    NSString *postButtonTitleString;
    NSString *navigationTitleString;
    
    // Facebook
    if (self.type == FacebookType){
        
        backgroundImageString = FACEBOOK_BACKGROUND_IMAGE_NAME;
        postButtonTitleString = FACEBOOK_POST_BUTTON_TITLE;
        navigationTitleString = FACEBOOK_TITLE;
        
    }
    // Twitter
    else {
        
        backgroundImageString = TWITTER_BACKGROUND_IMAGE_NAME;
        postButtonTitleString = TWITTER_POST_BUTTON_TITLE;
        navigationTitleString = TWITTER_TITLE;
        
    }
    
    self.navigationItem.title = navigationTitleString;
    
    self.backgroundImageView.image = [UIImage imageNamed:backgroundImageString];
    
    [self.postButton setTitle:postButtonTitleString forState:UIControlStateNormal];
    
    navigationTitleString = nil;
    postButtonTitleString = nil;
    backgroundImageString = nil;
    
}

#pragma mark - IBAction Method

- (IBAction)selfie:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:APP_TITLE message:IMAGE_ALERT_MESSAGE preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:GALLERY_TITLE style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        NSLog(@"Gallery selected");
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.delegate = weakSelf;
        [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
        
    }];
    
    [alertController addAction:galleryAction];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:CAMERA_TITLE style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        NSLog(@"Camera selected");
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = weakSelf;
        [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
        
    }];
    
    [alertController addAction:cameraAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CANCEL_TITLE style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (IBAction)postOnWall:(id)sender {
    
    if (![Utility isInternetConnectivity]) {
        
        [Utility showAlertWithTitle:APP_TITLE message:NO_INTERNET_TEXT controller:self completionBlock:^(UIAlertAction *action) {
            
            NSLog(@"Ok action");
            
        }];
        
        return;
        
    }
    
    NSString *shareLocationString = [NSString stringWithFormat:@"%@ %@", SHARE_LOCATION_TEXT, self.locationDetail[LOCATION_NAME_KEY]];
    
    NSString *composeTypeString;
    
    // Facebook
    if (self.type == FacebookType){
        
        composeTypeString = SLServiceTypeFacebook;
        
    }
    // Twitter
    else {

        composeTypeString = SLServiceTypeTwitter;
        
    }
    
    self.slComposeViewController = [SLComposeViewController composeViewControllerForServiceType:composeTypeString];
        
    [self.slComposeViewController setInitialText:shareLocationString];
        
    if (_isImagePresent) {
        
        [self.slComposeViewController addImage:self.previewImageView.image];
        
    }
    
    __weak typeof(self) weakSelf = self;
    
    [self.slComposeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
        
        __block BOOL success = NO;
        
        switch (result) {
            
            case SLComposeViewControllerResultCancelled:
                
                NSLog(@"Post Canceled");
                
                break;
                
            case SLComposeViewControllerResultDone:
                
                NSLog(@"Post Sucessful");
                
                success = YES;
                
                [Utility showAlertWithTitle:APP_TITLE message:@"Feed shared successfully" controller:weakSelf.slComposeViewController completionBlock:^(UIAlertAction *action) {
                    
                    NSLog(@"done");
                    
                }];
                
                break;
                
            default:
                NSLog(@"default");
                break;
        }
        
        if (success) {
            
            [Utility changeLastLocationFlagForUser:weakSelf.user];

            [weakSelf saveSharedLocationWithError:nil];
            
        }

    }];
    
    [self presentViewController:self.slComposeViewController animated:YES completion:Nil];

}

- (IBAction)clearSelfieImage:(id)sender {
    
    self.previewImageView.image = [UIImage imageNamed:PLACEHOLDER_IMAGE];
    
    self.clearButton.enabled = NO;
    
    _isImagePresent = NO;
    
}

#pragma mark - Database method

- (BOOL)saveSharedLocationWithError:(NSError *)error {
    
    NSManagedObjectContext *context = [self.appDelegate managedObjectContext];
    
    Location *location = (Location *)[NSEntityDescription insertNewObjectForEntityForName:LOCATION_ENTTY inManagedObjectContext:context];
    
    CLLocation *userLocation = self.locationDetail[LOCATION_KEY];
    
    location.latitude = @(userLocation.coordinate.latitude);
    location.longitude = @(userLocation.coordinate.longitude);
    location.isLastShareLocation = @(1);
    location.locationName = self.locationDetail[LOCATION_NAME_KEY];
    
    location.user = self.user;
    
    if (![context save:&error]) {
        
        return NO;
        
    }
    
    return YES;
    
}

#pragma mark - UIImagePickerControllerDelegate Method

/*
 This method is called when an image has been chosen from the library or taken from the camera.
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    NSLog(@"%@ %@", image, path);
    
    __weak typeof(self) weakSelf = self;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        _isImagePresent = YES;
        
        weakSelf.previewImageView.image = image;
        
        weakSelf.clearButton.enabled = YES;
        
    }];
    
}

@end
