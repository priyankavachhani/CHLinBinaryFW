//
//  ProviderDelegate.h
//  linphone
//
//  Created by REIS Benjamin on 29/11/2016.
//
//

#import <CallKit/CallKit.h>
//#import "WebApiController.h"
//#import "Utils.h"
#import "LinphoneManager.h"

#ifndef ProviderDelegate_h
#define ProviderDelegate_h

@interface ProviderDelegate : NSObject <CXProviderDelegate, CXCallObserverDelegate>
{
     //WebApiController *obj;
}

@property(nonatomic, strong) CXProvider *provider;
@property(nonatomic, strong) CXCallObserver *observer;
@property(nonatomic, strong) CXCallController *controller;
@property(nonatomic, strong) NSMutableDictionary *calls;
@property(nonatomic, strong) NSMutableDictionary *uuids;
@property(nonatomic, strong) NSMutableArray *calls_uuids;
@property(nonatomic) LinphoneCall *pendingCall;
@property LinphoneAddress *pendingAddr;
@property BOOL pendingCallVideo;
@property BOOL Call_completed;
@property int callKitCalls;

- (void)reportIncomingCall:(LinphoneCall *) call withUUID:(NSUUID *)uuid handle:(NSString *)handle video:(BOOL)video;
- (void)config;
- (void)configAudioSession:(AVAudioSession *)audioSession;
- (void)performEndCallActionWithUUID;
@property (nonatomic, strong) UINavigationController *navcon;
@end

#endif
