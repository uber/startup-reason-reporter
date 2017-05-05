//
//  Copyright (c) 2017 Uber Technologies, Inc. All rights reserved.
//
#import "UBApplicationStartupReasonReporterPriorRunInfo.h"

static NSString *const UBApplicationStartupResonReporterDataKey = @"appStartupReason";
static NSString *const UBApplicationStartupResonReporterDataPreviousAppVersionKey = @"prevAppVersion";
static NSString *const UBApplicationStartupResonReporterDataPreviousOSVersionKey = @"prevOSVersion";
static NSString *const UBApplicationStartupResonReporterDataBackgroundedKey = @"backgrounded";
static NSString *const UBApplicationStartupResonReporterDataDidTerminateKey = @"terminate";
static NSString *const UBApplicationStartupResonReporterDataBootTimeKey = @"prevBootTime";


@interface UBApplicationStartupReasonReporterPriorRunInfo ()

@property (nonatomic) NSUserDefaults *userDefaults;

@end


@implementation UBApplicationStartupReasonReporterPriorRunInfo

@synthesize hasData = _hasData;
@synthesize previousAppVersion = _previousAppVersion;
@synthesize previousOSVersion = _previousOSVersion;
@synthesize previousBootTime = _previousBootTime;
@synthesize backgrounded = _backgrounded;
@synthesize didTerminate = _didTerminate;

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
{
    self = [super init];
    if (self) {
        NSDictionary *dict = [userDefaults dictionaryForKey:UBApplicationStartupResonReporterDataKey];
        _userDefaults = userDefaults;

        if (dict) {
            _hasData = YES;

            if (dict[UBApplicationStartupResonReporterDataPreviousAppVersionKey]) {
                _previousAppVersion = dict[UBApplicationStartupResonReporterDataPreviousAppVersionKey];
            }
            if (dict[UBApplicationStartupResonReporterDataPreviousOSVersionKey]) {
                _previousOSVersion = dict[UBApplicationStartupResonReporterDataPreviousOSVersionKey];
            }
            if ([dict[UBApplicationStartupResonReporterDataBackgroundedKey] isKindOfClass:[NSNumber class]]) {
                _backgrounded = ((NSNumber *)dict[UBApplicationStartupResonReporterDataBackgroundedKey]).boolValue;
            }
            if ([dict[UBApplicationStartupResonReporterDataDidTerminateKey] isKindOfClass:[NSNumber class]]) {
                _didTerminate = ((NSNumber *)dict[UBApplicationStartupResonReporterDataDidTerminateKey]).boolValue;
            }
            if ([dict[UBApplicationStartupResonReporterDataBootTimeKey] isKindOfClass:[NSNumber class]]) {
                _previousBootTime = ((NSNumber *)dict[UBApplicationStartupResonReporterDataBootTimeKey]).longValue;
            }
        }
    }
    return self;
}

- (void)persist
{
    NSDictionary *dict = @{
        UBApplicationStartupResonReporterDataPreviousAppVersionKey : self.previousAppVersion ?: @"",
        UBApplicationStartupResonReporterDataPreviousOSVersionKey : self.previousOSVersion ?: @"",
        UBApplicationStartupResonReporterDataBackgroundedKey : @(self.backgrounded),
        UBApplicationStartupResonReporterDataDidTerminateKey : @(self.didTerminate),
        UBApplicationStartupResonReporterDataBootTimeKey : @(self.previousBootTime)
    };
    [self.userDefaults setObject:dict forKey:UBApplicationStartupResonReporterDataKey];
    [self.userDefaults synchronize];
    self.hasData = YES;
}


@end
