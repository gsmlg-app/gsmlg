/// Op names and helpers shared by the agent services server and client.
///
/// Request: `{id, op, args, reply}`; unary reply: `{id, ok, value|error}`;
/// stream reply: `{id, started}` then `{id, chunk}`* then `{id, done}` or `{id, error}`;
/// cancel: `{id, op: 'cancel', reply}`; server shutdown: `{closed: true}`.
library;

const opSecretsRead = 'secrets.read';
const opListDnsZones = 'data.listDnsZones';
const opFindDnsZones = 'data.findDnsZones';
const opServiceAccountById = 'data.serviceAccountById';
const opServiceAccountsByProvider = 'data.serviceAccountsByProvider';
const opLocalLlmGenerate = 'localLlm.generate';
const opLocalLlmStop = 'localLlm.stop';
const opCancel = 'cancel';

/// [RemoteAgentError.type] reported when the bridge is closed.
const servicesClosedType = 'AgentServicesClosed';

/// [RemoteAgentError.type] reported when a generation is never acknowledged.
const servicesTimeoutType = 'AgentServicesTimeout';

Map<String, Object?> errorToWire(Object e) => {
  'type': e.runtimeType.toString(),
  'message': e.toString(),
};
