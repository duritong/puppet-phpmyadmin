# determine the version of apache installed
Facter.add('phpmyadmin_version') do
  confine :osfamily => ['RedHat']
  setcode do
    s = Facter::Util::Resolution.exec('rpm -q --queryformat \'%{VERSION}\' phpMyAdmin')
    s == 'package phpMyAdmin is not installed' ? nil : s
  end
end
