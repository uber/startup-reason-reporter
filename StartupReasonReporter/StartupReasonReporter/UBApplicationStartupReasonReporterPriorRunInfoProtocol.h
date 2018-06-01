//
//  Copyright (c) Uber Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Defines a storage interface for the UBApplicationStartupReasonReporter.
 On launch, should contain information regarding the prior app run.
 When data is set thereafter, a call to persist should persist the data for the next app launch.
 */

NS_SWIFT_NAME(ApplicationStartupReasonReporterProtocol)

@protocol UBApplicationStartupReasonReporterPriorRunInfoProtocol

/// Indicates whether data exists for the prior run.  Generally, this will be false on the first run and true thereafter.
@property (nonatomic) BOOL hasData;
/// The app version of the prior app run.
@property (nonatomic, nullable, copy) NSString *previousAppVersion;
/// The OS version of the prior app run.
@property (nonatomic, nullable, copy) NSString *previousOSVersion;
/// The boot time of the prior app run.
@property (nonatomic) time_t previousBootTime;
/// Indicates whether the prior app run was backgrounded.
@property (nonatomic) BOOL backgrounded;
/// Indicates whether the prior app run was terminated.
@property (nonatomic) BOOL didTerminate;

/**
 Persists the current prior run info to disk.
 */
- (void)persist;
@end
