//
//  AppDelegate.m
//  FountDirect
//
//  Created by Zhang Xu on 6/27/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "AppDelegate.h"
#import "MainTabBarViewController.h"
#import "Constants.h"
#import <Google/Analytics.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface AppDelegate ()

@property (nonatomic, strong) NSURL *launchedURL;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
//    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
//    MainTabBarViewController *tab = [[MainTabBarViewController alloc]init];
//    self.window.rootViewController = tab;
//    [self.window makeKeyAndVisible];
    
    [Fabric with:@[[Crashlytics class]]];

    self.launchedURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    
    BOOL userIsActivated = [[NSUserDefaults standardUserDefaults] boolForKey:kConfirmedKey];
    
    [[NSUserDefaults standardUserDefaults] setBool:!userIsActivated forKey:kShouldDisplayBannerKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        NSLog(@"Requesting permission for push notifications..."); // iOS 8
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
                                                UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |
                                                UIUserNotificationTypeSound categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isFromNoticePage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:20 * 1024 * 1024
                                                                diskCapacity:200 * 1024 * 1024
                                                                    diskPath:nil];
        [NSURLCache setSharedURLCache:sharedCache];
        
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
        BOOL sessionExists = [[NSUserDefaults standardUserDefaults] boolForKey:kSessionKey];
        
        if (!sessionExists) {
            
            NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            for (NSHTTPCookie *cookie in [cookieJar cookies]) {
                
                //                NSLog(@"NAME:%@", cookie.name);
                
                if ([cookie.name isEqualToString:@"PLAY_SESSION"]) {
                    //                    sessionExists = YES;
                    [cookieJar deleteCookie:cookie];
                    
                }
            }
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Landing" bundle:nil];
            self.window.rootViewController = [storyboard instantiateInitialViewController];
            
        } else {
            
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            MainTabBarViewController *tab = [[MainTabBarViewController alloc] init];
            
            self.window.rootViewController = tab;
            
            NSDictionary *userInfo = [launchOptions valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
            
            if (userInfo) {
                [self performSelector:@selector(postNotificationToPresentPushMessagesVC:) withObject:userInfo afterDelay:0.5];
            }
        }
    
    [self.window makeKeyAndVisible];
    
    
    //#if DEBUG
    
    //#else
    //Google analytics
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    //    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    //#endif
   // [Fabric with:@[[Crashlytics class]]];
    
    return YES;

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void) postNotificationToPresentPushMessagesVC:(NSDictionary *) notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPushNotificationName object:notification];
}

@end
