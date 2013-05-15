class logstash::lumberjack::config {
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

  concat { '/etc/lumberjack/lumberjack.conf':
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    notify => Service['lumberjack'],
  }

  File['/etc/lumberjack'] -> Concat['/etc/lumberjack/lumberjack.conf']
}
