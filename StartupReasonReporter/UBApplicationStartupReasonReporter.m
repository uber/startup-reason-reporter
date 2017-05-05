//
//  Copyright (c) 2016-2017 Uber Technologies, Inc. All rights reserved.
//

#import "UBApplicationStartupReasonReporter.h"

#import <sys/sysctl.h>

UBStartupReason const UBStartupReasonDebug = @"debug";
UBStartupReason const UBStartupReasonFirstTime = @"first_time";
UBStartupReason const UBStartupReasonCrash = @"crash";
UBStartupReason const UBStartupReasonForceQuit = @"force_quit";
UBStartupReason const UBStartupReasonAppUpgrade = @"app_upgrade";
UBStartupReason const UBStartupReasonOSUpgrade = @"os_upgrade";
UBStartupReason const UBStartupReasonBackgroundEviction = @"background_eviction";
UBStartupReason const UBStartupReasonRestart = @"restart";
UBStartupReason const UBStartupReasonOutOfMemory = @"out_of_memory";


@interface UBApplicationStartupReasonReporter ()

@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) BOOL previousRunDidCrash;
@property (nonatomic) BOOL debugging;

@property (nonatomic) NSString *previousAppVersion;
@property (nonatomic) NSString *currentAppVersion;
@property (nonatomic) NSString *previousOSVersion;
@property (nonatomic) NSString *currentOSVersion;
@property (nonatomic) time_t currentBootTime;
@property (nonatomic) time_t previousBootTime;
@property (nonatomic) BOOL backgrounded;
@property (nonatomic) BOOL didTerminate;

@property (nonatomic) id<UBApplicationStartupReasonReporterPriorRunInfoProtocol> previousRunInfo;

@end


@implementation UBApplicationStartupReasonReporter

+ (time_t)systemBootTime
{
    struct timeval boottime;
    size_t size = sizeof(boottime);

    if (sysctlbyname("kern.boottime", &boottime, &size, NULL, 0) != -1) {
        return boottime.tv_sec;
    }
    return 0;
}

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter previousRunDidCrash:(BOOL)previousRunDidCrash previousRunInfo:(id<UBApplicationStartupReasonReporterPriorRunInfoProtocol>)previousRunInfo debugging:(BOOL)debugging
{
    self = [super init];
    if (self) {
        _startupReason = UBStartupReasonFirstTime;
        _previousRunDidCrash = previousRunDidCrash;
        _debugging = debugging;

        _currentAppVersion = [self currentBundleVersion];
        _previousAppVersion = _currentAppVersion;
        _currentOSVersion = [[UIDevice currentDevice] systemVersion];
        _previousOSVersion = _currentOSVersion;
        _backgrounded = NO;
        _didTerminate = NO;
        _currentBootTime = [UBApplicationStartupReasonReporter systemBootTime];
        _previousBootTime = 0;

        _previousRunInfo = previousRunInfo;

        if (previousRunInfo.hasData) {
            if (previousRunInfo.previousAppVersion) {
                _previousAppVersion = previousRunInfo.previousAppVersion;
            }
            if (previousRunInfo.previousOSVersion) {
                _previousOSVersion = previousRunInfo.previousOSVersion;
            }
            if (previousRunInfo.backgrounded) {
                _backgrounded = previousRunInfo.backgrounded;
            }
            if (previousRunInfo.didTerminate) {
                _didTerminate = previousRunInfo.didTerminate;
            }
            if (previousRunInfo.previousBootTime) {
                _previousBootTime = previousRunInfo.previousBootTime;
            }
            [self _detectStartupReason];
            _didTerminate = NO;
            _backgrounded = NO;
        }

        _notificationCenter = notificationCenter;
        [_notificationCenter addObserver:self selector:@selector(applicationDidBecomeActive)
                                    name:UIApplicationDidBecomeActiveNotification
                                  object:nil];
        [_notificationCenter addObserver:self selector:@selector(applicationWillResignActive)
                                    name:UIApplicationWillResignActiveNotification
                                  object:nil];
        [_notificationCenter addObserver:self selector:@selector(applicationWillTerminate)
                                    name:UIApplicationWillTerminateNotification
                                  object:nil];

        [self _persist];
    }
    return self;
}

- (void)_persist
{
    self.previousRunInfo.previousAppVersion = self.currentAppVersion ?: @"";
    self.previousRunInfo.previousOSVersion = self.currentOSVersion ?: @"";
    self.previousRunInfo.backgrounded = self.backgrounded;
    self.previousRunInfo.didTerminate = self.didTerminate;
    self.previousRunInfo.previousBootTime = self.currentBootTime;
    [self.previousRunInfo persist];
}

- (void)_detectStartupReason
{
    if (self.previousRunDidCrash) {
        self.startupReason = UBStartupReasonCrash;
    } else if (self.debugging) {
        self.startupReason = UBStartupReasonDebug;
    } else if (![self.previousOSVersion isEqualToString:self.currentOSVersion]) {
        self.startupReason = UBStartupReasonOSUpgrade;
    } else if (![self.previousAppVersion isEqualToString:self.currentAppVersion]) {
        self.startupReason = UBStartupReasonAppUpgrade;
    } else if (self.didTerminate) {
        self.startupReason = UBStartupReasonForceQuit;
    } else if (self.currentBootTime != self.previousBootTime) {
        self.startupReason = UBStartupReasonRestart;
    } else {
        if (self.backgrounded) {
            self.startupReason = UBStartupReasonBackgroundEviction;
        } else {
            self.startupReason = UBStartupReasonOutOfMemory;
        }
    }
}

- (NSString *)currentBundleVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

#pragma mark - Notifications

- (void)applicationDidBecomeActive
{
    self.backgrounded = NO;
    [self _persist];
}

- (void)applicationWillResignActive
{
    self.backgrounded = YES;
    [self _persist];
}

- (void)applicationWillTerminate
{
    self.didTerminate = YES;
    [self _persist];
}

- (void)dealloc
{
    [self.notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [self.notificationCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [self.notificationCenter removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

@end
