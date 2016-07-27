//
//  SelectColorAndSizeViewController.m
//  Spree
//
//  Created by Xu Zhang on 10/8/15.
//  Copyright (c) 2015 Syw. All rights reserved.
//

#import "SelectColorAndSizeViewController.h"
#import "ColorCollectionViewCell.h"
#import "SizeCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "KTCenterFlowLayout.h"
#import "OptionCollectionViewCell.h"
#import "UIColor+CustomColors.h"
#import "BaseProductAttributeModel.h"
#import "ServiceLayer.h"
#import "ProductFitModel.h"
#import "WebViewController.h"
#import "Constants.h"
#import <Google/Analytics.h>
#import "MainTabBarViewController.h"
#import <Crashlytics/Crashlytics.h>

@interface SelectColorAndSizeViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSArray *fitDataSource;
    NSArray *colorsDataSource;
    NSArray *sizeDataSource;
    NSArray *inseamDataSource;
    NSArray *styleDataSource;
    NSArray *optionDataSource;
    NSArray *option1DataSource;
    NSArray *flavorDataSource;
    NSInteger selectedRow; //For single selection
    ProductFlavorModel *selectedFlavorModel;
    ProductFitModel *selectedFitModel;
    ProductColorModel *selectedColorModel;
    ProductOptionModel *selectedOptionModel;
    ProductOption1Model *selectedOption1Model;
    ProductOption1Model *selectedOption2Model;
    ProductOption1Model *selectedOption3Model;
    ProductOption1Model *selectedOption4Model;
    BaseProductAttributeModel *selectedModel;
    BaseProductAttributeModel *sizeModel;
    BaseProductAttributeModel *selectedStyleModel;
    BaseProductAttributeModel *selectedInseamModel;
    
    NSString *selectedFit,*selectedColor,*selectedSize;
}
@end

@implementation SelectColorAndSizeViewController
@synthesize aModel;
@synthesize mediaArray;
@synthesize fieldName0;
@synthesize qualityStr;
@synthesize submitButtonOutlet;
@synthesize sellerName;

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden =YES;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:kSelectColorAndSizePageName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([qualityStr isEqualToString:@"LOW"]) {
        [submitButtonOutlet setTitle: [NSString stringWithFormat:@"BUY NOW on %@" ,sellerName] forState:UIControlStateNormal];
    }
    
    //    NSLog(@"%f" ,self.popupVIew.frame.size.height);
    //    NSLog(@"%f", self.view.frame.size.height);
    
#pragma array allocation
    
    fitDataSource = [NSArray array];
    colorsDataSource = [NSArray array];
    sizeDataSource = [NSArray array];
    inseamDataSource = [NSArray array];
    styleDataSource = [NSArray array];
    optionDataSource = [NSArray array];
    option1DataSource = [NSArray array];
    
#pragma UICollectionview layouts
    // Do any additional setup after loading the view.
    KTCenterFlowLayout *layout = (KTCenterFlowLayout *)self.fitCollectionView.collectionViewLayout;
    KTCenterFlowLayout *layout1 = (KTCenterFlowLayout *)self.colorCollectionView.collectionViewLayout;
    KTCenterFlowLayout *layout2 = (KTCenterFlowLayout *)self.sizeCollectionView.collectionViewLayout;
    KTCenterFlowLayout *layout3 = (KTCenterFlowLayout *)self.optionCollectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 10.0;
    layout1.minimumInteritemSpacing = 10.0;
    layout2.minimumInteritemSpacing = 10.0;
    layout2.minimumLineSpacing = 10.0;
    layout3.minimumInteritemSpacing = 10.0;
    layout3.minimumLineSpacing =10.0;
    if (self.dataSource.fits.count==0) {
        colorsDataSource = self.dataSource.colors;
        
        if (colorsDataSource.count>0) {
            sizeDataSource = self.dataSource.sizes;
            self.colorCollectionView.hidden = NO;
            self.colorImage.hidden = NO;
            self.colorTextLabel.hidden = NO;
            self.colorDetailLabel.hidden = NO;
            self.colorNameLabel.hidden = NO;
        }
        else if ([self.dataSource.option.options count] > 0) {
            fitDataSource = [self.dataSource.option.options mutableCopy];
            self.fitLabel.text = @"Options";
            self.fitCollectionView.hidden = NO;
            self.colorCollectionView.hidden = YES;
            self.colorImage.hidden = YES;
            self.colorTextLabel.hidden = YES;
            self.colorDetailLabel.hidden = YES;
            self.colorNameLabel.hidden = YES;
            self.sizeCollectionView.hidden =YES;
            self.sizeImage.hidden = YES;
            self.sizeTextLabel.hidden = YES;
            self.sizeDetailLabel.hidden = YES;
            self.optionTextLabel.hidden = YES;
            self.optionImage.hidden = YES;
        }
        else if ([self.dataSource.option1 count] > 0) {
            // Option 1 to 4
            self.fitLabel.text = @"Option1:";
            self.fitDetailLabel.hidden = YES;
            fitDataSource = self.dataSource.option1;
            self.fitCollectionView.hidden = NO;
            self.colorCollectionView.hidden = YES;
            self.colorImage.hidden = NO;
            self.colorTextLabel.text = @"Option2:";
            self.colorDetailLabel.hidden = YES;
            self.colorNameLabel.hidden = YES;
            self.sizeCollectionView.hidden =YES;
            self.sizeImage.hidden = NO;
            self.sizeTextLabel.text = @"Option3:";
            self.sizeDetailLabel.hidden = YES;
            self.optionTextLabel.text = @"Option4:";
            self.optionImage.hidden = NO;
        }
        else if ([self.dataSource.styles count] > 0) {
            // Styles only
            self.fitLabel.text = @"Style";
            fitDataSource = self.dataSource.styles;
            self.fitCollectionView.hidden = NO;
            self.colorCollectionView.hidden = YES;
            self.colorImage.hidden = YES;
            self.colorNameLabel.hidden = YES;
            self.colorTextLabel.hidden = YES;
            self.colorDetailLabel.hidden = YES;
            self.sizeCollectionView.hidden =YES;
            self.sizeImage.hidden = YES;
            self.sizeTextLabel.hidden = YES;
            self.sizeDetailLabel.hidden = YES;
            self.optionTextLabel.hidden = YES;
            self.optionImage.hidden = YES;
        }else if ([self.dataSource.flavor count] >0){
            self.colorTextLabel.text = @"Flavor";
            colorsDataSource = self.dataSource.flavor;
            //flavorDataSource = self.dataSource.flavor;
        }
        else{
            sizeDataSource = self.dataSource.sizes;
            self.fitCollectionView.hidden = YES;
            self.fitImage.hidden = YES;
            self.fitDetailLabel.hidden = YES;
            self.fitLabel.hidden = YES;
        }
        self.fitLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    else{
        
        fitDataSource = [self.dataSource.fits mutableCopy];
        colorsDataSource = self.dataSource.colors;
        if (colorsDataSource.count>0) {
            sizeDataSource = self.dataSource.sizes;
        }
        
        
    }
    
}


- (void)viewDidLayoutSubviews
{
    //collapse the Views - Fit , Size , Inseam, Color
    
    [super viewDidLayoutSubviews];
    if ([fitDataSource count] == 0 ) {
        self.fitHeightConstraint.constant = 0.0;
        [self checkTopConstraint];
    }
    if (!colorsDataSource) {
        self.colorHeightConstraint.constant = 0.0;
        [self checkTopConstraint];
    }
    else {
        self.colorHeightConstraint.constant = 91.0;
        [self checkTopConstraint];
    }
    if (!sizeDataSource || ([sizeDataSource count] == 0)) {
        self.sizeHeightConstraint.constant = 0.0;
        [self checkTopConstraint];
    }
    else {
        self.sizeHeightConstraint.constant = 91.0;
        [self checkTopConstraint];
    }
    if (!optionDataSource || ([optionDataSource count] == 0)) {
        self.optionHeightConstraint.constant = 0.0;
        [self checkTopConstraint];
    }
    else {
        self.optionHeightConstraint.constant = 91.0;
        [self checkTopConstraint];
    }
    
    //    _fitCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 70);
    //    _colorCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 70);
    //    _sizeCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 70);
    //    _optionCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 70);
    
}

- (void)checkTopConstraint
{
    //shrink the total popupView height
    
    if ((fitDataSource && ([fitDataSource count] > 0)) && (colorsDataSource || ([colorsDataSource count] > 0)) && (sizeDataSource && ([sizeDataSource count] > 0)) && (optionDataSource && ([optionDataSource count] > 0))) {
        self.popupViewTOpConstraint.constant = self.view.frame.size.height-461;
        self.fitLine.hidden = NO;
        self.sizeLine.hidden = NO;
        self.optionLine.hidden = NO;
        self.optionTextLabel.hidden = NO;
        self.optionView.hidden = NO;
        self.sizeImage.hidden = NO;
        self.sizeTextLabel.hidden = NO;
        self.optionImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"drop.png"]];
    }
    else if ((fitDataSource && ([fitDataSource count] > 0)) && (colorsDataSource && ([colorsDataSource count] > 0)) && (sizeDataSource && ([sizeDataSource count] > 0))) {
        self.popupViewTOpConstraint.constant = self.view.frame.size.height-370;
        self.optionTextLabel.hidden = YES;
        //self.optionLine.hidden = YES;
        //self.optionImage.hidden = YES;
        self.fitLine.hidden = NO;
        self.sizeLine.hidden = NO;
        self.sizeImage.hidden = NO;
        self.sizeTextLabel.hidden = NO;
    }
    else if ((fitDataSource && ([fitDataSource count] > 0)) && (colorsDataSource && ([colorsDataSource count] > 0))) {
        self.popupViewTOpConstraint.constant = self.view.frame.size.height-279;
        self.fitLine.hidden = NO;
        self.sizeTextLabel.hidden = YES;
        self.sizeImage.hidden = YES;
        //self.optionImage.hidden = YES;
        //self.optionTextLabel.hidden = YES;
        self.colorTextLabel.hidden = NO;
        self.colorImage.hidden = NO;
        self.colorNameLabel.hidden = NO;

    }
    else if ((colorsDataSource && ([colorsDataSource count] > 0)) && (sizeDataSource && ([sizeDataSource count] > 0))) {
        self.popupViewTOpConstraint.constant = self.view.frame.size.height-275;
        //self.optionImage.hidden = YES;
        //self.optionTextLabel.hidden = YES;
        self.fitLine.hidden = YES;
        self.optionLine.hidden = YES;
        self.fitImage.hidden = YES;
        self.sizeTextLabel.hidden = NO;
        self.sizeLine.hidden = NO;
        self.sizeImage.hidden = NO;
    }
    else if (sizeDataSource && ([sizeDataSource count] > 0)) {
        self.popupViewTOpConstraint.constant = self.view.frame.size.height-184;
        self.fitLine.hidden = YES;
        self.sizeLine.hidden = YES;
        self.optionLine.hidden = YES;
        self.optionImage.hidden = YES;
        self.optionTextLabel.hidden = YES;
    }
    else if (fitDataSource && ([fitDataSource count] > 0)){
        if ([fieldName0 isEqualToString:@"option 1"]) {
            self.fitLine.hidden = YES;
            self.sizeLine.hidden = YES;
            self.optionLine.hidden = YES;
            self.popupViewTOpConstraint.constant = self.view.frame.size.height-278;
            self.colorImage.hidden = YES;
            self.colorNameLabel.hidden = YES;
            self.colorTextLabel.hidden = YES;
            self.sizeTextLabel.hidden = YES;
            self.sizeImage.hidden = YES;
            self.optionTextLabel.hidden = YES;
            self.optionImage.hidden = YES;
            
        }else{
            self.popupViewTOpConstraint.constant = self.view.frame.size.height-186;
            self.fitLine.hidden = YES;
            self.sizeLine.hidden = YES;
            self.optionLine.hidden = YES;
            //self.fitImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"option.png"]];
        }
    }
    else if ((colorsDataSource || ([colorsDataSource count] > 0)) && (sizeDataSource && ([sizeDataSource count] > 0)) && (optionDataSource && ([optionDataSource count] > 0))) {
        self.popupViewTOpConstraint.constant = self.view.frame.size.height-457;
    }
    else if (colorsDataSource && ([colorsDataSource count] > 0)) {
        self.popupViewTOpConstraint.constant = self.view.frame.size.height-184;
        self.fitLine.hidden = YES;
        self.sizeLine.hidden = YES;
        self.optionLine.hidden = YES;
        self.sizeImage.hidden = YES;
        self.sizeTextLabel.hidden = YES;
    }
    
    
    
    [self.view layoutIfNeeded];
    
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.fitCollectionView) {
        return ([self.dataSource.fits count] > 0) ? [self.dataSource.fits count] : ([self.dataSource.option1 count] > 0) ? [self.dataSource.option1 count] : ([self.dataSource.styles count] > 0) ? [self.dataSource.styles count] : [self.dataSource.option.options count];
    }
    else if(collectionView == self.colorCollectionView) {
        return (colorsDataSource) ? [colorsDataSource count] : [self.dataSource.colors count];
    }
    else if(collectionView == self.optionCollectionView) {
        return (optionDataSource) ? [optionDataSource count] : [optionDataSource count];
    }
    return [sizeDataSource count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    
    if (collectionView == self.fitCollectionView){
        ProductFitModel *model = [fitDataSource objectAtIndex:indexPath.row];
        if ([self.dataSource.option.options count] > 0) {
            if ([fieldName0 isEqualToString:@"options"]) {
                self.fitLabel.text = @"Options:";
                SizeCollectionViewCell *sizeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sizeCell" forIndexPath:indexPath];
                sizeCell.sizeLabel.text = model.value;
                sizeCell.layer.borderColor = [UIColor grayColor].CGColor;
                cell = sizeCell;
            }else{
                ColorCollectionViewCell *colorCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"colorCell" forIndexPath:indexPath];
                self.fitLabel.text = @"Option:";
                [colorCell.colorImageView setImageWithURL:[NSURL URLWithString:model.value]];
                colorCell.colorImageView.layer.cornerRadius = 2.0;
                colorCell.colorImageView.layer.masksToBounds = YES;
                colorCell.layer.masksToBounds = YES;//NailPolish selection layer
                //For multiple selections:
                if (indexPath.row==selectedRow) {
                    [colorCell setSelected:YES];
                    [colorCell.layer setBorderColor:[UIColor selectedGrayColor].CGColor];
                    [colorCell.layer setBorderWidth:2.5f];
                    [colorCell.layer setCornerRadius:2.0f];
                }else{
                    [colorCell setSelected:NO];
                    [colorCell.layer setBorderColor:[UIColor clearColor].CGColor];
                    [colorCell.layer setBorderWidth:0.0f];
                    [colorCell.layer setCornerRadius:0.0f];
                    
                }
                
                cell = colorCell;
            }
        }
        else {
            SizeCollectionViewCell *sizeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sizeCell" forIndexPath:indexPath];
            sizeCell.sizeLabel.text = (([self.dataSource.option1 count] > 0) || ([self.dataSource.styles count] > 0)) ? model.text : model.value;
            sizeCell.layer.borderColor = [UIColor grayColor].CGColor;
            cell = sizeCell;
        }
        
        
        NSIndexPath *indexPathForFirstRow = [NSIndexPath indexPathForRow:selectedRow inSection:0];
        [self.fitCollectionView selectItemAtIndexPath:indexPathForFirstRow animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self collectionView:self.fitCollectionView didSelectItemAtIndexPath:indexPathForFirstRow];
    }
    if (collectionView == self.colorCollectionView) {
        if (selectedOption1Model) {
            ProductOption1Model *model = [colorsDataSource objectAtIndex:indexPath.row];
            SizeCollectionViewCell *sizeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sizeCell" forIndexPath:indexPath];
            
            sizeCell.sizeLabel.text = model.text;
            sizeCell.layer.borderColor = [UIColor grayColor].CGColor;
            cell = sizeCell;
            self.sizeCollectionView.hidden = NO;
            NSIndexPath *indexPathForFirstRow = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.colorCollectionView selectItemAtIndexPath:indexPathForFirstRow animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            [self collectionView:self.colorCollectionView didSelectItemAtIndexPath:indexPathForFirstRow];
        }else if (selectedFlavorModel){
            ProductFlavorModel *model = [colorsDataSource objectAtIndex:indexPath.row];
            SizeCollectionViewCell *sizeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sizeCell" forIndexPath:indexPath];
            sizeCell.sizeLabel.text = model.text;
            sizeCell.layer.borderColor = [UIColor grayColor].CGColor;
            cell = sizeCell;
            
        }
        else {
            ProductColorModel *model = [colorsDataSource objectAtIndex:indexPath.row];
            ColorCollectionViewCell *colorCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"colorCell" forIndexPath:indexPath];
            
            if ([model.value containsString:@"http"]) {
                [colorCell.colorImageView setImageWithURL:[NSURL URLWithString:model.value]];
            }else{
                [colorCell.colorImageView setImageWithURL:[NSURL URLWithString:model.image]];
            }
            
            colorCell.colorImageView.layer.cornerRadius = 2.0;
            colorCell.colorImageView.layer.masksToBounds = YES;
            cell = colorCell;
            NSIndexPath *indexPathForFirstRow = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.colorCollectionView selectItemAtIndexPath:indexPathForFirstRow animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            [self collectionView:self.colorCollectionView didSelectItemAtIndexPath:indexPathForFirstRow];
        }
    }
    if (collectionView == self.sizeCollectionView){
        SizeCollectionViewCell *sizeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sizeCell" forIndexPath:indexPath];
        if (collectionView == self.fitCollectionView) {
            ProductFitModel *fitModel = [self.dataSource.fits objectAtIndex:indexPath.row];
            sizeCell.sizeLabel.text = fitModel.value;
            sizeCell.layer.borderColor = [UIColor grayColor].CGColor;
        }
        else {
            sizeModel = [sizeDataSource objectAtIndex:indexPath.row];
            sizeCell.sizeLabel.text = sizeModel.text;
            sizeCell.layer.borderColor = [UIColor grayColor].CGColor;
        }
        cell = sizeCell;
        cell.layer.cornerRadius = 2.0f;
        cell.layer.masksToBounds = YES;
        NSIndexPath *indexPathForFirstRow = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.sizeCollectionView selectItemAtIndexPath:indexPathForFirstRow animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self collectionView:self.sizeCollectionView didSelectItemAtIndexPath:indexPathForFirstRow];
    }
    
    if (collectionView == self.optionCollectionView) {
        SizeCollectionViewCell *sizeCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sizeCell" forIndexPath:indexPath];
        ProductOption1Model *model = [optionDataSource objectAtIndex:indexPath.row];
        sizeCell.sizeLabel.text = model.text;
        sizeCell.layer.borderColor = [UIColor grayColor].CGColor;
        cell = sizeCell;
        cell.layer.cornerRadius = 2.0f;
        cell.layer.masksToBounds = YES;
        //Solve for multiple selection:
        if (indexPath.row==selectedRow) {
            [sizeCell setSelected:YES];
            [cell.layer setBorderColor:[UIColor selectedGrayColor].CGColor];
            [cell.layer setBorderWidth:2.5f];
            [cell.layer setCornerRadius:2.0f];
        }else{
            [sizeCell setSelected:NO];
            [cell.layer setBorderColor:[UIColor clearColor].CGColor];
            [cell.layer setBorderWidth:0.0f];
            [cell.layer setCornerRadius:0.0f];
            
        }
    }
    
    if (cell.selected){
        [cell.layer setBorderColor:[UIColor selectedGrayColor].CGColor];
        [cell.layer setBorderWidth:2.5f];
        [cell.layer setCornerRadius:2.0f];
    }else{
        [cell.layer setBorderColor:[UIColor clearColor].CGColor];
        [cell.layer setBorderWidth:0.0f];
        [cell.layer setCornerRadius:0.0f];
    }
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.fitCollectionView) {
        selectedRow=indexPath.row;
        
        if ([self.dataSource.fits count] > 0) {
            selectedFitModel = [self.dataSource.fits objectAtIndex:indexPath.row];
            colorsDataSource = selectedFitModel.colors;
            [self.colorCollectionView reloadData];
            [self viewDidLayoutSubviews];
            ProductFitModel *model = [fitDataSource objectAtIndex:indexPath.row];
            selectedFit = model.text;
        }
        else if ([self.dataSource.option1 count] > 0) {
            selectedOption1Model = (ProductOption1Model *)[self.dataSource.option1 objectAtIndex:indexPath.row];
            colorsDataSource = selectedOption1Model.subOptions;
            NSLog(@"colorsDataSource:%@",colorsDataSource);
            self.colorCollectionView.hidden = NO;
            [self viewDidLayoutSubviews];
            [self.colorCollectionView reloadData];
        }
        else if ([self.dataSource.styles count] > 0) {
            selectedStyleModel = (BaseProductAttributeModel *)[self.dataSource.styles objectAtIndex:indexPath.row];
        }
        else {
            selectedOptionModel = [self.dataSource.option.options objectAtIndex:indexPath.row];
        }
    }
    else if (collectionView == self.colorCollectionView) {
        selectedRow=indexPath.row;
        if ([selectedOption1Model.subOptions count] > 0) {
            selectedOption2Model = [selectedOption1Model.subOptions objectAtIndex:indexPath.row];
            sizeDataSource = selectedOption2Model.subOptions;
            NSLog(@"option:%@",sizeDataSource);
            [self viewDidLayoutSubviews];
            self.sizeCollectionView.hidden = NO;
            [_sizeCollectionView reloadData];
        }
        else {
            selectedColorModel = [colorsDataSource objectAtIndex:indexPath.row];
            if (selectedColorModel.styles) {
                sizeDataSource = selectedColorModel.styles;
            }
            else {
                sizeDataSource = selectedColorModel.sizes;
            }
            [self viewDidLayoutSubviews];
            [self.sizeCollectionView reloadData];
            
            ProductColorModel *model = [colorsDataSource objectAtIndex:indexPath.row];
            selectedColor = model.text;
            self.colorNameLabel.text=model.text;
           // NSLog(@"selectedColor %@",selectedColor);
        }
        
        
        
    }
    else if (collectionView == self.sizeCollectionView){
        if ([selectedOption2Model.subOptions count] > 0) {
            selectedOption3Model = [sizeDataSource objectAtIndex:indexPath.row];
            optionDataSource = selectedOption3Model.subOptions;
            [self viewDidLayoutSubviews];
            NSLog(@"option:%@",optionDataSource);
            [self.optionCollectionView reloadData];
            [self viewDidLayoutSubviews];
        }
        else {
            // NSLog(@"%@",selectedColorModel.styles);
            //if ([[sizeDataSource objectAtIndex:indexPath.row] isKindOfClass:[ProductColorModel class]]) {
            //if ([[colorsDataSource objectAtIndex:0]valueForKey:@"styles"]){
            if ([selectedColorModel.styles count]>0) {
                selectedStyleModel = [sizeDataSource objectAtIndex:indexPath.row];
                self.sizeTextLabel.hidden = NO;
                self.sizeTextLabel.text = @"Style:";
            }
            else {
                ProductSizeModel *size = (ProductSizeModel*)[sizeDataSource objectAtIndex:indexPath.row];
                if ([size.inseam count]>0) {
                    //                    self.optionTextLabel.hidden = NO;
                    //                    self.optionTextLabel.text = @"Inseam:";
                    optionDataSource = size.inseam;
                    sizeModel = [sizeDataSource objectAtIndex:indexPath.row];
                    selectedSize = sizeModel.text;
                    [self viewDidLayoutSubviews];
                    [self.optionCollectionView reloadData];
                }
                else {
                    sizeModel = [sizeDataSource objectAtIndex:indexPath.row];
                    selectedSize = sizeModel.text;
                }
            }
        }
    }
    
    else if (collectionView == self.optionCollectionView){
       // NSLog(@"%@",selectedOption1Model);
        selectedRow=indexPath.row;
        if (selectedFitModel) {
            selectedInseamModel = [optionDataSource objectAtIndex:indexPath.row];
        }
        else{
            selectedOption4Model = [optionDataSource objectAtIndex:indexPath.row];
        }
    }
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [cell.layer setBorderColor:[UIColor selectedGrayColor].CGColor];
    [cell.layer setBorderWidth:2.5f];
    [cell.layer setCornerRadius:2.0f];
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [collectionView  cellForItemAtIndexPath:indexPath];
    [cell.layer setBorderColor:[UIColor clearColor].CGColor];
    [cell.layer setBorderWidth:0.0f];
    [cell.layer setCornerRadius:0.0f];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 10, 0, 0);
}

- (IBAction)submitButton:(id)sender {
    
    if ([qualityStr isEqualToString:@"LOW"]) {
        [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NEWNotification" object:nil];
    } else {
        
        [ServiceLayer googleTrackEventWithCategory:kEventCategoryAddToCart actionName:kEventActionAddToCart label:kEventLabelAddingToCart value:1];
        
        aModel.productMetadata_size = selectedSize;
        aModel.productMetadata_color = selectedColor;
        aModel.productMetadata_fit = selectedFit;
        
        //        NSLog(@"%ld", [self.dataSource.option.options count]);
        if ([fieldName0 isEqualToString:@"option"]) {
            aModel.productMetadata_option = selectedOptionModel.text;
        }
        if([fieldName0 isEqualToString:@"options"]){
            aModel.productMetadata_options = selectedOptionModel.text;
        }
        if (selectedOption1Model) {
            aModel.productMetadata_option1 = selectedOption1Model.text;
        }
        if (selectedOption2Model) {
            aModel.productMetadata_option2 = selectedOption2Model.text;
        }
        if (selectedOption3Model) {
            aModel.productMetadata_option3 = selectedOption3Model.text;
        }
        if (selectedOption4Model) {
            aModel.productMetadata_option4 = selectedOption4Model.text;
        }
        if (selectedStyleModel) {
            aModel.productMetadata_style = selectedStyleModel.text;
        }
        if (selectedInseamModel) {
            aModel.productMetadata_inseam = selectedInseamModel.text;
        }
        ServiceLayer *aService = [[ServiceLayer alloc]init];
        //        NSLog(@"%@", aModel.mediaId);
        if([mediaArray count] > 0){
            
            [[Crashlytics sharedInstance] setObjectValue:aModel.productId forKey:@"Product ID"];
            
//            [[Crashlytics sharedInstance] crash];
            
            [aService postAddToCart:[self formatedParametersDict] completion:^(NSDictionary *dictionary) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorSizeVCDismissed" object:nil];
                
            }];
            //            NSLog(@"%d", (int) [[NSUserDefaults standardUserDefaults] integerForKey:kNumberOfItemsInCartKey]);
            
        }else{
            
            [aService postShopAddToCart:[self shopAddParametersDict] completion:^(NSDictionary *dictionary) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorSizeVCDismissed" object:nil];
                
            }];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
}

-(NSDictionary*)formatedParametersDict{
    
    NSDictionary *parameters = @{@"user[id]": aModel.userId,
                                 @"product[id]":aModel.productId ,
                                 @"productMetadata[product][id]":aModel.productMetadata_productId,
                                 @"media[id]":[mediaArray valueForKey:@"id"],
                                 @"visualTag[id]":aModel.visualTagId,
                                 @"productMetadata[option]":(aModel.productMetadata_option)?aModel.productMetadata_option:[NSNull null] ,
                                 @"productMetadata[fit]":(aModel.productMetadata_fit)?(aModel.productMetadata_fit): (@" ") ,
                                 @"productMetadata[color]":(aModel.productMetadata_color)?(aModel.productMetadata_color): (@" ") ,
                                 @"productMetadata[size]":(aModel.productMetadata_size)?(aModel.productMetadata_size): (@" "),
                                 @"productMetadata[options]":(aModel.productMetadata_options)?aModel.productMetadata_options:[NSNull null],
                                 @"productMetadata[inseam]":(aModel.productMetadata_inseam)?aModel.productMetadata_inseam:[NSNull null],
                                 @"productMetadata[style]": (aModel.productMetadata_style)?aModel.productMetadata_style:[NSNull null],
                                 @"productMetadata[option1]":(aModel.productMetadata_option1)?aModel.productMetadata_option1:[NSNull null],
                                 @"productMetadata[option2]":(aModel.productMetadata_option2)?aModel.productMetadata_option2:[NSNull null] ,
                                 @"productMetadata[option3]":(aModel.productMetadata_option3)?aModel.productMetadata_option3:[NSNull null] ,
                                 @"productMetadata[option4]":(aModel.productMetadata_option4)?aModel.productMetadata_option4:[NSNull null] ,
                                 @"productMetadata[price]":aModel.price ,
                                 @"productMetadata[availability]":aModel.productMetadata_availability ,
                                 @"quantity":aModel.quantity ,
                                 @"shippingMethod":aModel.shippingMethod ,
                                 @"originalUrl":aModel.originalUrl};
    
//    NSLog(@"FORMATED DICT:%@", parameters);
    
    return parameters;
}

-(NSDictionary*)shopAddParametersDict{
    NSDictionary *parameters = @{@"user[id]": aModel.userId,
                                 @"product[id]":aModel.productId ,
                                 @"productMetadata[product][id]":aModel.productMetadata_productId,
                                 @"productMetadata[option]":(aModel.productMetadata_option)?aModel.productMetadata_option:[NSNull null] ,
                                 @"productMetadata[fit]":(aModel.productMetadata_fit)?(aModel.productMetadata_fit): (@" ") ,
                                 @"productMetadata[color]":(aModel.productMetadata_color)?(aModel.productMetadata_color): (@" "),
                                 @"productMetadata[size]":(aModel.productMetadata_size)?(aModel.productMetadata_size): (@" "),
                                 @"productMetadata[options]":(aModel.productMetadata_options)?aModel.productMetadata_options:[NSNull null],
                                 @"productMetadata[inseam]":(aModel.productMetadata_inseam)?aModel.productMetadata_inseam:[NSNull null],
                                 @"productMetadata[style]": (aModel.productMetadata_style)?aModel.productMetadata_style:[NSNull null],
                                 @"productMetadata[option1]":(aModel.productMetadata_option1)?aModel.productMetadata_option1:[NSNull null],
                                 @"productMetadata[option2]":(aModel.productMetadata_option2)?aModel.productMetadata_option2:[NSNull null] ,
                                 @"productMetadata[option3]":(aModel.productMetadata_option3)?aModel.productMetadata_option3:[NSNull null] ,
                                 @"productMetadata[option4]":(aModel.productMetadata_option4)?aModel.productMetadata_option4:[NSNull null] ,
                                 @"productMetadata[price]":aModel.price ,
                                 @"productMetadata[availability]":aModel.productMetadata_availability ,
                                 @"quantity":aModel.quantity ,
                                 @"shippingMethod":aModel.shippingMethod ,
                                 @"originalUrl":aModel.originalUrl};
    
//    NSLog(@"SHOPP ADD DICT:%@", parameters);
    
    return parameters;
}

-(void) viewDidAppear:(BOOL)animated{
    
}

@end
