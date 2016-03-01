Pod::Spec.new do |s|

  s.name         = "BFLabel"
  s.version      = "0.1.0"
  s.summary      = "A rich text label."

  s.description  = <<-DESC
                   A rich text label. Emoticon enable
                   DESC

  s.homepage     = "https://github.com/baiyyyf/BFLabel"
  #s.screenshots  = "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/logo.png"

  s.license      = 'MIT'

  s.authors            = { "baiyyyf" => "byunfi@outlook.com" }
  s.social_media_url   = "http://twitter.com/baiyyyf"

  s.ios.deployment_target = "8.0"

  s.source       = { :git => "https://github.com/baiyyyf/BFLabel.git", :tag => s.version }

  s.source_files  = ["Source/*.swift", "Source/BFLabel.h"]
  s.public_header_files = ["Source/BFLabel.h"]


  s.requires_arc = true
  s.framework = "UIKit"

end
