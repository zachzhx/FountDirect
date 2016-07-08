//
//  resetPasswordViewController.m
//  Fount
//
//  Created by Zhang Xu on 2/23/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "resetPasswordViewController.h"
#import "NSAttributedString+StringStyles.h"
#import "UIColor+CustomColors.h"
#import "ServiceLayer.h"

@interface resetPasswordViewController ()

@end

@implementation resetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [UILabel new];
    titleLabel.attributedText = [NSAttributedString navigationTitleStyle:@"RESET PASSWORD"];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.userView.layer.cornerRadius = 5;
    self.userView.layer.borderColor=[UIColor customLightGrayColor].CGColor;
    self.userView.layer.borderWidth = 1;
    
    self.imageView.image = [UIImage imageNamed:@"placeholderuser"];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.imageView setTintColor:[UIColor lightGrayColor]];
    self.textfield.delegate=self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSString *emailText = self.textfield.text;
    [[[ServiceLayer alloc]init]postForgotPasswordwithEmail:emailText completion:^(NSDictionary *dictionary) {
        //NSLog(@"%@",dictionary);
        if (dictionary) {
            [self setupDropdownView];
            [self animateHeaderViewWithText:@"A reset email has been sent to your email address." backgroundColor:[UIColor greenMessageColor]];
            [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(goBackToSettings:) userInfo:nil repeats:NO];
        }else{
            [self setupDropdownView];
            [self animateHeaderViewWithText:@"Invalid email address" backgroundColor:[UIColor redColor]];
        }
    }];
    return YES;
}

//Header Animation

-(void)setupDropdownView{
    if(self.dropdownView==nil){
        self.dropdownView=[[UIView alloc]initWithFrame:CGRectMake(0, -40, self.view.frame.size.width, 40)];
        
        self.dropdownView.backgroundColor=[UIColor whiteColor];
        self.dropdownLabel = [[UILabel alloc]initWithFrame:self.dropdownView.bounds];
        self.dropdownLabel.textAlignment = NSTextAlignmentCenter;
        self.dropdownLabel.font = [UIFont fontWithName:@"Gill Sans" size:14];
        self.dropdownLabel.textColor=[UIColor whiteColor];
        self.dropdownLabel.backgroundColor = [UIColor clearColor];
        [self.dropdownView addSubview:self.dropdownLabel];
        [self.view addSubview:self.dropdownView];
    }
    
}

-(void)animateHeaderViewWithText:(NSString*)text backgroundColor:(UIColor*)backgroundColor{
           self.dropdownLabel.text = text;
        [UIView animateWithDuration:.5 delay:0 options:0 animations:^{
            self.dropdownView.frame = CGRectMake(0, self.navHeight, self.view.frame.size.width, 40);
            self.dropdownView.backgroundColor = backgroundColor;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.5 delay:2 options:0 animations:^{
                self.dropdownView.backgroundColor=[UIColor whiteColor];
                self.dropdownView.frame = CGRectMake(0, -40, self.view.frame.size.width, 40);
                
            } completion:^(BOOL finished) {
                NSLog(@"Animation Finished");
            }];
            ;
        }];
}

-(void)goBackToSettings:(NSTimer*)timer{
    [self.navigationController popViewControllerAnimated:YES];
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
