class logstash::indexer {
  Class['::logstash::config','::logstash::package'] -> Class['::logstash::indexer']

  User <| tag == 'logstash' |>
  Group <| tag == 'logstash' |>

  include concat::setup

  ::concat { "${::logstash::config::logstash_etc}/indexer.conf":
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service['logstash-indexer'];
  }

  ::concat::fragment {
    'logstash-indexer_input_header':
      target  => "${::logstash::config::logstash_etc}/indexer.conf",
      order   => '0999',
      content => "input {\n";

    'logstash-indexer_input_footer':
      target  => "${::logstash::config::logstash_etc}/indexer.conf",
      order   => '1998',
      content => "}\n";

    'logstash-indexer_filter_header':
      target  => "${::logstash::config::logstash_etc}/indexer.conf",
      order   => '1999',
      content => "filter {\n";

    'logstash-indexer_filter_footer':
      target  => "${::logstash::config::logstash_etc}/indexer.conf",
      order   => '2998',
      content => "}\n";

    'logstash-indexer_output_header':
      target  => "${::logstash::config::logstash_etc}/indexer.conf",
      order   => '2999',
      content => "output {\n";

    'logstash-indexer_output_footer':
      target  => "${::logstash::config::logstash_etc}/indexer.conf",
      order   => '3999',
      content => "}\n"
  }

  ::logstash::javainitscript { 'logstash-indexer':
    serviceuser    => $::logstash::config::logstash_user,
    servicegroup   => $::logstash::config::logstash_group,
    servicehome    => $::logstash::config::logstash_home,
    servicelogfile => "${::logstash::config::logstash_log}/indexer.log",
    servicejar     => $::logstash::package::jar,
    serviceargs    => " agent -f ${::logstash::config::logstash_etc}/indexer.conf -l ${::logstash::config::logstash_log}/indexer.log",
    java_home      => $::logstash::config::java_home,
  }

  service { 'logstash-indexer':
    ensure    => 'running',
    hasstatus => true,
    enable    => true,
    require   => [
      Logstash::Javainitscript['logstash-indexer'],
      Class['::logstash::package']],
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
