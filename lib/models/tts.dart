import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audio_service/audio_service.dart';

final validateUrl = Uri.https('id.twitch.tv', '/oauth2/validate');

const twitchClientId = "edfnh2q85za8phifif9jxt3ey6t9b9";

const botList = {
  'streamlab',
  'streamlabs',
  'nightbot',
  'xanbot',
  'ankhbot',
  'moobot',
  'wizebot',
  'phantombot',
  'streamelements',
  'streamelement'
};

class TtsMessage extends MediaItem {
  final String messageId;
  final String author;
  final String? coalescingHeader;
  final String message;
  final bool hasEmote;
  final Map<String, dynamic> emotes;

  const TtsMessage(
      {required this.messageId,
      required this.author,
      required this.message,
      this.coalescingHeader,
      required this.hasEmote,
      Map<String, dynamic>? emotes})
      : emotes = emotes ?? const {},
        super(id: messageId, artist: author, title: message);

  String get spokenMessage {
    if (coalescingHeader != null) {
      return "$coalescingHeader $message";
    }
    return message;
  }

  bool get isBotAuthor => botList.contains(author.toLowerCase());

  static List _parseEmotes(Map<String, dynamic> emotes) {
    var ranges = [];
    for (MapEntry e in emotes.entries) {
      for (final str in e.value) {
        final pair = str.split('-');
        final start = int.parse(pair[0]);
        final end = int.parse(pair[1]);
        ranges.add([start, end]);
      }
    }

    ranges.sort((a, b) => a[0].compareTo(b[0]));
    return ranges;
  }

  String get spokenNoEmotesMessage {
    var ranges = _parseEmotes(emotes);
    var res = "";
    var index = 0;
    for (var i = 0; i < ranges.length; i++) {
      var start = ranges[i][0];
      var end = ranges[i][1];
      if (start > index) {
        res += message.substring(index, start);
      }
      index = end + 1;
    }

    if (index < message.length) {
      res += message.substring(index);
    }
    return res;
  }
}

class TtsAudioHandler extends BaseAudioHandler with QueueHandler {
  final FlutterTts _tts = FlutterTts();
  var isBotMuted = false;
  var isEmoteMuted = false;
  var speed = 1.0;
  var pitch = 1.0;

  TtsAudioHandler() {
    _tts.setCompletionHandler(() async {
      final index = playbackState.value.queueIndex;
      if (index != null && index < queue.value.length - 1) {
        await skipToNext();
        await play();
      } else {
        playbackState.add(playbackState.value
            .copyWith(processingState: AudioProcessingState.buffering));
        await stop();
      }
    });

    playbackState.add(PlaybackState(
      controls: const [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.skipToNext,
      ],
      androidCompactActionIndices: const [0, 1, 2],
      processingState: AudioProcessingState.buffering,
      playing: false,
      queueIndex: 0,
    ));
  }

  @override
  Future<void> play() async {
    final index = playbackState.value.queueIndex;
    if (index == null) {
      return;
    }
    final message = queue.value[index] as TtsMessage;
    playbackState.add(playbackState.value.copyWith(controls: const [
      MediaControl.skipToPrevious,
      MediaControl.stop,
      MediaControl.skipToNext,
    ], processingState: AudioProcessingState.ready));
    await _tts.setSpeechRate(speed);
    await _tts.setPitch(pitch);
    if (isEmoteMuted) {
      await _tts.speak(message.spokenNoEmotesMessage);
    } else {
      await _tts.speak(message.spokenMessage);
    }
  }

  @override
  Future<void> stop() async {
    playbackState.add(playbackState.value.copyWith(controls: const [
      MediaControl.skipToPrevious,
      MediaControl.play,
      MediaControl.skipToNext,
    ]));
    await _tts.stop();
  }

  set enabled(bool enabled) {
    playbackState.add(playbackState.value.copyWith(playing: enabled));
    if (enabled) {
      skipToEnd();
    } else {
      stop();
    }
  }

  bool get enabled {
    return playbackState.value.playing;
  }

  @override
  Future<void> skipToPrevious() async {
    await stop();
    playbackState.add(playbackState.value
        .copyWith(processingState: AudioProcessingState.ready));
    super.skipToPrevious();
  }

  @override
  Future<void> skipToNext() async {
    final index = playbackState.value.queueIndex;
    if (index == null) {
      return;
    }
    super.skipToNext();
    await stop();
    if (index == queue.value.length - 1) {
      playbackState.add(playbackState.value
          .copyWith(processingState: AudioProcessingState.buffering));
      return;
    }

    final message = queue.value[index] as TtsMessage;
    if (message.isBotAuthor && isBotMuted) {
      if (index < queue.value.length - 1) {
        await skipToNext();
        await play();
      } else {
        await stop();
      }
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) {
      return;
    }
    playbackState.add(playbackState.value.copyWith(queueIndex: index));
    mediaItem.add(queue.value[index]);
    await super.skipToQueueItem(index);
  }

  Future<void> skipToEnd() async {
    await stop();
    await skipToQueueItem(queue.value.length - 1);
  }

  Future<void> force(TtsMessage message) async {
    await _tts.setSpeechRate(speed);
    await _tts.setPitch(pitch);
    await _tts.speak(message.spokenMessage);
  }
}

class TtsModel extends ChangeNotifier {
  TtsAudioHandler ttsHandler;

  Future<void> speak(TtsMessage message) async {
    await ttsHandler.addQueueItem(message);
    if (ttsHandler.enabled &&
        ttsHandler.playbackState.value.processingState ==
            AudioProcessingState.buffering) {
      await ttsHandler.skipToEnd();
      await ttsHandler.play();
    }
  }

  Future<void> force(TtsMessage message) => ttsHandler.force(message);

  bool get enabled {
    return ttsHandler.enabled;
  }

  set enabled(bool value) {
    ttsHandler.enabled = value;
    notifyListeners();
  }

  bool get isBotMuted => ttsHandler.isBotMuted;

  set isBotMuted(bool value) {
    ttsHandler.isBotMuted = value;
    notifyListeners();
  }

  double get speed => ttsHandler.speed;

  set speed(double value) {
    ttsHandler.speed = value;
    notifyListeners();
  }

  double get pitch => ttsHandler.pitch;

  set pitch(double value) {
    ttsHandler.pitch = value;
    notifyListeners();
  }

  bool get isEmoteMuted => ttsHandler.isEmoteMuted;

  set isEmoteMuted(bool value) {
    ttsHandler.isEmoteMuted = value;
    notifyListeners();
  }

  TtsModel.fromJson(this.ttsHandler, Map<String, dynamic> json) {
    if (json['isBotMuted'] != null) {
      ttsHandler.isBotMuted = json['isBotMuted'];
    }
    if (json['pitch'] != null) {
      ttsHandler.pitch = json['pitch'];
    }
    if (json['speed'] != null) {
      ttsHandler.speed = json['speed'];
    }
    if (json['isEmoteMuted'] != null) {
      ttsHandler.isEmoteMuted = json['isEmoteMuted'];
    }
  }

  Map<String, dynamic> toJson() => {
        "isBotMuted": isBotMuted,
        "isEmoteMuted": isEmoteMuted,
        "pitch": pitch,
        "speed": speed,
      };
}
