//
//  Copyright (c) Uber Technologies, Inc. All rights reserved.
//

#import "UBApplicationStartupReasonReporterPriorRunInfoProtocol.h"

#import <Foundation/Foundation.h>


/**
 An NSUserDefaults based implementation of UBApplicationStartupReasonReporterPriorRunInfoProtocol
 */
NS_SWIFT_NAME(ApplicationStartupReasonReporterPriorRunInfo)
@interface UBApplicationStartupReasonReporterPriorRunInfo : NSObject <UBApplicationStartupReasonReporterPriorRunInfoProtocol>

/**
 *  Returns the prior run information stored to disk at the given directory URL.
 *  @param directoryURL The directory to use to to store the startup reason data.
 *  @return the previous startup reason data if it was present on disk, or empty startup reason object.
 */
+ (nonnull instancetype)priorRunAtDirectoryURL:(nullable NSURL *)directoryURL;

@end
