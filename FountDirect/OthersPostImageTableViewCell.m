//
//  OthersPostImageTableViewCell.m
//  Fount
//
//  Created by Zhang Xu on 7/12/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "OthersPostImageTableViewCell.h"
#import "PostImageCollectionViewCell.h"
#import "Product.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation OthersPostImageTableViewCell

static NSString *const postIdentifier = @"PostMessageCell";
static NSString *const productIdentifier = @"ProductMessageCell";

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
    _messageView.layer.cornerRadius = 10;
    _messageView.layer.masksToBounds = YES;
    
    [self setupCollectionView];
}

-(void)setupCollectionView{
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"PostImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:postIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ProductMessageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:productIdentifier];
}

#pragma mark - CollectionView Datasource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    self.pageControl.numberOfPages = self.contentsCount;
    return self.contentsCount;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //MEDIA
    if ([self.messageType isEqualToString:@"MEDIA"]) {

        Product *productModel = self.productsArray[indexPath.row];

        if (indexPath.row == 0) {
            
            PostImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:postIdentifier forIndexPath:indexPath];
            
            NSString *profileUrlString;
            if ([self.mediaDictionary valueForKey:@"instagramUserProfileUrl"]) {
                profileUrlString = [self.mediaDictionary valueForKey:@"instagramUserProfileUrl"];
            }else{
                profileUrlString = [self.mediaDictionary valueForKey:@"fountUserProfileUrl"];
            }
            
            [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:profileUrlString] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            }];
            
            NSString *postOwnerNameString;
            if ([self.mediaDictionary valueForKey:@"instagramUserName"]) {
                postOwnerNameString = [self.mediaDictionary valueForKey:@"instagramUserName"];
            }else{
                postOwnerNameString = [self.mediaDictionary valueForKey:@"fountUserName"];
            }
            cell.nameLabel.text = postOwnerNameString;
            cell.captionLabel.text = [self.mediaDictionary valueForKey:@"caption"];
            [cell.postImageView sd_setImageWithURL:[NSURL URLWithString:[self.mediaDictionary valueForKey:@"standardResolutionURL"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            }];
            
            return cell;
            
        }else{
            ProductMessageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:productIdentifier forIndexPath:indexPath];

            cell.product = productModel;
            cell.productDictionary = [_productsArray objectAtIndex:indexPath.row];
            [cell setupCell];
            cell.delegate = self;
            
            return cell;
        }
        
    //PRODUCTS
    }else{
        NSDictionary *relevantMediaDictionary = self.relevantMediaArray[indexPath.row];
        
        if (indexPath.row == 0) {
            
            ProductMessageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:productIdentifier forIndexPath:indexPath];
            cell.product = self.productsArray[0];
            cell.productDictionary = [self.productsArray objectAtIndex:0];
            cell.delegate = self;
            [cell setupCell];
            
            return cell;
            
        }else{
            
            PostImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:postIdentifier forIndexPath:indexPath];
            
            NSString *profileUrlString;
            if ([relevantMediaDictionary objectForKey:@"instagramUserProfileUrl"]) {
                profileUrlString = [relevantMediaDictionary valueForKey:@"instagramUserProfileUrl"];
            }else{
                profileUrlString = [relevantMediaDictionary valueForKey:@"fountUserProfileUrl"];
            }
            
            [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:profileUrlString] placeholderImage:[UIImage imageNamed:@"placeholderprofile"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            }];
            
            NSString *postOwnerNameString;
            if ([relevantMediaDictionary valueForKey:@"instagramUserName"]) {
                postOwnerNameString = [relevantMediaDictionary valueForKey:@"instagramUserName"];
            }else{
                postOwnerNameString = [relevantMediaDictionary valueForKey:@"fountUserName"];
            }
            cell.nameLabel.text = postOwnerNameString;
            cell.captionLabel.text = [relevantMediaDictionary valueForKey:@"caption"];
            
            [cell.postImageView sd_setImageWithURL:[NSURL URLWithString:[relevantMediaDictionary valueForKey:@"standardResolutionURL"]] placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            }];
            
            return cell;
        }
    }
}

#pragma mark - ProductMessageCell Delegate
-(void)addToCartWithProductDictionary:(NSDictionary *)dictionary{
    [self.delegate othersPostAddTocart:dictionary];
}

-(void)goToWebsiteWithProductDictionary:(NSDictionary *)dictionary{
    [self.delegate othersPostGoToWebsite:dictionary];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat pageWidth = self.collectionView.frame.size.width;
    //    NSLog(@"%f",self.collectionView.contentOffset.x);
    
    int widthDifference = fabs((200+20)*2 - pageWidth);
    
    if (self.collectionView.contentOffset.x <= widthDifference) {
        self.pageControl.currentPage = self.collectionView.contentOffset.x / widthDifference;
    }else{
        self.pageControl.currentPage = ((self.collectionView.contentOffset.x - widthDifference) / 220 + 1);
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
