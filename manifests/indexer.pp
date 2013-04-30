class logstash::indexer (
  $filterworkers = 1) {
  Class['::logstash::config', '::logstash::package'] -> Class['::logstash::indexer']

  Group <| tag == 'logstash' |>
  User <| tag == 'logstash' |>

  service { 'logstash-indexer':
    ensure    => 'running',
    hasstatus => true,
    enable    => true,
    require   => [Logstash::Javainitscript['logstash-indexer'], Class['::logstash::package']],
  }

  ::logstash::javainitscript { 'logstash-indexer':
    serviceuser    => $::logstash::config::logstash_user,
    servicegroup   => $::logstash::config::logstash_group,
    servicehome    => $::logstash::config::logstash_home,
    servicelogfile => "${::logstash::config::logstash_log}/indexer.log",
    servicejar     => $::logstash::package::jar,
    serviceargs    => " agent -f ${::logstash::config::logstash_etc}/indexer -w ${filterworkers} -l ${::logstash::config::logstash_log}/indexer.log",
    java_home      => $::logstash::config::java_home,
  }

  file { "${::logstash::config::logstash_etc}/indexer":
    ensure  => directory,
    purge   => true,
    recurse => true,
    force   => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Service['logstash-indexer'],
  }

  if $::logstash::config::elasticsearch_provider == 'embedded' {
    file { "${::logstash::config::logstash_home}/data/elasticsearch":
      ensure  => directory,
      owner   => $::logstash::config::logstash_user,
      group   => $::logstash::config::logstash_group,
      before  => Service['logstash-indexer'],
      require => File["${::logstash::config::logstash_home}/data"],
    }

    file { "${::logstash::config::logstash_home}/data":
      ensure => directory,
      owner  => $::logstash::config::logstash_user,
      group  => $::logstash::config::logstash_group,
    }
  }

  file { '/etc/logrotate.d/logstash-indexer':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "${::logstash::config::logstash_log}/indexer.log {
    daily
    dateext
    compress
    rotate 7
    copytruncate
    notifempty
}
"
  }
}
