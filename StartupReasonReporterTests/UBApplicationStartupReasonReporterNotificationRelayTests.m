//
//  Copyright (c) Uber Technologies, Inc. All rights reserved.
//

#import "UBApplicationStartupReasonReporterNotificationRelay.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>


@interface UBApplicationStartupReasonReporterNotificationRelay ()

@property (nonatomic, readonly) NSMutableSet<id<UBApplicationStartupReasonReporterNotificationRelaySubscriber>> *subscribers;

@end


@interface UBApplicationStartupReasonReporterNotificationRelayTests : XCTestCase

@end


@implementation UBApplicationStartupReasonReporterNotificationRelayTests

- (void)test_addSubscriber
{
    id subscriber1 = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterNotificationRelaySubscriber));
    id subscriber2 = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterNotificationRelaySubscriber));

    UBApplicationStartupReasonReporterNotificationRelay *relay = [[UBApplicationStartupReasonReporterNotificationRelay alloc] init];
    [relay addSubscriber:subscriber1];
    [relay addSubscriber:subscriber2];

    XCTAssert([relay.subscribers containsObject:subscriber1]);
    XCTAssert([relay.subscribers containsObject:subscriber2]);
}

- (void)test_removeSubscriber
{
    id subscriber1 = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterNotificationRelaySubscriber));
    id subscriber2 = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterNotificationRelaySubscriber));

    UBApplicationStartupReasonReporterNotificationRelay *relay = [[UBApplicationStartupReasonReporterNotificationRelay alloc] init];
    [relay addSubscriber:subscriber1];
    [relay addSubscriber:subscriber2];
    [relay removeSubscriber:subscriber1];
    [relay removeSubscriber:subscriber2];

    XCTAssertFalse([relay.subscribers containsObject:subscriber1]);
    XCTAssertFalse([relay.subscribers containsObject:subscriber2]);
}

- (void)test_updateApplicationStateNotification
{
    id subscriber1 = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterNotificationRelaySubscriber));
    id subscriber2 = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterNotificationRelaySubscriber));
    NSNotification *notification = [[NSNotification alloc] initWithName:UIApplicationWillResignActiveNotification object:nil userInfo:nil];

    UBApplicationStartupReasonReporterNotificationRelay *relay = [[UBApplicationStartupReasonReporterNotificationRelay alloc] init];
    [relay addSubscriber:subscriber1];
    [relay addSubscriber:subscriber2];
    OCMExpect([subscriber1 processNotification:notification]);
    OCMExpect([subscriber2 processNotification:notification]);
    [relay updateApplicationStateNotification:notification];
    OCMVerifyAll(subscriber1);
    OCMVerifyAll(subscriber2);
}

@end
