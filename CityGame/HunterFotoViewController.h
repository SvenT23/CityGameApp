//
//  HunterFotoViewController.h
//  CityGame
//
//  Created by Sven Timmermans on 7/02/13.
//  Copyright (c) 2013 Wim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface HunterFotoViewController : UIViewController
//NavigationController is nodig om naar het camerascherm te gaan
//ImagePicker gebruiken om genomen foto te selecteren
<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    UIImageView *imageView;
    //variabele om te bepalen of het om een nieuwe foto gaat of een reeds gemaakte foto
    BOOL newMedia;
}

//Nodig voor custom album
@property (strong, atomic) ALAssetsLibrary* library;

//actions
- (IBAction)btnPhoto:(id)sender;
- (IBAction)btnPicker:(id)sender;
- (IBAction)btnSend:(id)sender;

//outlets
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSend;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segment;


@end