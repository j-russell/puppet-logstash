define logstash::lumberjack (
  $file,
  $window_size = undef,
  $fields      = {}
) {
  if !defined(Class['::logstash::lumberjack::package']) {
    class { '::logstash::lumberjack::package': }
  }

  if !defined(Class['::logstash::lumberjack::config']) {
    class { '::logstash::lumberjack::config': }
  }

  Class['::logstash::lumberjack::package'] -> Class['::logstash::lumberjack::config']

  concat::fragment { "lumberjack_${name}":
    target  => '/etc/lumberjack/lumberjack.conf',
    content => $file,
  }
}
