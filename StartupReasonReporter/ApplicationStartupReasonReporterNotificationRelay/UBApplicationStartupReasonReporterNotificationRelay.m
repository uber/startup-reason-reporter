//
//  Copyright (c) Uber Technologies, Inc. All rights reserved.
//

#import "UBApplicationStartupReasonReporterNotificationRelay.h"


@interface UBApplicationStartupReasonReporterNotificationRelay ()

@property (nonatomic, readonly) NSMutableSet<id<UBApplicationStartupReasonReporterNotificationRelaySubscriber>> *subscribers;
@property (nonatomic, readonly) NSObject *subscribersLockToken;

@end


@implementation UBApplicationStartupReasonReporterNotificationRelay

- (instancetype)init
{
    self = [super init];
    if (self) {
        _subscribers = [[NSMutableSet<UBApplicationStartupReasonReporterNotificationRelaySubscriber> alloc] init];
        _subscribersLockToken = [[NSObject alloc] init];
    }

    return self;
}

- (void)addSubscriber:(id<UBApplicationStartupReasonReporterNotificationRelaySubscriber>)subscriber
{
    @synchronized(self.subscribersLockToken)
    {
        [self.subscribers addObject:subscriber];
    }
}

- (void)removeSubscriber:(id<UBApplicationStartupReasonReporterNotificationRelaySubscriber>)subscriber
{
    @synchronized(self.subscribersLockToken)
    {
        [self.subscribers removeObject:subscriber];
    }
}

- (void)updateApplicationStateNotification:(NSNotification *)notification
{
    @synchronized(self.subscribersLockToken)
    {
        for (id<UBApplicationStartupReasonReporterNotificationRelaySubscriber> subscriber in self.subscribers.allObjects) {
            [subscriber processNotification:notification];
        }
    }
}

@end
