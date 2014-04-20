//
//  RYRegisterViewController.m
//  Ryff
//
//  Created by Christopher Laganiere on 4/12/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

#import "RYRegisterViewController.h"

// Custom UI
#import "RYStyleSheet.h"
#import "UIViewController+Extras.h"
#import "UIImage+Thumbnail.h"
#import "UIImage+Color.h"
#import "BlockAlertView.h"

// Associated View Controllers
#import "RYRegister2ViewController.h"
#import "RYServices.h"
#import "RYLocationServices.h"

// Data Managers
#import "SSKeychain.h"

@interface RYRegisterViewController () <POSTDelegate, LocationDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *latitude;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end

@implementation RYRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Prep for keyboard notifications
    [self registerForKeyboardNotifications];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[RYLocationServices sharedInstance] requestLocationCoordinatesForDelegate:self];
    
    // style images
    [_avatarImageView.layer setCornerRadius:50.0f];
    [_avatarImageView setClipsToBounds:YES];
    
    [_submitButton.imageView setImage:[[UIImage imageNamed:@"next"] imageWithOverlayColor:[RYStyleSheet baseColor]]];
    
    //give avatar tap gesture recognizer
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)];
    [_avatarImageView setUserInteractionEnabled:YES];
    [_avatarImageView addGestureRecognizer:singleFingerTap];
    
    UITapGestureRecognizer *backgroundTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [self.view addGestureRecognizer:backgroundTap];
    
    [self.view setBackgroundColor:[RYStyleSheet baseColor]];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[RYLocationServices sharedInstance] setLocationDelegate:nil];
    
    // Remove Gestures
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:recognizer];
    }
}

#pragma mark -
#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TextFields

- (void)backgroundTapped:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark - Actions

- (IBAction)submitRegistration:(id)sender
{
    _username  = _usernameText.text;
    _password           = _passwordText.text;
    NSString *email     = _emailText.text;
    NSString *bio       = _bioText.text;
    NSString *name      = _nameText.text;
    
    if (_username.length > 0 && _password.length > 0 && email.length > 0)
    {
        if (_latitude && _longitude)
        {
            //coordinates found
            //submit request
            NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
            
            requestDict[@"email"]       = email;
            requestDict[@"username"]    = _username;
            requestDict[@"password"]    = _password;
            requestDict[@"bio"]         = bio;
            requestDict[@"name"]        = name;
            requestDict[@"longitude"]   = _longitude;
            requestDict[@"latitude"]    = _latitude;
            
            [[RYServices sharedInstance] registerUserWithPOSTDict:requestDict avatar:_avatarImage forDelegate:self];
            
            [self showHUDWithTitle:@"Registering"];
        }
        else
        {
            [self showHUDWithTitle:@"Locating"];
        }
    }
}

#pragma mark -
#pragma mark - POSTDelegate

- (void) connectionFailed
{
    
}
- (void) postFailed:(NSString*)reason
{
    [self hideHUD];
    UIAlertView *postWarning = [[UIAlertView alloc] initWithTitle:@"Post Error" message:[NSString stringWithFormat:@"Error: %@", reason] delegate:nil cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
    [postWarning show];
}
- (void) postSucceeded:(id)response
{
    NSLog(@"Success: %@",response);
    
    NSDictionary *responseDict = response;
    NSDictionary *userDict = [responseDict objectForKey:kUserObjectKey];
    if (userDict)
    {
        [[NSUserDefaults standardUserDefaults] setObject:userDict forKey:kLoggedInUserKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [SSKeychain setPassword:_password forService:@"ryff" account:_username];
    }
    
    [self hideHUD];
    [self showCheckHUDWithTitle:@"Successfully Registered!" forDuration:1.0];
    [self performSelector:@selector(dismissViewController) withObject:self afterDelay:1.5];
}

#pragma mark -
#pragma mark - Transitions

- (void)dismissViewController
{
    //if you are presnting ViewController modally. then use below code
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - LocationDelegate

- (void) locationSuceededWithLat:(NSNumber*)latitude Long:(NSNumber*)longitude
{
    [self hideHUD];
    [self setLongitude:longitude];
    [self setLatitude:latitude];
}
- (void) locationFailedWithError:(NSError*)error
{
    [self hideHUD];
    BlockAlertView *locationWarning = [[BlockAlertView alloc] initWithTitle:@"Could Not Locate" message:@"Location services are necessary for proper functioning." delegate:nil cancelButtonTitle:@"Go Without" otherButtonTitles:@"Try Again",nil];
    [locationWarning setClickedButtonBlock:^(BlockAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex != alertView.cancelButtonIndex)
        {
            [[RYLocationServices sharedInstance] requestLocationCoordinatesForDelegate:self];
        }
        else
        {
            
        }
    }];
    [locationWarning show];
}

#pragma mark user's photo stuff

- (void)avatarTapped:(id)sender
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"No camera detected!");
        [self pickPhoto];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Photo",@"Pick from Photo Library", nil];
    [actionSheet showInView:self.view];
}

-(UIImagePickerController *) imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}

-(void) takePhoto
{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self.navigationController presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void) pickPhoto
{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (self.imagePicker == nil) {
        NSLog(@"It's nil!");
    }
    else
    {
        NSLog(@"Not nil!");
    }
    
    [self.navigationController presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    _avatarImage = info[UIImagePickerControllerOriginalImage];
    CGFloat avatarSize = 100.f;
    [_avatarImageView setImage:[_avatarImage createThumbnailToFillSize:CGSizeMake(avatarSize, avatarSize)]];
    [self.avatarImageView setImage:_avatarImage];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    
    switch (buttonIndex) {
        case 0:
            [self takePhoto];
            break;
        case 1:
            [self pickPhoto];
            break;
    }
}

#pragma mark -
#pragma mark - Keyboard Scroll Sizing
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= (kbSize.height + 44);
    
    // get active text field
    CGPoint textOrigin = CGPointMake(0, 0);
    for (UIView *view in self.view.subviews) {
        if (view.isFirstResponder)
        {
            textOrigin = view.frame.origin;
        }
    }
    
    if (!CGRectContainsPoint(aRect, textOrigin) ) {
        /*
        CGPoint scrollPoint = CGPointMake(0.0, textOrigin.y-kbSize.height);
        [_scrollView setContentOffset:scrollPoint animated:YES];
         */
        [_scrollView setFrame:aRect];
        [_scrollView setContentSize:self.view.frame.size];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    [_scrollView setFrame:self.view.frame];
}
@end
