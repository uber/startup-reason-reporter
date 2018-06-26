//
//  Copyright (c) Uber Technologies, Inc. All rights reserved.
//

#import "UBApplicationStartupReasonReporterPriorRunInfo.h"

static NSString *const UBApplicationStartupReasonReporterDataPreviousAppVersionKey = @"prevAppVersion";
static NSString *const UBApplicationStartupReasonReporterDataPreviousOSVersionKey = @"prevOSVersion";
static NSString *const UBApplicationStartupReasonReporterDataBackgroundedKey = @"backgrounded";
static NSString *const UBApplicationStartupReasonReporterDataDidTerminateKey = @"terminate";
static NSString *const UBApplicationStartupReasonReporterDataBootTimeKey = @"prevBootTime";

static NSString *const UBApplicationStartupReasonReporterFilename = @"priorRunInfo.json";


@interface UBApplicationStartupReasonReporterPriorRunInfo ()

@property (nonatomic, nullable) NSURL *filepath;

@end


@implementation UBApplicationStartupReasonReporterPriorRunInfo

@synthesize hasData = _hasData;
@synthesize previousAppVersion = _previousAppVersion;
@synthesize previousOSVersion = _previousOSVersion;
@synthesize previousBootTime = _previousBootTime;
@synthesize backgrounded = _backgrounded;
@synthesize didTerminate = _didTerminate;

+ (nonnull instancetype)priorRunAtDirectoryURL:(nullable NSURL *)directoryURL
{
    NSURL *filepath = [directoryURL URLByAppendingPathComponent:UBApplicationStartupReasonReporterFilename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryURL.path isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryURL.path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    UBApplicationStartupReasonReporterPriorRunInfo *priorRunInfo = [[UBApplicationStartupReasonReporterPriorRunInfo alloc] initWithFilepath:filepath];
    if (priorRunInfo == nil) {
        priorRunInfo = [[UBApplicationStartupReasonReporterPriorRunInfo alloc] init];
    }
    if (filepath != nil) {
        priorRunInfo.filepath = filepath;
    } else {
        priorRunInfo.filepath = [[NSURL alloc] initWithString:NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject];
    }

    return priorRunInfo;
}

- (void)persist
{
    self.hasData = YES;
    [self writeToFilepath:self.filepath];
}

#pragma mark - Persistence Translation

- (instancetype)initWithFilepath:(NSURL *)filepath
{
    NSData *data = [NSData dataWithContentsOfFile:filepath.path];
    NSDictionary *dictionaryRepresentation = nil;
    if (data != nil) {
        NSError *error = nil;
        dictionaryRepresentation = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSAssert(error == nil, @"error found when deserializing startup reason data: %@", error.localizedDescription);
    }
    self = [super init];
    if (self) {
        if (dictionaryRepresentation != nil) {
            _hasData = YES;
            if ([dictionaryRepresentation[UBApplicationStartupReasonReporterDataPreviousAppVersionKey] isKindOfClass:[NSString class]]) {
                _previousAppVersion = dictionaryRepresentation[UBApplicationStartupReasonReporterDataPreviousAppVersionKey];
            }
            if ([dictionaryRepresentation[UBApplicationStartupReasonReporterDataPreviousOSVersionKey] isKindOfClass:[NSString class]]) {
                _previousOSVersion = dictionaryRepresentation[UBApplicationStartupReasonReporterDataPreviousOSVersionKey];
            }
            if ([dictionaryRepresentation[UBApplicationStartupReasonReporterDataBootTimeKey] isKindOfClass:[NSNumber class]]) {
                _previousBootTime = [dictionaryRepresentation[UBApplicationStartupReasonReporterDataBootTimeKey] integerValue];
            }
            if ([dictionaryRepresentation[UBApplicationStartupReasonReporterDataBackgroundedKey] isKindOfClass:[NSNumber class]]) {
                _backgrounded = [dictionaryRepresentation[UBApplicationStartupReasonReporterDataBackgroundedKey] boolValue];
            }
            if ([dictionaryRepresentation[UBApplicationStartupReasonReporterDataDidTerminateKey] isKindOfClass:[NSNumber class]]) {
                _didTerminate = [dictionaryRepresentation[UBApplicationStartupReasonReporterDataDidTerminateKey] boolValue];
            }
        }
    }

    return self;
}

- (void)writeToFilepath:(NSURL *)filepath
{
    NSMutableDictionary *dictionaryRepresentation = [NSMutableDictionary dictionary];
    if (self.previousAppVersion != nil) {
        dictionaryRepresentation[UBApplicationStartupReasonReporterDataPreviousAppVersionKey] = self.previousAppVersion;
    }
    if (self.previousOSVersion) {
        dictionaryRepresentation[UBApplicationStartupReasonReporterDataPreviousOSVersionKey] = self.previousOSVersion;
    }
    dictionaryRepresentation[UBApplicationStartupReasonReporterDataBootTimeKey] = [NSNumber numberWithInteger:self.previousBootTime];
    dictionaryRepresentation[UBApplicationStartupReasonReporterDataBackgroundedKey] = [NSNumber numberWithBool:self.backgrounded];
    dictionaryRepresentation[UBApplicationStartupReasonReporterDataDidTerminateKey] = [NSNumber numberWithBool:self.didTerminate];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionaryRepresentation options:kNilOptions error:&error];
    NSAssert(error == nil, @"error found when serializing startup reason object: %@", error.localizedDescription);
    error = nil;
    [data writeToFile:filepath.path options:NSDataWritingAtomic error:&error];
    NSAssert(error == nil, @"error found when writing startup reason object: %@", error.localizedDescription);
}

@end
