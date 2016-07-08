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


@end
