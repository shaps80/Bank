Pod::Spec.new do |s|
  s.name             = "Bank"
  s.version          = "1.0.0"
  s.summary          = "A flexible, type-safe Caching library in Swift"
  s.homepage         = "https://github.com/shaps80/Bank"
  s.license          = 'MIT'
  s.author           = { "Shaps Mohsenin" => "shapsuk@me.com" }
  s.source           = { :git => "https://github.com/shaps80/Bank.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/shaps'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
end
