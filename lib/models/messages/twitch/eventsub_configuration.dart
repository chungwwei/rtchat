import 'package:flutter/material.dart';

class FollowEventConfig {
  bool showEvent;
  bool isEventPinnable;
  Duration eventDuration;

  FollowEventConfig(this.showEvent, this.isEventPinnable, this.eventDuration);

  FollowEventConfig.fromJson(Map<String, dynamic> json)
      : showEvent = json['showEvent'],
        isEventPinnable = json['isEventPinnable'],
        eventDuration = Duration(seconds: json['eventDuration'].toInt());

  Map<String, dynamic> toJson() => {
        "showEvent": showEvent,
        "isEventPinnable": isEventPinnable,
        "eventDuration": eventDuration.inSeconds.toInt(),
      };
}

class SubscriptionEventConfig {
  bool showEvent;
  bool isEventPinnable;
  Duration eventDuration;

  SubscriptionEventConfig(
      this.showEvent, this.isEventPinnable, this.eventDuration);

  SubscriptionEventConfig.fromJson(Map<String, dynamic> json)
      : showEvent = json['showEvent'],
        isEventPinnable = json['isEventPinnable'],
        eventDuration = Duration(seconds: json['eventDuration'].toInt());

  Map<String, dynamic> toJson() => {
        "showEvent": showEvent,
        "isEventPinnable": isEventPinnable,
        "eventDuration": eventDuration.inSeconds.toInt(),
      };
}

class CheerEventConfig {
  bool showEvent;
  bool isEventPinnable;
  Duration eventDuration;

  CheerEventConfig(this.showEvent, this.isEventPinnable, this.eventDuration);

  CheerEventConfig.fromJson(Map<String, dynamic> json)
      : showEvent = json['showEvent'],
        isEventPinnable = json['isEventPinnable'],
        eventDuration = Duration(seconds: json['eventDuration'].toInt());

  Map<String, dynamic> toJson() => {
        "showEvent": showEvent,
        "isEventPinnable": isEventPinnable,
        "eventDuration": eventDuration.inSeconds.toInt(),
      };
}

class RaidEventConfig {
  bool showEvent;
  bool isEventPinnable;
  Duration eventDuration;

  RaidEventConfig(this.showEvent, this.isEventPinnable, this.eventDuration);

  RaidEventConfig.fromJson(Map<String, dynamic> json)
      : showEvent = json['showEvent'],
        isEventPinnable = json['isEventPinnable'],
        eventDuration = Duration(seconds: json['eventDuration'].toInt());

  Map<String, dynamic> toJson() => {
        "showEvent": showEvent,
        "isEventPinnable": isEventPinnable,
        "eventDuration": eventDuration.inSeconds.toInt(),
      };
}

class EventSubConfigurationModel extends ChangeNotifier {
  FollowEventConfig followEventConfig =
      FollowEventConfig(false, false, const Duration(seconds: 5));
  SubscriptionEventConfig subscriptionEventConfig =
      SubscriptionEventConfig(false, false, const Duration(seconds: 5));
  CheerEventConfig cheerEventConfig =
      CheerEventConfig(true, true, const Duration(seconds: 5));
  RaidEventConfig raidEventConfig =
      RaidEventConfig(true, true, const Duration(seconds: 5));
  // other configs
  // final HypeTrainEventConfig;

  setFollowEventDuration(Duration duration) {
    followEventConfig.eventDuration = duration;
    notifyListeners();
  }

  setFollowEventShowable(bool value) {
    followEventConfig.showEvent = value;
    notifyListeners();
  }

  setFollowEventPinnable(bool value) {
    followEventConfig.isEventPinnable = value;
    notifyListeners();
  }

  setCheerEventDuration(Duration duration) {
    cheerEventConfig.eventDuration = duration;
    notifyListeners();
  }

  setCheerEventShowable(bool value) {
    cheerEventConfig.showEvent = value;
    notifyListeners();
  }

  setCheerEventPinnable(bool value) {
    cheerEventConfig.isEventPinnable = value;
    notifyListeners();
  }

  setRaidEventDuration(Duration duration) {
    raidEventConfig.eventDuration = duration;
    notifyListeners();
  }

  setRaidEventShowable(bool value) {
    raidEventConfig.showEvent = value;
    notifyListeners();
  }

  setRaidEventPinnable(bool value) {
    raidEventConfig.isEventPinnable = value;
    notifyListeners();
  }

  EventSubConfigurationModel.fromJson(Map<String, dynamic> json) {
    if (json['followEventConfig'] != null) {
      followEventConfig = FollowEventConfig.fromJson(json['followEventConfig']);
    }
    if (json['subscriptionEventConfig'] != null) {
      subscriptionEventConfig =
          SubscriptionEventConfig.fromJson(json['subscriptionEventConfig']);
    }
    if (json['cheerEventConfig'] != null) {
      cheerEventConfig = CheerEventConfig.fromJson(json['cheerEventConfig']);
    }
  }

  Map<String, dynamic> toJson() => {
        "followEventConfig": followEventConfig,
        'subscriptionEventConfig': subscriptionEventConfig,
        'cheerEventConfig': cheerEventConfig
      };
}
