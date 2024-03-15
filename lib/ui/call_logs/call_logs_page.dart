import 'dart:math';

import 'package:aishshreya/bloc/call_log_bloc.dart';
import 'package:aishshreya/data/model/CallLogDetail.dart';
import 'package:aishshreya/data/repository/employee_repository.dart';
import 'package:aishshreya/ui/widget/loading_widget.dart';
import 'package:aishshreya/ui/widget/occupedia_textfield.dart';
import 'package:aishshreya/utils/constants.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'call_log_filter_sheet.dart';

class CallLogsPage extends StatefulWidget {
  const CallLogsPage({Key? key}) : super(key: key);

  @override
  State<CallLogsPage> createState() => _CallLogsPageState();
}

class _CallLogsPageState extends State<CallLogsPage> {

  late final CallLogBloc bloc;

  @override
  void initState() {
    bloc = CallLogBloc(context.read<EmployeeRepository>());
    super.initState();
    bloc.msgController?.stream.listen((event) {
      AppMessageHandler().showSnackBar(context, event);
    });
    bloc.initCallLogs();
    bloc.scrollController.addListener(bloc.scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Call Logs", style: TextStyle(
          color: Colors.black,
        ),),
        // backgroundColor: K.themeColorSecondary,
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => Provider.value(
                  value: bloc,
                  child: const CallLogFilterSheet(),
                ),
              );
            },
            icon: const Icon(PhosphorIcons.funnel),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: AppTextField3(
              title: 'Search Number',
              controller: bloc.searchQuery,
              showTitle: false,
              icon: const Icon(PhosphorIcons.magnifying_glass, color: K.textGrey, size: 25,),
              onChanged: bloc.onSearch,
            ),
          ),
          Expanded(
            child: CustomScrollView(
              controller: bloc.scrollController,
              slivers: [
                const SliverToBoxAdapter(child: SizedBox()),
                ValueListenableBuilder(
                  valueListenable: bloc.logsState,
                  builder: (context, LoadingState state, _) {
                    if(state==LoadingState.loading) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: LoadingIndicator(color: K.themeColorPrimary),
                        ),
                      );
                    }
                    if(state==LoadingState.error || state == LoadingState.networkError) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(state==LoadingState.error ? "Some Error Occurred! Please try again!" : "No Internet Connection! Please Try Again!"),
                              TextButton(
                                onPressed: () {
                                  bloc.initCallLogs();
                                },
                                child: const Text("Retry"),
                              )
                            ],
                          ),
                        ),
                      );
                    }
                    return ValueListenableBuilder(
                        valueListenable: bloc.callLogs,
                        builder: (context, List<CallLogDetail> logs, _) {
                          if(logs.isEmpty) {
                            return const SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(child: Text("No Call Logs Available!")));
                          }

                        return ValueListenableBuilder(
                          valueListenable: bloc.searchingLogs,
                          builder: (context, bool searching, _) {
                            return ValueListenableBuilder(
                              valueListenable: bloc.searchLogs,
                              builder: (context, List<CallLogDetail> searchLogs, _) {
                                if(searching && searchLogs.isEmpty) {
                                  return const SliverFillRemaining(
                                      hasScrollBody: false,
                                      child: Center(child: Text("No Call Logs Found!")));
                                }
                                return MultiSliver(
                                  children: [
                                    CallLogsSliverList(logs: searching ? searchLogs : logs),
                                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                                    if(state==LoadingState.paginating) const SliverFillRemaining(
                                      hasScrollBody: false,
                                      child: Center(
                                        child: LoadingIndicator(color: K.themeColorPrimary),
                                      ),
                                    ),
                                    if(state==LoadingState.paginating) const SliverToBoxAdapter(child: SizedBox(height: 20)),
                                  ],
                                );
                              }
                            );
                          }
                        );
                      }
                    );
                  }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CallLogsSliverList extends StatelessWidget {
  final List<CallLogDetail> logs;
  const CallLogsSliverList({Key? key, required this.logs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, i) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: K.themeColorPrimary),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(PhosphorIcons.phone_incoming, size: 30, color: K.themeColorPrimary,),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    // Navigator.push(context, MaterialPageRoute(
                                    //     builder: (context) => ClientDetailPage(client: ClientDetail(id:dueServices[i].clientId, name: dueServices[i].clientName, phone: dueServices[i].clientPhone),)
                                    // ));
                                  },
                                  child: Text(logs[i].leadId==null ? "${logs[i].otherNumber}" : "${logs[i].leadName}", style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    // height: 1.2,
                                  ),),
                                ),
                                if(logs[i].leadId!=null) Text("${logs[i].leadPhone}", style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  // height: 1.2,
                                ),),
                                if(logs[i].createdAt!=null) Text("${DateFormat('MMM dd, hh:mm a').format(DateTime.parse(logs[i].createdAt ?? ''))}", style: TextStyle(
                                  fontSize: 12,
                                ),),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              //commented for 2.0
                              /*Text("${logs[i].empName}", style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                // height: 1.2,
                              ),),
                              Text("${logs[i].empPhone}", style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                // height: 1.2,
                              ),),*/
                              Row(
                                children:  [
                                  const Icon(PhosphorIcons.microphone, color: K.themeColorPrimary,size: 15,),
                                  const SizedBox(width: 5),
                                  //commented for 2.0
                                  /*Text('${logs[i].callStatus} (${DateFormat('mm:ss').format(DateFormat('s').parse(logs[i].callDuration ?? '0'))})', style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: K.textGrey.withOpacity(0.6),
                                    height: 1,
                                  ),),*/
                                  Text('${logs[i].callStatus}', style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: K.textGrey.withOpacity(0.6),
                                    height: 1,
                                  ),),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      //commented for 2.0
                      //if(logs[i].callRecord!=null) CallLogPlayer(url: logs[i].callRecord ?? ''),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          },
          childCount: logs.length,
        ),
      ),
    );
  }
}


class CallLogPlayer extends StatefulWidget {
  final String url;
  const CallLogPlayer({Key? key, required this.url}) : super(key: key);

  @override
  State<CallLogPlayer> createState() => _CallLogPlayerState();
}

class _CallLogPlayerState extends State<CallLogPlayer> {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(widget.url)));
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      _player.stop();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<Duration>(
          stream: _player.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data;
            return StreamBuilder<Duration>(
              stream: _player.bufferedPositionStream,
              builder: (context, snapshot) {
                final bufferedPosition = snapshot.data;
                return StreamBuilder<Duration?>(
                  stream: _player.durationStream,
                  builder: (context, snapshot) {
                    final duration = snapshot.data;
                    return SeekBar(
                      duration: duration ?? Duration.zero,
                      position: position ?? Duration.zero,
                      bufferedPosition: bufferedPosition ?? Duration.zero,
                      onChangeEnd: _player.seek,
                    );
                  }
                );
              }
            );
          },
        ),
        ControlButtons(_player),
      ],
    );
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }
}


/// Displays the play/pause button and volume/speed sliders.
class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Opens volume slider dialog
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              value: player.volume,
              stream: player.volumeStream,
              onChanged: player.setVolume,
            );
          },
        ),
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow, color: K.themeColorPrimary,),
                iconSize: 64.0,
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause, color: K.themeColorPrimary,),
                iconSize: 64.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay, color: K.themeColorPrimary,),
                iconSize: 64.0,
                onPressed: () => player.seek(Duration.zero),
              );
            }
          },
        ),
        StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, AsyncSnapshot<Duration> snapshot) {
            final duration = snapshot.data;
            return Text("${DateFormat('mm:ss').format(DateFormat('s').parse('${duration?.inSeconds ?? '0'}'))}/${DateFormat('mm:ss').format(DateFormat('s').parse('${player.duration?.inSeconds ?? '0'}'))}");
          },
        ),
      ],
    );
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    Key? key,
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
    this.onChangeEnd,
  }) : super(key: key);

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SliderTheme(
          data: _sliderThemeData.copyWith(
            thumbShape: SliderComponentShape.noThumb,
            activeTrackColor: Colors.blue.shade100,
            inactiveTrackColor: Colors.grey.shade300,
          ),
          child: ExcludeSemantics(
            child: Slider(
              min: 0.0,
              max: widget.duration.inMilliseconds.toDouble(),
              value: min(widget.bufferedPosition.inMilliseconds.toDouble(),
                  widget.duration.inMilliseconds.toDouble()),
              onChanged: (value) {
                setState(() {
                  _dragValue = value;
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(Duration(milliseconds: value.round()));
                }
              },
              onChangeEnd: (value) {
                if (widget.onChangeEnd != null) {
                  widget.onChangeEnd!(Duration(milliseconds: value.round()));
                }
                _dragValue = null;
              },
            ),
          ),
        ),
        SliderTheme(
          data: _sliderThemeData.copyWith(
            inactiveTrackColor: Colors.transparent,
          ),
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
                widget.duration.inMilliseconds.toDouble()),
            onChanged: (value) {
              setState(() {
                _dragValue = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged!(Duration(milliseconds: value.round()));
              }
            },
            onChangeEnd: (value) {
              if (widget.onChangeEnd != null) {
                widget.onChangeEnd!(Duration(milliseconds: value.round()));
              }
              _dragValue = null;
            },
          ),
        ),
        // Positioned(
        //   right: 16.0,
        //   bottom: 0.0,
        //   child: Text(
        //       RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
        //           .firstMatch("$_remaining")
        //           ?.group(1) ??
        //           '$_remaining',
        //       style: Theme.of(context).textTheme.caption),
        // ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}

void showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  String valueSuffix = '',
  // TODO: Replace these two by ValueStream.
  required double value,
  required Stream<double> stream,
  required ValueChanged<double> onChanged,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => SizedBox(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: const TextStyle(
                      fontFamily: 'Fixed',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0)),
              Slider(
                divisions: divisions,
                min: min,
                max: max,
                value: snapshot.data ?? value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
