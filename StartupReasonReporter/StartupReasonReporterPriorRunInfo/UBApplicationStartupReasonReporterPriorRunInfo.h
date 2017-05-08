//
//  Copyright (c) 2017 Uber Technologies, Inc. All rights reserved.
//

#import "UBApplicationStartupReasonReporterPriorRunInfoProtocol.h"

#import <Foundation/Foundation.h>

/**
 An NSUserDefaults based implementation of UBApplicationStartupReasonReporterPriorRunInfoProtocol
 */
NS_SWIFT_NAME(ApplicationStartupReasonReporterPriorRunInfo)

@interface UBApplicationStartupReasonReporterPriorRunInfo : NSObject <UBApplicationStartupReasonReporterPriorRunInfoProtocol>

/**
 Initializes a new UBApplicationStartupReasonReporterPriorRunInfo

 @param userDefaults The current user defaults
 */
- (nonnull instancetype)initWithUserDefaults:(nonnull NSUserDefaults *)userDefaults;

@end

