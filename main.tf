provider "docker" {
}

resource "docker_volume" "db_data" {}

resource "docker_network" "wordpress_net" {
  name = "wordpress_net"
}

resource "docker_container" "db" {
    name = "db"
    image = "mysql:5.7"
    restart = "always"
    network_mode = "wordpress_net"
    mounts {
        type = "volume"
        target = "/var/lib/mysql"
        source = "db_data"
    }
    env = [
     "MYSQL_ROOT_PASSWORD=wordpress",
     "MYSQL_PASSWORD=wordpress",
     "MYSQL_USER=wordpress",
     "MYSQL_DATABASE=wordpress"
    ]
}

resource "docker_container" "wordpress" {
    name = "wordpress"
    image = "wordpress:latest"
    restart = "always"
    network_mode = "wordpress_net"
    ports {
        internal = "80"
        external = "8080"
    }
    env = [
        "WORDPRESS_DB_HOST=db:3306",
        "WORDPRESS_DB_PASSWORD=wordpress"
    ]
}