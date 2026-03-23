# openapi.model.LogMetadata

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**userId** | **String** | The UUID for the user who triggered the event that is being logged. | 
**ipAddress** | **String** | The IP address from which the request that generated the log originated. | 
**username** | **String** | The email address of a user who is logging in.<br>*This field is only included in the metadata for logs relating to users logging in.* | [optional] 
**httpStatusCode** | **int** | The status code returned for and API request.<br>*This field is only included in the metadata for logs relating to API requests.* | [optional] 
**method** | **String** | The HTTP request method of the API request being logged.<br>*This field is only included in the metadata for logs relating to API requests.* * `GET` * `POST` * `PUT` * `PATCH` * `DELETE` | [optional] 
**requestPath** | **String** | The URI path of the API request being logged.<br>*This field is only included in the metadata for logs relating to API requests.* | [optional] 
**requestBody** | **String** | The request body provided for the API request being logged.<br>*This field is only included in the metadata for logs relating to API requests.* | [optional] 
**queryParameters** | **String** | The query string provided for the API request being logged.<br>*This field is only included in the metadata for logs relating to API requests.* | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


