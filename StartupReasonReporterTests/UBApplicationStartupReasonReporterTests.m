//
//  Copyright (c) 2016-2017 Uber Technologies, Inc. All rights reserved.
//

#import "UBApplicationStartupReasonReporter.h"
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>


@interface UBApplicationStartupReasonReporterTests : XCTestCase

@property (nonatomic) NSNotificationCenter *notificationCenter;

@property (nonatomic) NSString *currentAppVersion;
@property (nonatomic) NSString *currentOSVersion;

@property (nonatomic) NSArray *mocks;


@end


@implementation UBApplicationStartupReasonReporterTests

- (void)setUp
{
    [super setUp];
    self.currentAppVersion = @"2.0";
    self.currentOSVersion = @"9.0";
    self.notificationCenter = [[NSNotificationCenter alloc] init];

    id mainBundleMock = OCMPartialMock([NSBundle mainBundle]);
    OCMStub([mainBundleMock infoDictionary]).andReturn(@{ @"CFBundleVersion" : self.currentAppVersion });
    id NSBundleMock = OCMClassMock([NSBundle class]);
    OCMStub([NSBundleMock mainBundle]).andReturn(mainBundleMock);

    id deviceMock = OCMPartialMock([UIDevice currentDevice]);
    OCMStub([(UIDevice *)deviceMock systemVersion]).andReturn(self.currentOSVersion);
    id UIDeviceMock = OCMClassMock([UIDevice class]);
    OCMStub([UIDeviceMock currentDevice]).andReturn(deviceMock);

    self.mocks = @[ mainBundleMock, NSBundleMock, deviceMock, UIDeviceMock ];
}

- (void)tearDown
{
    [super tearDown];

    for (id mock in self.mocks) {
        [mock stopMocking];
    }
}

- (void)test_init_subscribedToNotificationCenter
{
    id notificationCenterMock = OCMPartialMock(self.notificationCenter);

    OCMExpect([notificationCenterMock addObserver:OCMOCK_ANY
                                         selector:@selector(applicationDidBecomeActive)
                                             name:UIApplicationDidBecomeActiveNotification
                                           object:nil]);
    OCMExpect([notificationCenterMock addObserver:OCMOCK_ANY
                                         selector:@selector(applicationWillResignActive)
                                             name:UIApplicationWillResignActiveNotification
                                           object:nil]);
    OCMExpect([notificationCenterMock addObserver:OCMOCK_ANY
                                         selector:@selector(applicationWillTerminate)
                                             name:UIApplicationWillTerminateNotification
                                           object:nil]);

    id<UBApplicationStartupReasonReporterPriorRunInfoProtocol> previousStartupMock = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterPriorRunInfoProtocol));
    UBApplicationStartupReasonReporter *reporter = [[UBApplicationStartupReasonReporter alloc]
        initWithNotificationCenter:(NSNotificationCenter *)notificationCenterMock
               previousRunDidCrash:NO
                   previousRunInfo:previousStartupMock
                         debugging:NO];

    OCMVerifyAll(notificationCenterMock);
    XCTAssertNotNil(reporter);
    [notificationCenterMock stopMocking];
}

- (void)test_init_persistsDefaultValues
{
    id previousStartupMock = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterPriorRunInfoProtocol));

    OCMExpect([previousStartupMock setBackgrounded:NO]);
    OCMExpect([previousStartupMock setPreviousAppVersion:@"2.0"]);
    OCMExpect([previousStartupMock setPreviousOSVersion:@"9.0"]);
    OCMExpect([previousStartupMock setDidTerminate:NO]);
    OCMExpect([previousStartupMock setPreviousBootTime:[UBApplicationStartupReasonReporter systemBootTime]]);

    OCMExpect([previousStartupMock persist]);

    UBApplicationStartupReasonReporter *reporter = [[UBApplicationStartupReasonReporter alloc]
        initWithNotificationCenter:self.notificationCenter
               previousRunDidCrash:NO
                   previousRunInfo:previousStartupMock
                         debugging:NO];

    OCMVerifyAll(previousStartupMock);
    XCTAssertNotNil(reporter);
}


- (void)test_init_whenBackgroundingOrForegrounding_persistsChange
{
    id previousStartupMock = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterPriorRunInfoProtocol));

    UBApplicationStartupReasonReporter *reporter = [[UBApplicationStartupReasonReporter alloc]
        initWithNotificationCenter:self.notificationCenter
               previousRunDidCrash:NO
                   previousRunInfo:previousStartupMock
                         debugging:NO];
    XCTAssertNotNil(reporter);

    OCMExpect([previousStartupMock setBackgrounded:YES]);
    OCMExpect([previousStartupMock setPreviousAppVersion:@"2.0"]);
    OCMExpect([previousStartupMock setPreviousOSVersion:@"9.0"]);
    OCMExpect([previousStartupMock setDidTerminate:NO]);
    OCMExpect([previousStartupMock setPreviousBootTime:[UBApplicationStartupReasonReporter systemBootTime]]);
    OCMExpect([previousStartupMock persist]);

    [self.notificationCenter postNotificationName:UIApplicationWillResignActiveNotification object:nil];
    OCMVerifyAll(previousStartupMock);

    OCMExpect([previousStartupMock setBackgrounded:NO]);
    OCMExpect([previousStartupMock persist]);

    [self.notificationCenter postNotificationName:UIApplicationDidBecomeActiveNotification object:nil];
    OCMVerifyAll(previousStartupMock);
}

- (void)test_init_whenTerminating_persistsChange
{
    id previousStartupMock = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterPriorRunInfoProtocol));

    UBApplicationStartupReasonReporter *reporter = [[UBApplicationStartupReasonReporter alloc]
        initWithNotificationCenter:self.notificationCenter
               previousRunDidCrash:NO
                   previousRunInfo:previousStartupMock
                         debugging:NO];
    XCTAssertNotNil(reporter);
    [self.notificationCenter postNotificationName:UIApplicationWillResignActiveNotification object:nil];

    OCMExpect([previousStartupMock setBackgrounded:YES]);
    OCMExpect([previousStartupMock setPreviousAppVersion:@"2.0"]);
    OCMExpect([previousStartupMock setPreviousOSVersion:@"9.0"]);
    OCMExpect([previousStartupMock setDidTerminate:YES]);
    OCMExpect([previousStartupMock setPreviousBootTime:[UBApplicationStartupReasonReporter systemBootTime]]);
    OCMExpect([previousStartupMock persist]);

    [self.notificationCenter postNotificationName:UIApplicationWillTerminateNotification object:nil];
    OCMVerifyAll(previousStartupMock);
}

- (void)test_init_correctStartupReason
{
    id previousStartupMock = OCMProtocolMock(@protocol(UBApplicationStartupReasonReporterPriorRunInfoProtocol));
    UBApplicationStartupReasonReporter *reporter = [[UBApplicationStartupReasonReporter alloc]
        initWithNotificationCenter:self.notificationCenter
               previousRunDidCrash:NO
                   previousRunInfo:previousStartupMock
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
    OCMStub([previousStartupMock hasData]).andReturn(YES);
    OCMStub([previousStartupMock backgrounded]).andReturn(backgrounded);
    OCMStub([previousStartupMock previousAppVersion]).andReturn(prevAppVersion);
    OCMStub([previousStartupMock previousOSVersion]).andReturn(prevOSVersion);
    OCMStub([previousStartupMock didTerminate]).andReturn(terminate);
    OCMStub([previousStartupMock previousBootTime]).andReturn(prevBootTime);
    UBApplicationStartupReasonReporter *reporter = [[UBApplicationStartupReasonReporter alloc]
        initWithNotificationCenter:self.notificationCenter
               previousRunDidCrash:previousRunDidCrash
                   previousRunInfo:previousStartupMock
                         debugging:debugging];

    XCTAssertEqualObjects(startupReason, reporter.startupReason);
}

@end
