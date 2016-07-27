//
//  MyPostImageTableViewCell.h
//  Fount
//
//  Created by Zhang Xu on 7/12/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductMessageCollectionViewCell.h"

@protocol myPostCellDelegate <NSObject>

-(void)myPostAddTocart:(NSDictionary *)productDictionary;
-(void)myPostGoToWebsite:(NSDictionary *)productDictionary;

@end

@interface MyPostImageTableViewCell : UITableViewCell<UICollectionViewDataSource, UICollectionViewDelegate, ProductMessageCellDelegate>

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewWidthConstraint;

@property (nonatomic, strong)ProductMessageCollectionViewCell *productMessageCell;

@property (nonatomic, strong) NSString *messageType;
@property (nonatomic, strong) NSArray *productsArray;
@property (nonatomic, strong) NSDictionary *mediaDictionary;
//@property (nonatomic, strong) NSArray *mediaArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewLeadingConstraint;

@property (nonatomic, strong) NSArray *relevantMediaArray;
@property (nonatomic, assign) NSInteger contentsCount;

@property (nonatomic, weak) id<myPostCellDelegate> delegate;

@end
