import 'package:flutter/material.dart';

import '../models/mod.dart';
import '../models/mod_data.dart';
import '../models/mod_manifest.dart';

class ModListTile extends StatefulWidget {
  final Mod mod;
  final ModData data;
  final Function(Mod, ModData) onRemove;

  const ModListTile({
    required this.mod,
    required this.data,
    required this.onRemove,
    super.key,
  });

  @override
  State<ModListTile> createState() => _ModListTileState();
}

class _ModListTileState extends State<ModListTile> {
  @override
  Widget build(BuildContext context) {
    final mod = widget.mod;
    final data = widget.data;

    return switch (mod.manifest) {
      ModManifestLegacy manifest => ListTile(
        key: ObjectKey(manifest.guid),
        title: Text(
          manifest.name,
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
        leading: manifest.iconPath != null
          ? Image.file(mod.getFileSync(manifest.iconPath!)!)
          : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 3,
          children: [
            if (manifest.options != null)
              DropdownMenu(
                dropdownMenuEntries: manifest.options!
                  .map((opt) => DropdownMenuEntry(value: opt, label: opt))
                  .toList(growable: false),
                initialSelection: manifest.options![data.selected[0]],
                onSelected: (value) => setState(() {
                  if (value == null) {
                    data.selected[0] = 0;
                  } else {
                    data.selected[0] = manifest.options!.indexOf(value);
                  }
                }),
              ),
            Switch(
              value: data.enabled,
              onChanged: (value) => setState(() => data.enabled = value),
            ),
            IconButton.outlined(
              onPressed: () => widget.onRemove(mod, data),
              icon: const Icon(Icons.remove_rounded, color: Colors.redAccent),
            ),
            SizedBox(width: 3),
          ],
        ),
      ),
      ModManifestV1 manifest => manifest.options?.isNotEmpty ?? false
        ? ExpansionTile(
          key: ObjectKey(manifest.guid),
          title: Text(
            manifest.name,
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
          leading: manifest.iconPath != null
            ? Image.file(mod.getFileSync(manifest.iconPath!)!)
            : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 3,
            children: [
              const Icon(Icons.expand_more),
              Switch(
                value: data.enabled,
                onChanged: (value) => setState(() => data.enabled = value),
              ),
              IconButton.outlined(
                onPressed: () => widget.onRemove(mod, data),
                icon: const Icon(Icons.remove_rounded, color: Colors.redAccent),
              ),
              SizedBox(width: 3),
            ],
          ),
          childrenPadding: EdgeInsets.only(right: 10),
          children: manifest.options!
            .asMap()
            .entries
            .map((kv) {
              final index = kv.key;
              final option = kv.value;
              return ListTile(
                leading: option.image != null
                  ? SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.file(
                      mod.getFileSync(option.image!)!,
                      fit: BoxFit.contain,
                    ),
                  )
                  : null,
                title: Text(option.name),
                subtitle: option.subOptions != null
                  ? DropdownButton(
                    isExpanded: true,
                    items: option.subOptions!.map((sub) {
                      return DropdownMenuItem(
                        value: sub,
                        child: Row(
                          children: [
                            if (sub.image != null)
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: Image.file(
                                  mod.getFileSync(sub.image!)!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            Column(
                              spacing: 3,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sub.name,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                Text(
                                  sub.description,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(growable: false),
                    onChanged: (value) => setState(() => data.selected[index] = option.subOptions!.indexOf(value!)),
                    value: option.subOptions![data.selected[index]],
                  )
                  : null,
                trailing: Checkbox(
                  value: data.toggled[index],
                  onChanged: (value) => setState(() => data.toggled[index] = value ?? false),
                ),
              );
            })
            .toList(growable: false),
        )
        : ListTile(
          key: ObjectKey(manifest.guid),
          title: Text(
            manifest.name,
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
          leading: manifest.iconPath != null
            ? Image.file(mod.getFileSync(manifest.iconPath!)!)
            : null,
          trailing: Row(
            spacing: 3,
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: data.enabled,
                onChanged: (value) => setState(() => data.enabled = value),
              ),
              IconButton.outlined(
                onPressed: () => widget.onRemove(mod, data),
                icon: const Icon(Icons.remove_rounded, color: Colors.redAccent),
              ),
              SizedBox(width: 3),
            ],
          ),
        ),
    };
  }
}