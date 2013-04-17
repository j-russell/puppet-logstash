class logstash::config (
  $logstash_home          = '/usr/local/logstash',
  $logstash_etc           = '/etc/logstash',
  $grok_patterns_dir      = '/etc/logstash/grok',
  $logstash_version       = '1.1.10',
  $logstash_log           = '/var/log/logstash',
  $logstash_jar_provider  = 'http',
  $logstash_baseurl       = 'https://logstash.objects.dreamhost.com/release/',
  $logstash_verbose       = 'no',
  $logstash_user          = 'logstash',
  $logstash_user_uid      = 3300,
  $logstash_group         = 'logstash',
  $logstash_user_gid      = 3300,
  $elasticsearch_provider = 'external',
  $elasticsearch_host     = '127.0.0.1',
  $elasticsearch_cluster  = 'elasticsearch',
  $java_home              = '/usr/lib/jvm/jre') {
  file { $logstash_home: ensure => 'directory', }

  file { "${logstash_home}/bin/":
    ensure  => 'directory',
    require => File[$logstash_home],
  }

  file { "${logstash_home}/lib/":
    ensure  => 'directory',
    require => File[$logstash_home],
  }

  file { $logstash_etc: ensure => 'directory', }

  file { $logstash_log:
    ensure  => 'directory',
    recurse => true,
  }

  file { $grok_patterns_dir:
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  class { '::logstash::package':
    logstash_home         => $logstash_home,
    logstash_version      => $logstash_version,
    logstash_jar_provider => $logstash_jar_provider,
    logstash_baseurl      => $logstash_baseurl,
  }

  class { '::logstash::user':
    logstash_user_uid => $logstash_user_uid,
    logstash_user_gid => $logstash_user_gid,
    logstash_home     => $logstash_home,
  }
}

