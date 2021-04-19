#ifndef AudioHelper_h
#define AudioHelper_h

//#import <AVFoundation/AVAudioSession.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface AudioHelper : NSObject

+ (NSArray *)bluetoothRoutes;
+ (AVAudioSessionPortDescription *)bluetoothAudioDevice;
+ (AVAudioSessionPortDescription *)builtinAudioDevice;
+ (AVAudioSessionPortDescription *)speakerAudioDevice;
+ (AVAudioSessionPortDescription *)audioDeviceFromTypes:(NSArray *)types;
@end

#endif 
