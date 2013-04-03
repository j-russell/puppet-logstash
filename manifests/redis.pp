class logstash::redis (
  $maxmemory = undef,
  $datadir   = undef,) {
  Class['::logstash::config'] -> Class['::logstash::redis']

  if $::logstash::config::redis_provider == 'package' {
    $redis_package = $::logstash::config::redis_version ? {
      /\d+./  => "${::logstash::config::redis_package}-${::logstash::config::redis_version}",
      default => $::logstash::config::redis_package,
    }

    package { $redis_package:
      ensure => present,
    }

    $redis_conf    = '/etc/redis.conf'
    $redis_service = 'redis'

    file { $redis_conf:
      ensure  => present,
      content => template('logstash/redis.conf.erb'),
      require => Package[$redis_package],
    }

    service { $redis_service:
      ensure    => 'running',
      hasstatus => true,
      enable    => true,
      subscribe => File[$redis_conf],
      require   => File[$redis_conf],
    }

    if $datadir {
      file { $datadir:
        ensure  => directory,
        owner   => 'redis',
        group   => 'redis',
        mode    => '0755',
        require => Package[$redis_package],
        before  => Service[$redis_service],
      }
    }
  }
}
