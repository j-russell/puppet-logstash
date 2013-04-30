class logstash::shipper (
  $filterworkers = 1) {
  Class['::logstash::config', '::logstash::package'] -> Class['::logstash::shipper']

  Group <| tag == 'logstash' |>
  User <| tag == 'logstash' |>

  service { 'logstash-shipper':
    ensure    => 'running',
    hasstatus => true,
    enable    => true,
    require   => [Logstash::Javainitscript['logstash-shipper'], Class['::logstash::package']],
  }

  ::logstash::javainitscript { 'logstash-shipper':
    serviceuser    => $::logstash::config::logstash_user,
    servicegroup   => $::logstash::config::logstash_group,
    servicehome    => $::logstash::config::logstash_home,
    servicelogfile => "${::logstash::config::logstash_log}/shipper.log",
    servicejar     => $::logstash::package::jar,
    serviceargs    => " agent -f ${::logstash::config::logstash_etc}/shipper -w ${filterworkers} -l ${::logstash::config::logstash_log}/shipper.log",
    java_home      => $::logstash::config::java_home,
  }

  file { "${::logstash::config::logstash_etc}/shipper":
    ensure  => directory,
    purge   => true,
    recurse => true,
    force   => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Service['logstash-shipper'],
  }

  file { '/etc/logrotate.d/logstash-shipper':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "${::logstash::config::logstash_log}/shipper.log {
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
