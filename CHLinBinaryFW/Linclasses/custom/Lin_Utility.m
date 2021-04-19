//
//  Lin_Utility.m
//  callhippolin
//
//  Created by Admin on 30/04/19.
//  Copyright © 2019 Admin. All rights reserved.
//

#import "Lin_Utility.h"



@implementation Lin_Utility
{
   
}

#pragma mark - Linphone Login

+(void)Lin_call_login:(NSString *)Username domain:(NSString *)Domain password:(NSString *)Password type:(NSString *)Type
{
    
//    linphone_core_load_config_from_xml(LC,
//                                       [LinphoneManager bundleFile:@"assistant_external_sip.rc"].UTF8String);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        @try {
            
            NSString *domain = Domain;
            NSString *username = Username;
            NSString *displayName = @"";
            NSString *pwd = Password;
            
            NSLog(@"domain : %@",domain);
            NSLog(@"username : %@",username);
            NSLog(@"displayName : %@",displayName);
            NSLog(@"pwd : %@",pwd);
            
            LinphoneProxyConfig *config = linphone_core_create_proxy_config(LC);
            LinphoneAddress *addr = linphone_address_new(NULL);
            LinphoneAddress *tmpAddr = linphone_address_new([NSString stringWithFormat:@"sip:%@",domain].UTF8String);
            
            linphone_address_set_username(addr, username.UTF8String);
            linphone_address_set_port(addr, linphone_address_get_port(tmpAddr));
            linphone_address_set_domain(addr, linphone_address_get_domain(tmpAddr));
            if (displayName && ![displayName isEqualToString:@""]) {
                linphone_address_set_display_name(addr, displayName.UTF8String);
            }
            linphone_proxy_config_set_identity_address(config, addr);
            NSString *type = @"";
            if([Type isEqualToString:@""])
            {
                type = @"UDP";
            }
            else
            {
                type = Type;
            }
            
            linphone_proxy_config_set_route(
                                            config,
                                            [NSString stringWithFormat:@"%s;transport=%s", domain.UTF8String, type.lowercaseString.UTF8String]
                                            .UTF8String);
            linphone_proxy_config_set_server_addr(
                                                  config,
                                                  [NSString stringWithFormat:@"%s;transport=%s", domain.UTF8String, type.lowercaseString.UTF8String]
                                                  .UTF8String);
            //    }
            linphone_proxy_config_enable_publish(config, TRUE);
            linphone_proxy_config_enable_register(config, TRUE);
            
            LinphoneAuthInfo *info =
            linphone_auth_info_new(linphone_address_get_username(addr), // username
                                   NULL,                                // user id
                                   pwd.UTF8String,                        // passwd
                                   NULL,                                // ha1
                                   linphone_address_get_domain(addr),   // realm - assumed to be domain
                                   linphone_address_get_domain(addr)    // domain
                                   );
            @autoreleasepool {
                sleep(2);
                linphone_core_add_auth_info(LC, info);
            }
            
//           @try {
//
//
//                    //NSLog(@"Trushang : EndPoinnts : login : time :  %@",[NSDate date]);
//                    if (config != NULL) {
//                   const LinphoneAuthInfo *auth = linphone_proxy_config_find_auth_info(config);
//                   if (auth) {
//                       LinphoneAuthInfo * newAuth = linphone_auth_info_clone(auth);
//                       linphone_core_remove_auth_info(LC, auth);
//                       linphone_core_add_auth_info(LC, newAuth);
//                   }
//                   else
//                   {
//                       linphone_core_add_auth_info(LC, info);
//                   }
//               }
//
//           }
//            @catch (NSException *exception)
//            {
//                //NSLog(@"\n \n \n \n \n \n ");
//                //NSLog(@"ERROR ERROR ERROR  ----- > 1 %@",exception.description);
//                //NSLog(@"\n \n \n \n \n \n ");
//            }
               
            linphone_address_unref(addr);
            linphone_address_unref(tmpAddr);
            
            if (config) {
                [[LinphoneManager instance] configurePushTokenForProxyConfig:config];
                if (linphone_core_add_proxy_config(LC, config) != -1) {
                    linphone_core_set_default_proxy_config(LC, config);
                    // reload address book to prepend proxy config domain to contacts' phone number
                    // todo: STOP doing that!
                    //                [[LinphoneManager.instance fastAddressBook] fetchContactsInBackGroundThread];
                    //                //[PhoneMainView.instance changeCurrentView:DialerView.compositeViewDescription];
                    NSLog(@"\n \n \n CallHippo : Done \n \n \n");
                } else
                {
                    //NSLog(@"\n \n \n CallHippo : Error1 \n \n \n");
                    //                  [self displayAssistantConfigurationError];
                }
            } else
            {
                //NSLog(@"\n \n \n CallHippo : Error2 \n \n \n");
                //            [self displayAssistantConfigurationError];
            }
        }
        @catch (NSException *exception)
        {
                           NSLog(@"\n \n \n \n \n \n ");
                           NSLog(@"ERROR ERROR ERROR  ----- > 2 %@",exception.description);
                           NSLog(@"\n \n \n \n \n \n ");
        }
        
        
        
    });
    
}
+ (void)displayAssistantConfigurationError
{
    UIWindow *windows = [[UIApplication sharedApplication].delegate window];
    UIViewController *vc = windows.rootViewController;
    UIAlertController *errView = [UIAlertController
                                  alertControllerWithTitle:NSLocalizedString(@"Assistant error", nil)
                                  message:NSLocalizedString(
                                                            @"Could not configure your account, please check parameters or try again later",
                                                            nil)
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action){
                                                          }];
    
    [errView addAction:defaultAction];
    [vc presentViewController:errView animated:YES completion:nil];
    
    return;
}

+(void)Linphone_all_login
{
    const bctbx_list_t *accounts = linphone_core_get_proxy_config_list(LC);
    size_t count = bctbx_list_size(accounts);
    
    for (size_t i = 1; i <= count; i++, accounts = accounts->next) {
        LinphoneProxyConfig *proxy = (LinphoneProxyConfig *)accounts->data;
//        //NSLog(@"Provider : %s",linphone_address_get_domain(linphone_proxy_config_get_identity_address(proxy)));
        //        phone.plivo.com
        NSString *string = [NSString stringWithFormat:@"%s",linphone_address_get_domain(linphone_proxy_config_get_identity_address(proxy))];
        
        NSString *name = [NSString
                         stringWithUTF8String:linphone_address_get_username(linphone_proxy_config_get_identity_address(proxy))];
        //NSLog(@"Trushang_Patel : ALL Login : %@",name);
    }
    
}

//+(void)Linphone_set_login:(NSString *)Username
//{
//    const bctbx_list_t *accounts = linphone_core_get_proxy_config_list(LC);
//    size_t count = bctbx_list_size(accounts);
//
//    for (size_t i = 1; i < count; i++, accounts = accounts->next) {
//        LinphoneProxyConfig *proxy = (LinphoneProxyConfig *)accounts->data;
//        //NSLog(@"Provider : %s",linphone_address_get_domain(linphone_proxy_config_get_identity_address(proxy)));
//        //        phone.plivo.com
//        NSString *string = [NSString stringWithFormat:@"%s",linphone_address_get_domain(linphone_proxy_config_get_identity_address(proxy))];
//
//        NSString *name = [NSString stringWithUTF8String:linphone_address_get_username(linphone_proxy_config_get_identity_address(proxy))];
//
//        //NSLog(@"Chetan ----- name ----- %@",name);
//        //NSLog(@"Chetan ----- Username ----- %@",Username);
//
//        if([name isEqualToString:Username])
//        {
//            LinphoneManager *lm = LinphoneManager.instance;
//            [lm configurePushTokenForProxyConfig:proxy];
//            linphone_core_set_default_proxy_config(LC, proxy);
//            [lm refreshRegisters];
//        }
//        //NSLog(@"Trushang_Patel : ALL Login : %@",name);
//    }
//}


+(void)checkProvider:(NSString*)countrySortName {
    NSMutableArray *callProviders;
    //   callProviders =  [[GlobalData sharedGlobalData] get_all_provider];
    callProviders =  [[NSUserDefaults standardUserDefaults] objectForKey:@"providersArray"];
    
    //NSLog(@"-------Providersss------------%@",callProviders);
    
    for (int i = 0 ; i < callProviders.count; i++) {
        if([countrySortName isEqualToString:callProviders[i][@"shortName"]]){
            //NSLog(@"Print out Going Call Provider 1 : %@",callProviders[i][@"outgoingCallProvider"]);
            NSString *outgoingCallProvider = callProviders[i][@"outgoingCallProvider"];
            if (outgoingCallProvider != (id)[NSNull null] && outgoingCallProvider != nil && ![outgoingCallProvider isEqualToString:@""]){
                //NSLog(@"Not Null");
                [self Linphone_set_login:callProviders[i][@"outgoingCallProvider"]];
                break;
            }
        }
    }
}

+(void)Linphone_set_login:(NSString*)provider{
    const bctbx_list_t *accounts = linphone_core_get_proxy_config_list(LC);
    size_t count = bctbx_list_size(accounts);
    
    for (size_t i = 1; i <= count; i++, accounts = accounts->next) {
        LinphoneProxyConfig *proxy = (LinphoneProxyConfig *)accounts->data;
        //NSLog(@"Provider : %s",linphone_address_get_domain(linphone_proxy_config_get_identity_address(proxy)));
        //        phone.plivo.com
        NSString *string = [NSString stringWithFormat:@"%s",linphone_address_get_domain(linphone_proxy_config_get_identity_address(proxy))];
                NSString *name = [NSString stringWithUTF8String:linphone_address_get_username(linphone_proxy_config_get_identity_address(proxy))];
        NSLog(@"Accoount login : %@",name);
        NSString *me = provider ;
        NSString *target = string ;
        NSRange range = [target  rangeOfString: me options: NSCaseInsensitiveSearch];
        //NSLog(@"found: %@", (range.location != NSNotFound) ? @"Yes" : @"No");
        //NSLog(@"found: %@ ----- %@",me,target);
        if (range.location != NSNotFound) {
            NSLog(@"Display Provider : %@",string);
            //            LinphoneManager *lm = LinphoneManager.instance;
            //            [lm configurePushTokenForProxyConfig:proxy];
            
            [LinphoneManager.instance configurePushTokenForProxyConfig:proxy];
            linphone_core_set_default_proxy_config(LC, proxy);
            [LinphoneManager.instance refreshRegisters];
        }else {
            NSLog(@"Not Found Provider");
        }
    }
}



/*

#pragma mark - Plivo Call


+(void)plivo_call_action:(NSString *)number
{
    [[CallKitInstance sharedInstance] configAudioSession:[AVAudioSession sharedInstance]];
    [[Phone sharedInstance] configureAudioSession];
    [[Phone sharedInstance] startAudioDevice];
    
    
    
    NSString *userID = [Default valueForKey:USER_ID];
    NSString *selno1 = [Default valueForKey:SELECTEDNO];
    
    NSString *selno = [number stringByReplacingOccurrencesOfString:@"+" withString:@""];
    selno = [selno stringByReplacingOccurrencesOfString:@"(" withString:@""];
    selno = [selno stringByReplacingOccurrencesOfString:@")" withString:@""];
    selno = [selno stringByReplacingOccurrencesOfString:@" " withString:@""];
    selno = [selno stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    //NSLog(@"\n \n \n Plivo_call_number : %@",selno);
    
    [Default setValue:selno forKey:CALL_NUMBER];
    NSDictionary *extraHeaders = @{@"X-PH-Userid":userID,@"X-PH-Fromnumber":selno1,@"X-PH-Devicetype":@"iOS"};
    
    
    PlivoOutgoing *plivo_outgoing_call;
    [CallKitInstance sharedInstance].callUUID = [NSUUID UUID];
    [CallKitInstance sharedInstance].calls_uuids = [[NSMutableArray alloc] init];
    /* outgoing call */
    
    //[[CallKitInstance sharedInstance] performStartCallActionWithUUID:[CallKitInstance sharedInstance].callUUID handle:selno];
//    plivo_outgoing_call = [[Phone sharedInstance] callWithDest:selno andHeaders:extraHeaders];
    
    
//}

@end
