//
//  Lin_Utility.h
//  callhippolin
//
//  Created by Admin on 30/04/19.
//  Copyright © 2019 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "linphone/linphonecore.h"
#import "LinphoneManager.h"
#import "Utils.h"

NS_ASSUME_NONNULL_BEGIN

@interface Lin_Utility : NSObject




+(void)Lin_call_login:(NSString *)Username domain:(NSString *)Domain password:(NSString *)Password type:(NSString *)Type;
+(void)Linphone_all_login;
+(void)Linphone_set_login:(NSString *)provider;
+(void)checkProvider:(NSString*)countrycode;
+(void)plivo_call_action:(NSString *)number;
@end

NS_ASSUME_NONNULL_END
