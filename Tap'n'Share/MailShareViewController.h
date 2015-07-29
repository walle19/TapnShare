//
//  MailShareViewController.h
//  Tap'n'Share
//
//  Created by Nikhil Wali on 28/07/15.
//  Copyright (c) 2015 Nikhil Wali. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "User.h"

@interface MailShareViewController : UIViewController

@property (nonatomic, strong) NSDictionary *locationDetail;

@property (nonatomic, strong) User *user;

@end
