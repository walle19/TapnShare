//
//  Utility.h
//  Tap'n'Share
//
//  Created by Nikhil Wali on 28/07/15.
//  Copyright (c) 2015 Nikhil Wali. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppDelegate.h"
#import "User.h"

typedef void(^actionBlock)(UIAlertAction *);

@interface Utility : NSObject

/*!
 Single instance of appDelegate.
 @return instance of appDelegate
 */
+ (AppDelegate *)appDelegateInstance;

/*!
 Method to show alert
 @param NSString titleString
 @param NSString messageString
 @param id sender
 @param block actionHandlerBlock
 */
+ (void)showAlertWithTitle:(NSString *)titleString message:(NSString *)messageString controller:(id)sender completionBlock:(actionBlock)actionHandlerBlock;

/*!
 Method to check internet connectivity
 @retun BOOL
 */
+ (BOOL)isInternetConnectivity;

/*!
 Method to change flag for all shared locations related to user.
 @param User user
 */
+ (void)changeLastLocationFlagForUser:(User *)user;

@end
