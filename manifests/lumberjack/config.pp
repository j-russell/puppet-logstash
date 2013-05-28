class logstash::lumberjack::config ($ssl_ca_path = undef, $ssl_ca_source = undef,) {
  include concat::setup

  file { '/etc/init.d/lumberjack':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/logstash/lumberjack.init'
  }

  service { 'lumberjack':
    ensure    => running,
    hasstatus => true,
  }

  File['/etc/init.d/lumberjack'] -> Service['lumberjack']

  file { '/etc/lumberjack':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  if $ssl_ca_source {
    file { $ssl_ca_path:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => $ssl_ca_source,
      require => File['/etc/lumberjack'],
      before  => Service['lumberjack'],
    }
  }

  concat { '/etc/lumberjack/lumberjack.conf':
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service['lumberjack'],
  }

  File['/etc/lumberjack'] -> Concat['/etc/lumberjack/lumberjack.conf']
}
