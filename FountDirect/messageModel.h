//
//  messageModel.h
//  Fount Direct
//
//  Created by Zhang Xu on 6/30/16.
//  Copyright © 2016 Syw. All rights reserved.
//

#import "BaseModel.h"

@interface messageModel : BaseModel

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *textContent;
@property (nonatomic, strong) NSString *timePassed;
@property (nonatomic, assign) BOOL isVisible;

@property (nonatomic, strong) NSString *fromUserDisplayName;
@property (nonatomic, assign) BOOL confirmRegistrationStatus;
@property (nonatomic, strong) NSString *entityName;
@property (nonatomic, assign) NSInteger fromUserId;

@property (nonatomic, strong) NSString *fromProfilePicture;
@property (nonatomic, assign) BOOL fromPrivateSetting;
@property (nonatomic, strong) NSString *fromFullName;
@property (nonatomic, strong) NSString *fromBio;

@property (nonatomic, strong) NSDictionary *mediaDictionary;
@property (nonatomic, strong) NSString *mediaCaption;
@property (nonatomic, assign) NSInteger mediaId;
@property (nonatomic, strong) NSString *mediaType;
@property (nonatomic, strong) NSString *mediaSource;
@property (nonatomic, assign) NSInteger mediaOwner, mediaUploader;

//@property (nonatomic, assign) NSInteger mediaLowResolutionWidth;
//@property (nonatomic, assign) NSInteger mediaLowResolutionHeight;
//@property (nonatomic, strong) NSString *mediaLowResolutionURL;

@property (nonatomic, assign) NSInteger mediaStandardResolutionWidth;
@property (nonatomic, assign) NSInteger mediaStandardResolutionHeight;
@property (nonatomic, strong) NSString *mediaStandardResolutionURL;

//@property (nonatomic, assign) NSInteger mediaThumbnailHeight;
//@property (nonatomic, strong) NSString *mediaThumbnailURL;
//@property (nonatomic, assign) NSInteger mediaThumbnailWidth;
@property (nonatomic, strong) NSString *mediaTags;
@property (nonatomic, strong) NSString *mediaIgUploaderName;
@property (nonatomic, strong) NSString *mediaIgUploaderProfileUrl;
@property (nonatomic, strong) NSString *mediaFountUploaderName;
@property (nonatomic, strong) NSString *mediaFountUploaderProfileUrl;

@property (nonatomic, strong) NSMutableArray *arrayOfProducts;
@property (nonatomic, strong) NSMutableArray *arrayOfRelevantMedias;

@end
