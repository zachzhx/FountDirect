//
//  SelectColorAndSizeViewController.h
//  Spree
//
//  Created by Xu Zhang on 10/8/15.
//  Copyright (c) 2015 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwoTapModel.h"
#import "PDPAddToCartModel.h"

@interface SelectColorAndSizeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *colorCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *sizeCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *fitCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *optionCollectionView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popupViewTOpConstraint;

@property (nonatomic, strong) TwoTapModel *dataSource;
@property (nonatomic, strong) PDPAddToCartModel *aModel;

@property (weak, nonatomic) IBOutlet UILabel *fitLabel;
@property (strong, nonatomic) IBOutlet UIImageView *fitImage;
@property (weak, nonatomic) IBOutlet UILabel *fitDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *fitLine;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fitHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *colorHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sizeHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *optionHeightConstraint;


@property (weak, nonatomic) IBOutlet UILabel *colorTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *colorImage;
@property (weak, nonatomic) IBOutlet UILabel *colorDetailLabel;


@property (strong, nonatomic)IBOutlet UIScrollView *bgScroll;
@property (weak, nonatomic) IBOutlet UILabel *optionTextLabel;
@property (strong, nonatomic) IBOutlet UIImageView *optionImage;
@property (weak, nonatomic) IBOutlet UILabel *optionLine;

@property (strong,nonatomic) IBOutlet UIView *fitView,*colorView,*sizeView,*optionView;

@property (weak, nonatomic) IBOutlet UILabel *sizeTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeDetailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sizeImage;
@property (weak, nonatomic) IBOutlet UILabel *sizeLine;

@property (nonatomic, strong) NSArray  *mediaArray;
@property (nonatomic, strong) NSString *fieldName0;
@property (nonatomic, strong) NSString *qualityStr;
@property (nonatomic, strong) NSString *sellerName;
@property (nonatomic, strong) NSString *buyURL;

@property (weak, nonatomic) IBOutlet UIView *popupVIew;

- (IBAction)submitButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *submitButtonOutlet;

@property (weak, nonatomic) IBOutlet UILabel *colorNameLabel;

@end
