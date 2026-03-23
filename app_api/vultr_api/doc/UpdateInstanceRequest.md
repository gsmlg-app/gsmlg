# openapi.model.UpdateInstanceRequest

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**appId** | **int** | Reinstall the instance with this [Application id](#operation/list-applications). | [optional] 
**imageId** | **String** | Reinstall the instance with this [Application image_id](#operation/list-applications). | [optional] 
**backups** | **String** | Enable automatic backups for the instance.  * enabled * disabled | [optional] 
**firewallGroupId** | **String** | The [Firewall Group id](#operation/list-firewall-groups) to attach to this Instance. | [optional] 
**enableIpv6** | **bool** | Enable IPv6.  * true | [optional] 
**osId** | **String** | Reinstall the instance with this [ISO id](#operation/list-isos). | [optional] 
**userData** | **String** | The user-supplied, base64 encoded [user data](https://docs.vultr.com/manage-instance-user-data-with-the-vultr-metadata-api/) to attach to this instance. | [optional] 
**tag** | **String** | Use `tags` instead. The user-supplied tag. | [optional] 
**plan** | **String** | Upgrade the instance with this [Plan id](#operation/list-plans). | [optional] 
**ddosProtection** | **bool** | Enable DDoS Protection (there is an additional charge for this).  * true * false | [optional] 
**attachPrivateNetwork** | **List<String>** | Use `attach_vpc` instead. An array of [Private Network ids](#operation/list-networks) to attach to this Instance. This parameter takes precedence over `enable_private_network`. Please choose one parameter. | [optional] [default to const []]
**attachVpc** | **List<String>** | An array of [VPC IDs](#operation/list-vpcs) to attach to this Instance. This parameter takes precedence over `enable_vpc`. Please choose one parameter. | [optional] [default to const []]
**attachVpc2** | **List<String>** | Use `attach_vpc` instead. An array of [VPC IDs](#operation/list-vpc2) to attach to this Instance. This parameter takes precedence over `enable_vpc2`. Please choose one parameter. | [optional] [default to const []]
**detachPrivateNetwork** | **List<String>** | Use `detach_vpc` instead. An array of [Private Network ids](#operation/list-networks) to detach from this Instance. This parameter takes precedence over `enable_private_network`. | [optional] [default to const []]
**detachVpc** | **List<String>** | An array of [VPC IDs](#operation/list-vpcs) to detach from this Instance. This parameter takes precedence over `enable_vpc`. | [optional] [default to const []]
**detachVpc2** | **List<String>** | Use `detach_vpc` instead. An array of [VPC IDs](#operation/list-vpc2) to detach from this Instance. This parameter takes precedence over `enable_vpc2`. | [optional] [default to const []]
**enablePrivateNetwork** | **bool** | Use `enable_vpc` instead.  If `true`, private networking support will be added to the new server.  This parameter attaches a single network. When no network exists in the region, it will be automatically created.  If there are multiple private networks in the instance's region, use `attach_private_network` instead to specify a network. | [optional] 
**enableVpc** | **bool** | If `true`, VPC support will be added to the new server.  This parameter attaches a single VPC. When no VPC exists in the region, it will be automatically created.  If there are multiple VPCs in the instance's region, use `attach_vpc` instead to specify a VPC. | [optional] 
**enableVpc2** | **bool** | Use `enable_vpc` instead.  If `true`, VPC 2.0 support will be added to the new server.  This parameter attaches a single VPC 2.0 network. When no VPC 2.0 network exists in the region, it will be automatically created.  If there are multiple VPC 2.0 networks in the instance's region, use `attach_vpc2` instead to specify a VPC 2.0 network. | [optional] 
**label** | **String** | The user supplied label. | [optional] 
**tags** | **List<String>** | Tags to apply to the instance. | [optional] [default to const []]
**userScheme** | **String** | Linux-only: The user scheme used for logging into this instance. The instance must be reinstalled for this change to take effect.  * root * limited | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


