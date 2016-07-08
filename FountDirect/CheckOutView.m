//
//  CheckOutView.m
//  Spree
//
//  Created by Xu Zhang on 10/30/15.
//  Copyright © 2015 Syw. All rights reserved.
//

#import "CheckOutView.h"
#import "UIColor+CustomColors.h"
#import <CoreText/CoreText.h>

@implementation CheckOutView
@synthesize selectbutton;
@synthesize button;
@synthesize lbl;

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        [self loadFooterView];
        
    }
    return self;
}



- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.userInteractionEnabled = YES;
        [self loadFooterView];
    }
    return self;
}

-(void)loadFooterView{
    
    
    selectbutton = [self createingButton];
    selectbutton.frame = CGRectMake(-15, 10, 80,24);
    [selectbutton setImage:[UIImage imageNamed:@"round-stoke1x.png"] forState:UIControlStateNormal];
    [selectbutton setTitle:@"All" forState:UIControlStateNormal];
    [selectbutton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self addSubview:selectbutton];
    
    lbl = [self createingLabel];
    [lbl setFrame:CGRectMake(60, 1, self.frame.size.width-140, 20)];
    lbl.font = [UIFont fontWithName:@"Gill Sans" size:18.0f];
    lbl.text= @"Subtotal : $0.00";
    [self addSubview:lbl];
    
    UILabel *lbl2 = [self createingLabel];
    [lbl2 setFrame:CGRectMake(60, lbl.frame.size.height+3, self.frame.size.width-140, 15)];
    NSString *str= @"* no shipping included";
    lbl2.textColor = [UIColor darkGrayColor];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",str]];
    [attString addAttribute:(NSString*)kCTUnderlineStyleAttributeName
                      value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                      range:(NSRange){0,[attString length]}];
    
    lbl2.attributedText = attString;
    [self addSubview:lbl2];
    
    //CHECK OUT button
    button = [self createingButton];
    button.backgroundColor=[UIColor themeColor];
    [button setTitle:@"CHECK OUT" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(self.frame.size.width-110, 3, 100,38);
    button.layer.cornerRadius = 3;
    [self addSubview:button];
}

-(UIButton*)createingButton{
    
    UIButton *createbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    createbutton.backgroundColor = [UIColor clearColor];
    [createbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    createbutton.titleLabel.font = [UIFont fontWithName:@"Gill Sans" size:14.0f];
    return createbutton;
}

-(UILabel*)createingLabel{
    
    UILabel *createlbl = [[UILabel alloc] init];
    createlbl.textColor = [UIColor blackColor];
    createlbl.font = [UIFont fontWithName:@"Gill Sans" size:14.0f];
    createlbl.backgroundColor=[UIColor clearColor];
    createlbl.userInteractionEnabled=NO;
    return createlbl;
}


-(void)SocialNetworkActionMethod:(id)sender{
    // NSLog(@"YES......");
}

@end
