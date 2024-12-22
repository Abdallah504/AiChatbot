import 'dart:io';


import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/chat-provider.dart';
import '../controller/image-utility.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ImagePickerUtility _imagePickerUtility= ImagePickerUtility();
  @override
  Widget build(BuildContext context) {

    return Consumer<ChatProvider>(builder: (context ,provider, _){
      return Scaffold(
        appBar:  AppBar(
          backgroundColor: Colors.black,
          title: Text('AI chatbot' , style: TextStyle(color: Colors.white),),
        ),
        body: DashChat(
            currentUser: ChatUser(id: "user"),
            onSend: (ChatMessage messages){
              provider.sendMessages(userMessage: messages.text??"");
            },
            messages: provider.messages.reversed.map((chat){
              return  ChatMessage(
                text: chat['message'],
                  user: ChatUser(id: chat['role'] == 'user' ?"user" :"bot",
                  firstName: chat['role'] =="bot"? "Bot":"You"
                  ),
                  customProperties: {
                  'isImage': chat['isImage'] ??false,
                    "image": chat['image'] ?? null
                  },
                  createdAt: DateTime.now(),

              );
            }).toList(),
          messageOptions: MessageOptions(
            messageMediaBuilder: (ChatMessage message, _, __) {
              // Custom rendering for media (e.g., images)
              if (message.medias != null && message.medias!.isNotEmpty) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: Image.network(
                    message.medias!.first.url,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                );
              }
              return SizedBox(); // Default rendering for non-media messages
            },
          ),
        ),
        floatingActionButton: Padding(
          padding:  EdgeInsets.all(30.0),
          child: FloatingActionButton(
            backgroundColor: Colors.black,
              onPressed: ()async{
              File? image = await _imagePickerUtility.piclImage();
              if(image !=null){
                provider.sendImage(image);
              }
              },
          child: Center(child: Icon(Icons.add,color: Colors.white,),),
          ),
        ),
      );
    });
  }
}
