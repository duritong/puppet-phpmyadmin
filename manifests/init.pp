# modules/phpmyadmin/manifests/init.pp - manage phpmyadmin stuff
# Copyright (C) 2007 admin@immerda.ch
#

# modules_dir { "phpmyadmin": }

class phpmyadmin {

    case $operatingsystem {
        gentoo: { include webapp-config }
    }
    
    $modulename = "phpmyadmin"
    $pkgname = "phpmyadmin"
    $gentoocat = "dev-db"
    $cnfname = "config.inc.php"
    $cnfpath = "/var/www/localhost/htdocs/phpmyadmin"

    package { $pkgname:
        ensure => present,
        category => $operatingsystem ? {
            gentoo => $gentoocat,
            default => '',
        }
    }

    file{
        "${cnfpath}/${cnfname}":
            source => [
                "puppet://$server/dist/${modulename}/${fqdn}/${cnfname}",
                "puppet://$server/${modulename}/${fqdn}/${cnfname}",
                "puppet://$server/${modulename}/${cnfname}"
            ],
            owner => root,
            group => 0,
            mode => 0444,
            require => Package[$pkgname],
    }

}

