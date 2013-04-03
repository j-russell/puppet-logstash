define logstash::grok::pattern (
  $pattern           = undef,
  $pattern_source    = undef,
  $grok_patterns_dir = $logstash::config::grok_patterns_dir,
  $name              = $title) {
  if (!$pattern and !$pattern_source) {
    fail('Must provide either $pattern or $pattern_source')
  } elsif ($pattern and $pattern_source) {
    fail('Must provide either $pattern or $pattern_source - not both')
  }

  file { $name:
    ensure  => present,
    path    => "${grok_patterns_dir}/${name}",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => $pattern_source,
    content => $pattern ? {
      undef   => undef,
      default => template('logstash/grok/pattern.erb'),
    },
  }

}
