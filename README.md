# Startup Reason Reporter [![Build Status](https://travis-ci.org/uber/startup-reason-reporter.svg?branch=master)](https://travis-ci.org/uber/startup-reason-reporter)

The Startup Reason Reporter provides developers the reason that an iOS application has launched, or equivalently, the reason that the application terminated on the prior launch.

## Use

Usage is fairly straight-forward:


Swift:

```swift
// Determine whether the app crashed on a prior launch
let crashedOnPriorLaunch = ...

// Initialize a storage mechanism implementing UBApplicationStartupReasonReporterPriorRunInfoProtocol
let previousRunInfo: ApplicationStartupReasonReporterProtocol = ...

// Initialize the notification relay
let notificationRelay = ApplicationStartupReasonReporterNotificationRelay()

// Initialize the startup reason reporter
let startupReasonReporter = ApplicationStartupReasonReporter(previousRunDidCrash: crashedOnPreviousLaunch,
previousRunInfo: previousRunInfo,
notificationRelay: notificationRelay,
debugging: false)

// Profit
let startupReason =  startupReasonReporter.startupReason

// ...
// In AppDelegate connect notification relay to app lifecycle methods

public func applicationDidBecomeActive(_ application: UIApplication) {
    notificationRelay.updateApplicationStateNotification(Notification(name: .UIApplicationDidBecomeActive))
}

public func applicationWillResignActive(_ application: UIApplication) {
    notificationRelay.updateApplicationStateNotification(Notification(name: .UIApplicationWillResignActive))
}

public func applicationWillTerminate(_ application: UIApplication) {
    notificationRelay.updateApplicationStateNotification(Notification(name: .UIApplicationWillTerminate))
}
```

Obj-C:

```objc
// Determine whether the app crashed on a prior launch
BOOL crashedOnPriorLaunch = ...

// Initialize a storage mechanism implementing UBApplicationStartupReasonReporterPriorRunInfoProtocol
id<UBApplicationStartupReasonReporterPriorRunInfoProtocol> runInfo = ...

// Initialize the notification relay
id<UBApplicationStartupReasonReporterNotificationRelayProtocol> = [[UBApplicationStartupReasonReporterNotificationRelay alloc] init]

// Initialize the startup reason reporter
UBApplicationStartupReasonReporter *startupReasonReporter = [[UBApplicationStartupReasonReporter alloc] initWithPreviousRunDidCrash:crashedOnPriorLaunch
        previousRunInfo:runInfo
        notificationRelay: notificationRelay
        debugging:[UBBuildType isDebugBuild]];

// Profit
UBStartupReason startupReason = startupReasonReporter.startupReason

// ...
// In AppDelegate connect notification relay to app lifecycle methods

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.notificationRelay updateApplicationStateNotification:[NSNotification notificationWithName:UIApplicationDidBecomeActiveNotification object:nil]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.notificationRelay updateApplicationStateNotification:[NSNotification notificationWithName:UIApplicationWillResignActiveNotification object:nil]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.notificationRelay updateApplicationStateNotification:[NSNotification notificationWithName:UIApplicationWillTerminateNotification object:nil]];
}
```

## Introduction

The UBStartupReasonReporter is based on the general idea that applications may terminate for a fixed set of reasons on iOS.  

Through process of elimination, the UBStartupReasonReporter can detect important events such as OOM crashes and app upgrades.  The full list of possible startup reasons is described below.

Critically, the reported startup reason is only as accurate as the the data that is provided to it.  For instance, some crash detection mechanisms may not encompass all forms of crashes, which may throw off the reported reason.  Additionally we found that application state notifications are not always delivered, or given time to execute unless you hook into the first notification emitted by the OS, in the corresponding AppDelegate method. This is why we provide a notification relay to easily hook into these lifecycle events.

Our process for detecting various startup reasons is detailed by Ali Ansari and Grzegorz Pstrucha in this blog post: [Reducing FOOMs in the iOS app](https://code.facebook.com/posts/1146930688654547/reducing-fooms-in-the-facebook-ios-app/)

In order for detection to work, you must provide a class that implements prior run storage and conforms to UBApplicationStartupReasonReporterPriorRunInfoProtocol.  We provide one such class, backed by the file system using JSON encoding, in UBApplicationStartupReasonReporterPriorRunInfo, though you may also wish to implement your own version that is backed by your preferred storage mechanism.

Possible startup reasons are as follows:

```objc
UBStartupReason const UBStartupReasonDebug = @"debug";
UBStartupReason const UBStartupReasonFirstTime = @"first_time";
UBStartupReason const UBStartupReasonCrash = @"crash";
UBStartupReason const UBStartupReasonForceQuit = @"force_quit";
UBStartupReason const UBStartupReasonAppUpgrade = @"app_upgrade";
UBStartupReason const UBStartupReasonOSUpgrade = @"os_upgrade";
UBStartupReason const UBStartupReasonBackgroundEviction = @"background_eviction";
UBStartupReason const UBStartupReasonRestart = @"restart";
UBStartupReason const UBStartupReasonOutOfMemory = @"out_of_memory";
```

## Installation
#### CocoaPods

To integrate the StartupReasonReporter into your project add the following to your `Podfile`:

```ruby
pod 'StartupReasonReporter', '~> 0.2.0'
```

To integrate only the `UBApplicationStartupReasonReporterPriorRunInfoProtocol` protocol, but not the implementation, add the following to your `Podfile`:

```ruby
pod 'StartupReasonReporter/Core', '~> 0.2.0'
```

#### Carthage

To integrate the StartupReasonReporter into your project using Carthage add the following to your `Cartfile`:

```ruby
github "uber/startup-reason-reporter" ~> 0.2.0
```

## Contributions

We'd love for you to contribute to our open source projects. Before we can accept your contributions, we kindly ask you to sign our [Uber Contributor License Agreement](https://docs.google.com/a/uber.com/forms/d/1pAwS_-dA1KhPlfxzYLBqK6rsSWwRwH95OCCZrcsY5rk/viewform).

- If you **find a bug**, open an issue or submit a fix via a pull request.
- If you **have a feature request**, open an issue or submit an implementation via a pull request
- If you **want to contribute**, submit a pull request.

## License

    Copyright (c) 2015 Uber Technologies, Inc.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
