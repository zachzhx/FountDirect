//
//  LoginViewController.m
//  Spree
//
//  Created by Rush on 9/11/15.
//  Copyright (c) 2015 Syw. All rights reserved.
//

#import "LoginViewController.h"
#import "UIColor+CustomColors.h"
#import "ServiceLayer.h"
#import "AppDelegate.h"
#import "Constants.h"
#import <SSKeychain.h>
#import "NSString+EmailValidation.h"
#import "MainTabBarViewController.h"
#import <LocalAuthentication/LocalAuthentication.h> //ZACH
#import "EHFAuthenticator.h"
#import <Security/Security.h>
#import <Google/Analytics.h>
#import "resetPasswordViewController.h"
#import "NSAttributedString+StringStyles.h"

#import "RNCryptor/RNEncryptor.h"
#import "RNCryptor/RNDecryptor.h"

#import "ServiceLayer.h"
#import <Crashlytics/Crashlytics.h>

//#import <AirshipKit/AirshipKit.h>

@interface LoginViewController () {
    BOOL checkBoxChecked;
    NSString *currentUserName;
    BOOL touchIDChecked;
}

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *checkBoxImageView;
@property (weak, nonatomic) IBOutlet UIButton *rememberMeButton;
@property (weak, nonatomic) IBOutlet UIImageView *touchIDcheckBoxImageView;
@property (weak, nonatomic) IBOutlet UIButton *touchIDButton;
@property (weak, nonatomic) IBOutlet UILabel *resetLabel;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
//    self.touchIDButton.hidden = YES;
//    self.touchIDButton.userInteractionEnabled = NO;
//    self.touchIDcheckBoxImageView.hidden = YES;
//    touchIDChecked = NO;
    
    self.resetLabel.textColor=[UIColor themeColor];
    self.resetLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetPassword:)];
    [self.resetLabel addGestureRecognizer:tapGesture];
    
    NSArray *accountArray = [SSKeychain accountsForService:kLoginKeychainService];
    
    //Will only store 1 account at a time
    if (accountArray.count > 0) {
        currentUserName = [accountArray[0] objectForKey:@"acct"];
        self.emailTextField.text = [accountArray[0] objectForKey:@"acct"];
        NSString *password = [SSKeychain passwordForService:kLoginKeychainService account:self.emailTextField.text];
        self.passwordTextField.text = password;
    }
    
    if(touchIDChecked){
        
        _rememberMeButton.userInteractionEnabled = NO;
        [self authenticateUser];
        
    }else{
        _rememberMeButton.userInteractionEnabled = YES;
    }
    
    if (self.presentedModally) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backbuttonimage"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked:)];
    }
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.attributedText = [NSAttributedString navigationTitleStyle:@"LOGIN"];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    self.navigationController.navigationBar.tintColor = [UIColor themeColor];
}

-(void)backButtonClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Setup Methods
-(void) setupView {
    self.loginButton.backgroundColor = [UIColor themeColor];
    self.loginButton.layer.cornerRadius = 5.0;
    
    checkBoxChecked = [[NSUserDefaults standardUserDefaults] boolForKey:kCheckBoxCheckedKey];
    touchIDChecked = [[NSUserDefaults standardUserDefaults] boolForKey:kTouchIDCheckedKey];
    
    [self displayCorrectCheckBox];
    [self displaytouchIDCheckBox];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    for (UIView *view in self.view.subviews) {
        if (view.isFirstResponder) {
            [view resignFirstResponder];
        }
    }
}

#pragma mark - Button Clicks
-(IBAction)loginClicked:(UIButton *)sender {
    
    BOOL emailValid = [self.emailTextField.text isValidEmail];
    
    if (emailValid && self.passwordTextField.text.length > 5 && self.emailTextField.text.length > 0) {
        
        [[[ServiceLayer alloc] init] loginWithEmail:self.emailTextField.text password:self.passwordTextField.text completion:^(NSDictionary *dictionary) {
            
            NSDictionary *errorDictionary = [dictionary objectForKey:@"error"];

            if (!errorDictionary) {
                if (checkBoxChecked) {
                    //Check if same user
                    if (![currentUserName isEqualToString:self.emailTextField.text]) {
                        [self deleteSavedUser];
                        [self createAccount];
                    }
                    
                } else {
                    
                    [self deleteSavedUser];
                }
                
                [[NSUserDefaults standardUserDefaults] setBool:checkBoxChecked forKey:kCheckBoxCheckedKey];
                [[NSUserDefaults standardUserDefaults] setBool:touchIDChecked forKey: kTouchIDCheckedKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                [tracker set:kGAIUserId value:[NSString stringWithFormat:@"%tu", [[[ServiceLayer alloc] init] getUserId]]];
                
                if (self.presentedModally) {
                    
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Login from Guest Screen"
                                                                          action:@"User Sign In"
                                                                           label:nil
                                                                           value:nil] build]];
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                } else {
                    
                    //Get string from backend
                    
//                    NSLog(@"TOKEN %@", [dictionary valueForKeyPath:@"payload.TOKEN"]);
                    
                    if ([self validateResponseWithBase64String:[dictionary valueForKeyPath:@"payload.TOKEN"]]) {
                    
                        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Login from Landing Screen"
                                                                              action:@"User Sign In"
                                                                               label:nil
                                                                               value:nil] build]];
                        
                            [self saveUserInfo:dictionary];
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSessionKey];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        
                            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                            MainTabBarViewController *mainTabVC = [[MainTabBarViewController alloc] init];
                            [self.view endEditing:YES];
                            appDelegate.window.rootViewController = mainTabVC;
                            
                    } else {
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid login credentials.\nTry again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        
                        [alert show];
                    }
                }
                
            } else {
                
                NSString *errorMessage = [errorDictionary objectForKey:@"message"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }];
        
    } else {
        UIAlertView *alert;
        
        if (!emailValid) {
            alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please check your email and try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        } else if (self.passwordTextField.text.length <= 5) {
            alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password must be more than 6 characters" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        }
        [alert show];
    }
}
         
#pragma mark - Helper Methods
-(void) saveUserInfo:(NSDictionary *) responseObject {
    NSString *displayName = [[[responseObject objectForKey:@"payload"] objectForKey:@"USER"] objectForKey:@"displayName"];
    [[NSUserDefaults standardUserDefaults] setObject:displayName forKey:kDisplayNameKey];

    NSString *email = [[[responseObject objectForKey:@"payload"] objectForKey:@"USER"] objectForKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:kEmailKey];

    NSString *profilePictureString = [[[[responseObject objectForKey:@"payload"] objectForKey:@"USER"] objectForKey:@"userInstagram"] objectForKey:@"instagramProfilePicture"];
    [[NSUserDefaults standardUserDefaults] setObject:profilePictureString forKey:kInstagramProfilePictureStringKey];

    NSInteger userId = [[[[responseObject objectForKey:@"payload"] objectForKey:@"USER"] objectForKey:@"id"] integerValue];

    [[NSUserDefaults standardUserDefaults] setInteger:userId forKey:kUserIdKey];

    [[NSUserDefaults standardUserDefaults] synchronize];

    [self logUser];

    [[[ServiceLayer alloc] init] updateDeviceTokenWithCompletionBlock:^(NSDictionary *dictionary) {
     //            NSLog(@"device Dict:%@", dictionary);
    }];
}
         
- (void) logUser {
    // TODO: Use the current user's information
    // You can call any combination of these three methods
    [CrashlyticsKit setUserIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:kUserIdKey]];
    [CrashlyticsKit setUserEmail:[[NSUserDefaults standardUserDefaults] objectForKey:kEmailKey]];
    [CrashlyticsKit setUserName:[[NSUserDefaults standardUserDefaults] objectForKey:kDisplayNameKey]];
}

-(BOOL) validateResponseWithBase64String:(NSString *) base64String {
    
//    NSString *str = @"dnguyen";
//    
    NSString *password = @"pdsfiahsgefsdufZ18732ydhsfYqoqeifVzzuhwfiTsgfdbsdfiuPwefMf813fK";
//
//    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
//    
//    NSString *dataString = [data base64EncodedStringWithOptions:kNilOptions];
//    
//    NSLog(@"DATA STRING:%@", dataString);
//    
//    NSData *data2 = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:password error:nil];
//    
//    NSString *dataString2 = [data2 base64EncodedStringWithOptions:kNilOptions];
//    
//    NSLog(@"DATA STRING 2:%@", dataString2);
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    
//    NSLog(@"BASE 64 STR:%@", base64String);
    
//    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:@"AwGGCXDW+4JPCZaFMnuxeO2er+OcMOPnMYtqHBx0ag2Yj2farHWGss3wiJ+4t5k5GoT9lRI4hIBfqEIbHuIhd0dahsHZU10KnwRR7HTVav+j3ZyCyFdEqXz/6dzPzdkBx5s=" options:0];
    
    NSData *decryptedData = [RNDecryptor decryptData:decodedData withSettings:kRNCryptorAES256Settings password:password error:nil];
    
    NSString *decodedStr = [[NSString  alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
    
//    NSLog(@"STR - %@", decodedStr);
//
//    NSLog(@"EMail:%@", [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]);
    
    //Check if email is the same
    if ([decodedStr isEqualToString:[self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) {
    
        return YES;
        
    } else {
        
        return NO;
    }
    
//    NSString *str = @"dnguyen";
//    
//    NSString *password = @"abc";
//    
//    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
//    
//    NSString *dataString = [data base64EncodedStringWithOptions:kNilOptions];
//    
//    NSLog(@"DATA STRING:%@", dataString);
//    
//    NSData *data2 = [RNEncryptor encryptData:data withSettings:kRNCryptorAES256Settings password:password error:nil];
//    
//    NSString *dataString2 = [data2 base64EncodedStringWithOptions:kNilOptions];
//    
//    NSLog(@"DATA STRING 2:%@", dataString2);
//    
//    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:dataString2 options:0];
//    
//    NSData *decryptedData = [RNDecryptor decryptData:decodedData withSettings:kRNCryptorAES256Settings password:password error:nil];
//    
//    NSString *decodedStr = [[NSString  alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
//    
//    NSLog(@"STR - %@", decodedStr);
}

-(IBAction)rememberMeButtonClicked:(UIButton *)sender {
    checkBoxChecked = !checkBoxChecked;
    [self displayCorrectCheckBox];
}

-(IBAction)touchIDButtonClicked:(UIButton *)sender {
    touchIDChecked = !touchIDChecked;
    [self displaytouchIDCheckBox];
}

#pragma mark - Helper Methods

-(void) displayCorrectCheckBox {
    if (checkBoxChecked) {
        self.checkBoxImageView.image = [UIImage imageNamed:@"checkbox_checked"];
    } else {
        self.checkBoxImageView.image = [UIImage imageNamed:@"checkbox_unchecked"];
    }
}

-(void) displaytouchIDCheckBox{
    if (touchIDChecked) {
        self.touchIDcheckBoxImageView.image = [UIImage imageNamed:@"checkbox_checked"];
        checkBoxChecked = YES;
        self.checkBoxImageView.image = [UIImage imageNamed:@"checkbox_checked"];
        self.rememberMeButton.userInteractionEnabled = NO;
        self.rememberMeButton.titleLabel.textColor = [UIColor lightGrayColor];
        
    } else {
        self.touchIDcheckBoxImageView.image = [UIImage imageNamed:@"checkbox_unchecked"];
        self.rememberMeButton.userInteractionEnabled = YES;
        self.rememberMeButton.titleLabel.textColor = [UIColor blackColor];
    }
    
}

-(void) createAccount {
    BOOL result = [SSKeychain setPassword:self.passwordTextField.text forService:kLoginKeychainService account:self.emailTextField.text];
    
    if (result) {
        NSLog(@"Saved successfully");
    } else {
        NSLog(@"Failed to save user");
    }
}

-(void) deleteSavedUser {
    SSKeychainQuery *query = [[SSKeychainQuery alloc] init];
    NSArray *accounts = [query fetchAll:nil];
    
    for (id account in accounts) {
        
        query.service = kLoginKeychainService;
        query.account = [account valueForKey:@"acct"];
        
        [query deleteItem:nil];
    }
}

-(void) goBack {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Touch ID
- (void)authenticateUser{
    NSError * error = nil;
    
    [[EHFAuthenticator sharedInstance] setReason:@"Log on to view your account"];
    [[EHFAuthenticator sharedInstance] setFallbackButtonTitle:@"Enter Password"];
    [[EHFAuthenticator sharedInstance] setUseDefaultFallbackTitle:YES];
    
    if (![EHFAuthenticator canAuthenticateWithError:&error]) {
        NSString * authErrorString = @"Check your Touch ID Settings";
        
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled:
                authErrorString = @"No Touch ID fingers enrolled";
                break;
            case LAErrorTouchIDNotAvailable:
                authErrorString = @"Touch ID not available on your device";
                break;
            case LAErrorPasscodeNotSet:
                authErrorString = @"Need a passcode set to use Touch ID";
                break;
            default:
                authErrorString = @"Check your Touch ID Settings";
                break;
        }
        
    }
    
    [[EHFAuthenticator sharedInstance] authenticateWithSuccess:^(){
        [self presentAlertControllerWithMessage:@"Successfully Authenticated!"];
        
    } andFailure:^(LAError errorCode){
        NSString * authErrorString;
        switch (errorCode) {
            case LAErrorSystemCancel:
                authErrorString = @"System cancelled authentication request due to app coming to foreground or background.";
                break;
            case LAErrorAuthenticationFailed:
                authErrorString = @"User failed after a few attempts.";
                break;
            case LAErrorUserCancel:
                authErrorString = @"User cancelled.";
                self.passwordTextField.hidden = NO;
                
                break;
                
            case LAErrorUserFallback:
                authErrorString = @"Fallback auth method should be implemented here.";
                break;
            case LAErrorTouchIDNotEnrolled:
                authErrorString = @"No Touch ID fingers enrolled.";
                break;
            case LAErrorTouchIDNotAvailable:
                authErrorString = @"Touch ID not available on your device.";
                break;
            case LAErrorPasscodeNotSet:
                authErrorString = @"Need a passcode set to use Touch ID.";
                break;
            default:
                authErrorString = @"Check your Touch ID Settings.";
                break;
        }
        [self presentAlertControllerWithMessage:authErrorString];
    }];
}

-(void) presentAlertControllerWithMessage:(NSString *) message{
    
    //to fetch details from keychain
    
    if ([message isEqualToString:@"Successfully Authenticated!"]) {
        
        NSArray *accountArray = [SSKeychain accountsForService:kLoginKeychainService];
//        NSLog(@"accountArray 2:%@",accountArray);
//        NSLog(@"accountArray count 2:%lu",(unsigned long)accountArray.count);
        //Will only store 1 account at a time
        if (accountArray.count > 0) {
            currentUserName = [accountArray[0] objectForKey:@"acct"];
            self.emailTextField.text = [accountArray[0] objectForKey:@"acct"];
            NSString *password = [SSKeychain passwordForService:kLoginKeychainService account:self.emailTextField.text];
            self.passwordTextField.text = password;
//            NSLog(@"password:%@",password);
        }
        
        [[[ServiceLayer alloc] init] loginWithEmail:self.emailTextField.text password:self.passwordTextField.text completion:^(NSDictionary *dictionary) {
            
            NSDictionary *errorDictionary = [dictionary objectForKey:@"error"];
            
            if (!errorDictionary) {
                if (checkBoxChecked) {
                    //Check if same user
                    if (![currentUserName isEqualToString:self.emailTextField.text]) {
                        [self deleteSavedUser];
                        [self createAccount];
                    }
                } else {
                    [self deleteSavedUser];
                }
                
                [self saveUserInfo:dictionary];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSessionKey];
                [[NSUserDefaults standardUserDefaults] setBool:checkBoxChecked forKey:kCheckBoxCheckedKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
                    MainTabBarViewController *mainTabVC = [[MainTabBarViewController alloc] init];
                    appDelegate.window.rootViewController = mainTabVC;
                
            } else {
                
                NSString *errorMessage = [errorDictionary objectForKey:@"message"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}

-(void)resetPassword:(UITapGestureRecognizer*)recognizer{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"resetPassword" bundle:nil];
    resetPasswordViewController *resetVC = [storyboard instantiateInitialViewController];
    self.navigationController.navigationBar.topItem.title = @"";
    resetVC.navHeight = 64;
    [self.navigationController pushViewController:resetVC animated:YES];
}

#pragma mark - Memory Warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
