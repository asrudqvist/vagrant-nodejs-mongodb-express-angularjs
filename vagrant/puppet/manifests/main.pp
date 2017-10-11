class apt_update {
    exec { "aptGetUpdate":
        command => "apt-get update",
        path => ["/bin", "/usr/bin"]
    }
}

class othertools {
    package { "git":
        ensure => latest,
        require => Exec["aptGetUpdate"]
    }

    package { "vim-common":
        ensure => latest,
        require => Exec["aptGetUpdate"]
    }

    package { "curl":
        ensure => present,
        require => Exec["aptGetUpdate"]
    }

    package { "htop":
        ensure => present,
        require => Exec["aptGetUpdate"]
    }
		
}

class mosquitto 
{
    exec { "adddMosquittoRepo":
        command => "apt-add-repository ppa:mosquitto-dev/mosquitto-ppa",
        path => ["/bin", "/usr/bin"]
    }

	exec { "aptGetUpdate 2":
        command => "sudo apt-get update",
        path => ["/bin", "/usr/bin"],
		require => Exec["adddMosquittoRepo"],
    }
	
	package { "mosquitto":
        ensure => present,
		provider => 'apt',
        require => Exec["aptGetUpdate 2"]
    }

	package { "mosquitto-clients":
        ensure => present,
		provider => 'apt',
        require => Package["mosquitto"]
    }

}

class node-js {
  include apt
  apt::ppa {
    'ppa:chris-lea/node.js': notify => Package["nodejs"]
  }

  package { "nodejs" :
      ensure => latest,
      require => [Exec["aptGetUpdate"],Class["apt"]]
  }

  exec { "npm-update" :
      cwd => "/home/vagrant",
      command => "npm -g update",
      onlyif => ["test -d /vagrant/node_modules"],
      path => ["/bin", "/usr/bin"],
      require => Package['nodejs']
  }
  
  exec { "npm-express" :
      cwd => "/home/vagrant",
      command => "npm -g install express ; npm -g install express-generator",
	  creates => "/home/vagrant/.express",
      path => ["/bin", "/usr/bin"],
      require => Exec['npm-update']
  }
}

class mongodb {
  exec { "10genKeys":
    command => "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10",
    path => ["/bin", "/usr/bin"],
    notify => Exec["aptGetUpdate"],
    unless => "apt-key list | grep 10gen"
  }

  file { "10gen.list":
    path => "/etc/apt/sources.list.d/10gen.list",
    ensure => file,
    content => "deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen",
    notify => Exec["10genKeys"]
  }

  package { "mongodb-10gen":
    ensure => present,
    require => [Exec["aptGetUpdate"],File["10gen.list"]]
  }
}

include apt_update
include othertools
include node-js
include mongodb
include mosquitto