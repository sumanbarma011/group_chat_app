import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key,required this.selectImage});
 final void Function (File image)selectImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? pickedImage;
  void _pickedImage() async {
    final XFile? photo = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    if (photo == null) {
      return;
    }
    setState(() {
      pickedImage = File(photo.path);
      
    });
      widget.selectImage(pickedImage!);

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: pickedImage != null ? FileImage(pickedImage!) : null,
        ),
        TextButton.icon(
            onPressed: _pickedImage,
            icon: const Icon(Icons.image),
            label: Text('Add item',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)))
      ],
    );
  }
}
