import 'dart:developer';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as ioclient;

import 'geo_service.dart';
import 'user_settings.dart';

typedef OnConnectionStatusCallback = void Function();
//typedef OnPeerConnectionStatusCallback = void Function();
typedef OnPeersReadyCallback = void Function();
typedef OnRemoteStreamCallback = void Function(MediaStream stream);
typedef OnLocalStreamCallback = void Function(MediaStream stream);
typedef OnRemoteCallCancelCallback = void Function(String msg);

class SignalingService {
  final settings = UserSettings();

  // WS
  // Flag para conocer si estamos conectados al Hub
  late ioclient.Socket _socket;
  var connected = false;
  late OnConnectionStatusCallback onConnectionStatusChanged;

  // WebRTC
  //late OnPeerConnectionStatusCallback onPCStatusChanged;
  // Hemos recibido la lista de peers
  late OnPeersReadyCallback onPeersReady;
  late OnPeersReadyCallback onRecibidoListaDePares;

  // Preparado el stream local
  late OnLocalStreamCallback onLocalStreamChanged;
  // Recibimos un stream remoto
  late OnRemoteStreamCallback onRemoteStreamChanged;
  late OnRemoteCallCancelCallback onRemoteCallCancel;

  late MediaStream localStream;
  late MediaStream remoteStream;

  List<MediaDeviceInfo>? mediaDevicesList;

  final sdpConstraints = {
    "mandatory": {
      "OfferToReceiveAudio": true,
      "OfferToReceiveVideo": true,
    },
    "optional": [],
  };
  // final loopbackConstraints = <String, dynamic>{
  //   'mandatory': {},
  //   'optional': [
  //     {'DtlsSrtpKeyAgreement': true},
  //   ],
  // };

  final configuration = <String, dynamic>{
    'iceServers': [
      //STUN
      {'url': 'stun:stun.l.google.com:19302'},
      // {'url': 'stun:stun1.l.google.com:19302'},
      // {'url': 'stun:stun2.l.google.com:19302'},
      // {'url': 'stun:stun3.l.google.com:19302'},
      // {'url': 'stun:stun4.l.google.com:19302'},
      // {'url': 'stun:iphone-stun.strato-iphone.de:3478'},
      // {'url': 'stun:numb.viagenie.ca:3478'},
      // {'url': 'stun:s1.taraba.net:3478'},
      //TURN
      // {
      //   'url': 'turn:turn.bistri.com:80',
      //   'credential': 'homeo',
      //   'username': 'homeo'
      // },
      // {
      //   'url': 'turn:turn.anyfirewall.com:443?transport=tcp',
      //   'credential': 'webrtc',
      //   'username': 'webrtc'
      // },
    ]
  };

  static final infoNOTSET = {
    'peerid': 'NOT SET',
    'alias': 'NOT SET',
    'description': 'NOT SET',
    'oncall': false,
    'platform': 'NOT SET',
    'position': 'NOT SET',
  };

  dynamic remoteInfo = infoNOTSET;
  dynamic localInfo = infoNOTSET;
  List<dynamic> pares = [];

  late RTCPeerConnection pc;

  init() async {
    localInfo['peerid'] = settings.peerId;
    localInfo['alias'] = settings.alias;
    localInfo['description'] = settings.description;
    localInfo['position'] = await GeoService.determinePosition();

    mediaDevicesList = await navigator.mediaDevices.enumerateDevices();
    _connect();
    // createPeerConnection(configuration).then((value) {
    //   pc = value;
    // });
  }

  reconnect() {
    close();
    _connect();
  }

  void close() {
    _socket.disconnect();
    _socket.dispose();
  }

  _connect() {
    _socket = ioclient.io(
        settings.signalingHost,
        ioclient.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            //.setTransports(['websocket', 'polling']) // for Flutter or Dart VM
            //.disableAutoConnect() // disable auto-connection
            //.setExtraHeaders({'foo': 'bar'}) // optional
            .setQuery({
          'peerid': localInfo['peerid'],
          'alias': settings.alias,
          'description': settings.description,
          'platform': settings.platform,
          'position': localInfo['position']
        }).build());

    _socket.connect();
    // CONTROL DEL ESTADO DE LA CONEXION CON HUB
    _socket.onConnectError(connectionStatusChanged);
    _socket.onError(connectionStatusChanged);
    _socket.onConnect(connectionStatusChanged);

    // RECIBIMOS LOS PEERS CONECTADOS
    _socket.on('on-peers', (data) {
      log('[on-peers] $data');

      pares = data;
      onRecibidoListaDePares();
    });
    // RECIBIMOS LA ORDEN DE COLGAR LA LLAMADA
    _socket.on('on-hangup', (_) => onCallCancelada('📞 Llamada colgada'));
    _socket.on('on-failed', (_) => onCallCancelada('📢 Llamada fallida'));

    // RECIBIMOS UNA LLAMADA
    _socket.on('on-call', (data) async {
      await onCallAceptada(data);
    });

    // MENSAJES DE INTERCAMBIO DE CANDIDATOS SDP
    _socket.on('on-candidate', (candidateData) async {
      log('[on-candidate] $candidateData');
      try {
        final RTCIceCandidate candidate = RTCIceCandidate(
            candidateData['candidate'],
            candidateData['sdpMid'],
            candidateData['sdpMLineIndex']);
        await pc.addCandidate(candidate);
      } catch (e) {
        log(e.toString());
        //cancelCall();
      }
    });

    // RECIBIMOS LA RESPUESTA DEL LLAMADO (PASO2)
    _socket.on('on-answer', (answer) async {
      log('[on-answer] $answer');
      RTCSessionDescription remoteSession =
          RTCSessionDescription(answer['sdp'], answer['type']);

      pc.setRemoteDescription(remoteSession);
    });
  }

// ESTADO DE LA CONEXIÓN CAMBIA
  void connectionStatusChanged(_) {
    connected = _socket.connected;
    onConnectionStatusChanged();
  }

  // LLAMADA SALIENTE (PASO1)
  void makeCall(String remotePeerID) async {
    remoteInfo = pares.firstWhere((peer) => peer['peerid'] == remotePeerID);

    // Creamos el y la establecemos con nuestro stream
    await _createPeerConnection(); // peer SALIENTE//LLAMADOR
    // Creamos y guardamos la oferta (descripción de la sesion) que vamos a hacer
    RTCSessionDescription offer = await pc.createOffer(sdpConstraints);
    pc.setLocalDescription(
        offer); // Guardamos la oferta para intercambiar en onICECandidate
    // Enviamos la oferta (SDP) al peer remoto en una CALL
    sendMesage('call', {'topeerid': remotePeerID, 'offer': offer.toMap()});
  }

  void cancelCall() async {
    //sendMesage('hangup', localSession['peerid']); // A
    onCallCancelada(
        '📞 Llamada finalizada'); // B <--  o A o B localPeerID (pero tambien en el hub)
    sendMesage('hangup', remoteInfo['peerid']);
  }

  void onCallCancelada(String msg) async {
    //localStream.getTracks().forEach((track) => track.stop());
    log('[on-hangup] ');
    // TODO: Revisar esto
    if (pc == null) return;

    // try {
    //if (localStream != null) {
    await pc.removeStream(localStream);
    //}
    // } on Exception {
    //   log('Error peer sin localStream');
    // }

    await pc.close();
    await pc.dispose(); //<-- evitar un peerConection is nul?¿?¿
    //pc = await createPeerConnection(configuration);
    onRemoteCallCancel(msg);
  }

  // LLAMA ENTRANTE
  Future<void> onCallAceptada(data) async {
    //log('[on-call] $data');
    remoteInfo = data['remotepeer'];
    debugPrint("[on-call] $remoteInfo");
    // Creamos el y la establecemos con nuestro stream local

    await _createPeerConnection();

    // Obtenemos la sesion llamante (oferta)
    RTCSessionDescription sesionLlamante =
        RTCSessionDescription(data['offer']['sdp'], data['offer']['type']);
    await pc.setRemoteDescription(sesionLlamante);
    // Creamos la sesion llamada (answer)
    final RTCSessionDescription answer = await pc.createAnswer(sdpConstraints);
    // y la guardamos
    await pc.setLocalDescription(answer);

    sendMesage(
      'answer',
      {
        'peerid': remoteInfo['peerid'], // peerid que me llama
        'answer': answer.toMap(),
      },
    );
  }

  _createPeerConnection() async {
    // Creamos el peer SALIENTE o ENTRANTE pidiendo la info a un STUN
    pc = await createPeerConnection(configuration);

    // Configuramos el peer con el Stream LOCAL siempre
    // El stream remoto lo recogemos en onAddStream
    await pc.addStream(localStream);

    // onAddStream se ejecuta como respuesta de nuestro peer remoto
    // indicando su Stream
    pc.onAddStream = (MediaStream stream) {
      remoteStream = stream;
      onRemoteStreamChanged(stream);
    };
    // onIceCandidate se ejecuta cuando el peer remoto acepta la conexión
    pc.onIceCandidate = (RTCIceCandidate candidate) {
      log('[onIceCandidate]');
      sendMesage('candidate',
          {"peerid": remoteInfo['peerid'], "candidate": candidate.toMap()});
    };

    pc.onSignalingState = _onSignalingState;
    pc.onIceGatheringState = _onIceGatheringState;
    pc.onIceConnectionState = _onIceConnectionState;
    pc.onConnectionState = _onPeerConnectionState;
    pc.onRenegotiationNeeded = _onRenegotiationNeeded;
  }

  void getSessions() {
    _socket.emit('peers', _socket.id);
  }

  void setAlias(String alias, String description) {
    _socket.emit('alias', {'alias': alias, 'description': description});
  }

  void sendMesage(String eventName, dynamic data) =>
      _socket.emit(eventName, data);

  void getLocalStream(Size size) async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': {
        //'aspectRatio': 9 / 16,
        'aspectRatio': size.width / size.height,
        'facingMode': 'user',
        'optional': [],
      }
    };

    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);
    localStream = stream;
    onLocalStreamChanged(stream);
  }

  Future<List<MediaDeviceInfo>> getMediaDevices() async {
    return await navigator.mediaDevices.enumerateDevices();
  }

  void _onSignalingState(RTCSignalingState state) {
    //RTCSignalingState.RTCSignalingStateStable
    log(state.toString());
  }

  void _onIceGatheringState(RTCIceGatheringState state) {
    //RTCIceGatheringState.RTCIceGatheringStateComplete
    log(state.toString());
  }

  void _onIceConnectionState(RTCIceConnectionState state) {
    // RTCIceConnectionState.RTCIceConnectionStateConnected
    // RTCIceConnectionState.RTCIceConnectionStateChecking
    // RTCIceConnectionState.RTCIceConnectionStateFailed
    log(state.toString());
    if (state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
      onCallCancelada('😱 Error de conexión');
      sendMesage('failed', remoteInfo['peerid']);
    }
  }

  void _onPeerConnectionState(RTCPeerConnectionState state) {
    // RTCPeerConnectionState.RTCPeerConnectionStateConnecting
    // RTCPeerConnectionState.RTCPeerConnectionStateConnected
    // RTCPeerConnectionState.RTCPeerConnectionStateFailed

    log(state.toString());
  }

  void _onRenegotiationNeeded() {
    log('RenegotiationNeeded');
  }
}
