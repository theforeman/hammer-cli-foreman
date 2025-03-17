Host Creation
=============

Host creation is one of the most complex commands in the hammer's foreman plugin. The majority of its parameters
is obvious but there are some that need further explanation as their values differ with the type of a compute resource.

**Warning:**
Output of `hammer host create -h` may vary with the Foreman server used and plugins installed.

Sample help output for `hammer-cli-foreman 0.15.0` and `Foreman 1.20` follows:

```
$ hammer host create -h
Usage:
    hammer host create [OPTIONS]

Options:
 --architecture ARCHITECTURE_NAME                              Architecture name
 --architecture-id ARCHITECTURE_ID
 --ask-root-password ASK_ROOT_PW                               One of true/false, yes/no, 1/0.
 --autoheal AUTOHEAL                                           Sets whether the Host will autoheal subscriptions upon checkin
                                                               One of true/false, yes/no, 1/0.
 --build BUILD                                                 One of true/false, yes/no, 1/0.
 --comment COMMENT                                             Additional information about this host
 --compute-attributes COMPUTE_ATTRS                            Compute resource attributes
                                                               Comma-separated list of key=value
 --compute-profile COMPUTE_PROFILE_NAME                        Name to search by
 --compute-profile-id COMPUTE_PROFILE_ID
 --compute-resource COMPUTE_RESOURCE_NAME                      Compute resource name
 --compute-resource-id COMPUTE_RESOURCE_ID
 --config-group-ids CONFIG_GROUP_IDS                           IDs of associated config groups
                                                               Comma separated list of values. Values containing comma should be quoted or escaped with backslash
 --config-groups CONFIG_GROUP_NAMES                            Comma separated list of values. Values containing comma should be quoted or escaped with backslash
 --content-source CONTENT_SOURCE_NAME                          Content Source name
 --content-source-id CONTENT_SOURCE_ID
 --content-view CONTENT_VIEW_NAME                              Name to search by
 --content-view-id CONTENT_VIEW_ID                             Content view numeric identifier
 --domain DOMAIN_NAME                                          Domain name
 --domain-id DOMAIN_ID                                         Numerical ID or domain name
 --enabled ENABLED                                             Include this host within Foreman reporting
                                                               One of true/false, yes/no, 1/0.
 --hostgroup HOSTGROUP_NAME                                    Hostgroup name
 --hostgroup-id HOSTGROUP_ID
 --hostgroup-title HOSTGROUP_TITLE                             Hostgroup title
 --hypervisor-guest-uuids HYPERVISOR_GUEST_UUIDS               List of hypervisor guest uuids
                                                               Comma separated list of values. Values containing comma should be quoted or escaped with backslash
 --image IMAGE_NAME                                            Name to search by
 --image-id IMAGE_ID
 --installed-products-attributes INSTALLED_PRODUCTS_ATTRIBUTES List of products installed on the host
                                                               Comma separated list of values. Values containing comma should be quoted or escaped with backslash
 --interface INTERFACE                                         Interface parameters
                                                               Comma-separated list of key=value
                                                               Can be specified multiple times.
 --ip IP                                                       Not required if using a subnet with DHCP proxy
 --kickstart-repository REPOSITORY_NAME                        Kickstart repository name
 --kickstart-repository-id KICKSTART_REPOSITORY_ID             Repository Id associated with the kickstart repo used for provisioning
 --lifecycle-environment LIFECYCLE_ENVIRONMENT_NAME            Name to search by
 --lifecycle-environment-id LIFECYCLE_ENVIRONMENT_ID           ID of the environment
 --location LOCATION_NAME                                      Location name
 --location-id LOCATION_ID
 --location-title LOCATION_TITLE                               Location title
 --mac MAC                                                     Required for managed host that is bare metal, not required if it's a
                                                               Virtual machine
 --managed MANAGED                                             True/False flag whether a host is managed or unmanaged. Note: this value
                                                               Also determines whether several parameters are required or not
                                                               One of true/false, yes/no, 1/0.
 --medium MEDIUM_NAME                                          Medium name
 --medium-id MEDIUM_ID
 --model MODEL_NAME                                            Model name
 --model-id MODEL_ID
 --name NAME
 --operatingsystem OPERATINGSYSTEM_TITLE                       Operating system title
 --operatingsystem-id OPERATINGSYSTEM_ID
 --organization ORGANIZATION_NAME                              Organization name
 --organization-id ORGANIZATION_ID                             Organization ID
 --organization-title ORGANIZATION_TITLE                       Organization title
 --overwrite OVERWRITE                                         One of true/false, yes/no, 1/0.
                                                               Default: "true"
 --owner OWNER_LOGIN                                           Login of the owner
 --owner-id OWNER_ID                                           ID of the owner
 --owner-type OWNER_TYPE                                       Host's owner type
                                                               Possible value(s): 'User', 'Usergroup'
 --parameters PARAMS                                           Host parameters
                                                               Comma-separated list of key=value
 --partition-table PARTITION_TABLE_NAME                        Partition table name
 --partition-table-id PARTITION_TABLE_ID
 --product PRODUCT_NAME                                        Name to search by
 --product-id PRODUCT_ID                                       Product numeric identifier
 --progress-report-id PROGRESS_REPORT_ID                       UUID to track orchestration tasks status, GET
                                                               /api/orchestration/:UUID/tasks
 --provision-method PROVISION_METHOD                           The method used to provision the host.
                                                               Possible value(s): 'build', 'image'
 --puppet-ca-proxy PUPPET_CA_PROXY_NAME
 --puppet-ca-proxy-id PUPPET_CA_PROXY_ID                       Puppet CA proxy ID
 --puppet-class-ids PUPPET_CLASS_IDS                           Comma separated list of values. Values containing comma should be quoted or escaped with backslash
 --puppet-classes PUPPET_CLASS_NAMES                           Comma separated list of values. Values containing comma should be quoted or escaped with backslash
 --puppet-environment PUPPET_ENVIRONMENT_NAME                  Puppet Environment name
 --puppet-environment-id PUPPET_ENVIRONMENT_ID
 --puppet-proxy PUPPET_PROXY_NAME
 --puppet-proxy-id PUPPET_PROXY_ID                             Puppet proxy ID
 --pxe-loader PXE_LOADER                                       DHCP filename option (Grub2/PXELinux by default)
                                                               Possible value(s): 'None', 'PXELinux BIOS', 'PXELinux UEFI', 'Grub UEFI', 'Grub2 UEFI', 'Grub2 UEFI SecureBoot', 'Grub2 UEFI HTTP', 'Grub2 UEFI HTTPS', 'Grub2 UEFI HTTPS SecureBoot', 'iPXE Embedded', 'iPXE UEFI HTTP', 'iPXE Chain BIOS', 'iPXE Chain UEFI'
 --realm REALM_NAME                                            Name to search by
 --realm-id REALM_ID                                           Numerical ID or realm name
 --release-version RELEASE_VERSION                             Release version for this Host to use (7Server, 7.1, etc)
 --root-password ROOT_PW                                       Required if host is managed and value is not inherited from host group or default password in settings
 --service-level SERVICE_LEVEL                                 Service level to be used for autoheal
 --subnet SUBNET_NAME                                          Subnet name
 --subnet-id SUBNET_ID
 --volume VOLUME                                               Volume parameters
                                                               Comma-separated list of key=value
                                                               Can be specified multiple times.
 -h, --help                                                    Print help

```

Example
=======

An example command for creating a host with 2 volumes (5GB raw + 10 GB qcow2) using
a default network interface on a **libvirt** provider can look like this:
```bash
hammer host create
  --hostgroup=my_hostgroup                   # most of the settings is done in the hostgroup
  --compute-resource=libvirt                 # set the libvirt provider
  --compute-attributes="cpus=2"              # specify the provider specific options, see the list below
  --interface="primary=true,compute_type=network,compute_network=default" # add a network interface, can be passed multiple times
  --volume="capacity=5G"                     # add a volume, can be passed multiple times
  --volume="capacity=10G,format_type=qcow2"  # add another volume with different size and type
  --name="test-host"
```

Please note that volumes, interfaces and compute attributes **differ significantly** across compute resource types.
See the list of all possible option keys below.


Common interface settings
=========================

Please note that managed hosts need to have one primary interface. Always set `primary=true` for one of your interfaces.

Available keys for `--interface`:
```
mac
ip
type       # One of interface, bmc, bond
name
subnet_id
domain_id
identifier
managed    # true/false
primary    # true/false, each managed hosts needs to have one primary interface.
provision  # true/false
virtual    # true/false

# for virtual interfaces:
tag         # VLAN tag, this attribute has precedence over the subnet VLAN ID. Only for virtual interfaces.
attached_to # Identifier of the interface to which this interface belongs, e.g. eth1.

# for bonds:
mode             # One of balance-rr, active-backup, balance-xor, broadcast, 802.3ad, balance-tlb, balance-alb
attached_devices # Identifiers of slave interfaces, e.g. [eth1,eth2].
bond_options

# for BMCs:
provider   # always IPMI
username
password
```

Provider specific options
=========================

## EC2
Available keys for `--compute-attributes`:
```
flavor_id          # select one of available flavours
availability_zone
security_group_ids
managed_ip
groups
```

## GCE
Available keys for `--compute-attributes`:
```
machine_type # one of available flavors
network
associate_external_ip
```

## Libvirt
Available keys for `--compute-attributes`:
```
cpus          # number of CPUs
memory        # string, amount of memory, value in bytes
start         # Must be a 1 or 0, whether to start the machine or not
firmware      # automatic/bios/uefi/uefi_secure_boot (UEFI with Secure Boot enabled)
```

Available keys for `--interface`:
```
compute_type                      # one of [bridge, network]
compute_network / compute_bridge  # name of interface according to type
compute_model                     # one of [virtio, rtl8139, ne2k_pci, pcnet, e1000]
```

Available keys for `--volume`:
```
pool_name   # list of available storage pools
capacity    # string value, e.g. 10G
format_type # one of [raw, qcow2]
allocation  # initial allocation, e.g. 0G
```

## OpenStack
Available keys for `--compute-attributes`:
```
availability_zone
boot_from_volume
flavor_ref
image_ref
tenant_id
security_groups
network
```

## VMware
Available keys for `--compute-attributes`:
```
cpus                  CPU count
corespersocket        Number of cores per socket (applicable to hardware versions < 10 only)
memory_mb             Integer number, amount of memory in MB
firmware              automatic/bios/uefi/uefi_secure_boot (UEFI with Secure Boot enabled)
cluster               Cluster ID from VMware
resource_pool         Resource Pool ID from VMware
path                  Path to folder
guest_id              Guest OS ID form VMware
hardware_version      Hardware version ID from VMware
add_cdrom             Must be a 1 or 0, Add a CD-ROM drive to the virtual machine
cpuHotAddEnabled      Must be a 1 or 0, lets you add memory resources while the machine is on
memoryHotAddEnabled   Must be a 1 or 0, lets you add CPU resources while the machine is on the machine or not
annotation            Annotation Notes
scsi_controllers      List with SCSI controllers definitions
                        type - ID of the controller from VMware
                        key  - Key of the controller (e.g. 1000)
virtual_tpm           Must be a 1 or 0, Enable virtual TPM. Only compatible with EFI firmware
start         # Must be a 1 or 0, whether to start the machine or not
```

Available keys for `--interface`:
```
compute_type      # Type of the network adapter, for example one of:
                  #   VirtualVmxnet3
                  #   VirtualE1000
                  # See documentation center for your version of vSphere to find
                  # more details about available adapter types:
                  # https://www.vmware.com/support/pubs/
compute_network   # network ID from VMware
```

Available keys for `--volume`:
```
name
storage_pod         Storage Pod ID from VMware
datastore           Datastore ID from VMware
size_gb             Integer number, volume size in GB
thin                true/false
eager_zero          true/false
mode                persistent/independent_persistent/independent_nonpersistent
controller_key      Associated SCSI controller key
```
