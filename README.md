# Startup Reason Reporter [![Build Status](https://travis-ci.com/uber/startup-reason-reporter.svg)](https://travis-ci.com/uber/startup-reason-reporter)

The Startup Reason Reporter provides developers the the reason that an iOS application has launched, or equivalently, the reason that the application terminated on the prior launch.

## Use

Usage is fairly straight-forward:


Swift:
```
// Determine whether the app crashed on a prior launch
let crashedOnPriorLaunch = ...

// Initialize a storage mechanism implementing UBApplicationStartupReasonReporterPriorRunInfoProtocol
let previousRunInfo: ApplicationStartupReasonReporterProtocol = ...

// Initialize the startup reason reporter
let startupReasonReporter = ApplicationStartupReasonReporter(notificationCenter: NotificationCenter.default, 
previousRunDidCrash: crashedOnPreviousLaunch, 
previousRunInfo: previousRunInfo, 
debugging: false)

// Profit
let startupReason =  startupReasonReporter.startupReason
```

Obj-C:
```
// Determine whether the app crashed on a prior launch
BOOL crashedOnPriorLaunch = ...

// Initialize a storage mechanism implementing UBApplicationStartupReasonReporterPriorRunInfoProtocol
id<UBApplicationStartupReasonReporterPriorRunInfoProtocol> runInfo = ...

// Initialize the startup reason reporter
UBApplicationStartupReasonReporter *applicationStartupReasonReporter = [[UBApplicationStartupReasonReporter alloc] initWithNotificationCenter:[NSNotificationCenter defaultCenter]
        previousRunDidCrash:self.crashReporter.crashDetected
        previousRunInfo:runInfo
        debugging:[UBBuildType isDebugBuild]];

// Profit
UBStartupReason startupReason = startupReasonReporter.startupReason
```

## Introduction

The UBStartupReasonReporter is based on the general idea that applications may terminate for a fixed set of reasons on iOS.  

Through process of elimination, the UBStartupReasonReporter can detect important events such as OOM crashes and app upgrades.  The full list of possible startup reasons is described below.

Critically, the reported startup reason is only as accurate as the the data that is provided to the ApplicationStartupReasonReporter.  Some crash detection mechanisms may not encompass all forms of crashes.

Our process for detecting various startup reasons is detailed by Ali Ansari and Grzegorz Pstrucha in this blog post: [Reducing FOOMs in the iOS app](https://code.facebook.com/posts/1146930688654547/reducing-fooms-in-the-facebook-ios-app/)

In order for detection to work, you must provide a class that implements prior run storage and conforms to UBApplicationStartupReasonReporterPriorRunInfoProtocol.  We provide one such class, backed by NSUserDefaults, in UBApplicationStartupReasonReporterPriorRunInfo, though you may also wish to implement your own version that is backed by your preferred storage mechanism.

Possible startup reasons are as follows:

```
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

To integrate NAME into your project add the following to your `Podfile`:

```ruby
pod 'StartupReasonReporter', '~> 0.1'
```

#### Carthage

To integrate NAME into your project using Carthage add the following to your `Cartfile`:

```ruby
github "uber/StartupReasonReporter" ~> 0.1
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
