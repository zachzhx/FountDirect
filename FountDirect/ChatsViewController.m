//
//  ChatsViewController.m
//  FountDirect
//
//  Created by Zhang Xu on 6/27/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "ChatsViewController.h"
#import "UIColor+CustomColors.h"

@interface ChatsViewController ()

@end

@implementation ChatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.tintColor = [UIColor themeColor];
    [self setupNavigationBar];
}

#pragma mark - Setup Methods
-(void)setupNavigationBar{
    
}

-(void)setupShoppingCart{
    UILabel *label = [[UILabel alloc]init];
    
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
