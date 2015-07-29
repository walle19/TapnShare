//
//  ShareOptionsViewController.m
//  Tap'n'Share
//
//  Created by Nikhil Wali on 28/07/15.
//  Copyright (c) 2015 Nikhil Wali. All rights reserved.
//

#import "ShareOptionsViewController.h"
#import "MailShareViewController.h"
#import "SocialNetworkShareViewController.h"

NSString * const MAIL_SEGUE_ID = @"mailSegueID";
NSString * const FACEBOOK_SEGUE_ID = @"facebookSegueID";
NSString * const TWITTER_SEGUE_ID = @"twitterSegueID";

NSString * const NAVIGATION_TITLE = @"Share Via";

@interface ShareOptionsViewController ()

@property (nonatomic, strong) MailShareViewController *mailShareViewController;

@property (nonatomic, strong) SocialNetworkShareViewController *socialNetworkShareViewController;

@end

@implementation ShareOptionsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = NAVIGATION_TITLE;
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:MAIL_SEGUE_ID]) {
        
        self.mailShareViewController = segue.destinationViewController;
        self.mailShareViewController.user = self.user;
        self.mailShareViewController.locationDetail = self.locationDetail;
        
    }
    else {
        
        self.socialNetworkShareViewController = segue.destinationViewController;
        self.socialNetworkShareViewController.user = self.user;
        self.socialNetworkShareViewController.locationDetail = self.locationDetail;
        
        if ([segue.identifier isEqualToString:FACEBOOK_SEGUE_ID]) {
            
            self.socialNetworkShareViewController.type = FacebookType;
            
        }
        else if ([segue.identifier isEqualToString:TWITTER_SEGUE_ID]) {
            
            self.socialNetworkShareViewController.type = TwitterType;
            
        }
        
    }
    
}

@end
