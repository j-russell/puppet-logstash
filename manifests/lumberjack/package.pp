class logstash::lumberjack::package (
  $package_name    = 'lumberjack',
  $package_version = 'installed',
) {
  package { $package_name:
    ensure => $package_version
  }
}
