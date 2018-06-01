//
//  Copyright (c) Uber Technologies, Inc. All rights reserved.
//

#import "UBApplicationStartupReasonReporter.h"
#import "UBApplicationStartupReasonReporterNotificationRelay.h"
#import "UBApplicationStartupReasonReporterPriorRunInfo.h"
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>


@interface UBApplicationStartupReasonReporter () <UBApplicationStartupReasonReporterNotificationRelaySubscriber>

@end


@interface UBApplicationStartupReasonReporterTests : XCTestCase

@property (nonatomic) NSString *currentAppVersion;
@property (nonatomic) NSString *currentOSVersion;
@property (nonatomic) id sharedApplicationMock;
@property (nonatomic) id previousStartupMock;
@property (nonatomic) id notificationRelayMock;

@property (nonatomic) NSArray *mocks;


@end


@implementation UBApplicationStartupReasonReporterTests

- (void)setUp
{
    [super setUp];
    self.currentAppVersion = @"2.0";
    self.currentOSVersion = @"9.0";

    id mainBundleMock = OCMPartialMock([NSBundle mainBundle]);
    OCMStub([mainBundleMock infoDictionary]).andReturn(@{ @"CFBundleVersion" : self.currentAppVersion });
    id NSBundleMock = OCMClassMock([NSBundle class]);
    OCMStub([NSBundleMock mainBundle]).andReturn(mainBundleMock);

    id deviceMock = OCMPartialMock([UIDevice currentDevice]);
    OCMStub([(UIDevice *)deviceMock systemVersion]).andReturn(self.currentOSVersion);
    id UIDeviceMock = OCMClassMock([UIDevice class]);
    OCMStub([UIDeviceMock currentDevice]).andReturn(deviceMock);

    self.sharedApplicationMock = OCMPartialMock([UIApplication alloc]);
    id UIApplicationMock = OCMClassMock([UIApplication class]);
    OCMStub([UIApplicationMock sharedApplication]).andReturn(self.sharedApplicationMock);

    self.previousStartupMock = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterPriorRunInfoProtocol));
    self.notificationRelayMock = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterNotificationRelayProtocol));

    self.mocks = @[ mainBundleMock, NSBundleMock, deviceMock, UIDeviceMock, self.sharedApplicationMock, UIApplicationMock, self.previousStartupMock, self.notificationRelayMock ];
}

- (void)tearDown
{
    [super tearDown];

    for (id mock in self.mocks) {
        [mock stopMocking];
    }
}

- (void)test_init_notificationRelaySubscribe
{
    id notificationRelayMock = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterNotificationRelayProtocol));
    OCMStub([self.sharedApplicationMock applicationState]).andReturn(UIApplicationStateActive);

    OCMExpect([notificationRelayMock addSubscriber:OCMOCK_ANY]);

    id<UBApplicationStartupReasonReporterPriorRunInfoProtocol> previousStartupMock = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterPriorRunInfoProtocol));
    UBApplicationStartupReasonReporter *reporter = [[UBApplicationStartupReasonReporter alloc]
        initWithPreviousRunDidCrash:NO
                    previousRunInfo:previousStartupMock
                  notificationRelay:notificationRelayMock
                          debugging:NO];

    XCTAssertNotNil(reporter);
}

- (void)test_init_whenBackgroundingOrForegrounding_persistsChange
{
    id notificationRelay = [[UBApplicationStartupReasonReporterNotificationRelay alloc] init];
    OCMStub([self.sharedApplicationMock applicationState]).andReturn(UIApplicationStateActive);

    UBApplicationStartupReasonReporter *reporter = [[UBApplicationStartupReasonReporter alloc]
        initWithPreviousRunDidCrash:NO
                    previousRunInfo:self.previousStartupMock
                  notificationRelay:notificationRelay
                          debugging:NO];
    XCTAssertNotNil(reporter);

    OCMExpect([self.previousStartupMock setBackgrounded:YES]);
    OCMExpect([self.previousStartupMock setPreviousAppVersion:@"2.0"]);
    OCMExpect([self.previousStartupMock setPreviousOSVersion:@"9.0"]);
    OCMExpect([self.previousStartupMock setDidTerminate:NO]);
    OCMExpect([self.previousStartupMock setPreviousBootTime:[UBApplicationStartupReasonReporter systemBootTime]]);
    OCMExpect([self.previousStartupMock persist]);

    [notificationRelay updateApplicationStateNotification:[NSNotification notificationWithName:UIApplicationWillResignActiveNotification object:nil]];
    OCMVerifyAll(self.previousStartupMock);

    OCMExpect([self.previousStartupMock setBackgrounded:NO]);
    OCMExpect([self.previousStartupMock persist]);

    [notificationRelay updateApplicationStateNotification:[NSNotification notificationWithName:UIApplicationDidBecomeActiveNotification object:nil]];
    OCMVerifyAll(self.previousStartupMock);
}

- (void)test_init_whenTerminating_persistsChange
{
    id notificationRelay = [[UBApplicationStartupReasonReporterNotificationRelay alloc] init];
    OCMStub([self.sharedApplicationMock applicationState]).andReturn(UIApplicationStateActive);

    UBApplicationStartupReasonReporter *reporter = [[UBApplicationStartupReasonReporter alloc]
        initWithPreviousRunDidCrash:NO
                    previousRunInfo:self.previousStartupMock
                  notificationRelay:notificationRelay
                          debugging:NO];
    XCTAssertNotNil(reporter);
    [notificationRelay updateApplicationStateNotification:[NSNotification notificationWithName:UIApplicationWillResignActiveNotification object:nil]];

    OCMExpect([self.previousStartupMock setBackgrounded:YES]);
    OCMExpect([self.previousStartupMock setPreviousAppVersion:@"2.0"]);
    OCMExpect([self.previousStartupMock setPreviousOSVersion:@"9.0"]);
    OCMExpect([self.previousStartupMock setDidTerminate:YES]);
    OCMExpect([self.previousStartupMock setPreviousBootTime:[UBApplicationStartupReasonReporter systemBootTime]]);
    OCMExpect([self.previousStartupMock persist]);

    [notificationRelay updateApplicationStateNotification:[NSNotification notificationWithName:UIApplicationWillTerminateNotification object:nil]];
    OCMVerifyAll(self.previousStartupMock);
}

- (void)test_init_correctStartupReason
{
    OCMStub([self.sharedApplicationMock applicationState]).andReturn(UIApplicationStateActive);

    UBApplicationStartupReasonReporter *reporter = [[UBApplicationStartupReasonReporter alloc]
        initWithPreviousRunDidCrash:NO
                    previousRunInfo:self.previousStartupMock
                  notificationRelay:self.notificationRelayMock
                          debugging:NO];
    XCTAssertEqualObjects(reporter.startupReason, UBStartupReasonFirstTime);

    [self verifyStartupReasonIs:UBStartupReasonAppUpgrade
               withBackgrounded:NO
                 prevAppVersion:@"1.0"
                  prevOSVersion:@"9.0"
                      terminate:NO
                   prevBootTime:[UBApplicationStartupReasonReporter systemBootTime]
            previousRunDidCrash:NO
                      debugging:NO];

    [self verifyStartupReasonIs:UBStartupReasonOSUpgrade
               withBackgrounded:YES
                 prevAppVersion:@"2.0"
                  prevOSVersion:@"8.0"
                      terminate:NO
                   prevBootTime:[UBApplicationStartupReasonReporter systemBootTime]
            previousRunDidCrash:NO
                      debugging:NO];

    [self verifyStartupReasonIs:UBStartupReasonForceQuit
               withBackgrounded:YES
                 prevAppVersion:@"2.0"
                  prevOSVersion:@"9.0"
                      terminate:YES
                   prevBootTime:[UBApplicationStartupReasonReporter systemBootTime]
            previousRunDidCrash:NO
                      debugging:NO];

    [self verifyStartupReasonIs:UBStartupReasonBackgroundEviction
               withBackgrounded:YES
                 prevAppVersion:@"2.0"
                  prevOSVersion:@"9.0"
                      terminate:NO
                   prevBootTime:[UBApplicationStartupReasonReporter systemBootTime]
            previousRunDidCrash:NO
                      debugging:NO];

    [self verifyStartupReasonIs:UBStartupReasonOutOfMemory
               withBackgrounded:NO
                 prevAppVersion:@"2.0"
                  prevOSVersion:@"9.0"
                      terminate:NO
                   prevBootTime:[UBApplicationStartupReasonReporter systemBootTime]
            previousRunDidCrash:NO
                      debugging:NO];

    [self verifyStartupReasonIs:UBStartupReasonCrash
               withBackgrounded:YES
                 prevAppVersion:@"2.0"
                  prevOSVersion:@"9.0"
                      terminate:YES
                   prevBootTime:[UBApplicationStartupReasonReporter systemBootTime]
            previousRunDidCrash:YES
                      debugging:NO];

    [self verifyStartupReasonIs:UBStartupReasonRestart
               withBackgrounded:NO
                 prevAppVersion:@"2.0"
                  prevOSVersion:@"9.0"
                      terminate:NO
                   prevBootTime:([UBApplicationStartupReasonReporter systemBootTime] - 100)
            previousRunDidCrash:NO
                      debugging:NO];

    [self verifyStartupReasonIs:UBStartupReasonDebug
               withBackgrounded:YES
                 prevAppVersion:@"2.0"
                  prevOSVersion:@"9.0"
                      terminate:YES
                   prevBootTime:([UBApplicationStartupReasonReporter systemBootTime])
            previousRunDidCrash:NO
                      debugging:YES];
}

- (void)verifyStartupReasonIs:(NSString *)startupReason
             withBackgrounded:(BOOL)backgrounded
               prevAppVersion:(NSString *)prevAppVersion
                prevOSVersion:(NSString *)prevOSVersion
                    terminate:(BOOL)terminate
                 prevBootTime:(time_t)prevBootTime
          previousRunDidCrash:(BOOL)previousRunDidCrash
                    debugging:(BOOL)debugging
{
    id previousStartupMock = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterPriorRunInfoProtocol));
    id notificationRelayMock = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterNotificationRelayProtocol));
    OCMStub([previousStartupMock hasData]).andReturn(YES);
    OCMStub([previousStartupMock backgrounded]).andReturn(backgrounded);
    OCMStub([previousStartupMock previousAppVersion]).andReturn(prevAppVersion);
    OCMStub([previousStartupMock previousOSVersion]).andReturn(prevOSVersion);
    OCMStub([previousStartupMock didTerminate]).andReturn(terminate);
    OCMStub([previousStartupMock previousBootTime]).andReturn(prevBootTime);
    UBApplicationStartupReasonReporter *reporter = [[UBApplicationStartupReasonReporter alloc]
        initWithPreviousRunDidCrash:previousRunDidCrash
                    previousRunInfo:previousStartupMock
                  notificationRelay:notificationRelayMock
                          debugging:debugging];

    XCTAssertEqualObjects(startupReason, reporter.startupReason);
}

@end
