//
//  Constant.h
//  Tap'n'Share
//
//  Created by Nikhil Wali on 28/07/15.
//  Copyright (c) 2015 Nikhil Wali. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 App Title
 */
extern NSString * const APP_TITLE;

/*!
 Database
 */
extern NSString * const USER_ENTTY;
extern NSString * const LOCATION_ENTTY;

/*!
 Storyboard
 */
extern NSString * const MAIN_STORYBOARD;

/*!
 Logged-in user
 */
extern NSString * const LOGGED_IN_USER;

/*!
 Location
 */
extern NSString * const LOCATION_KEY;
extern NSString * const LOCATION_NAME_KEY;

extern NSString * const SHARE_LOCATION_TEXT;

/*!
 Internet connectivity
 */
extern NSString * const NO_INTERNET_TEXT;

/*
 Social Network Type
 */
typedef NS_ENUM(NSInteger, SocialNetworkType) {
    FacebookType,
    TwitterType
};