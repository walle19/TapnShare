//
//  HomeViewController.m
//  Tap'n'Share
//
//  Created by Nikhil Wali on 28/07/15.
//  Copyright (c) 2015 Nikhil Wali. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "HomeViewController.h"
#import "ShareOptionsViewController.h"
#import "Location.h"

static CLLocationDistance latitudinalMeters = 800;
static CLLocationDistance longitudinalMeters = 800;

NSString * const ANNOTATION_TITLE = @"I am here!";

NSString * const LOGOUT_IMAGE_NAME = @"logout";
NSString * const REFRESH_IMAGE_NAME = @"refresh_black";

NSString * const SHARE_OPTIONS_STORYBOARD_ID = @"shareOptionsViewID";

NSString * const LOCATION_NOT_FOUND_TEXT = @"Location not found";

@interface HomeViewController () <MKMapViewDelegate> {
    
    CLLocationManager *_locationManager;
    
    CLGeocoder *_geocoder;
    
    CLPlacemark *_placemark;
    
}

@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) ShareOptionsViewController *shareOptionsViewController;

@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.appDelegate = [Utility appDelegateInstance];

    [self displayNavigationBar];    //setting up navigation bar for display
    
    [self showCurrentLocationOnMap];    //show current location of user on map
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    [self pinLastShareLocation];    //to pin last shared location on map

}

#pragma mark - Business logic

- (void)displayNavigationBar {
    
    self.navigationItem.title = APP_TITLE;

    UIBarButtonItem *logoutBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:LOGOUT_IMAGE_NAME] style:UIBarButtonItemStylePlain target:self action:@selector(logout)];

    self.navigationItem.rightBarButtonItems = @[logoutBarButtonItem];

    UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:REFRESH_IMAGE_NAME] style:UIBarButtonItemStylePlain target:self action:@selector(refreshLocation)];
    
    self.navigationItem.leftBarButtonItems = @[refreshBarButtonItem];
    
}

- (void)showCurrentLocationOnMap {
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;

    [self.mapView removeAnnotations:self.mapView.annotations];  //to remove all pins
    
    _geocoder = [[CLGeocoder alloc] init];
    
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager requestAlwaysAuthorization];

    [_locationManager startUpdatingLocation];
    
}

- (void)pinLastShareLocation {
    
    NSArray *locations = self.user.locations.allObjects;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isLastShareLocation == 1"];
    
    NSArray *lastSharedLocation = [locations filteredArrayUsingPredicate:predicate];
    
    Location *lastLocation = lastSharedLocation.firstObject;
    
    CLLocationDegrees latitude = lastLocation.latitude.doubleValue;
    CLLocationDegrees longitude = lastLocation.longitude.doubleValue;
    
    CLLocation *lastLocations = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    //add the annotation to last shared location
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    pointAnnotation.coordinate = lastLocations.coordinate;
    pointAnnotation.title = ANNOTATION_TITLE;
    
    [self.mapView addAnnotation:pointAnnotation];
    
}

- (void)logout {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)refreshLocation {
    
    if (!_locationManager) {
        
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager requestAlwaysAuthorization];
        
    }
    
    self.mapView.showsUserLocation = YES;

    [_locationManager startUpdatingLocation];
    
}

- (void)currentPlacemarkForLocation:(CLLocation *)location {
    
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        NSLog(@"Found placemarks: %@", placemarks);
        
        if (error != nil || !placemarks.count) {
            
            NSLog(@"%@", error.localizedDescription);
            
            return;
            
        }
        
        _placemark = [placemarks lastObject];
        
    } ];

}

#pragma mark - MKMapView Delegate Method

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    
    [Utility showAlertWithTitle:APP_TITLE message:error.localizedDescription controller:self completionBlock:^(UIAlertAction *action) {
        
        NSLog(@"Ok action");
        
    }];
    
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    
    [Utility showAlertWithTitle:APP_TITLE message:error.localizedDescription controller:self completionBlock:^(UIAlertAction *action) {
        
        NSLog(@"Ok action");
        
    }];
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    [self currentPlacemarkForLocation:userLocation.location];
    
    //zoom into the region of pin on map
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, latitudinalMeters, longitudinalMeters);
    
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    //add the annotation to current location
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    pointAnnotation.coordinate = userLocation.coordinate;
    pointAnnotation.title = ANNOTATION_TITLE;
    
    [self.mapView addAnnotation:pointAnnotation];
        
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if (![Utility isInternetConnectivity]) {
        
        [Utility showAlertWithTitle:APP_TITLE message:NO_INTERNET_TEXT controller:self completionBlock:^(UIAlertAction *action) {
            
            NSLog(@"Ok action");
            
        }];
        
        return;
        
    }
    
    if (!self.mapView.userLocation.location || _placemark.name.length == 0) {
        
        [Utility showAlertWithTitle:APP_TITLE message:LOCATION_NOT_FOUND_TEXT controller:self completionBlock:^(UIAlertAction *action) {
            
            NSLog(@"Ok action");
            
        }];
        
        return;
        
    }
    
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
    self.shareOptionsViewController = (ShareOptionsViewController *)[mystoryboard instantiateViewControllerWithIdentifier:SHARE_OPTIONS_STORYBOARD_ID];
    self.shareOptionsViewController.locationDetail = @{ LOCATION_NAME_KEY : _placemark.name, LOCATION_KEY : self.mapView.userLocation.location};

    self.shareOptionsViewController.user = self.user;
    
    [self.navigationController pushViewController:self.shareOptionsViewController animated:YES];
    
}

@end
