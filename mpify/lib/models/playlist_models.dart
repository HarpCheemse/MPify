import 'package:flutter/material.dart';

class PlaylistModels extends ChangeNotifier{
  String _selectedPlaylist = 'Playlist Name';
  String get selectedPlaylist => _selectedPlaylist;

  void setSelectedPlaylist(String name){
    _selectedPlaylist = name;
    notifyListeners();
  }
  
}