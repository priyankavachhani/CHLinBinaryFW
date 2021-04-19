#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

#include "linphone/linphonecore.h"
#include "Contact.h"

@interface FastAddressBook : NSObject
//
@property(readonly, nonatomic) NSMutableDictionary *addressBookMap;
//@property BOOL needToUpdate;
//
//- (void) fetchContactsInBackGroundThread;
//- (BOOL)deleteContact:(Contact *)contact;
//- (BOOL)deleteCNContact:(CNContact *)CNContact;
//- (BOOL)deleteAllContacts;
//- (BOOL)saveContact:(Contact *)contact;
//- (BOOL)saveCNContact:(CNContact *)CNContact contact:(Contact *)Contact;
//
//+ (BOOL)isAuthorized;
//
//// TOOLS
//
+ (Contact *)getContactWithAddress:(const LinphoneAddress *)address;
//- (CNContact *)getCNContactFromContact:(Contact *)acontact;
//
//+ (UIImage *)imageForContact:(Contact *)contact;
//+ (UIImage *)imageForAddress:(const LinphoneAddress *)addr;
//+ (UIImage *)imageForSecurityLevel:(LinphoneChatRoomSecurityLevel)level;
//
//+ (BOOL)contactHasValidSipDomain:(Contact *)person;
//+ (BOOL)isSipURIValid:(NSString*)addr;
//
//+ (NSString *)displayNameForContact:(Contact *)person;
+ (NSString *)displayNameForAddress:(const LinphoneAddress *)addr;
//
//+ (BOOL)isSipURI:(NSString *)address;
//+ (BOOL)isSipAddress:(CNLabeledValue<CNInstantMessageAddress *> *)sipAddr;
//+ (NSString *)normalizeSipURI:(NSString *)address;
//
//+ (NSString *)localizedLabel:(NSString *)label;
//- (void)registerAddrsFor:(Contact *)contact;
//
@end
