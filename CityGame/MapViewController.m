//
//  MapViewController.m
//  CityGame
//
//  Created by Sven Timmermans on 6/02/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //defines the background queue

#import "AppDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "LogViewController.h"
//annotation klassen importeren
#import "JagerAnnotation.h"
#import "ProoiAnnotation.h"
#import "SqliteDb.h"
#import "WebserviceConnection.h" //WS klasse importeren
#import "CheckInternetConnection.h"
#import "MapViewController.h"

@interface MapViewController ()
@property CLLocationCoordinate2D userLocation;

@end

@implementation MapViewController

@synthesize userLocation = _userLocation;
SqliteDb *dbConnection;
CheckInternetConnection *internetCon;

//variabele om te controleren of er internet verbinding is of niet
bool internetConnection;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.mapView.delegate = self;
    
    // the interval with which all locations will be updated
    int seconds = 10;
    //NSTimer *interval =
    // boolean that will hold whether an uploaded image was approved or not
    Boolean approved = true;
    if (approved==true){
        [NSTimer scheduledTimerWithTimeInterval:seconds target:self
                                       selector:@selector(tick) userInfo:nil repeats:YES];
    }
    //database aanmaken indien nodig
    dbConnection = [[SqliteDb alloc]init];
    [dbConnection createDB];
    
    internetCon = [[CheckInternetConnection alloc] init];
}

-(void)clear{
    //deletes the previous annotations on the map
    [self.mapView removeAnnotations:self.mapView.annotations];
}

-(void)tick{
    NSDate *methodStart = [NSDate date];
    
    // calls the function to empty the map
    [self clear];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    internetConnection = [internetCon isConnectionAvailable];
    //als er geen internet connectie is moeten den punten in een sqlite databank opgeslagen worden
    if(internetConnection==TRUE){
        // makes the background queue and calls the fetched data function for the hunters
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL:
                            [NSURL URLWithString:[NSString stringWithFormat:@"http://webservice.citygamephl.be/CityGameWS/resources/generic/getLocations/%@/%@/Jager",appDelegate.gameID, appDelegate.playerID]]];
            
            //times how long fetching the data cost
            NSDate *methodEnd = [NSDate date];
            NSTimeInterval executionTime = [methodEnd timeIntervalSinceDate:methodStart];
            [LogViewController logMethodDuration:executionTime :@"jagers opvragen"];
            
            
            [self performSelectorOnMainThread:@selector(hunterData:) withObject:data waitUntilDone:YES];
            
            // times how long displaying the data cost
            methodEnd = [NSDate date];
            executionTime = [methodEnd timeIntervalSinceDate:methodStart];
            [LogViewController logMethodDuration:executionTime :@"Totaal jagers"];
        });
        
        methodStart = [NSDate date];
        
        // sets up the prey connection
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL:
                            [NSURL URLWithString:[NSString stringWithFormat:@"http://webservice.citygamephl.be/CityGameWS/resources/generic/getLocations/%@/%@/Prooi",appDelegate.gameID, appDelegate.playerID]]];
            NSDate *methodEnd = [NSDate date];
            NSTimeInterval executionTime = [methodEnd timeIntervalSinceDate:methodStart];
            [LogViewController logMethodDuration:executionTime :@"prooi opvragen"];
            [self performSelectorOnMainThread:@selector(preyData:) withObject:data waitUntilDone:YES];
            
            // times how long displaying the data cost
            methodEnd = [NSDate date];
            executionTime = [methodEnd timeIntervalSinceDate:methodStart];
            [LogViewController logMethodDuration:executionTime :@"Totaal prooi"];
        });
    }
    
}

- (void)hunterData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSArray* json = [NSJSONSerialization
                     JSONObjectWithData:responseData //1
                     
                     options:kNilOptions
                     error:&error];
    
    for (NSDictionary *user in json) {
        // Gets the values of the prey (there should only be one, so the for loop shouldn't be necessary
        NSString* name = [user objectForKey:@"player"];
        NSNumber* longitude = [user objectForKey:@"longitude"];
        NSNumber* latitude = [user objectForKey:@"latitude"];
        
        // logs the data
        NSLog(@"%@ is at longitude: %@ and latitude: %@", name, longitude, latitude);
        
        // adds the location to the map
        JagerAnnotation *jager = [[JagerAnnotation alloc] init];
        jager.titel = @"Groep1";
        jager.subTitel= name;
        CLLocationCoordinate2D test;
        test.latitude = [latitude doubleValue];
        test.longitude = [longitude doubleValue];
        jager.coordinaat = test;
        
        [self.mapView addAnnotation:jager];
    }
}

- (void)preyData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSArray* json = [NSJSONSerialization
                     JSONObjectWithData:responseData //1
                     
                     options:kNilOptions
                     error:&error];
    
    for (NSDictionary *user in json) {
        // Gets the values of the different hunters
        NSString* name = [user objectForKey:@"player"];
        NSNumber* longitude = [user objectForKey:@"longitude"];
        NSNumber* latitude = [user objectForKey:@"latitude"];
        
        // logs the data
        NSLog(@"%@ is at longitude: %@ and latitude: %@", name, longitude, latitude);
        
        // adds the location to the map
        CLLocationCoordinate2D test;
        
        ProoiAnnotation *prooi = [[ProoiAnnotation alloc] init];
        prooi.titel = @"Konijntje";
        prooi.subTitel= name;
        test.latitude = [latitude doubleValue];
        test.longitude = [longitude doubleValue];
        prooi.coordinaat = test;
        [self.mapView addAnnotation:prooi];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showLocation
{
    //Dwingt de kaart zich te beperken tot een regio van 800 op 800 rond de locatie van de gebruiker
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance
    (_userLocation, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region]
                   animated:YES];
}

//User locatie wordt geupdate
-	(void)mapView:(MKMapView *)mapView didUpdateUserLocation:
(MKUserLocation *)userLocation
{
    _userLocation = userLocation.coordinate;
    
    //Punt toevoegen aan de kaart
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(50.9377, 5.3458);
    //titel en subtitel geven aan het punt
    point.title = @"Me";
    point.subtitle = @"You are here!";
    
    [self.mapView addAnnotation:point];
    internetConnection = [internetCon isConnectionAvailable];
    //als er geen internet connectie is moeten den punten in een sqlite databank opgeslagen worden
    if(internetConnection!=TRUE){
        [dbConnection saveData:userLocation.coordinate.longitude :userLocation.coordinate.latitude];
    }else{
        //locatie van de speler naar de webservice sturen
        
        // creates the variables for posting since we don't have a login attached
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSNumber *playerID = appDelegate.playerID;
        NSNumber *gameID = appDelegate.gameID;
        NSNumber *latitude = [NSNumber numberWithDouble:_userLocation.latitude];
        NSNumber *longitude = [NSNumber numberWithDouble:_userLocation.longitude];
        
        // creates the request for the post method
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://webservice.citygamephl.be/CityGameWS/resources/generic/setPlayerCoordinate"]];
        [request setPostValue:playerID forKey:@"playerID"];
        [request setPostValue:gameID forKey:@"gameID"];
        [request setPostValue:latitude forKey:@"latitude"];
        [request setPostValue:longitude forKey:@"longitude"];
        
        //executes
        [request startSynchronous];
        NSError *error = [request error];
        if (!error) {
            NSString *response = [request responseString];
            NSLog(@"%@", response);
        } else {
            NSLog(@"error: %@", error);
        }
        
    }
    //[dbConnection sendLocations];
}

//methode wwordt opgeroepen bij plaatsen van pin op kaart
-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *pinView = nil;
    //controleren of de annotatie == locatie gebruiker
    if(annotation != _mapView.userLocation)
    {
        if ([annotation isKindOfClass:[JagerAnnotation class]]) // Indien om het om een jager gaat
        {
            static NSString *defaultPinID = @"com.invasivecode.pin";
            pinView = (MKAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
            if ( pinView == nil )
                pinView = [[MKAnnotationView alloc]
                           initWithAnnotation:annotation reuseIdentifier:defaultPinID];
            
            //pinView.pinColor = MKPinAnnotationColorGreen;
            pinView.canShowCallout = YES;
            //pinView.animatesDrop = YES;
            //de pin een custom image toewijzen
            pinView.image = [UIImage imageNamed:@"Elmer-Fudd-Hunting-icon.png"];
        }else if ([annotation isKindOfClass:[ProoiAnnotation class]]){ //Als het om de prooi gaat
            static NSString *defaultPinID = @"com.invasivecode.pin";
            pinView = (MKAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
            if ( pinView == nil )
                pinView = [[MKAnnotationView alloc]
                           initWithAnnotation:annotation reuseIdentifier:defaultPinID];
            
            //pinView.pinColor = MKPinAnnotationColorGreen;
            pinView.canShowCallout = YES;
            //pinView.animatesDrop = YES;
            pinView.image = [UIImage imageNamed:@"Prooi.png"];            }
    }
    else {
        [_mapView.userLocation setTitle:@"Ik ben hier"];
    }
    return pinView;
}

- (IBAction)clearMap:(id)sender {
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
}

- (IBAction)refresh:(id)sender {
    [self showLocation];
}
@end
