//
//  Utility.m
//  Tap'n'Share
//
//  Created by Nikhil Wali on 28/07/15.
//  Copyright (c) 2015 Nikhil Wali. All rights reserved.
//

#import "Reachability.h"
#import "Utility.h"
#import "Location.h"

static AppDelegate *_appDelegate = nil;

static Reachability *networkReachability = nil;

NSString * const HOSTNAME = @"www.google.com";

@implementation Utility

+ (AppDelegate *)appDelegateInstance {
    
    static dispatch_once_t once;
    
    dispatch_once(&once, ^ {
        
        _appDelegate = [UIApplication sharedApplication].delegate;
        
    });
    
    return _appDelegate;
    
}

+ (void)showAlertWithTitle:(NSString *)titleString message:(NSString *)messageString controller:(id)sender completionBlock:(actionBlock)actionHandlerBlock {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:titleString message:messageString preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        actionHandlerBlock(action);
        
    }];
    
    [alertController addAction:okAction];
    
    [sender presentViewController:alertController animated:YES completion:nil];
    
}

+ (BOOL)isInternetConnectivity {
    
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^{

        networkReachability = [Reachability reachabilityWithHostName:HOSTNAME];
        
    });
    
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

    if (networkStatus == NotReachable) {
        
        NSLog(@"There IS NO internet connection");
        
        return NO;
        
    }
    
    NSLog(@"There IS internet connection");
    
    return YES;
    
}

+ (void)changeLastLocationFlagForUser:(User *)user {
    
    NSArray *locations = user.locations.allObjects;
    
    for (Location *loc in locations) {
        
        loc.isLastShareLocation = @(0);
        
    }
    
}

@end
