//
//  SecondViewController.m
//  CityGame
//
//  Created by Wim on 15/12/12.
//  Copyright (c) 2012 Wim. All rights reserved.
//

#import "AppDelegate.h"
#import "LogViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SecondViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"//custom album
#import "NSDataAdditions.h"
@interface SecondViewController ()

@end

@implementation SecondViewController
@synthesize imageView=_imageView;
@synthesize library;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.library = [[ALAssetsLibrary alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setBtnSend:nil];
    self.library = nil;
    [super viewDidUnload];
}

- (IBAction)btnPhoto:(id)sender {
    //Controleren of het device over een camera beschikt
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.editing = YES;
        imagePickerController.delegate = (id)self;
        
        [self presentModalViewController:imagePickerController animated:YES];
        //Het gaat om een nieuwe foto dus moet opgeslagen worden
        newMedia = YES;
    }
}


//getrokken foto's te bekijken
- (IBAction)btnPicker:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        //source is de photo library
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  nil];
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker animated:YES];
        //Niet nodig om foto op te slagen
        newMedia = NO;
    }
}


- (IBAction)btnSend:(id)sender {
    NSDate *methodStart = [NSDate date];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSNumber *player = appDelegate.playerID;
    
    NSNumber *task = appDelegate.taskID;
    NSString *photo = [self getStringFromImage:_imageView.image];
    
    // timen hoe lang het duurde om de foto te converteren
    NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:methodStart];
    [LogViewController logMethodDuration:executionTime :@"foto converteren"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://webservice.citygamephl.be/CityGameWS/resources/generic/sendPhoto"]];
    [request setPostValue:player forKey:@"playerID"];
    [request setPostValue:task forKey:@"taskID"];
    [request setPostValue:photo forKey:@"photo"];
    [request setPostValue:FALSE forKey:@"groupPhoto"];
    [request setPostValue:FALSE forKey:@"photoPrey"];
    [request setPostValue:appDelegate.role forKey:@"roleName"];
    
    
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        if([response isEqualToString:@"false"]){
            [LogViewController logMethodDuration:9 :@"Foto doorsturen mislukt!"];
        }
        
        NSLog(@"%@", response);
    } else {
        NSLog(@"error: %@", error);
        [LogViewController logMethodDuration:9 :error.description];
    }
    
    executionTime = [[NSDate date] timeIntervalSinceDate:methodStart];
    [LogViewController logMethodDuration:executionTime :@"Totaal foto doorsturen"];
    
}

//afbeelding naar string converteren
-(NSString *)getStringFromImage:(UIImage *)image{
	if(image){
        //kwaliteit van foto kleiner maken
        image = [UIImage imageWithCGImage:image.CGImage scale:0.25 orientation:image.imageOrientation];
		NSData *dataObj = UIImagePNGRepresentation(image);
		return [dataObj base64Encoding];
	} else {
		return @"";
	}
}


//image picker delegate control implementeren
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
    [self dismissModalViewControllerAnimated:YES];
    //kijken of het om het type foto gaat
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info
                          objectForKey:UIImagePickerControllerOriginalImage];
        //De foto weergeven in het tabblad foto
        _imageView.image = image;
        _btnSend.enabled=TRUE;
        //als het een nieuwe foto is, deze opslagen
        //finishedSavingWithError wordt opgeroepen na het al dan niet succesvol opslagen van de foto
        if (newMedia)
            [self.library saveImage:image toAlbum:@"City game" withCompletionBlock:^(NSError *error) {
                if (error!=nil) {
                    NSLog(@"Big error: %@", [error description]);
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle: @"Save failed"
                                          message: @"Failed to save image"\
                                          delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                    [alert show];
                }
            }];
        
        [picker dismissModalViewControllerAnimated:NO];

    }
}

//Wanneer de gebruiker vanuit het camera scherm het nemen van de foto annuleerd
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
