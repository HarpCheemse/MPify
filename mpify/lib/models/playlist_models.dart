import 'package:flutter/material.dart';

class PlaylistModels extends ChangeNotifier{
  String _selectedPlaylist = 'Playlist Name';
  
  String get selectedPlaylist => _selectedPlaylist;
  List<String> _playlists = [];
  List<String> get playlists => _playlists;

  void updateListOfPlaylist(List<String> newListOfPlaylist) {
    _playlists = newListOfPlaylist;
    notifyListeners();
  }


  void setSelectedPlaylist(String name){
    _selectedPlaylist = name;
    notifyListeners();
  }
  
}