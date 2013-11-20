Host Creation
=============

Host creation is one of the most complex commands in the hammer's foreman plugin. The majority of its parameters
is obvious but there are some that need further explanation as their values differ with the type of a compute resource.

```
$ hammer host create -h
Usage:
    hammer host create [OPTIONS]

Options:
    --name NAME
    --ip IP                       Not required if using a subnet with dhcp proxy.
    --mac MAC                     Not required if it's a virtual machine.
    --puppet-class-ids PUPPET_CLASS_IDS Comma separated list of values.
    --medium-id MEDIUM_ID
    --subnet-id SUBNET_ID
    --sp-subnet-id SP_SUBNET_ID
    --model-id MODEL_ID
    --hostgroup-id HOSTGROUP_ID
    --owner-id OWNER_ID
    --puppet-ca-proxy-id PUPPET_CA_PROXY_ID
    --security-groups SECURITY_GROUPS
    --environment-id ENVIRONMENT_ID
    --architecture-id ARCHITECTURE_ID
    --domain-id DOMAIN_ID
    --puppet-proxy-id PUPPET_PROXY_ID
    --operatingsystem-id OPERATINGSYSTEM_ID
    --partition-table-id PARTITION_TABLE_ID
    --compute-resource-id COMPUTE_RESOURCE
    --partition-table-id PARTITION_TABLE
    --build BUILD                 One of true/false, yes/no, 1/0.
                                  Default: "true"
    --managed MANAGED             One of true/false, yes/no, 1/0.
                                  Default: "true"
    --enabled ENABLED             One of true/false, yes/no, 1/0.
                                  Default: "true"
    --parameters PARAMS           Host parameters.
                                  Comma-separated list of key=value.
    --compute-attributes COMPUTE_ATTRS Compute resource attributes.
                                  Comma-separated list of key=value.
    --volume VOLUME               Volume parameters
                                  Comma-separated list of key=value.
                                  Can be specified multiple times.
    --interface INTERFACE         Interface parameters.
                                  Comma-separated list of key=value.
                                  Can be specified multiple times.
    -h, --help                    print help
```

Example
=======

An example command for creating a host with 2 volumes (5GB raw + 10 GB qcow2) using
a default network interface on a libvirt provider can look like this:
```bash
hammer host create
  --hostgroup-id=4                           # most of the settings is done in the hostgroup
  --compute-resource-id=1                    # set the libvirt provider
  --compute-attributes="cpus=2"              # specify the provider specific options, see the list below
  --interface="type=network,network=default" # add a network interface, can be passed multiple times
  --volume="capacity=5G"                     # add a volume, can be passed multiple times
  --volume="capacity=10G,format_type=qcow2"  # add another volume with different size and type
  --name="test-host"
  --ip="1.2.3.4"
```

See the list of all possible option keys below.


Provider specific options
=========================

## Bare Metal
Available keys for `--interface`:
```
type       # one of Nic::Managed, Nic::BMC
mac
name
domain_id
subnet_id
ip
provider   # always IPMI
username   # BMC only
password   # BMC only
```

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
start         # boolean, whether to start the machine or not
```

Available keys for `--interface`:
```
type              # one of [:bridge, :network]
network / :bridge # name of interface according to type
model             # one of [virtio, rtl8139, ne2k_pci, pcnet, e1000]
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
start      # boolean, whether to start the machine or not
```

Available keys for `--interface`:
```
name         # eg. eth0
network      # select one of available networks for a cluster
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

## vmWare
Available keys for `--compute-attributes`:
```
cpus       # cpu count
memory_mb  # integer number
cluster
path
```

Available keys for `--interface`:
```
network
```

Available keys for `--volume`:
```
datastore
name
size_gb    # integer number
```

