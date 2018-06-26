//
//  Copyright (c) Uber Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Subscriber protocol which is used to respond to notifications emitted.
 */
NS_SWIFT_NAME(ApplicationStartupReasonReporterNotificationRelaySubscriber)
@protocol UBApplicationStartupReasonReporterNotificationRelaySubscriber

@required

/**
 *  Perform any work as a result of the given notification.
 *  @param notification the notification emitted.
 */
- (void)processNotification:(NSNotification *)notification;

@end

/**
 *  Notification relay protocol to relay notifications to a set of subscribers.
 */
NS_SWIFT_NAME(ApplicationStartupReasonReporterNotificationRelayProtocol)
@protocol UBApplicationStartupReasonReporterNotificationRelayProtocol

@required

/**
 *  Add a subscriber to the set of subscribers responding to notifications.
 *  @param subscriber the subscriber to add.
 */
- (void)addSubscriber:(id<UBApplicationStartupReasonReporterNotificationRelaySubscriber>)subscriber;

/**
 *  Remove a subscriber from the set of subscribers responding to notifications.
 *  @param subscriber the subscriber to remove.
 */
- (void)removeSubscriber:(id<UBApplicationStartupReasonReporterNotificationRelaySubscriber>)subscriber;

/**
 *  Relays the notification to the set of subscribers.
 *  @param notification the notification to relay.
 */
- (void)updateApplicationStateNotification:(NSNotification *)notification;

@end

/**
 *  Notification relay class to relay notifications to a set of subscribers.
 */
NS_SWIFT_NAME(ApplicationStartupReasonReporterNotificationRelay)
@interface UBApplicationStartupReasonReporterNotificationRelay : NSObject <UBApplicationStartupReasonReporterNotificationRelayProtocol>

@end

NS_ASSUME_NONNULL_END
