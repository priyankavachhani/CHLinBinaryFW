//
//  ProviderDelegate.m
//  linphone
//
//  Created by REIS Benjamin on 29/11/2016.
//
//

#import "ProviderDelegate.h"
#import "LinphoneManager.h"
#import "PhoneMainView.h"
#include "linphone/linphonecore.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
//#import "IQKeyboardManager.h"
//#import "OnCallVC.h"
//#import "LoginVC.h"
//#import "DialerVC.h"
//#import "Constant.h"
//#import "MainViewController.h"
//#import "UIViewController+LGSideMenuController.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
//#import "WebApiController.h"
//#import "UtilsClass.h"
//#import "GlobalData.h"
//#import "AppDelegate.h"
//#import "twilio_callkit.h"
#import "Log.h"

@implementation ProviderDelegate


- (instancetype)init {
//    NSLog(@"Provider_callkit :: init");
    self = [super init];
   // [[Phone sharedInstance] setDelegate:self];
    _calls = [[NSMutableDictionary alloc] init];
    self.uuids = [[NSMutableDictionary alloc] init];
    self.calls_uuids = [[NSMutableArray alloc] init];
    self.pendingCall = NULL;
    self.pendingAddr = NULL;
    self.pendingCallVideo = FALSE;
    self.Call_completed = false;
    CXCallController *callController = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];
    [callController.callObserver setDelegate:self queue:dispatch_get_main_queue()];
    self.controller = callController;
    self.callKitCalls = 0;
    if (!self) {
        LOGD(@"ProviderDelegate not initialized...");
    }
    return self;
}

- (void)config {
//    NSLog(@"Provider_callkit :: config");
    CXProviderConfiguration *config = [[CXProviderConfiguration alloc] initWithLocalizedName:@"CallHippo"];
    config.ringtoneSound = @"notes_of_the_optimistic.caf";
    config.supportsVideo = FALSE;
   
    config.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"callhippo"]);

    NSArray *ar = @[ [NSNumber numberWithInt:(int)CXHandleTypePhoneNumber] ];
    NSSet *handleTypes = [[NSSet alloc] initWithArray:ar];
//    [config setSupportedHandleTypes:handleTypes];
    
    config.supportedHandleTypes = [[NSSet alloc] initWithObjects:[NSNumber numberWithInt:(int)CXHandleTypePhoneNumber], nil];
    [config setMaximumCallGroups:1];
    [config setMaximumCallsPerCallGroup:1];
    self.provider = [[CXProvider alloc] initWithConfiguration:config];
    [self.provider setDelegate:self queue:dispatch_get_main_queue()];
}

- (instancetype)initWithType:(CXHandleType)type
                       value:(NSString *)value
{
    NSLog(@"Provider_callkit :: initWithType");
    return self;
}



- (void)configAudioSession:(AVAudioSession *)audioSession {
    if (@available(iOS 10, *)) {
        // iOS 11 (or newer) ObjC code
        
        NSError *err = nil;
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                             mode:AVAudioSessionModeVoiceChat
                          options:AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionAllowBluetoothA2DP
                            error:&err];
        if (err) {
            LOGE(@"Unable to change audio session because: %@", err.localizedDescription);
            err = nil;
        }
        [audioSession setMode:AVAudioSessionModeVoiceChat error:&err];
        if (err) {
            LOGE(@"Unable to change audio mode because : %@", err.localizedDescription);
            err = nil;
        }
        double sampleRate = 48000.0;
        [audioSession setPreferredSampleRate:sampleRate error:&err];
        if (err) {
            LOGE(@"Unable to change preferred sample rate because : %@", err.localizedDescription);
            err = nil;
        }
    }
    else
    {
        
    }
    
}


- (void)reportIncomingCall:(LinphoneCall *) call withUUID:(NSUUID *)uuid handle:(NSString *)handle video:(BOOL)video; {
    // Create update to describe the incoming call and caller
   
//    NSString *callingprovider = [Default valueForKey:CallingProvider];
//    if([callingprovider isEqualToString:Login_Linphone])
//    {
     NSLog(@"Provider_callkit :: reportIncomingCall");
     self.Call_completed = false;
//l    NSString *Userid = [Default valueForKey:USER_ID];
//    if (Userid != nil)
//    {
    LinphoneCall *call2 = linphone_core_get_current_call(LC);
    NSLog(@"Hello X-PH-From: %@",_calls);
    
    
    const LinphoneAddress *addr = linphone_call_get_remote_address(call2);
    NSString *Phonenumber_get = [NSString stringWithFormat:@"%@",[FastAddressBook displayNameForAddress:addr] ? [FastAddressBook displayNameForAddress:addr] : @""];
    NSLog(@"Patel : %@",Phonenumber_get);
    
//    NSLog(@"Mixallcontact : %@",Mixallcontact);
        NSString *str = [Phonenumber_get stringByReplacingOccurrencesOfString:@"+" withString:@""] ;
   
    NSArray *Mixallcontact = [[NSArray alloc] init];
 //l   Mixallcontact = [[GlobalData sharedGlobalData] get_mix_contact_list];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"(number_int contains[c] %@)",str];
    NSArray *filteredContacts = [Mixallcontact filteredArrayUsingPredicate:filter];
    NSString *contact_save = @"";
        
    if(filteredContacts.count != 0)
    {
        NSDictionary *dic = [filteredContacts objectAtIndex:0];
        //  NSLog(@"Call Contact Find search dic == == > : %@",dic);
        NSLog(@"Trushang Dic : %@",dic);
        NSString *str = [dic valueForKey:@"name"];
        contact_save = str;
        if(!dic[@"_id"])
        {
            NSLog(@"Call Contact Find search dic == == > : %@",dic);
            NSString *ContactName = [dic valueForKey:@"name"];
            NSString *ContactNumber = [dic valueForKey:@"number"];
     //l       [UtilsClass contact_save_in_callhippo:ContactName contact_number:ContactNumber];
        }
        
    }

    NSString *name = @"";
    NSString *number = Phonenumber_get;
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"extraHeader"])
    {
        NSDictionary *dic =  [[NSUserDefaults standardUserDefaults] objectForKey:@"extraHeader"];
        name = [dic valueForKey:@"xphfrom"];
        number = [dic valueForKey:@"xphfromnumber"];
        name = [name stringByRemovingPercentEncoding];
        NSString *name1 = [name stringByReplacingOccurrencesOfString:@"+" withString:@""];
        NSLog(@"Values : %d",[self validateString:name1 withPattern:@"^[0-9]+$"]);
        if([self validateString:name1 withPattern:@"^[0-9]+$"])
        {
            if(![contact_save isEqualToString:@""])
            {
                name = contact_save;
            }
        }
        else
        {
//            if(![contact_save isEqualToString:@""])
//            {
//                name = contact_save;
//            }
        }
        
        //User exists
    }
    else
    {
        name = Phonenumber_get;
       
        //User doesn't exist
    }
    
    CXCallUpdate *update = [[CXCallUpdate alloc] init];
    update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:number];
    update.localizedCallerName = name;
    update.supportsDTMF = TRUE;
    update.supportsHolding = TRUE;
    update.supportsGrouping = TRUE;
    update.supportsUngrouping = TRUE;
    update.hasVideo = TRUE;

    // Report incoming call to system
    LOGD(@"CallKit: report new incoming call with call-id: [%@] and UUID: [%@]", [_calls objectForKey:uuid], uuid);
    [self.provider reportNewIncomingCallWithUUID:uuid
                                          update:update
                                      completion:^(NSError *error) {
                                          if (error) {
                                              LOGE(@"CallKit: cannot complete incoming call with call-id: [%@] and UUID: [%@] from [%@] caused by [%@]",
                                                   [self.calls objectForKey:uuid], uuid, handle, [error localizedDescription]);
                                              
                                              
                                              
                                              if ([error code] == CXErrorCodeIncomingCallErrorFilteredByDoNotDisturb ||
                                                  [error code] == CXErrorCodeIncomingCallErrorFilteredByBlockList)
                                                  linphone_call_decline(call,LinphoneReasonBusy); /*to give a chance for other devices to answer*/
                                              else
                                                  linphone_call_decline(call,LinphoneReasonUnknown);
                                          }else {
                                              LOGE(@"CallKit: cannot complete incoming call with call-id: [%@] and UUID: [%@] from [%@] caused by [%@]",
                                                   [self.calls objectForKey:uuid], uuid, handle, [error localizedDescription]);
                                          }
                                      }];
//}
  //  }
}

- (void)setPendingCall:(LinphoneCall *)pendingCall {
    
//    NSString *callingprovider = [Default valueForKey:CallingProvider];
//    if([callingprovider isEqualToString:Login_Linphone])
//    {
//    NSLog(@"Provider_callkit :: setPendingCall");
    if (pendingCall) {
        _pendingCall = pendingCall;
        if (_pendingCall)
            linphone_call_ref(_pendingCall);
    } else if (_pendingCall) {
        linphone_call_unref(_pendingCall);
        _pendingCall = NULL;
    }
//    }
}

#pragma mark - CXProviderDelegate Protocol
//
//- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
//    NSUUID *uuid = action.callUUID;
//    NSString *callID = [self.calls objectForKey:uuid]; // first, make sure this callid is not already involved in a call
//    LOGD(@"CallKit: Answering call with call-id: [%@] and UUID: [%@]", callID, uuid);
//    // chetan joshi
//    [self configAudioSession:[AVAudioSession sharedInstance]];
//    [action fulfill];
//    LinphoneCall *call = [LinphoneManager.instance callByCallId:callID];
//    NSLog(@"Call pickup joshi");
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *crtl = [[UIViewController alloc]init];
//    OnCallVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"OnCallVC"];
//
//        vc.modalPresentationStyle = UIModalPresentationPopover;
////        [crtl presentViewController:vc animated:YES completion:nil];
//
//    UIWindow* topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    topWindow.rootViewController = [UIViewController new];
//    topWindow.windowLevel = UIWindowLevelAlert + 1;
//
//    [topWindow makeKeyAndVisible];
//    [topWindow.rootViewController presentViewController:vc animated:YES completion:nil];
//
//
//    if (!call)
//        return;
//
//    self.callKitCalls++;
//    self.pendingCall = call;
//
//    NSLog(@"Call pickup Chetan");
//
//}


- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action
{
   // NSString *callingprovider = [Default valueForKey:CallingProvider];
//    if([callingprovider isEqualToString:Login_Linphone])
//    {
        
    NSLog(@"Provider_callkit :: performAnswerCallAction");
 //l   NSString *Userid = [Default valueForKey:USER_ID];
//    if (Userid != nil)
//    {

    NSUUID *uuid = action.callUUID;
    NSString *callID = [self.calls objectForKey:uuid]; // first, make sure this callid is not already involved in a call
    LOGD(@"CallKit: Answering call with call-id: [%@] and UUID: [%@]", callID, uuid);
    NSLog(@"Headers : %@",action.description);
    [self configAudioSession:[AVAudioSession sharedInstance]];
    [action fulfill];
    LinphoneCall *call = [LinphoneManager.instance callByCallId:callID];
    if (!call)
        return;
    
    self.callKitCalls++;
    self.pendingCall = call;
    
    LinphoneCore *lc = [LinphoneManager getLc];
    LinphoneCall *currentcall = linphone_core_get_current_call(lc);

    

//l    [FIRAnalytics logEventWithName:@"ch_oncallDialer_incomingCall" parameters:nil];
    UIWindow *mainWindow = [UIApplication sharedApplication].windows[0];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
//L    LoginVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
//    DialerVC *vc1 = [storyboard instantiateViewControllerWithIdentifier:@"DialerVC"];
//    OnCallVC *vc2 = [storyboard instantiateViewControllerWithIdentifier:@"OnCallVC"];
    
    const LinphoneAddress *addr = linphone_call_get_remote_address(currentcall);
    NSString *Phonenumber_get = [NSString stringWithFormat:@"%@",[FastAddressBook displayNameForAddress:addr] ? [FastAddressBook displayNameForAddress:addr] : @""];
    NSLog(@"Patel : %@",Phonenumber_get);
    
    
    NSString *name = @"";
    NSString *number = Phonenumber_get;
        NSString *transferBy = @"";
    NSString *xphto = @"";
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"extraHeader"])
    {
        NSDictionary *dic =  [[NSUserDefaults standardUserDefaults] objectForKey:@"extraHeader"];
        name = [dic valueForKey:@"xphfrom"];
        number = [dic valueForKey:@"xphfromnumber"];
        transferBy = [dic valueForKey:@"xphfirstcallusername"];
        xphto = [dic valueForKey:@"xphto"];
        
//L        NKVPhonePickerTextField *txtText = [[NKVPhonePickerTextField alloc] initWithFrame:CGRectMake(20, 20, 20, 20)];
//        txtText.text = @"";
////        [txtText insertText:number];
//        [txtText insertText:[dic valueForKey:@"xphtotransferNumber"]];
//l        NSString *Country_ShotName = txtText.country.countryCode ? txtText.country.countryCode : @"";
        
//l        [Default setValue:[Country_ShotName lowercaseString] forKey:Selected_Department_Flag];
//        [Default setValue:xphto forKey:Selected_Department];
 //l       NSLog(@"Flag Name : %@",[Country_ShotName lowercaseString]);
        //User exists
    }
    else
    {
        name = Phonenumber_get;
        //User doesn't exist
    }
    
//L    vc2.CallStatus = INCOMING;
//    vc2.CallStatusfinal = INCOMING;
//    vc2.ContactName = name ? name : @"";
//    vc2.ContactNumber = number ? number : @"";
//    vc2.transferCall = transferBy ? transferBy : @"";
//    vc2.IncCallOutCall = @"Incoming";

//L    [Default setValue:Timer_Start forKey:Timer_Call];
//    [Default synchronize];
    
  /*L      UINavigationController *navController123 = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
        NSArray *views = navController123.viewControllers;
        MainViewController *mainviews = [views objectAtIndex:0];
        UINavigationController *navigationControllerfinal = (UINavigationController *)mainviews.rootViewController;
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr addObjectsFromArray:navigationControllerfinal.viewControllers];
        [arr addObject:vc2];
        NSLog(@"Nav :: %@",navigationControllerfinal.viewControllers);
        NSLog(@"Views :: %@",arr);
        
        [navigationController setViewControllers:arr animated:true];
        MainViewController *mainViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
        mainViewController.rootViewController = navigationController;
        [mainViewController setupWithType:11];
        UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:mainViewController];
        navController.navigationBar.hidden = true;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        navController.navigationBar.hidden = true;
        [appDelegate window].rootViewController = navController;
        [[appDelegate window] setNeedsLayout];
        [[appDelegate window] makeKeyAndVisible];*/
    
//}
   // }
}

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action {
//    NSString *callingprovider = [Default valueForKey:CallingProvider];
//    if([callingprovider isEqualToString:Login_Linphone])
//    {
    NSLog(@"Provider_callkit :: performStartCallAction");
    NSUUID *uuid = action.callUUID;
    NSString *callID = [self.calls objectForKey:uuid]; // first, make sure this callid is not already involved in a call
    // To restart Audio Unit
    [self configAudioSession:[AVAudioSession sharedInstance]];
//    [action fulfill];
    LinphoneCall *call;
    if (![callID isEqualToString:@""]) {
        call = linphone_core_get_current_call(LC);
    } else {
        call = [LinphoneManager.instance callByCallId:callID];
    }
    if (call != NULL) {
        self.callKitCalls++;
        self.pendingCall = call;
//         [action fulfillWithDateStarted:[NSDate date]];
    }
   [action fulfill];
   // }
}

- (void)requestTransaction:(CXTransaction *)transaction {
//    NSString *callingprovider = [Default valueForKey:CallingProvider];
//    if([callingprovider isEqualToString:Login_Linphone])
//    {
    NSLog(@"Provider_callkit :: requestTransaction");
    [LinphoneManager.instance.providerDelegate.controller requestTransaction:transaction completion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error requesting transaction: %@", error.localizedDescription);
        } else {
            NSLog(@"Requested transaction successfully");
        }
    }];
   // }
}
- (void)performEndCallActionWithUUID
{
    //NSString *callingprovider = [Default valueForKey:CallingProvider];
//l    [Default setValue:Timer_Stop forKey:Timer_Call];
//    if([callingprovider isEqualToString:Login_Linphone])
//    {
    NSLog(@"Provider_callkit :: performEndCallActionWithUUID");
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self-> _calls_uuids.count != 0)
        {
                   if([self->_calls_uuids objectAtIndex:0] != nil)
                   {
                       NSUUID *uuid = (NSUUID *)[LinphoneManager.instance.providerDelegate.calls_uuids objectAtIndex:0];
                       //        CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:uuid];
                       //        CXTransaction *trasanction = [[CXTransaction alloc] initWithAction:endCallAction];
                       
                       NSLog(@"-->Trushang  : Call UUID : %@",self.calls_uuids);
                       NSLog(@"-->Trushang  : Call UUID : %@",uuid);
                       
                       CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:uuid];
                       CXTransaction *transaction = [[CXTransaction alloc] init];
                       [transaction addAction:endCallAction];
                       [self requestTransaction:transaction];
                   }
                   else
                   {
                       NSLog(@"\n \n \n \n \n \n");
                       NSLog(@"Providerdelegate : performEndCallActionWithUUID : ****** Error ****** ");
                       NSLog(@"\n \n \n \n \n \n");
                   }
        }
    });
  //  }
}
- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
//    NSString *callingprovider = [Default valueForKey:CallingProvider];
//    if([callingprovider isEqualToString:Login_Linphone])
//    {
    NSLog(@"Provider_callkit :: performEndCallAction");
    self.callKitCalls--;
    
    if (linphone_core_is_in_conference(LC)) {
        LinphoneManager.instance.conf = TRUE;
        linphone_core_terminate_conference(LC);
        LOGD(@"CallKit: Ending the conference");
    } else if (linphone_core_get_calls_nb(LC) > 1) {
        LinphoneManager.instance.conf = TRUE;
        linphone_core_terminate_all_calls(LC);
        LOGD(@"CallKit: Ending all the ongoing calls");
    } else {
        NSUUID *uuid = action.callUUID;
        NSString *callID = [self.calls objectForKey:uuid];
        NSLog(@"CallKit: Ending the call with call-id:");

        if (callID) {
            
            NSLog(@"CallKit: Ending the call with call-id: [%@] and UUID: [%@]", callID, uuid);

            LOGD(@"CallKit: Ending the call with call-id: [%@] and UUID: [%@]", callID, uuid);
            LinphoneCall *call = [LinphoneManager.instance callByCallId:callID];
            if (call) {
                 NSLog(@"CallKit: Ending the call with call-id:");
//                 [Default setValue:@"true" forKey:@"fromEndCallInLockState"];
                linphone_call_terminate((LinphoneCall *)call);
                
               
                
            }
            [self.uuids removeObjectForKey:callID];
            [self.calls removeObjectForKey:uuid];
        }
    }
    [action fulfill];
   // }
}


- (void)provider:(CXProvider *)provider performSetMutedCallAction:(nonnull CXSetMutedCallAction *)action {
//    NSString *callingprovider = [Default valueForKey:CallingProvider];
//    if([callingprovider isEqualToString:Login_Linphone])
//    {
    NSLog(@"Provider_callkit :: performSetMutedCallAction");
    [action fulfill];
//    if ([//[PhoneMainView.instance currentView] equal:CallView.compositeViewDescription]) {
//        CallView *view = (CallView *)//[PhoneMainView.instance popToView:CallView.compositeViewDescription];
//        [view.microButton toggle];
//    }
  //  }
}
- (void)provider:(CXProvider *)provider performSetHeldCallAction:(nonnull CXSetHeldCallAction *)action {
//    NSString *callingprovider = [Default valueForKey:CallingProvider];
//    if([callingprovider isEqualToString:Login_Linphone])
//    {
    NSLog(@"Provider_callkit :: performSetHeldCallAction");
    //NSLog(@"Trushang_code : performSetHeldCallAction :");
    if (linphone_core_is_in_conference(LC) && action.isOnHold) {
        linphone_core_leave_conference(LC);
        LOGD(@"CallKit: Leaving conference");
        NSLog(@"Trushang_code : Leave :");
        [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCallUpdate object:self];
        [action fail];
        return;
    }
    
    if (linphone_core_get_calls_nb(LC) > 1 && action.isOnHold) {
        linphone_core_pause_all_calls(LC);
        NSLog(@"Trushang_code : Push :");
        LOGD(@"CallKit: Pausing all ongoing calls");
        [action fail];
        return;
    }
    
    NSUUID *uuid = action.callUUID;
    NSString *callID = [self.calls objectForKey:uuid];
    if (!callID) {
        [action fail];
        return;
    }
    
    LOGD(@"CallKit: Call  with call-id: [%@] and UUID: [%@] paused status changed to: []", callID, uuid, action.isOnHold ? @"Paused" : @"Resumed");
    LinphoneCall *call = [LinphoneManager.instance callByCallId:callID];
    if (!call)
        return;
    
    if (action.isOnHold) {
        NSLog(@"Trushang_code : Hold :");
//l                 [self holdUnholdApiCall:@"callhold/plivo"];
        LinphoneManager.instance.speakerBeforePause = LinphoneManager.instance.speakerEnabled;
        linphone_call_pause((LinphoneCall *)call);
    } else {
        if (linphone_core_get_conference(LC)) {
            NSLog(@"Trushang_code : Connect :");
            linphone_core_enter_conference(LC);
            [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCallUpdate object:self];
        } else {
            NSLog(@"Trushang_code : Hold :");
//l                        [self holdUnholdApiCall:@"callunhold/plivo"];
            [self configAudioSession:[AVAudioSession sharedInstance]];
            self.pendingCall = call;
        }
    }
    [action fulfill];
 //   }
}

//- (void)provider:(CXProvider *)provider performSetHeldCallAction:(nonnull CXSetHeldCallAction *)action {
//    [action fulfill];
//    if (linphone_core_is_in_conference(LC) && action.isOnHold) {
//        linphone_core_leave_conference(LC);
//        LOGD(@"CallKit: Leaving conference");
//        [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCallUpdate object:self];
//        return;
//    }
//
//    if (linphone_core_get_calls_nb(LC) > 1 && action.isOnHold) {
//        linphone_core_pause_all_calls(LC);
//        LOGD(@"CallKit: Pausing all ongoing calls");
//        return;
//    }
//
//    NSUUID *uuid = action.callUUID;
//    NSString *callID = [self.calls objectForKey:uuid];
//    if (!callID) {
//        return;
//    }
//
//    LOGD(@"CallKit: Call  with call-id: [%@] and UUID: [%@] paused status changed to: []", callID, uuid, action.isOnHold ? @"Paused" : @"Resumed");
//    LinphoneCall *call = [LinphoneManager.instance callByCallId:callID];
//    if (!call)
//        return;
//
//    if (action.isOnHold) {
//        LinphoneManager.instance.speakerBeforePause = LinphoneManager.instance.speakerEnabled;
//        linphone_call_pause((LinphoneCall *)call);
//    } else {
//        if (linphone_core_get_conference(LC)) {
//            linphone_core_enter_conference(LC);
//            [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCallUpdate object:self];
//        } else {
//            [self configAudioSession:[AVAudioSession sharedInstance]];
//            self.pendingCall = call;
//        }
//    }
//}

- (void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action {
//    NSString *callingprovider = [Default valueForKey:CallingProvider];
//    if([callingprovider isEqualToString:Login_Linphone])
//    {
    NSLog(@"Provider_callkit :: performPlayDTMFCallAction");
    [action fulfill];
    NSUUID *uuid = action.callUUID;
    NSString *callID = [self.calls objectForKey:uuid];
    LOGD(@"CallKit: playing DTMF for call with call-id: [%@] and UUID: [%@]", callID, uuid);
    LinphoneCall *call = [LinphoneManager.instance callByCallId:callID];
    char digit = action.digits.UTF8String[0];
    linphone_call_send_dtmf((LinphoneCall *)call, digit);
  //  }
}

- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
//    NSString *callingprovider = [Default valueForKey:CallingProvider];
//    if([callingprovider isEqualToString:Login_Linphone])
//    {
     NSLog(@"Provider_callkit :: didActivateAudioSession");
    //LOGD(@"CallKit: Audio session activated");
    // Now we can (re)start the call
    if (self.pendingCall) {
        LinphoneCallState state = linphone_call_get_state(self.pendingCall);
        switch (state) {
            case LinphoneCallIncomingReceived:
                [LinphoneManager.instance acceptCall:(LinphoneCall *)self.pendingCall evenWithVideo:_pendingCallVideo];
                break;
            case LinphoneCallPaused:
                linphone_call_resume((LinphoneCall *)self.pendingCall);
                break;
            case LinphoneCallStreamsRunning:
                // May happen when multiple calls
                break;
            default:
                break;
        }
    } else {
        if (_pendingAddr) {
//            [LinphoneManager.instance doCall:_pendingAddr];
        } else {
            LOGE(@"CallKit: No pending call");
        }
    }

//    [self setPendingCall:NULL];
//    if (_pendingAddr)
//        linphone_address_unref(_pendingAddr);
//    _pendingAddr = NULL;
//    _pendingCallVideo = FALSE;
    //}
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(nonnull AVAudioSession *)audioSession {
//    NSString *callingprovider = [Default valueForKey:CallingProvider];
//    if([callingprovider isEqualToString:Login_Linphone])
//    {
    NSLog(@"Provider_callkit :: didDeactivateAudioSession");
//    [self setPendingCall:NULL];
//    if (_pendingAddr)
//        linphone_address_unref(_pendingAddr);
//    _pendingAddr = NULL;
//    _pendingCallVideo = FALSE;
  //  }
}
- (void)providerDidReset:(CXProvider *)provider {
//    NSString *callingprovider = [Default valueForKey:CallingProvider];
//    if([callingprovider isEqualToString:Login_Linphone])
//    {
    NSLog(@"Provider_callkit :: providerDidReset");
//    LinphoneManager.instance.conf = TRUE;
//    linphone_core_terminate_all_calls(LC);
//    [self.calls removeAllObjects];
//    [self.uuids removeAllObjects];
   // }
}

#pragma mark - CXCallObserverDelegate Protocol

- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    
//    NSString *callingprovider = [Default valueForKey:CallingProvider];
//    if([callingprovider isEqualToString:Login_Linphone])
//    {
    
    NSLog(@"Provider_callkit :: callObserver");
    NSString *LoginProvider = [Default valueForKey:CallingProvider];
    if([LoginProvider isEqualToString:Login_Plivo])
    {
        NSLog(@" ProviderDelegate : Plivo Pakdayo");
    }
    else if([LoginProvider isEqualToString:Login_Twilio])
    {
    
    
         NSLog(@"Twilio_callkit : ProviderDelegate : Twilio UUIDS --> %@",self.calls_uuids);
            if(call.hasEnded)
           {
               NSLog(@"Twilio_callkit : End %@",self.calls_uuids);
               if(self.calls_uuids.count > 1)
                      {
                      
                          if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
                              NSUUID *uuid = [self.calls_uuids objectAtIndex:1];
                              NSLog(@"\n \n \n \n \n \n \n \n  Trushang_code : www  Callkit www : UUID : %@\n \n \n \n \n ",uuid);
                              if (!uuid) {
                                  return;
                              }
                              CXSetHeldCallAction *act = [[CXSetHeldCallAction alloc] initWithCallUUID:uuid onHold:NO];
                              CXTransaction *tr = [[CXTransaction alloc] initWithAction:act];
                              [[twilio_callkit sharedInstance].callKitCallController requestTransaction:tr
                                                                                              completion:^(NSError *err)
                               {
                                   //                                                                            2398985-af17-4515-b754-72173bf972c4
                                   if (err) {
                                       NSLog(@"Twilio_callkit : Papi :  Error requesting transaction: %@", err.localizedDescription);
                                   } else {
                                       NSLog(@"Twilio_callkit : Papi :Requested transaction successfully");
                                       //                                                                               [self configAudioSession:[AVAudioSession sharedInstance]];
                                   }
                               }];
                          }
                      }
           }
    }
    else
    {
        NSLog(@"Trushang_code : callChanged :");
        if(![self.calls_uuids containsObject:call.UUID])
        {
            [self.calls_uuids addObject:call.UUID];
        }
        NSLog(@"\n \n \n \n \n \n \n \n  Trushang_code : callChanged  : UUID : %@\n \n \n \n \n ",call.UUID);
        if(call.hasEnded)
        {
            if (self.pendingCall) {
                NSLog(@"\n \n \n \n \n \n \n \n  Trushang_code : END  : UUID : %@\n \n \n \n \n ",call.UUID);
                if (linphone_core_get_conference(LC)) {
                    NSLog(@"Trushang_code :  LinphoneCallPaused   : Connect :");
                    linphone_core_enter_conference(LC);
                    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneCallUpdate object:self];
                } else {
                    NSLog(@"Trushang_code :  LinphoneCallPaused   : Dont Know :");
                    
                    NSLog(@"Trushang_Chetan : Papi : Call");
                    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_x_Max) {
//l                        [Default setValue:Timer_Stop forKey:Timer_Call];
//                        [Default synchronize];
                        NSUUID *uuid = (NSUUID *)[LinphoneManager.instance.providerDelegate.calls_uuids objectAtIndex:0];
                        NSLog(@"\n \n \n \n \n \n \n \n  Trushang_code : LinphoneCallLog www : UUID : %@\n \n \n \n \n ",uuid);
                        if (!uuid) {
                            return;
                        }
                        CXSetHeldCallAction *act = [[CXSetHeldCallAction alloc] initWithCallUUID:uuid onHold:NO];
                        CXTransaction *tr = [[CXTransaction alloc] initWithAction:act];
                        [LinphoneManager.instance.providerDelegate.controller requestTransaction:tr
                                                                                      completion:^(NSError *err){
                                                                                          NSLog(@"\n \n \n \n \n \n \n \n \n \n \n \n ");
                                                                                          NSLog(@" Callkit Error : %@ ",err.description);
                                                                                          NSLog(@"\n \n \n \n \n \n \n \n \n \n \n \n ");
                                                                                          if (err)
                                                                                          {
                                                                                              [self holdUnholdApiCall:@"callunhold/plivo"];
                                                                                          }
                                                                                          else
                                                                                          {
                                                                                              
                                                                                          }
                                                                                          
                                                                                      }];
                    }
                    linphone_core_enter_conference(LC);
                    
                    linphone_call_resume((LinphoneCall *)self.pendingCall);
                    [self configAudioSession:[AVAudioSession sharedInstance]];
                    
                    
                }
            } else {
                if (_pendingAddr) {
                    // [LinphoneManager.instance doCall:_pendingAddr];
                } else {
                    LOGE(@"CallKit: No pending call");
                }
            }
            
        }
    }
    
    
  //  }
   
}
- (BOOL)validateString:(NSString *)string withPattern:(NSString *)pattern
{
    @try {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
        return [predicate evaluateWithObject:string];
    }
    @catch (NSException *exception) {
        
        return NO;
    }
    
}
/*-(void)holdUnholdApiCall:(NSString *)holdplivo {
    
    //    [Processcall showLoadingWithView:self.navigationController.view withLabel:nil];
    NSString *authToken = @"";
//l    if([Default valueForKey:AUTH_TOKEN] != nil || [Default valueForKey:AUTH_TOKEN] != [NSNull null] || [Default valueForKey:AUTH_TOKEN] != (id)[NSNull null])
//    {
//        authToken = [Default valueForKey:AUTH_TOKEN];
//    }
    
    NSString *userId = @"";
    if([Default valueForKey:USER_ID] != nil || [Default valueForKey:USER_ID] != [NSNull null] || [Default valueForKey:USER_ID] != (id)[NSNull null])
    {
        userId = [Default valueForKey:USER_ID];
    }
    
    NSString *plivoAuthToken = @"";
    if([Default valueForKey:CALLHIPPO_AUTH_TOKEN] != nil || [Default valueForKey:CALLHIPPO_AUTH_TOKEN] != [NSNull null] || [Default valueForKey:CALLHIPPO_AUTH_TOKEN] != (id)[NSNull null])
    {
        plivoAuthToken =  [Default valueForKey:CALLHIPPO_AUTH_TOKEN];
    }
    
    NSString *plivoAutId = @"";
    if([Default valueForKey:CALLHIPPO_AUTH_ID] != nil || [Default valueForKey:CALLHIPPO_AUTH_ID] != [NSNull null] || [Default valueForKey:CALLHIPPO_AUTH_ID] != (id)[NSNull null])
    {
        plivoAutId = [Default valueForKey:CALLHIPPO_AUTH_ID];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@",holdplivo];
    NSDictionary *passDict = @{@"authId":plivoAutId,
                               @"authToken":plivoAuthToken,
                               @"callHoldUrl":@"https://s3.amazonaws.com/callhippo_staging/call_hold/15168789827365a4c70c0bc9e741f843ad5c6.mp3",
                               @"calluid":@"1899ca94-518f-413b-9277-96b553f69c5a",
                               @"deviceType":@"iOS",
                               @"userId":userId};
    
    obj = [[WebApiController alloc] init];
    [obj callAPI_POST:url andParams:passDict SuccessCallback:@selector(login:response:) andDelegate:self];
}

- (void)login:(NSString *)apiAlias response:(NSData *)response {
    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"TRUSHANG : STATUSCODE ************** holdUnholdApiCall   : %@",apiAlias);
    if([apiAlias isEqualToString:Status_Code])
    {
        UIViewController *view = [[UIViewController alloc] init];
        //[UtilsClass logoutUser:view];
       // [UtilsClass logoutUser:view error:[response1 valueForKey:@"error"][@"error"] showAlert:YES];
    }
    else
    {
        
    if ([[response1 valueForKey:@"success"] integerValue] == 1) {
        // [UtilsClass showAlert:@"Done" contro:self];
    }else {
        NSLog(@"fail hold response");
        @try {
            [UtilsClass showAlert:[response1 valueForKey:@"error"][@"error"] contro:self];
        }
        @catch (NSException *exception) {
        }
    }
        
    }
}
*/

//- (void)callUpdate:(NSNotification *)notif {
//    LinphoneCall *call = [[notif.userInfo objectForKey:@"call"] pointerValue];
//    LinphoneCallState state = [[notif.userInfo objectForKey:@"state"] intValue];
//    NSString *message = [notif.userInfo objectForKey:@"message"];
//    NSLog(@"Trushang You are working : %u",state);
//
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate soket_disconnect];
//    NSString *name = [NSString stringWithFormat:@"%u",state];
//
//    switch (state) {
//        case LinphoneCallIncomingReceived:
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallIncomingReceived");
//            name = [NSString stringWithFormat:@"LinphoneCallIncomingReceived"];
//            break;
//
//        case LinphoneCallIncomingEarlyMedia: {
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallIncomingEarlyMedia");
//            name = [NSString stringWithFormat:@"LinphoneCallIncomingEarlyMedia"];
//            break;
//        }
//        case LinphoneCallOutgoingInit: {
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallOutgoingInit");
//            name = [NSString stringWithFormat:@"LinphoneCallOutgoingInit"];
//            break;
//        }
//        case LinphoneCallPausedByRemote:
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallPausedByRemote");
//            name = [NSString stringWithFormat:@"LinphoneCallPausedByRemote"];
//        case LinphoneCallConnected: {
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallConnected");
//            name = [NSString stringWithFormat:@"LinphoneCallConnected"];
//            // call connected
//            self.Call_completed = true;
//            break;
//        }
//        case LinphoneCallStreamsRunning: {
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallStreamsRunning");
//            name = [NSString stringWithFormat:@"LinphoneCallStreamsRunning"];
//
//
//            break;
//        }
//        case LinphoneCallUpdatedByRemote: {
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallUpdatedByRemote");
//            name = [NSString stringWithFormat:@"LinphoneCallUpdatedByRemote"];
//            break;
//        }
//        case LinphoneCallError: {
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallError");
//            name = [NSString stringWithFormat:@"LinphoneCallError"];
//            if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
//            {
//                if(self.Call_completed == true)
//                {
//                    self.Call_completed = false;
//                    NSString *numbVer = [Default valueForKey:IS_ACW_ENABLE];
//                    int num = [numbVer intValue];
//                    if (num == 1)
//                    {
////                        [self endWorkApi];
//                    }
//                }
//
//            }
//        }
//        case LinphoneCallEnd:
//        {
//            if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
//            {
//                if(self.Call_completed == true)
//                {
//                    self.Call_completed = false;
//                    NSString *numbVer = [Default valueForKey:IS_ACW_ENABLE];
//                    int num = [numbVer intValue];
//                    if (num == 1)
//                    {
////                        [self endWorkApi];
//                    }
//                }
//
//            }
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallEnd");
//            name = [NSString stringWithFormat:@"LinphoneCallEnd"];
//
//            break;
//        }
//        case LinphoneCallEarlyUpdatedByRemote:
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallEarlyUpdatedByRemote");
//            name = [NSString stringWithFormat:@"LinphoneCallEarlyUpdatedByRemote"];
//        case LinphoneCallEarlyUpdating:
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallEarlyUpdating");
//            name = [NSString stringWithFormat:@"LinphoneCallEarlyUpdating"];
//        case LinphoneCallIdle:
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallIdle");
//            name = [NSString stringWithFormat:@"LinphoneCallIdle"];
//            break;
//        case LinphoneCallOutgoingEarlyMedia:
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallOutgoingEarlyMedia");
//            name = [NSString stringWithFormat:@"LinphoneCallOutgoingEarlyMedia"];
//        case LinphoneCallOutgoingProgress: {
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallOutgoingProgress");
//            name = [NSString stringWithFormat:@"LinphoneCallOutgoingProgress"];
//            break;
//        }
//        case LinphoneCallOutgoingRinging:
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallOutgoingRinging");
//            name = [NSString stringWithFormat:@"LinphoneCallOutgoingRinging"];
//        case LinphoneCallPaused:
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallPaused");
//            name = [NSString stringWithFormat:@"LinphoneCallPaused"];
//        case LinphoneCallPausing:
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallPausing");
//            name = [NSString stringWithFormat:@"LinphoneCallPausing"];
//        case LinphoneCallRefered:
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallRefered");
//            name = [NSString stringWithFormat:@"LinphoneCallRefered"];
//        case LinphoneCallReleased:
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallReleased");
//            name = [NSString stringWithFormat:@"LinphoneCallReleased"];
//            break;
//        case LinphoneCallResuming: {
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallResuming");
//            name = [NSString stringWithFormat:@"LinphoneCallResuming"];
//            break;
//        }
//        case LinphoneCallUpdating:
//            NSLog(@"Callkit : Trushang_Patel_call :  LinphoneCallUpdating");
//            name = [NSString stringWithFormat:@"LinphoneCallUpdating"];
//            break;
//    }
//
//}
//
//- (void)endWorkApi {
//
////    [Processcall showLoadingWithView:self.navigationController.view withLabel:nil];
//
//    NSString *userId = [Default valueForKey:USER_ID];
//    NSString *parentId = [Default valueForKey:PARENT_ID];
//
//
////    NSString *newString = [someString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//
//    NSLog(@"Test 1 %@",userId);
//    NSLog(@"Test 2 %@",parentId);
//
//    NSDictionary *passDict;
//
//
//
//
//    NSDictionary *extraHeader = [[NSDictionary alloc]init];
//    extraHeader = [[NSUserDefaults standardUserDefaults]objectForKey:@"extraHeader"];
//
//    NSString *strFromNumber = [extraHeader valueForKey:@"xphfromnumber"];
//    NSString *strToNumber = [extraHeader valueForKey:@"xphtotransferNumber"];
//
//    BOOL boolValue = [[extraHeader valueForKey:@"xphcalltransfer"] boolValue];
//
//    passDict = @{
//        @"user":userId,
//        @"parentId":parentId,
//        @"afterCallWorkNote" : @"Kill State Check",
//        @"acwDuration" : @"00:00",
//        @"CallratingStar":@"4.5",
//        @"to" : strToNumber,
//        @"from":strFromNumber,
//        @"isTransferedCall":@(boolValue)
//    };
//
//    NSLog(@"Login Dic ************ : %@",passDict);
//
//
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:passDict
//                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
//                                                         error:nil];
//    NSString *jsonString;
//    if (! jsonData) {
//
//    } else {
//        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    }
//    obj = [[WebApiController alloc] init];
//
////    [obj callAPI_POST:Login_URL andParams:passDict SuccessCallback:@selector(login:response:) andDelegate:self];
//
//    [obj callAPI_POST_RAW:@"endaftercallwork" andParams:jsonString SuccessCallback:@selector(endWorkApi:response:) andDelegate:self];
//}
//
//- (void)endWorkApi:(NSString *)apiAlias response:(NSData *)response{
//    NSDictionary *response1 = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
//    NSLog(@"Login_response : %@",response1);
//    NSLog(@"TRUSHANG : STATUSCODE **************11  : %@",apiAlias);
//
//    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//    localNotification.alertBody = @"Kill State resoponse Linphone";
//    localNotification.soundName = UILocalNotificationDefaultSoundName;
//    localNotification.applicationIconBadgeNumber = 0;
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//
//    if([apiAlias isEqualToString:Status_Code])
//    {
//        [UtilsClass logoutUser:self];
//    }
//    else
//    {
//
//    }
//
//}


@end

