# openapi.model.CreateInstanceRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**region** | **String** | The [Region id](#operation/list-regions) where the Instance is located. | 
**plan** | **String** | The [Plan id](#operation/list-plans) to use when deploying this instance. | 
**osId** | **int** | The [Operating System id](#operation/list-os) to use when deploying this instance. | [optional] 
**ipxeChainUrl** | **String** | The URL location of the iPXE chainloader. | [optional] 
**isoId** | **String** | The [ISO id](#operation/list-isos) to use when deploying this instance. | [optional] 
**scriptId** | **String** | The [Startup Script id](#operation/list-startup-scripts) to use when deploying this instance. | [optional] 
**snapshotId** | **String** | The [Snapshot id](#operation/list-snapshots) to use when deploying the instance. | [optional] 
**enableIpv6** | **bool** | Enable IPv6.  * true | [optional] 
**disablePublicIpv4** | **bool** | Don't set up a public IPv4 address when IPv6 is enabled. Will not do anything unless `enable_ipv6` is also `true`.  * true | [optional] 
**attachPrivateNetwork** | **List<String>** | Use `attach_vpc` instead. An array of [Private Network ids](#operation/list-networks) to attach to this Instance. This parameter takes precedence over `enable_private_network`. Please choose one parameter. | [optional] [default to const []]
**attachVpc** | **List<String>** | An array of [VPC IDs](#operation/list-vpcs) to attach to this Instance. This parameter takes precedence over `enable_vpc`. Please choose one parameter. | [optional] [default to const []]
**attachVpc2** | **List<String>** | Use `attach_vpc` instead. An array of [VPC IDs](#operation/list-vpc2) to attach to this Instance. This parameter takes precedence over `enable_vpc2`. Please choose one parameter. | [optional] [default to const []]
**label** | **String** | A user-supplied label for this instance. | [optional] 
**sshkeyId** | **List<String>** | The [SSH Key id](#operation/list-ssh-keys) to install on this instance. | [optional] [default to const []]
**backups** | **String** | Enable automatic backups for the instance (does not work for VX1 block storage).  * enabled * disabled | [optional] 
**blockDevices** | [**List<Object>**](Object.md) | Available for VX1 instances: Define your block devices, create bootable block devices, use local storage (if plan has local storage) as scratch disk. Local Only: ``` \"block_devices\": [   {     \"block_id\": \"local\",     \"bootable\": true   } ] ``` Local Boot + New Block: ``` \"block_devices\": [   {     \"block_id\": \"local\",     \"bootable\": true   },   {     \"disk_size\": 50,     \"label\": \"New Block Label\"   } ] ``` Bootable Block (new): ``` \"block_devices\": [   {     \"disk_size\": 50,     \"label\": \"New Bootable Block\",     \"bootable\": true   } ] ``` Bootable Block (existing): ``` \"block_devices\": [   {     \"block_id\": \"BLOCK_DEVICE_UUID\",     \"bootable\": true   } ] ``` Bootable Block (existing) and Local NVMe: ``` \"block_devices\": [   {     \"block_id\": \"local\"   },   {     \"block_id\": \"BLOCK_DEVICE_UUID\",     \"bootable\": true   } ] ``` | [optional] [default to const []]
**appId** | **int** | The [Application id](#operation/list-applications) to use when deploying this instance. | [optional] 
**imageId** | **String** | The [Application image_id](#operation/list-applications) to use when deploying this instance. | [optional] 
**userData** | **String** | The user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) to attach to this instance. | [optional] 
**ddosProtection** | **bool** | Enable DDoS protection (there is an additional charge for this).  * true * false | [optional] 
**activationEmail** | **bool** | Notify by email after deployment.  * true * false (default) | [optional] 
**hostname** | **String** | The hostname to use when deploying this instance. | [optional] 
**tag** | **String** | Use `tags` instead. The user-supplied tag. | [optional] 
**firewallGroupId** | **String** | The [Firewall Group id](#operation/list-firewall-groups) to attach to this Instance. | [optional] 
**reservedIpv4** | **String** | ID of the floating IP to use as the main IP of this server. | [optional] 
**enablePrivateNetwork** | **bool** | Use `enable_vpc` instead.  If `true`, private networking support will be added to the new server.  This parameter attaches a single network. When no network exists in the region, it will be automatically created.  If there are multiple private networks in the instance's region, use `attach_private_network` instead to specify a network. | [optional] 
**enableVpc** | **bool** | If `true`, VPC support will be added to the new server.  This parameter attaches a single VPC. When no VPC exists in the region, it will be automatically created.  If there are multiple VPCs in the instance's region, use `attach_vpc` instead to specify a network. | [optional] 
**enableVpc2** | **bool** | Use `enable_vpc` instead.  If `true`, VPC 2.0 support will be added to the new server.  This parameter attaches a single VPC 2.0 network. When no VPC 2.0 network exists in the region, it will be automatically created.  If there are multiple VPC 2.0 networks in the instance's region, use `attach_vpc2` instead to specify a network. | [optional] 
**vpcOnly** | **bool** | if `true`, this VPS will not receive a public IP or public NIC.  A `vpc_id` will be required in the `attach_vpc` array. The first `vpc_id` provided must have a NAT Gateway attached.  This VPS will gain access to the internet via the NAT Gateway attached to the VPC. | [optional] 
**tags** | **List<String>** | Tags to apply to the instance | [optional] [default to const []]
**userScheme** | **String** | Linux-only: The user scheme used for logging into this instance. By default, the \"root\" user is configured. Alternatively, a limited user with sudo permissions can be selected.  * root * limited | [optional] 
**appVariables** | [**Object**](.md) | The [app variable inputs](#operation/list-marketplace-app-variables) for configuring the marketplace app (name/value pairs). | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


