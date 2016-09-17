Pod::Spec.new do |s|

s.name         = "flag-icon-swift"
s.version      = "0.1.0"
s.license      = "MIT"
s.homepage     = "https://github.com/malczak/flag-icon-swift"
s.summary      = "A collection of all country flags to be used in Swift"
s.author       = { "Mateusz Malczak" => "mateusz@malczak.info" }
s.source       = { :git => "https://github.com/malczak/flag-icon-swift.git", :branch => "swift" }

s.platform     = :ios, "8.0"

s.source_files  = "Source/*.swift"
s.exclude_files = "Source/*Tests.swift"

s.requires_arc = true
end
