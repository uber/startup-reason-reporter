#
# Be sure to run `pod lib lint StartupReasonReporter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'StartupReasonReporter'
  s.version          = '0.1.0'
  s.summary          = 'Provides the reason that an iOS application has launched.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The Startup Reason Reporter provides developers the the reason that an iOS application has launched, or equivalently, the reason that the application terminated on the prior launch.
                       DESC

  s.homepage         = 'https://github.com/uber/StartupReasonReporter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.source           = { :git => 'https://github.com/uber/StartupReasonReporter.git', :tag => s.version.to_s }
  s.author           = "Uber"
  
  s.ios.deployment_target = '8.0'

  s.source_files = 'StartupReasonReporter/**/*'
  
  s.subspec 'Core' do |core|
    core.source_files = 'StartupReasonReporter/StartupReasonReporter/*'
  end

end
