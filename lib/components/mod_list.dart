import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../helpers/dialog.dart';
import '../models/mod.dart';
import '../models/mod_data.dart';
import '../services/mod_manager.dart';
import 'mod_list_tile.dart';
import 'search_bar.dart' as my;

class ModList extends StatefulWidget {
  final ModManagerService manager;

  const ModList({required this.manager, super.key});

  @override
  State<ModList> createState() => _ModListState();
}

class _ModListState extends State<ModList> {
  final _log = Logger("ModList");
  final _searchController = TextEditingController();
  bool _searching = false;
  CancelableOperation<void>? _searchOperation;
  String _lastQuery = "";
  bool _expanded = false;
  List<Mod> _mods = const [];

  @override
  void initState() {
    super.initState();
    _searchOperation = CancelableOperation.fromFuture(_load());
  }

  @override
  Widget build(BuildContext context) {
    if (_searching) {
      return Column(
        spacing: 3,
        children: [
          my.SearchBar(
            controller: _searchController,
            onSearch: _onSearch,
          ),
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    } else {
      final list = _lastQuery.isEmpty
        ? DragTarget<Mod>(
          onAcceptWithDetails: (details) {
            final mod = details.data;
            final profile = widget.manager.activeProfile;
            
            _log.fine("Adding mod \"${mod.manifest.getName()}\" to profile \"${profile.name}\"");

            if (profile.mods.any((data) => data.guid == mod.manifest.getIdentifier())) return;

            setState(() {
              profile.mods.add(mod.manifest.createModData());
              _mods.add(mod);
            });
          },
          builder: (context, _, _) => Padding(
            padding: EdgeInsets.only(right: _expanded ? 300 : 20),
            child: ReorderableListView.builder(
              itemBuilder: (context, index) {
                final mod = _mods[index];
                final data = widget.manager.activeProfile.mods[index];
                return DragTarget<Mod>(
                  onAcceptWithDetails: (details) {
                    final mod = details.data;
                    final profile = widget.manager.activeProfile;
                    
                    _log.fine("Adding mod \"${mod.manifest.getName()}\" to profile \"${profile.name}\" at $index");
                    
                    setState(() {
                      profile.mods.insert(index, mod.manifest.createModData());
                      _mods.insert(index, mod);
                    });
                  },
                  key: ObjectKey(mod.manifest.getIdentifier()),
                  builder: (context, _, _) => ModListTile(
                    mod: mod,
                    data: data,
                    onRemove: _remove,
                  ),
                );
              },
              itemCount: _mods.length,
              onReorder: _reorder,
            ),
          ),
        )
        : ListView.builder(
          itemBuilder: (context, index) {
            final mod = _mods[index];
            final data = widget.manager.activeProfile.mods.firstWhere((data) => data.guid == mod.manifest.getIdentifier());
            return ModListTile(
              mod: mod,
              data: data,
              onRemove: _remove,
            );
          },
          itemCount: _mods.length,
        );
        
      Widget? library;
      if (_lastQuery.isEmpty) {
        library = AnimatedPositioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: _expanded ? 300 : 20,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _expanded
            ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 20,
                  child: GestureDetector(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: const Icon(Icons.arrow_right),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Library",
                        softWrap: false,
                      ),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final libraryMods = widget.manager.mods
                              .where((mod) => !widget.manager.activeProfile.mods.any((data) => data.guid == mod.manifest.getIdentifier()))
                              .toList(growable: false);
                            libraryMods.sort((a, b) => a.manifest.getName().compareTo(b.manifest.getName()));
                            return ListView.builder(
                              itemBuilder: (context, index) {
                                final mod = libraryMods[index];
                                return Draggable<Mod>(
                                  data: mod,
                                  feedback: SizedBox(
                                    width: 280,
                                    child: Container(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      child: ListTile(
                                        title: Text(
                                          mod.manifest.getName(),
                                          overflow: TextOverflow.fade,
                                          softWrap: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      mod.manifest.getName(),
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                    ),
                                    trailing: IconButton(
                                      onPressed: () => _deleteMod(mod),
                                      icon: const Icon(Icons.delete_forever),
                                      hoverColor: Colors.red,
                                    ),
                                  ),
                                );
                              },
                              itemCount: libraryMods.length,
                            );
                          }
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
            : GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: DragTarget<Mod>(
                builder: (context, _, _) => Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: const Icon(Icons.arrow_left),
                ),
              ),
            ),
        );
      }

      return Column(
        spacing: 3,
        children: [
          my.SearchBar(
            controller: _searchController,
            onSearch: _onSearch,
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                list,
                if (_lastQuery.isEmpty)
                  library!,
              ],
            ),
          ),
        ],
      );
    }
  }

  void _onSearch(String query) {
    _log.fine("Searching for: \"$query\"");
    _searchOperation?.cancel();
    _searchOperation = CancelableOperation.fromFuture(_search(query));
  }

  Future<void> _load() async {
    setState(() => _searching = true);
    
    final manager =  widget.manager;
    final profile = manager.activeProfile;
    final mods = <Mod>[];
    for (final data in profile.mods) {
      final mod = manager.getModByGuid(data.guid);
      if (mod == null) continue;
      mods.add(mod);
    }

    setState(() {
      _lastQuery = "";
      _mods = mods;
      _searching = false;
    });
  }

  Future<void> _search(String query) async {
    setState(() => _searching = true);

    if (query.isEmpty) {
      await _load();
      return;
    }
    
    final manager =  widget.manager;
    final profile = manager.activeProfile;
    final mods = <Mod>[];
    for (final data in profile.mods) {
      final mod = manager.getModByGuid(data.guid);
      if (mod == null) continue;
      if (mod.manifest.getName().contains(query)) mods.add(mod);
    }

    setState(() {
      _lastQuery = query;
      _mods = mods;
      _searching = false;
    });
  }

  void _reorder(int oldIndex, int newIndex) {
    final profile = widget.manager.activeProfile;

    setState(() {
      final mod = _mods.removeAt(oldIndex);
      final data = profile.mods.removeAt(oldIndex);

      if (newIndex >= profile.mods.length) {
        _log.fine("Moving mod \"${mod.manifest.getName()}\" from $oldIndex to end in profile \"${profile.name}\"");

        _mods.add(mod);
        profile.mods.add(data);
      } else {
        _log.fine("Moving mod \"${mod.manifest.getName()}\" from $oldIndex to $newIndex in profile \"${profile.name}\"");
        
        _mods.insert(newIndex, mod);
        profile.mods.insert(newIndex, data);
      }
    });
  }

  void _remove(Mod mod, ModData data) {
    final profile = widget.manager.activeProfile;

    _log.fine("Removing mod \"${mod.manifest.getName()}\" from profile \"${profile.name}\"");

    setState(() {
      _mods.remove(mod);
      profile.mods.remove(data);
    });
  }

  Future<void> _deleteMod(Mod mod) async {
    final result = await showConfirmDialog(
      context,
      title: "Delete?",
      question: "Do you really want to delete \"${mod.manifest.getName()}\"?",
    );

    if (!result) return;
    
    showWaitDialog(context, title: "Deleting \"${mod.manifest.getName()}\"...");
    
    try {
      await widget.manager.removeMod(mod);
    } on Exception catch (e) {
      closeDialog(context);
      showNotificationDialog(
        context,
        text: "Failed to delete mod!\n$e",
        type: NotificationType.error,
      );
      return;
    }

    setState(() {
      _mods.remove(mod);
    });

    closeDialog(context);
  }
}