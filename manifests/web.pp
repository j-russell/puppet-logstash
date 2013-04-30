class logstash::web {
  Class['::logstash::config', '::logstash::package'] -> Class['::logstash::web']

  Group <| tag == 'logstash' |>
  User <| tag == 'logstash' |>

  logstash::javainitscript { 'logstash-web':
    serviceuser    => $::logstash::config::logstash_user,
    servicegroup   => $::logstash::config::logstash_group,
    servicehome    => $::logstash::config::logstash_home,
    servicelogfile => "${::logstash::config::logstash_log}/web.log",
    servicejar     => $::logstash::package::jar,
    serviceargs    => " web --backend elasticsearch://localhost:9300/${::logstash::config::elasticsearch_cluster} -l ${::logstash::config::logstash_log}/web.log",
    java_home      => $::logstash::config::java_home,
  }

  service { 'logstash-web':
    ensure    => 'running',
    hasstatus => true,
    enable    => true,
    require   => Logstash::Javainitscript['logstash-web'],
  }

  file { '/etc/logrotate.d/logstash-web':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "${::logstash::config::logstash_log}/web.log {
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

