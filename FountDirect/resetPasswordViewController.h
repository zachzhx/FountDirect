//
//  resetPasswordViewController.h
//  Fount
//
//  Created by Zhang Xu on 2/23/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface resetPasswordViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (strong,nonatomic) UIView *dropdownView;
@property (strong,nonatomic) UILabel *dropdownLabel;
@property int navHeight;

@end
