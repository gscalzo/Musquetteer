Pod::Spec.new do |s|
  s.name     = 'Musquetteer'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'A iOS MQTT client lib.'
  s.homepage = 'https://github.com/gscalzo/Musquetteer'
  s.author   = { 'Giordano Scalzo' => 'giordano.scalzo@gmail.com' }
  s.source   = { :git => 'https://github.com/gscalzo/Musquetteer.git', :tag => '0.0.1'  }
  s.source_files = 'Musquetteer/Lib/**/*.{h,m,c}'
  s.platform = :ios
  s.requires_arc = true
end
