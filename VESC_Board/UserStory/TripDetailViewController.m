//
//  TripDetailViewController.m
//  vesc
//
//  Created by Rene Sijnke on 03/03/2017.
//  Copyright © 2017 Rene Sijnke. All rights reserved.
//

#import "TripDetailViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "VSCDataStore.h"
#import "VSCStatsHelper.h"


@interface TripDetailViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *paceLabel;

@property int seconds;
@property float distance;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation TripDetailViewController


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mapView.delegate = self;
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.stopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    self.timeLabel.textColor = [UIColor whiteColor];
    self.distanceLabel.textColor = [UIColor whiteColor];
    self.paceLabel.textColor = [UIColor whiteColor];
    
    self.timeLabel.text = @"";
    self.distanceLabel.text = @"";
    self.paceLabel.text = @"";
    
    [self updateView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.trip) {
        [self.mapView setRegion:[self mapRegion]];
        // make the line(s!) on the map
        [self.mapView addOverlay:[self polyLine]];
        
        self.timeLabel.text = [NSString stringWithFormat:@"Time: %@",  [VSCStatsHelper stringifySecondCount:self.trip.duration usingLongFormat:NO]];
        self.distanceLabel.text = [NSString stringWithFormat:@"Distance: %@", [VSCStatsHelper stringifyDistance:self.trip.distance]];
        self.paceLabel.text = [NSString stringWithFormat:@"Pace: %@",  [VSCStatsHelper stringifyAvgPaceFromDist:self.trip.distance overTime:self.trip.duration]];
    } else {
        if (self.locationManager == nil) {
            [self startLocationUpdates];
        }
    }
}


-(void)setStatus:(VSCTripStatus)status {
    _status = status;
    
    if (self.status == VSCTripStatusRunning) {
        self.seconds = 0;
        self.distance = 0;
        self.locations = [NSMutableArray array];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self
                                                    selector:@selector(eachSecond) userInfo:nil repeats:YES];
        
        if (self.locationManager == nil) {
            [self startLocationUpdates];
        }
        
    } else if(self.status == VSCTripStatusStopped) {
        [self.locationManager stopUpdatingLocation];
        
        if (self.locations.count > 0) {
            [self saveTrip];
        }
    }
    
    [self updateView];
    
}

-(void)updateView {
    self.timeLabel.hidden = self.status == VSCTripStatusWaiting;
    self.distanceLabel.hidden = self.status == VSCTripStatusWaiting;
    self.paceLabel.hidden = self.status == VSCTripStatusWaiting;
    
    self.startButton.hidden = self.status == VSCTripStatusReview || self.status == VSCTripStatusRunning;
    self.stopButton.hidden = self.status == VSCTripStatusReview || self.status == VSCTripStatusWaiting;
    self.closeButton.hidden = self.status == VSCTripStatusRunning;
}

#pragma mark - Trip timers 

- (void)eachSecond {
    self.seconds++;
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %@",  [VSCStatsHelper stringifySecondCount:self.seconds usingLongFormat:NO]];
    self.distanceLabel.text = [NSString stringWithFormat:@"Distance: %@", [VSCStatsHelper stringifyDistance:self.distance]];
    self.paceLabel.text = [NSString stringWithFormat:@"Pace: %@",  [VSCStatsHelper stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
}

#pragma mark - Trip locations

- (void)startLocationUpdates {
    // Create the location manager if this object does not
    // already have one.
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    // Movement threshold for new events.
    self.locationManager.distanceFilter = 10; // meters
    
    [self.locationManager startUpdatingLocation];
}

#pragma mark - Trip status

- (void)saveTrip {
    
    VSCTrip *newTrip = [VSCTrip newObject];
    VSCStatsHelper *helper = [VSCStatsHelper sharedInstance];
    
    newTrip.distance = self.distance;
    newTrip.duration = self.seconds;
    newTrip.timestamp = [NSDate date];
    newTrip.amphours = helper.maxAmpHours;
    
    NSMutableArray *locationArray = [NSMutableArray array];
    for (CLLocation *location in self.locations) {
        VSCLocation *locationObject = [VSCLocation newObject];
        
        locationObject.timestamp = location.timestamp;
        locationObject.latitude = location.coordinate.latitude;
        locationObject.longitude = location.coordinate.longitude;
        [locationArray addObject:locationObject];
    }
    
    newTrip.locations = [NSOrderedSet orderedSetWithArray:locationArray];
    self.trip = newTrip;
    
    [[VSCDataStore sharedInstance] saveContext];
    
    
    [self.mapView setRegion:[self mapRegion]];
    // make the line(s!) on the map
    [self.mapView addOverlay:[self polyLine]];
}

#pragma mark - Location delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    if (self.status == VSCTripStatusWaiting && locations.count > 0) {
        [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(locations.firstObject.coordinate, 500, 500) animated:YES];
        return;
    }
    
    for (CLLocation *newLocation in locations) {
        NSDate *eventDate = newLocation.timestamp;
        
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
            
            // update distance
            if (self.locations.count > 0) {
                self.distance += [newLocation distanceFromLocation:self.locations.lastObject];
                
                CLLocationCoordinate2D coords[2];
                coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
                coords[1] = newLocation.coordinate;
                
                MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500);
                [self.mapView setRegion:region animated:YES];
                
                [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
            }
            
            [self.locations addObject:newLocation];
        }
    }
    
}

#pragma mark - User interaction

- (IBAction)onStartPressed:(id)sender {
    [self setStatus:VSCTripStatusRunning];
}

- (IBAction)onStopPressed:(id)sender {
    [self setStatus:VSCTripStatusStopped];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClosePressed:(id)sender {
    [self.locationManager stopUpdatingLocation];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Setters

-(void)setTrip:(VSCTrip *)trip {
    
    if (_trip != trip) {
        _trip = trip;
        [self setStatus:VSCTripStatusReview];
    }
}

#pragma mark - Map

- (MKCoordinateRegion)mapRegion {
    
    MKCoordinateRegion region;
    VSCLocation *initialLoc = self.trip.locations.firstObject;
    
    float minLat = initialLoc.latitude;
    float minLng = initialLoc.longitude;
    float maxLat = initialLoc.latitude;
    float maxLng = initialLoc.longitude;
    
    for (VSCLocation *location in self.trip.locations) {
        if (location.latitude < minLat) {
            minLat = location.latitude;
        }
        if (location.longitude < minLng) {
            minLng = location.longitude;
        }
        if (location.latitude > maxLat) {
            maxLat = location.latitude;
        }
        if (location.longitude > maxLng) {
            maxLng = location.longitude;
        }
    }
    
    region.center.latitude = (minLat + maxLat) / 2.0f;
    region.center.longitude = (minLng + maxLng) / 2.0f;
    
    region.span.latitudeDelta = (maxLat - minLat) * 1.1f; // 10% padding
    region.span.longitudeDelta = (maxLng - minLng) * 1.1f; // 10% padding
    
    return region;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = [UIColor blueColor];
        aRenderer.lineWidth = 3;
        return aRenderer;
    }
    return nil;
}



- (MKPolyline *)polyLine {
    
    CLLocationCoordinate2D coords[self.trip.locations.count];
    
    for (int i = 0; i < self.trip.locations.count; i++) {
        VSCLocation *location = [self.trip.locations objectAtIndex:i];
        coords[i] = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    }
    
    return [MKPolyline polylineWithCoordinates:coords count:self.trip.locations.count];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
