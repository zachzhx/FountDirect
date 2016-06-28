//
//  MainTabBarViewController.m
//  FountDirect
//
//  Created by Zhang Xu on 6/27/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "Constants.h"
#import "ChatsViewController.h"
#import "ContactsViewController.h"
#import "MeViewController.h"


@interface MainTabBarViewController ()

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIStoryboard *chatsStoryboard = [UIStoryboard storyboardWithName:@"chats" bundle:nil];
    ChatsViewController *chatsVC = [chatsStoryboard instantiateInitialViewController];
    
    UIStoryboard *contactsStoryboard = [UIStoryboard storyboardWithName:@"contacts" bundle:nil];
    ContactsViewController *contactsVC = [contactsStoryboard instantiateInitialViewController];
    
    UIStoryboard *meStoryboard = [UIStoryboard storyboardWithName:@"me" bundle:nil];
    MeViewController *meVC = [meStoryboard instantiateInitialViewController];
    
    NSArray *viewControllers = @[chatsVC, contactsVC, meVC];
    [self setViewControllers:viewControllers];
    
    chatsVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"Chats" image:[UIImage imageNamed:@"discover"] tag:1];
    contactsVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"Contacts" image:[UIImage imageNamed:@"shop"] tag:2];
    meVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"Me" image:[UIImage imageNamed:@"me"] tag:3];
    
    [self setDelegate:self];
}

-(void)tabBar:(UITabBar *)theTabBar didSelectItem:(UITabBarItem *)item{
    for (int i = 0; i < theTabBar.items.count; i++) {
        if(theTabBar.selectedItem == theTabBar.items[i]){
            NSLog(@"Selected tab: %d", i);
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
