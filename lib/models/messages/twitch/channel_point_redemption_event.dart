import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rtchat/models/messages/message.dart';

class TwitchChannelPointRedemptionEventModel extends MessageModel {
  final String redeemerUsername;
  final String status;
  final String rewardName;
  final int rewardCost;
  final String? userInput;

  const TwitchChannelPointRedemptionEventModel(
      {required DateTime timestamp,
      required String messageId,
      required this.redeemerUsername,
      required this.status,
      required this.rewardName,
      required this.rewardCost,
      required this.userInput})
      : super(messageId: messageId, timestamp: timestamp);

  static TwitchChannelPointRedemptionEventModel fromDocumentData(
      Map<String, dynamic> data) {
    return TwitchChannelPointRedemptionEventModel(
        timestamp: data['timestamp'].toDate(),
        messageId: "channel.point-redemption-${data['event']['id']}",
        redeemerUsername: data['event']['user_name'],
        status: data['event']['status'],
        rewardName: data['event']['reward']['title'],
        rewardCost: data['event']['reward']['cost'],
        userInput: data['event']['user_input']);
  }

  IconData get icon {
    switch (status) {
      case "fulfilled":
        return Icons.done;
      case "cancelled":
        return Icons.close;
      case "unfulfilled":
        return Icons.timer;
      case "unknown":
        return Icons.help;
      default:
        return Icons.done;
    }
  }
}
