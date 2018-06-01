//
//  Copyright (c) Uber Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UBApplicationStartupReasonReporterNotificationRelay.h"
#import "UBApplicationStartupReasonReporterPriorRunInfoProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// A reason that the application launched.
typedef NSString *UBStartupReason NS_SWIFT_NAME(StartupReason) NS_STRING_ENUM;

/// The application is being debugged.
extern UBStartupReason const UBStartupReasonDebug;

/// The application was started for the first time.
extern UBStartupReason const UBStartupReasonFirstTime;

/// The application started because it previously crashed.
extern UBStartupReason const UBStartupReasonCrash;

/// The application started since it was force quit on the last run.
extern UBStartupReason const UBStartupReasonForceQuit;

/// The application started because it was upgraded.
extern UBStartupReason const UBStartupReasonAppUpgrade;

/// The application started because the OS was upgraded.
extern UBStartupReason const UBStartupReasonOSUpgrade;

/// The application started because it was evicted from background on the last run.
extern UBStartupReason const UBStartupReasonBackgroundEviction;

/// The application started because the device was restarted after the last run.
extern UBStartupReason const UBStartupReasonRestart;

/// The application started because it ran out of memory in the foreground.
extern UBStartupReason const UBStartupReasonOutOfMemory;

NS_SWIFT_NAME(ApplicationStartupReasonReporter)

/**
 The Startup Reason Reporter provides developers with the reason that an iOS application has launched, or equivalently, the reason that the application terminated on the prior launch.
 */
@interface UBApplicationStartupReasonReporter : NSObject

/// The reason the application started up.
@property (nonatomic) UBStartupReason startupReason;

/// The time when the system was last booted.
+ (time_t)systemBootTime;

/**
 Unavailable.
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 Initializes a new UBApplicationStartupReasonReporter.

 @param previousRunDidCrash Indicates whether the prior run was a crash
 @param previousRunInfo An implementation of UBApplicationStartupReasonReporterPriorRunInfoProtocol which contains information about the prior run and will store information about the current run.
 @param notificationRelay the relay which emits application state update notifications.
 @param debugging True if this app run is for debugging, false otherwise.  This is useful if the app is being developed in the simulator, for instance.
 */
- (instancetype)initWithPreviousRunDidCrash:(BOOL)previousRunDidCrash
                            previousRunInfo:(id<UBApplicationStartupReasonReporterPriorRunInfoProtocol>)previousRunInfo
                          notificationRelay:(id<UBApplicationStartupReasonReporterNotificationRelayProtocol>)notificationRelay
                                  debugging:(BOOL)debugging;

@end

NS_ASSUME_NONNULL_END
