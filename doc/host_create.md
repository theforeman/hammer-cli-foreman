Host Creation
=============

Host creation is one of the most complex commands in the hammer's foreman plugin. The majority of its parameters
is obvious but there are some that need further explanation as their values differ with the type of a compute resource.

**Warning:**
Output of `hammer host create -h` may vary with the Foreman server used and plugins installed.

Sample help output for `hammer-cli-foreman 0.2.0` and `Foreman 1.8` follows:

```
$ hammer host create -h
Usage:
    hammer host create [OPTIONS]

Options:
 --architecture ARCHITECTURE_NAME          Architecture name
 --architecture-id ARCHITECTURE_ID
 --ask-root-password ASK_ROOT_PW           One of true/false, yes/no, 1/0.
 --build BUILD                             One of true/false, yes/no, 1/0.
                                           Default: "true"
 --comment COMMENT                         Additional information about this host
 --compute-attributes COMPUTE_ATTRS        Compute resource attributes.
                                           Comma-separated list of key=value.
 --compute-profile COMPUTE_PROFILE_NAME    Name to search by
 --compute-profile-id COMPUTE_PROFILE_ID
 --compute-resource COMPUTE_RESOURCE_NAME  Compute resource name
 --compute-resource-id COMPUTE_RESOURCE_ID
 --domain DOMAIN_NAME                      Domain name
 --domain-id DOMAIN_ID                     Numerical ID or domain name
 --enabled ENABLED                         One of true/false, yes/no, 1/0.
                                           Default: "true"
 --environment ENVIRONMENT_NAME            Environment name
 --environment-id ENVIRONMENT_ID
 --hostgroup HOSTGROUP_NAME                Hostgroup name
 --hostgroup-id HOSTGROUP_ID
 --hostgroup-title HOSTGROUP_TITLE         Hostgroup title
 --image IMAGE_NAME                        Name to search by
 --image-id IMAGE_ID
 --interface INTERFACE                     Interface parameters.
                                           Comma-separated list of key=value.
                                           Can be specified multiple times.
 --ip IP                                   not required if using a subnet with DHCP proxy
 --location LOCATION_NAME                  Location name
 --location-id LOCATION_ID
 --mac MAC                                 required for managed host that is bare metal, not required if it’s a virtual machine
 --managed MANAGED                         One of true/false, yes/no, 1/0.
                                           Default: "true"
 --medium MEDIUM_NAME                      Medium name
 --medium-id MEDIUM_ID
 --model MODEL_NAME                        Model name
 --model-id MODEL_ID
 --name NAME
 --operatingsystem OPERATINGSYSTEM_TITLE   Operating system title
 --operatingsystem-id OPERATINGSYSTEM_ID
 --organization ORGANIZATION_NAME          Organization name
 --organization-id ORGANIZATION_ID
 --owner OWNER_LOGIN                       Login of the owner
 --owner-id OWNER_ID                       ID of the owner
 --owner-type OWNER_TYPE                   Host’s owner type
 --parameters PARAMS                       Host parameters.
                                           Comma-separated list of key=value.
 --partition-table PARTITION_TABLE_NAME    Partition table name
 --partition-table-id PARTITION_TABLE_ID
 --progress-report-id PROGRESS_REPORT_ID   UUID to track orchestration tasks status, GET /api/orchestration/:UUID/tasks
 --provision-method METHOD                 One of 'build', 'image'
 --puppet-ca-proxy PUPPET_CA_PROXY_NAME
 --puppet-ca-proxy-id PUPPET_CA_PROXY_ID
 --puppet-class-ids PUPPET_CLASS_IDS       Comma separated list of values.
 --puppet-classes PUPPET_CLASS_NAMES       Comma separated list of values.
 --puppet-proxy PUPPET_PROXY_NAME
 --puppet-proxy-id PUPPET_PROXY_ID
 --realm REALM_NAME                        Name to search by
 --realm-id REALM_ID                       Numerical ID or realm name
 --root-pass ROOT_PASS                     required if host is managed and value is not inherited from host group or default password in settings
 --root-password ROOT_PW
 --subnet SUBNET_NAME                      Subnet name
 --subnet-id SUBNET_ID
 --volume VOLUME                           Volume parameters
                                           Comma-separated list of key=value.
                                           Can be specified multiple times.
 -h, --help                                print help
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
image_id           # select one of available images
availability_zone
security_group_ids
managed_ip
```

## GCE
Available keys for `--compute-attributes`:
```
machine_type # one of available flavors
image_id
network
external_ip
```

## Libvirt
Available keys for `--compute-attributes`:
```
cpus          # number of CPUs
memory        # string, amount of memory, value in bytes
start         # Must be a 1 or 0, whether to start the machine or not
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
capacity    # string value, eg. 10G
format_type # one of [raw, qcow2]
```

## OpenStack
Available keys for `--compute-attributes`:
```
flavor_ref
image_ref
tenant_id
security_groups
network
```

## oVirt
Available keys for `--compute-attributes`:
```
cluster
template   # hardware profile to use
cores      # int value, number of cores
memory     # amount of memory, int value in bytes
start      # Must be a 1 or 0, whether to start the machine or not
```

Available keys for `--interface`:
```
compute_name         # eg. eth0
compute_network      # select one of available networks for a cluster
```

Available keys for `--volume`:
```
size_gb          # volume size in GB, integer value
storage_domain   # select one of available storage domains
bootable         # boolean, only one volume can be bootable
```

## Rackspace
Available keys for `--compute-attributes`:
```
flavor_id
image_id
```

## VMware
Available keys for `--compute-attributes`:
```
cpus                 # cpu count
corespersocket       # number of cores per socket
                     # (applicable to hardware versions < 10 only)
memory_mb            # integer number
cluster              # cluster id from VMware
path                 # path to folder
guest_id             # guest OS id form VMware
scsi_controller_type # id of the controller from VMware
hardware_version     # hardware version id from VMware
start                # Boolean, expressed as 0 or 1, whether to start the machine or not
```

Available keys for `--interface`:
```
compute_type      # Type of the network adapter, for example one of:
                  #   VirtualVmxnet
                  #   VirtualVmxnet2
                  #   VirtualVmxnet3
                  #   VirtualE1000
                  #   VirtualE1000e
                  #   VirtualPCNet32
                  # See documentation center for your version of vSphere to find
                  # more details about available adapter types:
                  # https://www.vmware.com/support/pubs/
compute_network   # network id from VMware
```

Available keys for `--volume`:
```
datastore  # datastore id from VMware
name
size_gb    # integer number
thin       # true/false
eager_zero # true/false
```
