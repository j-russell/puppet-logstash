class logstash::package (
  $logstash_home         = $::logstash::config::logstash_home,
  $logstash_version      = $::logstash::config::logstash_version,
  $logstash_jar_provider = $::logstash::config::logstash_jar_provider,
  $logstash_baseurl      = $::logstash::config::logstash_baseurl,
  $java_provider         = $::logstash::config::java_provider,
  $java_package          = $::logstash::config::java_package) {
  Class['::logstash::config'] -> Class['::logstash::package']

  $logstash_jar = sprintf('%s-%s-%s', 'logstash', $logstash_version, 'monolithic.jar')
  $jar          = "${logstash_home}/${logstash_jar}"

  if $logstash_jar_provider == 'package' {
    package { 'logstash':
      ensure => 'latest',
    }
  } elsif $logstash_jar_provider == 'puppet' {
    file { "${logstash_home}/${logstash_jar}":
      ensure => present,
      source => "puppet:///modules/logstash/${logstash_jar}",
    }
  }

  $logstash_url = "${logstash_baseurl}/${logstash_jar}"

  exec { "curl -o ${logstash_home}/${logstash_jar} ${logstash_url}":
    timeout => 0,
    cwd     => '/tmp',
    creates => "${logstash_home}/${logstash_jar}",
    path    => [
      '/usr/bin',
      '/usr/sbin'],
    require => Package['curl'],
  }

  if $logstash_jar_provider == 'external' {
    notify { "It's up to you to provde ${logstash_jar}":
    }
  }

  if $java_provider == 'package' {
    package { $java_package:
      ensure => installed,
    }
  }
}
