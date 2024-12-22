import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerUtility{
  final ImagePicker _picker = ImagePicker();

  Future<File?>piclImage()async{
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if(pickedFile !=null){
      return File(pickedFile.path);
    }
    return null;
  }
}