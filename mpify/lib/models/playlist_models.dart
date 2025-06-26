import 'package:flutter/material.dart';

class PlaylistModels extends ChangeNotifier{
  String _selectedPlaylist = 'Playlist Name';
  bool _isPlayerOpen = true;
  
  String get selectedPlaylist => _selectedPlaylist;
  List<String> _playlists = [];
  List<String> get playlists => _playlists;
  bool get isPlayerOpen => _isPlayerOpen;

  void tooglePlayer() {
    _isPlayerOpen = !_isPlayerOpen;
    notifyListeners();
  }

  void updateListOfPlaylist(List<String> newListOfPlaylist) {
    _playlists = newListOfPlaylist;
    notifyListeners();
  }


  void setSelectedPlaylist(String name){
    _selectedPlaylist = name;
    notifyListeners();
  }
  
}