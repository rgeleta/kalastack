/**
 *
 * Class that governs the creation of the mysql-server configuration
 *
 */
class mysql::server::config {

  mysql::my { "my.cnf":
    path => "/etc/mysql/my.cnf",
    data_dir => "/etc/kalastack/mysql",
    require => Class["mysql::server::install"],
    notify => Class["mysql::server::service"],
    subscribe => Class["apparmor::service"],
  }

  file { "/etc/kalastack/mysql":
    ensure  => directory,
    mode    => 777,
    subscribe => File["/etc/kalastack"],
  }

  exec { "movedata":
    path    => "/bin:/usr/bin",
    unless  => "du -h /etc/kalastack/mysql | grep mysql/mysql && du -h /etc/kalastack/mysql/performance_schema | grep mysql/performance_schema && du -h /etc/kalastack/mysql/phpmyadmin | grep mysql/phpmyadmin",
    command => "sudo service mysql stop && sudo cp -R /var/lib/mysql/mysql /etc/kalastack/mysql && sudo cp -R /var/lib/mysql/performance_schema /etc/kalastack/mysql && sudo cp -R /var/lib/mysql/phpmyadmin /etc/kalastack/mysql && sudo service mysql start",
    require => File["/etc/kalastack/mysql"],
    subscribe => Exec["phpmyadmincontrolconfig"],
  }

  user { "mysql":
    groups => ['dialout'],
    require => Class["mysql::server::install"],
  }

}
