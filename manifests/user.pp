class logstash::user (
  $logstash_user     = $::logstash::config::logstash_user,
  $logstash_group    = $::logstash::config::logstash_group,
  $logstash_user_uid = $::logstash::config::logstash_user_uid,
  $logstash_user_gid = $::logstash::config::logstash_user_gid,
  $logstash_home     = $::logstash::config::logstash_home) {
  Class['::logstash::config'] -> Class['::logstash::user']

  User {
    ensure     => present,
    managehome => true,
    shell      => '/bin/false',
    system     => true,
  }

  Group {
    ensure => present }

  @group { $logstash_group:
    gid => $logstash_user_gid,
    tag => 'logstash',
  }

  @user { $logstash_user:
    comment => 'logstash system account',
    tag     => 'logstash',
    uid     => $logstash_user_uid,
    gid     => $logstash_user_gid,
    home    => "${logstash_home}/logstash",
    require => Group[$logstash_group],
  }
}
