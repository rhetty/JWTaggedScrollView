Pod::Spec.new do |s|
  s.name         = "JWTaggedScrollView"
  s.version      = "0.0.1"
  s.summary      = "Views can be switched by triggering tags or swipping."
  s.homepage     = "https://github.com/rhetty/JWTaggedScrollView.git"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Jiawei Huang" => "tcrhetty@gmail.com" }
  s.platform     = :ios, "7.0"
  s.ios.deployment_target = "7.0"
  s.source       = { :git => "https://github.com/rhetty/JWTaggedScrollView.git", :tag => s.version}
  s.source_files  = 'JWTaggedScrollView/TaggedScrollView/*.{h,m}'
  s.requires_arc = true
end