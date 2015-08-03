module ::Openstack
  # Contribute back to openstack-common

  include ::ChefVaultItem
  def vault_secret(bag_name, index)
    ::Chef::Log.info "Loading vault secret #{index} from #{bag_name}"
    chef_vault_item(bag_name, index)[index]
  end
end
