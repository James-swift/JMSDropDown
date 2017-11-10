Pod::Spec.new do |s|

  s.name          = "JMSDropDown"
  s.version       = "1.0.2"
  s.license       = "MIT"
  s.summary       = "A custom dropdown written in Swift."
  s.homepage      = "https://github.com/James-swift/JMSDropDown"
  s.author        = { "xiaobs" => "1007785739@qq.com" }
  s.source        = { :git => "https://github.com/James-swift/JMSDropDown.git", :tag => "1.0.2" }
  s.requires_arc  = true
  s.description   = <<-DESC
                   JMSDropDown - A custom dropdown written in Swift.
                   DESC
  s.source_files  = "JMSDropDown/DropDown/*", "JMSDropDown/DropDown/helpers/*"
  s.platform      = :ios, '8.0'
  s.framework     = 'Foundation', 'UIKit'

end
