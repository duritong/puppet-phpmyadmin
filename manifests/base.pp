class phpmyadmin::base {
    include php
    include php::extensions::mysql
    include php::extensions::mcrypt

    package { phpmyadmin:
        ensure => present,
        require => Package[php],
    }

    file{ phpmyadmin_config:
            path => "/var/www/localhost/htdocs/phpmyadmin/config.inc.php",
            source => [
                "puppet://$server/modules/site-phpmyadmin/${fqdn}/config.inc.php",
                "puppet://$server/modules/site-phpmyadmin/config.inc.php",
                "puppet://$server/modules/phpmyadmin/config.inc.php"
            ],
            ensure => file,
            owner => root,
            group => 0,
            mode => 0444,
            require => Package[phpmyadmin],
    }

}

