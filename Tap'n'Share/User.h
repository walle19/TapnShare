//
//  User.h
//  Tap'n'Share
//
//  Created by Nikhil Wali on 29/07/15.
//  Copyright (c) 2015 Nikhil Wali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location;

@interface User : NSManagedObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) NSSet *locations;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addLocationsObject:(Location *)value;
- (void)removeLocationsObject:(Location *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

@end
