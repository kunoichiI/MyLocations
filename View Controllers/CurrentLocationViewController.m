//
//  CurrentLocationViewController.m
//  MyLocations
//
//  Created by Mingyuan Wang on 5/26/15.
//  Copyright (c) 2015 Mingyuan Wang. All rights reserved.
//

#import "CurrentLocationViewController.h"
#import "LocationDetailsViewController.h"
#import "NSMutableString+AddText.h"
#import <AudioToolbox/AudioServices.h>

@interface CurrentLocationViewController () <UITabBarControllerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *location;
@property (nonatomic) BOOL updatingLocation;
@property (nonatomic) NSError *lastLocationError;
@property (nonatomic) CLGeocoder *geocoder;
@property (nonatomic) CLPlacemark *placemark;
@property (nonatomic) BOOL performingReverseGeocoding;
@property (nonatomic) NSError *lastGeocodingError;
@property (nonatomic) UIButton *logoButton;
@property (nonatomic) BOOL logoVisible;
@property (nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation CurrentLocationViewController {
    SystemSoundID _soundID;
}

- (void)updateLabels
{
    if (self.location != nil) {
        self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.location.coordinate.latitude];
        self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.location.coordinate.longitude];
        self.tagButton.hidden = NO;
        self.messageLabel.text = @" ";
        self.latitudeTextLabel.hidden = NO;
        self.longitudeTextLabel.hidden = NO;
        
        if (self.placemark != nil) {
            self.addressLabel.text = [self stringFromPlacemark: self.placemark];
        } else if (self.performingReverseGeocoding){
            self.addressLabel.text = @"Searching for Address... ";
        } else if (self.lastGeocodingError != nil){
            self.addressLabel.text = @"Error Finding Address";
        } else {
            self.addressLabel.text  = @"No Address Found";
        }
    }
    else {
        self.latitudeLabel.text = @"";
        self.longitudeLabel.text = @"";
        self.addressLabel.text = @"";
        self.tagButton.hidden = YES;
        
        self.latitudeTextLabel.hidden = YES;
        self.longitudeTextLabel.hidden = YES;
        
        NSString *statusMessage;
        if (self.lastLocationError != nil ) {
            if ([self.lastLocationError.domain isEqualToString:kCLErrorDomain] && self.lastLocationError.code == kCLErrorDenied) {
                statusMessage = @"Location Services Disabled";
            }else {
                statusMessage = @"Error Getting Location";
            }
        }
        else if (! [CLLocationManager locationServicesEnabled]){
                    statusMessage = @"Location Services Disabled";
            } else if (self.updatingLocation){
                statusMessage = @"Searching...";
            } else {
                statusMessage = @" ";
                [self showLogoView];
            }
            self.messageLabel.text = statusMessage;
        }
}

-(NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
    NSMutableString *line1 = [NSMutableString stringWithCapacity:100];
    [line1 addText:thePlacemark.subThoroughfare withSeparator:@" "];
    [line1 addText:thePlacemark.thoroughfare withSeparator:@" "];
    
    NSMutableString *line2 = [NSMutableString stringWithCapacity:100];
    [line2 addText:thePlacemark.locality withSeparator:@" "];
    [line2 addText:thePlacemark.administrativeArea withSeparator:@" "];
    [line2 addText:thePlacemark.postalCode withSeparator:@" "];
    
    if ([line1 length] == 0) {
        [line2 appendString:@"\n"];
        return line2;
    } else {
        [line1 appendString:@"\n"];
        [line1 appendString:line2];
        return line1;
    }
}

-(void)addText:(NSString *)text toLine:(NSMutableString *)line withSeparator:(NSString *)separator
{
    if (text != nil) {
        if ([line length] > 0) {
            [line appendString:separator];
        }
        [line appendString:text];
    }
}

-(void)confitureGetButton
{
    if (self.updatingLocation) {
        [self.getButton setTitle:@"Stop" forState:UIControlStateNormal];
        if (self.spinner == nil) {
            self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            self.spinner.center = CGPointMake(self.messageLabel.center.x, self.messageLabel.center.y + self.spinner.bounds.size.height/2.0f + 15.0f);
            [self.spinner startAnimating];
            [self.containerView addSubview:self.spinner];
        }
    } else {
        [self.getButton setTitle:@"Get My Location" forState:UIControlStateNormal];
        
        [self.spinner removeFromSuperview];
        self.spinner = nil;
    }
}

- (void)startLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [self.locationManager startUpdatingLocation];
        self.updatingLocation = YES;
        
        [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
    }
}


-(void)stopLocationManager
{
    if (self.updatingLocation) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
        
        [self.locationManager stopUpdatingLocation];
        self.locationManager.delegate = nil;
        self.updatingLocation = NO;
    }
}

-(void)didTimeOut:(id)obj
{
    //NSLog(@"*** Time out");
    
    if (self.location == nil) {
        [self stopLocationManager];
        
        self.lastLocationError = [NSError errorWithDomain:@"MyLocationsErrorDomain" code:1 userInfo:nil];
        
        [self updateLabels];
        [self confitureGetButton];
    }
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.locationManager = [[CLLocationManager alloc]init];
        self.geocoder = [[CLGeocoder alloc] init];
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.delegate = self;
    self.tabBarController.tabBar.translucent = NO;
    [self loadSoundEffect];
   
}



- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self updateLabels];
    [self confitureGetButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)getLocation:(id)sender
{
    if (self.logoVisible) {
        [self hideLogoView];
    }
    if (self.updatingLocation) {
        [self stopLocationManager];
    }else {
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        self.location = nil;
        self.lastLocationError = nil;
        self.placemark = nil;
        self.lastGeocodingError = nil;
        
        [self startLocationManager];
    }
    [self updateLabels];
    [self confitureGetButton];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //NSLog(@"didFailWithError %@", error);
    
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    
    [self stopLocationManager];
    self.lastLocationError = error;
    
    [self updateLabels];
    [self confitureGetButton];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    
    //NSLog(@"didUpdateLocations %@", newLocation);
    
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
        return;
    }
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    CLLocationDistance distance = MAXFLOAT;
    if (self.location != nil) {
        distance = [newLocation distanceFromLocation:self.location];
    }
    
    if (self.location == nil || self.location.horizontalAccuracy > newLocation.horizontalAccuracy) {
        self.lastLocationError = nil;
        self.location = newLocation;
        [self updateLabels];
        
        if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
            //NSLog(@"*** We're done!");
            [self stopLocationManager];
            [self confitureGetButton];
            
            if (distance > 0) {
                self.performingReverseGeocoding = NO;
            }
        }
        
        if (! self.performingReverseGeocoding) {
            //NSLog(@"*** Going to geocode");
            
            self.performingReverseGeocoding = YES;
            [self.geocoder reverseGeocodeLocation:self.location  completionHandler:^(NSArray *placemarks, NSError *error) {
                //NSLog(@"*** Found placemarks: %@, error: %@", placemarks, error);
                self.lastGeocodingError = error;
                if (error == nil && [placemarks count] > 0) {
                    if (self.placemark == nil) {
                        NSLog(@"FIRST TIME!");
                        [self playSoundEffect];
                    }
                    self.placemark = [placemarks lastObject];
                }else {
                    self.placemark = nil;
                }
                self.performingReverseGeocoding = NO;
                [self updateLabels];
            }];
            
        } else if (distance < 1.0) {
            NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:self.location.timestamp];
            if (timeInterval > 10) {
                //NSLog(@"*** Force done!");
                [self stopLocationManager];
                [self updateLabels];
                [self confitureGetButton];
            }
        }
    }
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    tabBarController.tabBar.translucent = (viewController != self);
    return YES;
}

#pragma mark - Logo View

- (void)showLogoView
{
    if (self.logoVisible) {
        return;
    }
    self.logoVisible = YES;
    self.containerView.hidden = YES;
    
    self.logoButton = [ UIButton buttonWithType:UIButtonTypeCustom];
    [self.logoButton setBackgroundImage:[UIImage imageNamed:@"Logo"] forState:UIControlStateNormal];
    [self.logoButton sizeToFit];
    [self.logoButton addTarget:self action:@selector(getLocation:) forControlEvents:UIControlEventTouchUpInside];
    self.logoButton.center = CGPointMake(self.view.bounds.size.width / 2.0f, self.view.bounds.size.height / 2.0f - 49.0f);
    
    [self.view addSubview:self.logoButton];
}
-(void)hideLogoView
{
    self.logoVisible = NO;
    self.containerView.hidden = NO;
    
    self.containerView.center = CGPointMake(self.view.bounds.size.width * 2.0f, 40.0f + self.containerView.bounds.size.height /2.0f);
    
    CABasicAnimation *panelMover = [CABasicAnimation animationWithKeyPath:@"position"];
    panelMover.removedOnCompletion = NO;
    panelMover.fillMode = kCAFillModeForwards;
    panelMover.duration = 0.6;
    panelMover.fromValue = [NSValue valueWithCGPoint:self.containerView.center];
    panelMover.toValue = [NSValue valueWithCGPoint:CGPointMake(160.0f, self.containerView.center.y)];
    panelMover.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    panelMover.delegate = self;
    [self.containerView.layer addAnimation:panelMover forKey:@"panelMover"];
    
    CABasicAnimation *logoMover = [CABasicAnimation animationWithKeyPath:@"position"];
    logoMover.removedOnCompletion = NO;
    logoMover.fillMode = kCAFillModeForwards;
    logoMover.duration = 0.5;
    logoMover.fromValue = [NSValue valueWithCGPoint:self.logoButton.center];
    logoMover.toValue = [NSValue valueWithCGPoint:CGPointMake(-160.0f, self.logoButton.center.y)];
    logoMover.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self.logoButton.layer addAnimation:logoMover forKey:@"logoMOver"];
    
    CABasicAnimation *logoRotator = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    logoRotator.removedOnCompletion = NO;
    logoRotator.fillMode = kCAFillModeForwards;
    logoRotator.duration = 0.5;
    logoRotator.fromValue = @0.0f;
    logoRotator.toValue = @(-2.0f * M_PI);
    logoRotator.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self.logoButton.layer addAnimation:logoRotator forKey:@"logoRotator"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.containerView.layer removeAllAnimations];
    self.containerView.center = CGPointMake(self.view.bounds.size.width / 2.0f, 40.0f + self.containerView.bounds.size.height / 2.0f);
    
    [self.logoButton.layer removeAllAnimations];
    [self.logoButton removeFromSuperview];
    self.logoButton = nil;
}

#pragma mark - Sound Effect

- (void)loadSoundEffect
{
    NSString *path =[[NSBundle mainBundle] pathForResource:@"Sound.caf" ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
    if (fileURL == nil) {
        NSLog(@"NSURL is nil for path: %@", path);
        return;
    }
    OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &_soundID);
    if (error != kAudioServicesNoError) {
        NSLog(@"Error code %d loading sound at path: %@", (int)error,path);
        return;
    }
}

- (void)unloadSoundEffect
{
    AudioServicesDisposeSystemSoundID(_soundID);
    _soundID = 0;
}

- (void)playSoundEffect
{
    AudioServicesPlaySystemSound(_soundID);
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TagLocation"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        
        LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;
        
        controller.coordinate =self.location.coordinate;
        controller.placemark = self.placemark;
        controller.managedObjectContext = self.managedObjectContext;
    }
}

@end
