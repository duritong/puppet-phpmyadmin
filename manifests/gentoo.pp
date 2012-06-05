class phpmyadmin::gentoo inherits phpmyadmin::base {
  require webapp_config

  Package[phpmyadmin]{
    category => 'dev-db',
  }
}

