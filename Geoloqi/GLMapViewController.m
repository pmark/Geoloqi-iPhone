//
//  MapViewController.m
//  Geoloqi
//
//  Created by Justin R. Miller on 6/8/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import "GLMapViewController.h"
#import "GLMutablePolyline.h"
#import "GLMutablePolylineView.h"
#import "ASIHTTPRequest.h"
#import "CJSONDeserializer.h"

@implementation GLMapViewController

@synthesize map;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/
- (void)viewDidLoad {
	[super viewDidLoad];

	// Set when the view loads, this is the first time the map has been viewed.
	// The map will center on the user's location as soon as it's received
	firstLoad = YES;
	
	// TODO: Make this use [GLAuthenticationManager callAPIPath] instead
	
	ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:
						   [NSURL URLWithString:
							[NSString stringWithFormat:
							 @"http://fakeapi.local/1/location/history?count=200&thinning=3&oauth_token=%@",
							 gAppDelegate.locationUpdateManager.deviceKey]]];
	req.delegate = self;
	[req startAsynchronous];
	
	NSLog(@"MapDidLoad");
	
	// Observe our own location manager for updates
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(locationUpdated:)
												 name:GLLocationUpdateManagerDidUpdateLocationNotification
											   object:nil];
	
	// Observe the map for location updates
	[map.userLocation addObserver:self  
					   forKeyPath:@"location"  
						  options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)  
						  context:NULL];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	
	line = [[GLMutablePolyline alloc] init];
	[map addOverlay:line];
	
	if (![request error]) {
		NSData *json = [request responseData];
		NSError *err = nil;
		NSDictionary *points = [[CJSONDeserializer deserializer] deserializeAsDictionary:json
																				   error:&err];
		if (points) {
			for (NSDictionary *point in [points objectForKey:@"points"]) {
				if ( ! [[point valueForKeyPath:@"location.position.horizontal_accuracy"] isEqual:[NSNull null]] &&
                    [[point valueForKeyPath:@"location.position.horizontal_accuracy"] doubleValue] < 100) {
					CLLocationCoordinate2D coord;
					coord.latitude = [[point valueForKeyPath:@"location.position.latitude"] doubleValue];
					coord.longitude = [[point valueForKeyPath:@"location.position.longitude"] doubleValue];
					[line addCoordinate:coord];
				}
			}
			[lineView setNeedsDisplayInMapRect:line.boundingMapRect];
		}
	}
	
    if ( ! MKMapRectIsNull(line.boundingMapRect))
        [map setRegion:MKCoordinateRegionForMapRect(line.boundingMapRect)
              animated:YES];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Failed to get most recent 200 points: %@", [request error]);
}

// This method is called when our internal location manager receives a new point
- (void)locationUpdated:(NSNotification *)theNotification {
	CLLocation *newLoc = gAppDelegate.locationUpdateManager.currentLocation;

	// add new location to polyline
	MKMapRect updateRect = [line addCoordinate:newLoc.coordinate];
	if (!MKMapRectIsNull(updateRect)) {
		//NSLog(@"Setting needs display in %@ on %@", MKStringFromMapRect(updateRect), lineView);
		[lineView setNeedsDisplayInMapRect:updateRect];
	}
}

// When the map view receives its location, this method is called
// This is separate from our internal location manager with the on/off switch
- (void)observeValueForKeyPath:(NSString *)keyPath 
					  ofObject:(id)object 
						change:(NSDictionary *)change 
					   context:(void *)context {

	if(firstLoad && map.userLocation)
    {
        [self zoomMapToLocation:map.userLocation.location];
		firstLoad = NO;
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView
			viewForOverlay:(id <MKOverlay>)overlay {
	
	if ([overlay isKindOfClass:[GLMutablePolyline class]]) {
		if (!lineView) {
			lineView = [[GLMutablePolylineView alloc] initWithOverlay:overlay];
		}
		return lineView;
	}
	
	return nil;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)zoomMapToLocation:(CLLocation *)location
{
    MKCoordinateSpan span;
    span.latitudeDelta  = 0.03;
    span.longitudeDelta = 0.03;
    
    MKCoordinateRegion region;
    
    [map setCenterCoordinate:location.coordinate animated:YES];
    
    region.center = location.coordinate;
    region.span   = span;
    
    [map setRegion:region animated:YES];
}


- (void)dealloc {
	[lineView release];
	[line release];
	[map release];
    [super dealloc];
}


@end
