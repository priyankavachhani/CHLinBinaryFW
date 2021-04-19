/* LinphoneManager.h
 *
 * Copyright (C) 2011  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Photos/Photos.h>
#import <CoreTelephony/CTCallCenter.h>

#import <sqlite3.h>
#import "IASKSettingsStore.h"
//#import "FastAddressBook.h"
#include "linphone/linphonecore.h"
#include "bctoolbox/list.h"

#import "ProviderDelegate.h"
#import <UIKit/UIKit.h>

#import "Utils/FastAddressBook.h"

//@class ProviderDelegate;

extern NSString *const LINPHONERC_APPLICATION_KEY;

extern NSString *const kLinphoneCoreUpdate;
extern NSString *const kLinphoneDisplayStatusUpdate;
extern NSString *const kLinphoneMessageReceived;
extern NSString *const kLinphoneTextComposeEvent;
extern NSString *const kLinphoneCallUpdate;
extern NSString *const kLinphoneRegistrationUpdate;
extern NSString *const kLinphoneMainViewChange;
extern NSString *const kLinphoneAddressBookUpdate;
extern NSString *const kLinphoneLogsUpdate;
extern NSString *const kLinphoneSettingsUpdate;
extern NSString *const kLinphoneBluetoothAvailabilityUpdate;
extern NSString *const kLinphoneConfiguringStateUpdate;
extern NSString *const kLinphoneGlobalStateUpdate;
extern NSString *const kLinphoneNotifyReceived;
extern NSString *const kLinphoneNotifyPresenceReceivedForUriOrTel;
extern NSString *const kLinphoneCallEncryptionChanged;
extern NSString *const kLinphoneFileTransferSendUpdate;
extern NSString *const kLinphoneFileTransferRecvUpdate;
extern NSString *const kLinphoneQRCodeFound;
extern NSString *const kLinphoneChatCreateViewChange;

typedef enum _NetworkType {
    network_none = 0,
    network_2g,
    network_3g,
    network_4g,
    network_lte,
    network_wifi
} NetworkType;

typedef enum _Connectivity {
    wifi,
    wwan,
    none
} Connectivity;

extern const int kLinphoneAudioVbrCodecDefaultBitrate;

/* Application specific call context */
typedef struct _CallContext {
    LinphoneCall* call;
    bool_t cameraIsEnabled;
} CallContext;

struct NetworkReachabilityContext {
    bool_t testWifi, testWWan;
    void (*networkStateChanged) (Connectivity newConnectivity);
};

@interface LinphoneCallAppData :NSObject {
@public
    bool_t batteryWarningShown;
    UILocalNotification *notification;
    NSMutableDictionary *userInfos;
    bool_t videoRequested; /*set when user has requested for video*/
    NSTimer* timer;
};
@end

typedef struct _LinphoneManagerSounds {
    SystemSoundID vibrate;
} LinphoneManagerSounds;

@interface LinphoneManager : NSObject {
@protected
    SCNetworkReachabilityRef proxyReachability;
    
@private
    NSTimer* mIterateTimer;
    NSMutableArray*  pushCallIDs;
    Connectivity connectivity;
    UIBackgroundTaskIdentifier pausedCallBgTask;
    UIBackgroundTaskIdentifier incallBgTask;
    UIBackgroundTaskIdentifier pushBgTaskRefer;
    UIBackgroundTaskIdentifier pushBgTaskCall;
    UIBackgroundTaskIdentifier pushBgTaskMsg;
    CTCallCenter* mCallCenter;
    NSDate *mLastKeepAliveDate;
@public
    CallContext currentCallContextBeforeGoingBackground;
}
+ (LinphoneManager*)instance;
#ifdef DEBUG
+ (void)instanceRelease;
#endif
+ (LinphoneCore*) getLc;
+ (BOOL)runningOnIpad;
+ (BOOL)isNotIphone3G;
+ (NSString *)getPreferenceForCodec: (const char*) name withRate: (int) rate;
+ (BOOL)isCodecSupported: (const char*)codecName;
+ (NSSet *)unsupportedCodecs;
+ (NSString *)getUserAgent;
+ (int)unreadMessageCount;

- (void)playMessageSound;
- (void)resetLinphoneCore;
- (void)startLinphoneCore;
- (void)destroyLinphoneCore;
- (BOOL)resignActive;
- (void)becomeActive;
- (BOOL)enterBackgroundMode;
- (void)addPushCallId:(NSString*) callid;
- (void)configurePushTokenForProxyConfig: (LinphoneProxyConfig*)cfg;
- (BOOL)popPushCallID:(NSString*) callId;
- (void)acceptCallForCallId:(NSString*)callid;
- (LinphoneCall *)callByCallId:(NSString *)call_id;
- (void)cancelLocalNotifTimerForCallId:(NSString*)callid;
- (void)alertLIME:(LinphoneChatRoom *)room;
- (void)startPushLongRunningTask:(NSString *)loc_key callId:(NSString *)callId;
+ (BOOL)langageDirectionIsRTL;
+ (void)kickOffNetworkConnection;
- (void)setupNetworkReachabilityCallback;

- (void)refreshRegisters;

- (bool)allowSpeaker;

- (void)configureVbrCodecs;

+ (BOOL)copyFile:(NSString*)src destination:(NSString*)dst override:(BOOL)override;
+ (PHFetchResult *)getPHAssets:(NSString *)key;
+ (NSString*)bundleFile:(NSString*)file;
+ (NSString *)preferenceFile:(NSString *)file;
+ (NSString *)documentFile:(NSString *)file;
+ (NSString*)dataFile:(NSString*)file;
+ (NSString*)cacheDirectory;

- (void)acceptCall:(LinphoneCall *)call evenWithVideo:(BOOL)video;
- (void)send:(NSString *)replyText toChatRoom:(LinphoneChatRoom *)room;
- (void)call:(const LinphoneAddress *)address;
- (BOOL)doCall:(const LinphoneAddress *)iaddr;
- (BOOL)doCallWithSas:(const LinphoneAddress *)iaddr isSas:(BOOL)isSas;

+(id)getMessageAppDataForKey:(NSString*)key inMessage:(LinphoneChatMessage*)msg;
+(void)setValueInMessageAppData:(id)value forKey:(NSString*)key inMessage:(LinphoneChatMessage*)msg;

- (void)lpConfigSetString:(NSString*)value forKey:(NSString*)key;
- (void)lpConfigSetString:(NSString *)value forKey:(NSString *)key inSection:(NSString *)section;
- (NSString *)lpConfigStringForKey:(NSString *)key;
- (NSString *)lpConfigStringForKey:(NSString *)key inSection:(NSString *)section;
- (NSString *)lpConfigStringForKey:(NSString *)key withDefault:(NSString *)value;
- (NSString *)lpConfigStringForKey:(NSString *)key inSection:(NSString *)section withDefault:(NSString *)value;

- (void)lpConfigSetInt:(int)value forKey:(NSString *)key;
- (void)lpConfigSetInt:(int)value forKey:(NSString *)key inSection:(NSString *)section;
- (int)lpConfigIntForKey:(NSString *)key;
- (int)lpConfigIntForKey:(NSString *)key inSection:(NSString *)section;
- (int)lpConfigIntForKey:(NSString *)key withDefault:(int)value;
- (int)lpConfigIntForKey:(NSString *)key inSection:(NSString *)section withDefault:(int)value;

- (void)lpConfigSetBool:(BOOL)value forKey:(NSString*)key;
- (void)lpConfigSetBool:(BOOL)value forKey:(NSString *)key inSection:(NSString *)section;
- (BOOL)lpConfigBoolForKey:(NSString *)key;
- (BOOL)lpConfigBoolForKey:(NSString *)key inSection:(NSString *)section;
- (BOOL)lpConfigBoolForKey:(NSString *)key withDefault:(BOOL)value;
- (BOOL)lpConfigBoolForKey:(NSString *)key inSection:(NSString *)section withDefault:(BOOL)value;

- (void)silentPushFailed:(NSTimer*)timer;

- (void)removeAllAccounts;

+ (BOOL)isMyself:(const LinphoneAddress *)addr;

- (void)shouldPresentLinkPopup;

- (void)setProviderDelegate:(ProviderDelegate *)del;

- (void) setLinphoneManagerAddressBookMap:(NSDictionary*) addressBook;
//- (OrderedDictionary*) getLinphoneManagerAddressBookMap;

- (void) setContactsUpdated:(BOOL) updated;   // Trushang_delete
- (BOOL) getContactsUpdated;

- (void)checkNewVersion;

- (void)loadAvatar;

@property(strong, nonatomic) ProviderDelegate *providerDelegate;

@property (nonatomic) BOOL isTesting;
@property(nonatomic, strong) FastAddressBook *fastAddressBook;
@property Connectivity connectivity;
@property (nonatomic) NetworkType network;
@property (nonatomic) const char*  frontCamId;
@property (nonatomic) const char*  backCamId;
@property(strong, nonatomic) NSString *SSID;
@property (nonatomic) sqlite3* database;
@property(nonatomic, strong) NSData *pushNotificationToken;
@property (nonatomic) LinphoneManagerSounds sounds;
@property (nonatomic, strong) NSMutableArray *logs;
@property (nonatomic, assign) BOOL speakerBeforePause;
@property (nonatomic, assign) BOOL speakerEnabled;
@property (nonatomic, assign) BOOL bluetoothAvailable;
@property (nonatomic, assign) BOOL bluetoothEnabled;
@property (nonatomic, strong) NSString* contactSipField;
@property (nonatomic,copy) NSString* contactFilter;
@property (copy) void (^silentPushCompletion)(UIBackgroundFetchResult);
@property (nonatomic) BOOL wasRemoteProvisioned;
@property (nonatomic) LpConfig *configDb;
//@property(nonatomic, strong) InAppProductsManager *iapManager;
@property(strong, nonatomic) NSMutableArray *fileTransferDelegates;
@property BOOL nextCallIsTransfer;
@property BOOL conf;
@property(strong, nonatomic) NSDictionary *pushDict;
@property(strong, nonatomic) NSDictionary *linphoneManagerAddressBookMap;
@property (nonatomic, assign) BOOL contactsUpdated;
@property(strong, nonatomic) UIImage *avatar;

@end
