import 'package:audio_service/audio_service.dart';
import 'dart:async';

import 'package:audioplayer/audioplayer.dart';


const streamUrl =
    'http://stm16.abcaudio.tv:25584/player.mp4';

bool buttonState = true;

CustomAudioPlayer player = CustomAudioPlayer();

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl stopControl = MediaControl(
    androidIcon: 'drawable/ic_action_stop',
    label: 'Stop',
    action: MediaAction.stop);

class Player {

  initPlaying() {
    connect();
    AudioService.start(
      backgroundTaskEntrypoint: _backgroundAudioPlayerTask,
      resumeOnClick: true,
      androidNotificationChannelName: 'ABC Rádio',
      notificationColor: 0x5E6263,
      androidNotificationIcon: 'mipmap/radio',
    );
  }
}

void connect() async {
  await AudioService.connect();
}

void _backgroundAudioPlayerTask() async {
  AudioServiceBackground.run(() => CustomAudioPlayer());
}

class CustomAudioPlayer extends BackgroundAudioTask {
  AudioPlayer audioPlayer = new AudioPlayer();
  bool _playing;
  Completer _completer = Completer();

  Future<void> onStart() async {
    MediaItem mediaItem = MediaItem(
        id: 'audio_1',
        album: 'ABC Radio',
        title: 'A rádio que não cansa vc');
    AudioServiceBackground.setMediaItem(mediaItem);
    onPlay();
    await _completer.future;
  }

//  Future<void> audioStart() async {
//    await controller.setNetworkDataSource(streamUrl, autoPlay: true);
//    print('Audio Start OK');
//  }

  void playPause() {
    if (_playing)
      onPause();
    else
      onPlay();
  }

  void onPlay() async {
    await audioPlayer.play(streamUrl);
    //FlutterRadio.play(url: streamUrl);
    _playing = true;
    AudioServiceBackground.setState(
        controls: [pauseControl, stopControl],
        basicState: BasicPlaybackState.playing);
  }

  void onPause() async {
    await audioPlayer.pause();
   // FlutterRadio.playOrPause(url: streamUrl);
    AudioServiceBackground.setState(
        controls: [playControl, stopControl],
        basicState: BasicPlaybackState.paused);
  }

  void onStop() async {
    await audioPlayer.stop();
   // FlutterRadio.stop();
    AudioServiceBackground.setState(
        controls: [], basicState: BasicPlaybackState.stopped);
    _completer.complete();
  }
}
