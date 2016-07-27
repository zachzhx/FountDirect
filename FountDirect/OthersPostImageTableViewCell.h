//
//  OthersPostImageTableViewCell.h
//  Fount
//
//  Created by Zhang Xu on 7/12/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductMessageCollectionViewCell.h"

@protocol othersPostCellDelegate <NSObject>

-(void)othersPostAddTocart:(NSDictionary *)productDictionary;
-(void)othersPostGoToWebsite:(NSDictionary *)productDictionary;

@end

@interface OthersPostImageTableViewCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource,ProductMessageCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIView *messageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) NSString *messageType;
//@property (nonatomic, strong) NSArray *mediaArray;
@property (nonatomic, strong) NSArray *productsArray;
@property (nonatomic, strong) NSDictionary *mediaDictionary;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profileToTopConstraint;

@property (nonatomic, strong) NSArray *relevantMediaArray;
@property (nonatomic, assign) NSInteger contentsCount;

@property (nonatomic, weak) id <othersPostCellDelegate> delegate;

@end
