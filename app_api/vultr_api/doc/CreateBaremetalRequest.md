# openapi.model.CreateBaremetalRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**region** | **String** | The [Region id](#operation/list-regions) to create the instance. | 
**plan** | **String** | The [Bare Metal plan id](#operation/list-metal-plans) to use for this instance. | 
**scriptId** | **String** | The [Startup Script id](#operation/list-startup-scripts) to use for this instance. | [optional] 
**enableIpv6** | **bool** | Enable IPv6.  * true | [optional] 
**sshkeyId** | **List<String>** | The [SSH Key id](#operation/list-ssh-keys) to install on this instance. | [optional] [default to const []]
**userData** | **String** | The user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) for this Instance. | [optional] 
**label** | **String** | The user-supplied label. | [optional] 
**activationEmail** | **bool** | Notify by email after deployment.  * true * false (default) | [optional] 
**hostname** | **String** | The user-supplied hostname to use when deploying this instance. | [optional] 
**tag** | **String** | Use `tags` instead. The user-supplied tag. | [optional] 
**reservedIpv4** | **String** | The [Reserved IP id](#operation/list-reserved-ips) for this instance. | [optional] 
**osId** | **int** | If supplied, deploy the instance using this [Operating System id](#operation/list-os). | [optional] 
**snapshotId** | **String** | If supplied, deploy the instance using this [Snapshot ID](#operation/list-snapshots). | [optional] 
**appId** | **int** | If supplied, deploy the instance using this [Application id](#operation/list-applications). | [optional] 
**imageId** | **String** | If supplied, deploy the instance using this [Application image_id](#operation/list-applications). | [optional] 
**ipxeChainUrl** | **String** | The URL location of the iPXE chainloader. If used, `os_id` must be set to 159. | [optional] 
**persistentPxe** | **bool** | Enable persistent PXE.  * true * false (default) | [optional] 
**attachVpc2** | **List<String>** | An array of [VPC IDs](#operation/list-vpc2) to attach to this Bare Metal Instance. This parameter takes precedence over `enable_vpc2`. Please choose one parameter. | [optional] [default to const []]
**detachVpc2** | **List<String>** | An array of [VPC IDs](#operation/list-vpc2) to detach from this Bare Metal Instance. This parameter takes precedence over `enable_vpc2`. | [optional] [default to const []]
**enableVpc2** | **bool** | If `true`, VPC 2.0 support will be added to the new server.  This parameter attaches a single VPC 2.0 network. When no VPC 2.0 network exists in the region, it will be automatically created.  If there are multiple VPC 2.0 networks in the instance's region, use `attach_vpc2` instead to specify a VPC 2.0 network. | [optional] 
**tags** | **List<String>** | Tags to apply to the instance. | [optional] [default to const []]
**userScheme** | **String** | Linux-only: The user scheme used for logging into this instance. By default, the \"root\" user is configured. Alternatively, a limited user with sudo permissions can be selected.  * root * limited | [optional] 
**mdiskMode** | **String** | The RAID configuration used for the disks on this instance. The instance must be reinstalled for this change to take effect.  * raid1 * jbod * none (default) | [optional] 
**appVariables** | [**Object**](.md) | The [app variable inputs](#operation/list-marketplace-app-variables) for configuring the marketplace app (name/value pairs). | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


