define logstash::javainitscript (
  $servicename     = $title,
  $serviceuser,
  $servicegroup    = undef,
  $servicehome,
  $serviceuserhome = undef,
  $servicelogfile,
  $servicejar,
  $serviceargs,
  $java_home       = '/usr/lib/jvm/jre') {
  $myservicegroup    = $servicegroup ? {
    undef   => $serviceuser,
    default => $servicegroup,
  }

  $myserviceuserhome = $serviceuserhome ? {
    undef   => $servicehome,
    default => $serviceuserhome,
  }

  file { "/etc/init.d/${servicename}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('logstash/javainitscript.erb')
  }
}
