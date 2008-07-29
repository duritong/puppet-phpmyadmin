# modules/phpmyadmin/manifests/init.pp - manage phpmyadmin stuff
# Copyright (C) 2007 admin@immerda.ch
#

# modules_dir { "phpmyadmin": }

class phpmyadmin {
    case $operatingsystem {
        gentoo: { include phpmyadmin::gentoo }
        centos: { include phpmyadmin::centos }
        default: { include phpmyadmin::base }
    }
}

class phpmyadmin::base {
    include php
    include php::mysql

    package { phpmyadmin:
        ensure => present,
        require => Package[php],
    }

    file{ phpmyadmin_config:
            path => "/var/www/localhost/htdocs/phpmyadmin/config.inc.php",
            source => [
                "puppet://$server/files/phpmyadmin/${fqdn}/config.inc.php",
                "puppet://$server/files/phpmyadmin/config.inc.php",
                "puppet://$server/phpmyadmin/config.inc.php"
            ],
            ensure => file,
            owner => root,
            group => 0,
            mode => 0444,
            require => Package[phpmyadmin],
    }

}

class phpmyadmin::gentoo inherits phpmyadmin::base {
    include webapp-config

    Package[phpmyadmin]{
        category => 'dev-db',
        require => Package[webapp-config],
    }
}

class phpmyadmin::centos inherits phpmyadmin::base {
    Package[phpmyadmin]{
        name => 'phpMyAdmin',
        require +> Package[php-mysql],
    }

    File[phpmyadmin_config]{
        path => '/etc/phpMyAdmin/config.inc.php',
    }
}
