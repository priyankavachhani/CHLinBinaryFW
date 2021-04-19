
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MessageUI.h>


/* These imports are here so that we can import PhoneMainView.h without bothering to import all the rest of the view headers */

#import "Utils.h"

#define DYNAMIC_CAST(x, cls)                                                                                           \
	({                                                                                                                 \
		cls *inst_ = (cls *)(x);                                                                                       \
		[inst_ isKindOfClass:[cls class]] ? inst_ : nil;                                                               \
	})

#define VIEW(x)                                                                                                        \
	DYNAMIC_CAST([PhoneMainView.instance.mainViewController getCachedController:x.compositeViewDescription.name], x)

#define LINPHONE_DUMMY_SUBJECT "dummy subject"

@class PhoneMainView;

@interface RootViewManager : NSObject

//@property(nonatomic, strong) PhoneMainView *portraitViewController;
//@property(nonatomic, strong) PhoneMainView *rotatingViewController;
//@property(nonatomic, strong) NSMutableArray *viewDescriptionStack;

+(RootViewManager*)instance;
//+ (void)setupWithPortrait:(PhoneMainView*)portrait;
- (PhoneMainView*)currentView;

@end


@interface PhoneMainView : UIViewController< MFMessageComposeViewControllerDelegate> {
    @private
//    NSMutableArray *inhibitedEvents;
}


//@property(nonatomic, strong) IBOutlet UIView *statusBarBG;
//@property(nonatomic, strong) IBOutlet UIView *mainViewController;

//@property(nonatomic, strong) NSString *currentName;
//@property(nonatomic, strong) NSString *previousView;
//@property(nonatomic, strong) NSString *name;
@property(weak, readonly) UIView *currentView;
//@property LinphoneChatRoom* currentRoom;
@property(readonly, strong) MPVolumeView *volumeView;
//@property (weak, nonatomic) UIView *waitView;


//- (void) setPreviousViewName:(NSString*)previous;
//- (NSString*) getPreviousViewName;
//+ (NSString*) getPreviousViewName;
- (void)startUp;
- (void)displayIncomingCall:(LinphoneCall*) call;
- (void)setVolumeHidden:(BOOL)hidden;
//- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result;

//- (void)addInhibitedEvent:(id)event;
//- (BOOL)removeInhibitedEvent:(id)event;

//- (void)updateApplicationBadgeNumber;
//- (void)getOrCreateOneToOneChatRoom:(const LinphoneAddress *)remoteAddress waitView:(UIView *)waitView isEncrypted:(BOOL)isEncrypted;
//- (LinphoneChatRoom *)createChatRoom:(const char *)subject addresses:(bctbx_list_t *)addresses andWaitView:(UIView *)waitView isEncrypted:(BOOL)isEncrypted isGroup:(BOOL)isGroup;
//- (void)goToChatRoom:(LinphoneChatRoom *)cr;
+ (PhoneMainView*) instance;

- (BOOL)isIphoneXDevice;

@end

//void main_view_chat_room_state_changed(LinphoneChatRoom *cr, LinphoneChatRoomState newState);
