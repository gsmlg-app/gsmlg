# openapi.model.InstanceGet

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | A unique ID for the VPS Instance. | [optional] 
**os** | **String** | The [Operating System name](#operation/list-os). | [optional] 
**ram** | **int** | The amount of RAM in MB. | [optional] 
**disk** | **int** | The size of the disk in GB. | [optional] 
**mainIp** | **String** | The main IPv4 address. | [optional] 
**vcpuCount** | **int** | Number of vCPUs. | [optional] 
**region** | **String** | The [Region id](#operation/list-regions) where the Instance is located. | [optional] 
**defaultPassword** | **String** | The default password assigned at deployment. Only available for ten minutes after deployment. | [optional] 
**dateCreated** | **String** | The date this instance was created. | [optional] 
**status** | **String** | The current status.  * active * pending * suspended * resizing | [optional] 
**powerStatus** | **String** | The power-on status.  * running * stopped | [optional] 
**serverStatus** | **String** | The server health status.  * none * locked * installingbooting * ok | [optional] 
**allowedBandwidth** | **int** | Monthly bandwidth quota in GB. | [optional] 
**netmaskV4** | **String** | The IPv4 netmask in dot-decimal notation. | [optional] 
**gatewayV4** | **String** | The gateway IP address. | [optional] 
**v6Networks** | [**List<InstanceV6NetworksInner>**](InstanceV6NetworksInner.md) | An array of IPv6 objects. | [optional] [default to const []]
**hostname** | **String** | The hostname for this instance. | [optional] 
**label** | **String** | The user-supplied label for this instance. | [optional] 
**tag** | **String** | Use `tags` instead. The user-supplied tag for this instance. | [optional] 
**internalIp** | **String** | The internal IP used by this instance, if set. Only relevant when a VPC is attached. | [optional] 
**vpcOnly** | **bool** | The flag used when this VM will not receive a public IP and get its internet access through a NAT Gateway on the VPC. | [optional] 
**vpcs** | [**List<AttachedVpcs>**](AttachedVpcs.md) | List of VPC Networks to which the instance is attached. | [optional] [default to const []]
**kvm** | **String** | HTTPS link to the Vultr noVNC Web Console. | [optional] 
**osId** | **int** | The [Operating System id](#operation/list-os) used by this instance. | [optional] 
**appId** | **int** | The [Application id](#operation/list-applications) used by this instance. | [optional] 
**imageId** | **String** | The [Application image_id](#operation/list-applications) used by this instance. | [optional] 
**snapshotId** | **String** | The [Snapshot id](#operation/list-snapshots) used by this instance. | [optional] 
**firewallGroupId** | **String** | The [Firewall Group id](#operation/list-firewall-groups) linked to this Instance. | [optional] 
**features** | **List<String>** | \"auto_backups\", \"ipv6\", \"ddos_protection\" | [optional] [default to const []]
**plan** | **String** | A unique ID for the Plan. | [optional] 
**tags** | **List<String>** | Tags to apply to the instance. | [optional] [default to const []]
**userScheme** | **String** | The user scheme.  * root * limited | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


