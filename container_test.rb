PORT = attribute('port', default: '8080', description: 'port set by user')

control 'cont-01' do
  impact 1.0
  title 'Containers Running'
  desc "MySQL 5.7 container should running and have correct environment"

  describe docker_container 'db' do
    it { should exist }
    it { should be_running }
    its('image') { should eq 'mysql:5.7' }
  end

  describe json({ command: 'docker inspect db'}) do
    its([0,'Config','Env']) { should include 'MYSQL_DATABASE=wordpress' }
    its([0,'Config','Env']) { should include 'MYSQL_USER=wordpress' }
    its([0,'Config','Env']) { should include /MYSQL_ROOT_PASSWORD/ }
    its([0,'Config','Env']) { should include /MYSQL_PASSWORD/ }
    its([0,'HostConfig','RestartPolicy','Name']) { should eq 'always' }
  end
end

control 'cont-02' do
  impact 1.0
  title 'Containers Running'
  desc "WordPress container should be running and have correct environment"

  describe docker_container 'wordpress' do
    it { should exist }
    it { should be_running }
    its('id') { should_not eq '' }
    its('repo') { should eq 'wordpress' }
  end

  describe json({ command: 'docker inspect wordpress'}) do
    its([0,'Config','Env']) { should include /WORDPRESS_DB_HOST=db.*/ }
    its([0,'Config','Env']) { should include /WORDPRESS_DB_PASSWORD/ }
    its([0,'HostConfig','RestartPolicy','Name']) { should eq 'always' }
  end
end

control 'env-01' do
  impact 1.0
  title 'Environment Specified Port'
  desc "WordPress container map port specified by user"

  describe docker_container 'wordpress' do
    its('ports') { should eq "0.0.0.0:#{PORT}->80/tcp" }
  end
end

control 'net-01' do
  impact 1.0
  title 'Container Network'
  desc "Containers Should Use Private Network"

  describe command('docker network ls -f name=wordpress_net -q | wc -l') do
    its('stdout') { should match /1/ }
  end

  describe json({ command: 'docker inspect wordpress'}) do
    its([0,'HostConfig','NetworkMode']) { should eq 'wordpress_net' }
  end

  describe json({ command: 'docker inspect db'}) do
    its([0,'HostConfig','NetworkMode']) { should eq 'wordpress_net' }
  end
end

control 'vol-01' do
  impact 1.0
  title 'Database Volume'
  desc "Database should use persistent volume"

  describe command('docker volume ls -f name=db_data') do
    its('stdout') { should match /db_data/ }
    its('stdout') { should match /local/ }
  end

  describe json({ command: 'docker inspect db'}) do
    its([0,'Mounts',0,'Type']) { should eq 'volume' }
    its([0,'Mounts',0,'Name']) { should eq 'db_data' }
  end
end