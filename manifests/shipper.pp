class logstash::shipper {
  Class['::logstash::config', '::logstash::package'] -> Class['::logstash::shipper']

  Group <| tag == 'logstash' |>
  User <| tag == 'logstash' |>

  service { 'logstash-shipper':
    ensure    => 'running',
    hasstatus => true,
    enable    => true,
    require   => Logstash::Javainitscript['logstash-shipper'],
  }

  include concat::setup

  ::concat { "${::logstash::config::logstash_etc}/shipper.conf":
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service['logstash-shipper'];
  }

  ::concat::fragment {
    'logstash-shipper_input_header':
      target  => "${::logstash::config::logstash_etc}/shipper.conf",
      order   => '0999',
      content => "input {\n";

    'logstash-shipper_input_footer':
      target  => "${::logstash::config::logstash_etc}/shipper.conf",
      order   => '1998',
      content => "}\n";

    'logstash-shipper_filter_header':
      target  => "${::logstash::config::logstash_etc}/shipper.conf",
      order   => '1999',
      content => "filter {\n";

    'logstash-shipper_filter_footer':
      target  => "${::logstash::config::logstash_etc}/shipper.conf",
      order   => '2998',
      content => "}\n";

    'logstash-shipper_output_header':
      target  => "${::logstash::config::logstash_etc}/shipper.conf",
      order   => '2999',
      content => "output {\n";

    'logstash-shipper_output_footer':
      target  => "${::logstash::config::logstash_etc}/shipper.conf",
      order   => '3999',
      content => "}\n"
  }

  ::logstash::javainitscript { 'logstash-shipper':
    serviceuser    => $::logstash::config::logstash_user,
    servicegroup   => $::logstash::config::logstash_group,
    servicehome    => $::logstash::config::logstash_home,
    servicelogfile => "${::logstash::config::logstash_log}/shipper.log",
    servicejar     => $::logstash::package::jar,
    serviceargs    => " agent -f ${::logstash::config::logstash_etc}/shipper.conf -l ${::logstash::config::logstash_log}/shipper.log",
    java_home      => $::logstash::config::java_home,
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
