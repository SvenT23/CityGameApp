//
//  MapViewController.h
//  CityGame
//
//  Created by Sven Timmermans on 6/02/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)refresh:(id)sender;
- (IBAction)clearMap:(id)sender;


@end
