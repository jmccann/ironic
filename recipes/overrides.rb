include_recipe 'openstack-bare-metal::conductor'

class ::Chef::Recipe # rubocop:disable Documentation
  include ::Openstack
end

db_user = node['openstack']['db']['bare-metal']['username']
db_pass = get_password 'db', 'ironic'
db_connection = db_uri('bare-metal', db_user, db_pass)

mq_service_type = node['openstack']['mq']['bare-metal']['service_type']

if mq_service_type == 'rabbitmq'
  node['openstack']['mq']['bare-metal']['rabbit']['ha'] && (rabbit_hosts = rabbit_servers)
  mq_password = get_password 'user', node['openstack']['mq']['bare-metal']['rabbit']['userid']
elsif mq_service_type == 'qpid'
  mq_password = get_password 'user', node['openstack']['mq']['bare-metal']['qpid']['username']
end

image_endpoint = endpoint 'image-api'

identity_endpoint = internal_endpoint 'identity-internal'
identity_admin_endpoint = admin_endpoint 'identity-admin'
service_pass = get_password 'service', 'openstack-bare-metal'

auth_uri = auth_uri_transform(identity_endpoint.to_s, node['openstack']['bare-metal']['api']['auth']['version'])
identity_uri = identity_uri_transform(identity_admin_endpoint)

network_endpoint = internal_endpoint 'network-api' || {}
api_bind = internal_endpoint 'bare-metal-api-bind'

# Contribute attributizing: enabled-drivers, swift, node['openstack']['bare-metal']['deploy_callback_timeout']
r = resources('template[/etc/ironic/ironic.conf]')
r.cookbook 'ironic'
r.variables api_bind_address: api_bind.host,
            api_bind_port: api_bind.port,
            db_connection: db_connection,
            mq_service_type: mq_service_type,
            mq_password: mq_password,
            rabbit_hosts: rabbit_hosts,
            network_endpoint: network_endpoint,
            glance_protocol: image_endpoint.scheme,
            glance_host: image_endpoint.host,
            glance_port: image_endpoint.port,
            auth_uri: auth_uri,
            identity_uri: identity_uri,
            service_pass: service_pass,
            swift_key: get_password('user', 'admin')

# Contribute fix node cleaning
cookbook_file '/usr/lib/python2.7/site-packages/ironic/drivers/modules/agent_base_vendor.py' do
  notifies :restart, 'service[ironic-conductor]', :delayed
end
