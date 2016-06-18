# manage the basis of a phppgadmin
class phpmyadmin(
  $blowfish_secret = trocla("phpmyadmin_blowfish_secret_${::fqdn}",'plain','length: 32'),
  $servers = [
    { 'host' => 'localhost' },
  ],
) {
  include ::php
  include ::php::extensions::mysql
  include ::php::extensions::mcrypt


  package{'phpMyAdmin':
    ensure  => installed,
    require => Package['php','php-mysql'],
  } -> file{'/etc/phpMyAdmin/config.custom.php':
    content => template('phpmyadmin/config.custom.php.erb'),
    owner   => root,
    group   => 0,
    mode    => '0444',
  } -> file_line{'phpmyadmin_config_include':
    path  => '/etc/phpMyAdmin/config.inc.php',
    line  => 'require(\'/etc/phpMyAdmin/config.custom.php\');',
    after => '.*cfg\[\'PmaNoRelation_DisableWarning\'\] = .*',
  }
}
