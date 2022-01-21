import 'package:fireflutter/src/chat/chat.data.model.dart';
import 'package:flutter/material.dart';

typedef FunctionEnter = void Function(String roomId);
typedef FunctionRoomsItemBuilder = Widget Function(ChatMessageModel);
typedef MessageBuilder = Widget Function(ChatMessageModel);
typedef InputBuilder = Widget Function(void Function(String));

const ERROR_CHAT_MESSAGE_ADD =
    'Failed to send message (ERROR_CHAT_MESSAGE_ADD)';
