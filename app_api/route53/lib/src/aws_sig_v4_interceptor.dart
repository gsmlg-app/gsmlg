import 'dart:convert';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:dio/dio.dart';

/// AWS Signature V4 interceptor for Dio.
///
/// Signs all requests with AWS Signature V4 authentication.
class AwsSigV4Interceptor extends Interceptor {
  AwsSigV4Interceptor({
    required String accessKeyId,
    required String secretAccessKey,
    required String region,
    this.serviceName = 'route53',
  })  : _signer = AWSSigV4Signer(
          credentialsProvider: AWSCredentialsProvider(
            AWSCredentials(accessKeyId, secretAccessKey),
          ),
        ),
        _region = region;

  final AWSSigV4Signer _signer;
  final String _region;
  final String serviceName;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final uri = options.uri;

      // Prepare the body
      List<int>? bodyBytes;
      if (options.data != null) {
        if (options.data is String) {
          bodyBytes = utf8.encode(options.data as String);
        } else if (options.data is Map) {
          bodyBytes = utf8.encode(jsonEncode(options.data));
        } else if (options.data is List<int>) {
          bodyBytes = options.data as List<int>;
        }
      }

      // Map Dio method to AWS method
      final method = switch (options.method.toUpperCase()) {
        'GET' => AWSHttpMethod.get,
        'POST' => AWSHttpMethod.post,
        'PUT' => AWSHttpMethod.put,
        'DELETE' => AWSHttpMethod.delete,
        'PATCH' => AWSHttpMethod.patch,
        'HEAD' => AWSHttpMethod.head,
        _ => AWSHttpMethod.get,
      };

      // Create the AWS request
      final awsRequest = AWSHttpRequest(
        method: method,
        uri: uri,
        headers: {
          AWSHeaders.host: uri.host,
          if (bodyBytes != null) AWSHeaders.contentType: 'application/xml',
        },
        body: bodyBytes,
      );

      // Sign the request
      final scope = AWSCredentialScope(
        region: _region,
        service: AWSService(serviceName),
      );

      final signedRequest = await _signer.sign(
        awsRequest,
        credentialScope: scope,
      );

      // Apply signed headers to the request
      options.headers.addAll(signedRequest.headers);

      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Failed to sign AWS request: $e',
        ),
      );
    }
  }
}
