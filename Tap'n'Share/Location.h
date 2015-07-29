//
//  Location.h
//  Tap'n'Share
//
//  Created by Nikhil Wali on 29/07/15.
//  Copyright (c) 2015 Nikhil Wali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Location : NSManagedObject

@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *isLastShareLocation;

@property (nonatomic, strong) NSString *locationName;

@property (nonatomic, strong) User *user;

@end
