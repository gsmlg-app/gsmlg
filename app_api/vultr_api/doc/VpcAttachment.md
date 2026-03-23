# openapi.model.VpcAttachment

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | The ID of the VPS or BareMetal Subscription attached to this VPC. | [optional] 
**type** | **String** | The type of subscription attached, either vps or baremetal. | [optional] 
**macAddress** | **String** | The Mac Address of the attached interface. | [optional] 
**dateAdded** | **String** | The date this VPC was attached to this subscription. | [optional] 
**ip** | [**VpcAttachmentIp**](VpcAttachmentIp.md) |  | [optional] 
**linkedSubscription** | [**VpcAttachmentLinkedSubscription**](VpcAttachmentLinkedSubscription.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


