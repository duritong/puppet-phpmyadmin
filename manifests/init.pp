# manage the basis of a phppgadmin
class phpmyadmin(
  $blowfish_secret = trocla("phpmyadmin_blowfish_secret_${::fqdn}",'plain','length: 32'),
  $servers         = [
    { 'host' => 'localhost' },
  ],
  $upload_dir      = '/var/lib/phpMyAdmin/upload',
  $save_dir        = '/var/lib/phpMyAdmin/save',
) {
  include ::php
  include ::php::extensions::mysql
  include ::php::extensions::mcrypt

  if $facts['phpmyadmin_version'] {
    $guessed_version = $facts['phpmyadmin_version']
  } else {
    $guessed_version = '4.4.15.10'
  }

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
  } -> file{'/usr/share/phpMyAdmin/doc/html': # fix broken rpm
    ensure => link,
    target => "/usr/share/doc/phpMyAdmin-${guessed_version}/html",
  }
}
