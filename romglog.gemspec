Gem::Specification.new do |s|
  s.name        = 'romglog'
  s.version     = '0.0.8'
  s.summary     = "Realtime git log + reflog using fseventsd based on benhoskings's omglog."
  s.description = "Realtime git log + reflog using fseventsd based on benhoskings's omglog. omg! :)"
  s.authors     = ["Huiming Teo"]
  s.email       = 'teohuiming@gmail.com'
  s.files       = `git ls-files bin/ lib/`.split("\n")
  s.executables = ['omglog', 'romglog']
  s.homepage    = 'http://github.com/teohm/romglog'

  s.add_dependency 'rb-fsevent', '~> 0.9.0'
  s.add_dependency 'rb-inotify', '~> 0.8.8'
end
