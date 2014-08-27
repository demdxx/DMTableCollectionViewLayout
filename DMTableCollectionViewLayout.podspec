Pod::Spec.new do |s|
  s.name            = 'DMTableCollectionViewLayout'
  s.author          = { "Dmitry Ponomarev" => "demdxx@gmail.com" }
  s.version         = '0.0.1'
  s.license         = 'MIT'
  s.summary         = 'UICollectionView transform into a table'
  s.homepage        = 'https://github.com/demdxx/DMTableCollectionViewLayout'
  s.source          = {:git => 'https://github.com/demdxx/DMTableCollectionViewLayout.git', :tag => 'v0.0.1'}

  # Deployment
  s.platform        = :ios

  s.source_files    = 'src/*.{h,m}'
  s.requires_arc    = true

  s.ios.frameworks  = 'Foundation', 'UIKit'
end