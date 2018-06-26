//
//  Copyright (c) Uber Technologies, Inc. All rights reserved.
//

#import "UBApplicationStartupReasonReporterPriorRunInfo.h"
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>


@interface UBApplicationStartupReasonReporterPriorRunInfoTests : XCTestCase

@end


@implementation UBApplicationStartupReasonReporterPriorRunInfoTests

- (void)test_priorRunAtDirectoryURL
{
    NSMutableDictionary *dictionaryRepresentation = [NSMutableDictionary dictionary];
    dictionaryRepresentation[@"prevAppVersion"] = @"test_version";
    dictionaryRepresentation[@"prevOSVersion"] = @"test_os_version";
    dictionaryRepresentation[@"prevBootTime"] = [NSNumber numberWithInteger:1];
    dictionaryRepresentation[@"backgrounded"] = [NSNumber numberWithBool:YES];
    dictionaryRepresentation[@"terminate"] = [NSNumber numberWithBool:YES];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionaryRepresentation options:kNilOptions error:nil];

    NSURL *url = [NSURL URLWithString:@"test"];
    id NSDataMock = OCMClassMock([NSData class]);
    OCMStub([NSDataMock dataWithContentsOfFile:[url URLByAppendingPathComponent:@"priorRunInfo.json"].path]).andReturn(data);
    UBApplicationStartupReasonReporterPriorRunInfo *info = [UBApplicationStartupReasonReporterPriorRunInfo priorRunAtDirectoryURL:url];

    XCTAssertTrue([info.previousAppVersion isEqualToString:@"test_version"]);
    XCTAssertTrue([info.previousOSVersion isEqualToString:@"test_os_version"]);
    XCTAssertTrue(info.previousBootTime == 1);
    XCTAssertTrue(info.backgrounded);
    XCTAssertTrue(info.didTerminate);
}

- (void)test_persist
{
    __block UBApplicationStartupReasonReporterPriorRunInfo *info = [[UBApplicationStartupReasonReporterPriorRunInfo alloc] init];
    info.previousAppVersion = @"test_version";
    info.previousOSVersion = @"test_os_version";
    info.previousBootTime = 1;
    info.backgrounded = YES;
    info.didTerminate = YES;

    id NSJSONSerializationMock = OCMClassMock([NSJSONSerialization class]);
    id dataMock = OCMPartialMock([NSData data]);
    OCMStub([NSJSONSerializationMock dataWithJSONObject:OCMOCK_ANY options:kNilOptions error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
                                                                                                                        __unsafe_unretained NSDictionary *dict = nil;
                                                                                                                        [invocation getArgument:&dict atIndex:2];

                                                                                                                        XCTAssertTrue([dict[@"prevAppVersion"] isEqualToString:info.previousAppVersion]);
                                                                                                                        XCTAssertTrue([dict[@"prevOSVersion"] isEqualToString:info.previousOSVersion]);
                                                                                                                        XCTAssertTrue([dict[@"backgrounded"] boolValue]);
                                                                                                                        XCTAssertTrue([dict[@"terminate"] boolValue]);
                                                                                                                        XCTAssertTrue([dict[@"prevBootTime"] integerValue] == 1);
                                                                                                                    }).andReturn(dataMock);
    OCMStub([dataMock writeToFile:OCMOCK_ANY options:NSDataWritingAtomic error:[OCMArg anyObjectRef]]).andReturn(YES);
    [info persist];
    OCMVerify([dataMock writeToFile:OCMOCK_ANY options:NSDataWritingAtomic error:[OCMArg anyObjectRef]]);
}

@end
