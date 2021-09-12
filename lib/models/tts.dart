import 'package:flutter/material.dart';
import 'package:rtchat/models/messages/message.dart';
import 'package:rtchat/models/messages/tts_audio_handler.dart';
import 'package:rtchat/models/messages/twitch/user.dart';

class TtsModel extends ChangeNotifier {
  TtsAudioHandler ttsHandler;
  Set<TwitchUserModel> mutedUsers = {};

  set messages(List<MessageModel> messages) {
    // for tts, we sort of cheat a bit and just append the new messages to the end of the list.
    final queue = ttsHandler.queue.value;
    final index = queue.isNotEmpty
        ? messages
            .lastIndexWhere((message) => message.messageId == queue.last.id)
        : -1;
    final mediaItems = messages
        .sublist(index + 1)
        .map((message) => TtsMediaItem.fromMessageModel(message))
        .whereType<TtsMediaItem>()
        .toList();
    if (index == -1) {
      // looks like we wiped the history, so reset the queue.
      enabled = false;
      ttsHandler.updateQueue(mediaItems);
    } else {
      ttsHandler.addQueueItems(mediaItems);
    }
  }

  Future<void> clearQueue() async {
    await ttsHandler.updateQueue([]);
  }

  List<TtsMediaItem> get queue {
    return ttsHandler.queue.value as List<TtsMediaItem>;
  }

  Future<void> force(String message) => ttsHandler.force(message);

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

  void addNameToBlacklist(TwitchUserModel model) {
    mutedUsers.add(model);
    ttsHandler.mutedUsers = mutedUsers;
    notifyListeners();
  }

  void removeNameFromBlacklist(TwitchUserModel model) {
    if (mutedUsers.isNotEmpty && mutedUsers.contains(model)) {
      mutedUsers.remove(model);
      ttsHandler.mutedUsers = mutedUsers;
      notifyListeners();
    }
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
    final mutedUsers = json['mutedUsers'];
    if (mutedUsers != null) {
      for (var user in mutedUsers) {
        mutedUsers.add(TwitchUserModel.fromJson(user));
      }
    }
  }

  Map<String, dynamic> toJson() => {
        "isBotMuted": isBotMuted,
        "isEmoteMuted": isEmoteMuted,
        "pitch": pitch,
        "speed": speed,
        'mutedUsers': mutedUsers
      };
}
