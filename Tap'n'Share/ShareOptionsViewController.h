//
//  ShareOptionsViewController.h
//  Tap'n'Share
//
//  Created by Nikhil Wali on 28/07/15.
//  Copyright (c) 2015 Nikhil Wali. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "User.h"

@interface ShareOptionsViewController : UIViewController

@property (nonatomic, strong) User *user;

@property (nonatomic, strong) NSDictionary *locationDetail;

@end
