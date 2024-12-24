import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
// import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:musik_streaming_app/widgets/volume_control_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SongsListScreen extends StatefulWidget {
  SongsListScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SongsListScreen> createState() => _SongsListScreenState();
}

class _SongsListScreenState extends State<SongsListScreen> {
  final Map<String, Uint8List?> _albumArts = {};
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  double _trackDuration = 0.0;
  int _currentTrackIndex = 0;
  double _volume = 0.02;
  bool isVolumeControlVisible = true;
  List<File> _audioFiles = [];
  double initialChildSize = 0.1;
  DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  bool snap = false;
  PanelController panelController = PanelController();
  String error = "";
 
  @override
  void initState() {
    super.initState();
    _volume = 0.05;
    _initializePlayer();
    _scanAudioFiles();
    _fetchMetadata();
    _currentTrackIndex = 1;
  }

  void _scanAudioFiles() async {
    if (Platform.isWindows) {
      // Get the current username
      String? username = Platform.environment['USERNAME'];
      if (username == null) {
        print("Unable to determine the current user.");
        return;
      }

      // Directories to scan for audio files
      List<Directory> directories = [
        Directory('C:\\Users\\$username\\Music'),
        Directory('C:\\Users\\$username\\Downloads'),
        Directory('Downloads'),
      ];

      List<File> audioFiles = [];
      for (Directory directory in directories) {
        if (await directory.exists()) {
          List<FileSystemEntity> files = directory.listSync(recursive: true);
          for (var file in files) {
            if (file is File && _isAudioFile(file.path)) {
              audioFiles.add(file);
            }
          }
        }
      }

      setState(() {
        _audioFiles = audioFiles;
      });
    } else if (Platform.isAndroid) {
      try {
        // Request storage permission
        final permissionStatus = await Permission.storage.request();

        if (permissionStatus.isGranted) {
          // Directories to scan for audio files and videos
          List<Directory?> directories = [
            await getExternalStorageDirectory(),
            Directory('/storage/emulated/0/Music'),
            Directory('/storage/emulated/0/Download'),
            Directory('/storage/emulated/0/Videos'),
          ];

          List<File> audioFiles = [];
          for (Directory? directory in directories) {
            if (directory != null && await directory.exists()) {
              List<FileSystemEntity> files =
                  directory.listSync(recursive: true);
              for (var file in files) {
                if (file is File && (_isAudioFile(file.path))) {
                  audioFiles.add(file);
                }
              }
            }
          }

          setState(() {
            _audioFiles = audioFiles;
          });
        }
      } catch (e) {
        print("$e -------------------------------------");
        error = e.toString();
      }
    }
  }

  bool _isAudioFile(String filePath) {
    const validExtensions = ['mp3', "mp4", 'wav', 'aac', 'ogg', 'm4a', 'flac'];
    String extension = filePath.split('.').last.toLowerCase();
    return validExtensions.contains(extension);
  }

  void _initializePlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _trackDuration = duration.inSeconds.toDouble();
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _currentPosition = position.inSeconds.toDouble();
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _playNextTrack();
    });
  }

  void _playNextTrack() {
    setState(() {
      _currentTrackIndex = (_currentTrackIndex + 1) % _audioFiles.length;
    });
    print("Next track index: $_currentTrackIndex");
    print("Next track file: ${_audioFiles[_currentTrackIndex].path}");
    _playPauseAudio(_audioFiles[_currentTrackIndex]);
  }

  void _playPauseAudio(File file) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        print("Playing file: ${file.path}");
        await _audioPlayer.play(DeviceFileSource(file.path));
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  void _skip() {
    setState(() {
      _currentTrackIndex = (_currentTrackIndex + 1) % _audioFiles.length;
      _playPauseAudio(_audioFiles[_currentTrackIndex]);
    });
  }

  void _skip_previous() {
    setState(() {
      _currentTrackIndex = (_currentTrackIndex - 1) % _audioFiles.length;
      _playPauseAudio(_audioFiles[_currentTrackIndex]);
    });
  }

  String formatDuration(double durationInSeconds) {
    int minutes = (durationInSeconds / 60).floor();
    int seconds = (durationInSeconds % 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchMetadata() async {
    try {
      // Using Future.wait to fetch metadata in parallel
      final metadataResults = await Future.wait(
        _audioFiles.map((file) async {
          try {
            final metadata = await MetadataRetriever.fromFile(file);
            return MapEntry(file.path, metadata.albumArt);
          } catch (e) {
            return MapEntry(file.path, null); // Return null if fetching fails
          }
        }),
      );

      // Update the state with the fetched metadata
      setState(() {
        for (var result in metadataResults) {
          _albumArts[result.key] = result.value;
        }
      });
    } catch (e) {
      // Handle any potential errors in the Future.wait itself
      print('Error fetching metadata: $e');
    }
  }

  void _expandSheet() {
    setState(() {
      initialChildSize = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SlidingUpPanel(
            // border: Border.all(),
            backdropEnabled: true,
            backdropColor: Colors.black.withOpacity(0.5),
            color: Colors.white,
            controller: panelController,
            minHeight: MediaQuery.sizeOf(context).height * .1,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(0),
            ),
            panelBuilder: (scrollController) =>
                _buildPanelContent(scrollController),
            collapsed: _buildCollapsedPlayer(),
            body: _buildSongList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.sizeOf(context).height * .30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00A889),
                    const Color(0xFF007A65),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, size: 28, color: Colors.white),
                    onPressed: () {
                      // Handle menu action
                    },
                  ),
                  Text(
                    // 'Your Playlist',
                    error,
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert,
                        size: 28, color: Colors.white),
                    onPressed: () {
                      // Handle more action
                    },
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discover Music',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Listen to your favorite tracks anytime, anywhere!',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ListView.builder(
              itemCount: _audioFiles.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final song = _audioFiles[index];
                final albumArt = _albumArts[song.path];
                final isCurrentTrack = _currentTrackIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentTrackIndex = index;
                      _playPauseAudio(_audioFiles[_currentTrackIndex]);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCurrentTrack
                          ? const Color(0xFF00A889)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                        if (isCurrentTrack)
                          BoxShadow(
                            color: const Color(0xFF00A889).withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: albumArt != null
                              ? Image.memory(
                                  albumArt,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.music_note,
                                    size: 40,
                                    color: Colors.grey[600],
                                  ),
                                ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.uri.pathSegments.last.split('.').first,
                                style: TextStyle(
                                  color: isCurrentTrack
                                      ? Colors.white
                                      : Colors.grey[800],
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                song.uri.pathSegments.last
                                    .split('.')
                                    .last
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: isCurrentTrack
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(
                            isCurrentTrack && _isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            color: isCurrentTrack
                                ? Colors.white
                                : Colors.grey[800],
                            size: 40,
                          ),
                          onPressed: () {
                            setState(() {
                              _currentTrackIndex = index;
                              _playPauseAudio(_audioFiles[_currentTrackIndex]);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedPlayer() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Album Art with Circular Border
          Container(
            margin: const EdgeInsets.all(10),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: _albumArts[_currentTrackIndex] != null
                  ? Image.memory(
                      _albumArts[_currentTrackIndex]!,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.music_note, color: Colors.white, size: 40),
            ),
          ),
          // Song Info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _audioFiles.isNotEmpty
                      ? _audioFiles[_currentTrackIndex]
                          .uri
                          .pathSegments
                          .last
                          .split('.')
                          .first
                      : "No Track Selected",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      formatDuration(_currentPosition),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _currentPosition /
                            (_trackDuration == 0 ? 1 : _trackDuration),
                        backgroundColor: Colors.white12,
                        color: const Color(0xFF00A889),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      formatDuration(_trackDuration),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Playback and Extra Controls
          Row(
            children: [
              // Shuffle Icon
              // IconButton(
              //   icon: const Icon(Icons.shuffle, color: Colors.white),
              //   onPressed: () {
              //     // Shuffle logic
              //   },
              // ),
              // // Repeat Icon
              // IconButton(
              //   icon: const Icon(Icons.repeat, color: Colors.white),
              //   onPressed: () {
              //     // Repeat logic
              //   },
              // ),
              // Play/Pause Button
              ElevatedButton(
                onPressed: () {
                  _playPauseAudio(_audioFiles[_currentTrackIndex]);
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  backgroundColor: const Color(0xFF00A889),
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildPanelContent(ScrollController scrollController) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black,
            Color.fromARGB(255, 0, 168, 137),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: _albumArts[_currentTrackIndex] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.memory(
                      _albumArts[_currentTrackIndex]!,
                      key: ValueKey<int>(_currentTrackIndex),
                      width: MediaQuery.of(context).size.width * 0.75,
                      height: MediaQuery.of(context).size.height * 0.35,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height * 0.35,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white30, width: 2),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      color: Colors.white54,
                      size: 80,
                    ),
                  ),
          ),
          const SizedBox(height: 2),
          Text(
            _audioFiles.isNotEmpty
                ? _audioFiles[_currentTrackIndex]
                    .uri
                    .pathSegments
                    .last
                    .split('.')
                    .first
                : "No Track Selected",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _audioFiles.isNotEmpty
                ? "Duration: ${formatDuration(_trackDuration)}"
                : "00:00",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.1,
              maxChildSize: 0.7,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(
                          Icons.music_note,
                          color: Color.fromARGB(255, 0, 168, 137),
                        ),
                        title: Text(
                          'Track $index',
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          // Handle item tap
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          SliderTheme(
            data: SliderThemeData(
              thumbColor: Color.fromARGB(255, 0, 168, 137),
              activeTrackColor: Color.fromARGB(255, 0, 168, 137),
              inactiveTrackColor: Colors.white24,
              trackHeight: 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            ),
            child: Slider(
              value: _currentPosition,
              min: 0.0,
              max: _trackDuration,
              onChanged: (value) async {
                setState(() {
                  _currentPosition = value;
                });
                await _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(_currentPosition),
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  formatDuration(_trackDuration),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                color: Colors.white,
                iconSize: 36,
                onPressed: _skip_previous,
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  _playPauseAudio(_audioFiles[_currentTrackIndex]);
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Color.fromARGB(255, 0, 168, 137),
                  shadowColor: Colors.black45,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 5),
              IconButton(
                icon: const Icon(Icons.skip_next),
                color: Colors.white,
                iconSize: 36,
                onPressed: _skip,
              ),
            ],
          ),
          const SizedBox(height: 5),
          VolumeControlWidget(
            volume: _volume,
            onVolumeChanged: (value) {
              setState(() {
                _volume = value;
              });
              _audioPlayer.setVolume(_volume);
            },
          ),
        ],
      ),
    );
  }
}
