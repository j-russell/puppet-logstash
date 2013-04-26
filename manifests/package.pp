class logstash::package (
  $logstash_home         = $::logstash::config::logstash_home,
  $logstash_version      = $::logstash::config::logstash_version,
  $logstash_jar          = $::logstash::config::logstash_jar,
  $logstash_jar_provider = $::logstash::config::logstash_jar_provider,
  $logstash_baseurl      = $::logstash::config::logstash_baseurl) {
  Class['::logstash::config'] -> Class['::logstash::package']

  if !$logstash_jar {
    $logstash_jar_file = sprintf('%s-%s-%s', 'logstash', $logstash_version, 'flatjar.jar')
  } else {
    $logstash_jar_file = $logstash_jar
  }

  $jar = "${logstash_home}/${logstash_jar_file}"

  if $logstash_jar_provider == 'package' {
    package { 'logstash':
      ensure => 'latest',
    }
  } elsif $logstash_jar_provider == 'puppet' {
    file { $jar:
      ensure => present,
      source => "puppet:///modules/logstash/${logstash_jar_file}",
    }
  }

  $logstash_url = "${logstash_baseurl}/${logstash_jar_file}"

  exec { "curl -o ${jar} ${logstash_url}":
    timeout => 0,
    cwd     => '/tmp',
    creates => $jar,
    path    => [
      '/usr/bin',
      '/usr/sbin'],
  }

  if $logstash_jar_provider == 'external' {
    notify { "It's up to you to provide ${logstash_jar_file}":
    }
  }
}
