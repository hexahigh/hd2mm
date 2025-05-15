import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../helpers/dialog.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

final class _SubOptionState {
  bool expanded = false;
  final nameController = TextEditingController();
  String? nameError = "Name can not be empty!";
  final descriptionController = TextEditingController();
  var imagePathController = TextEditingController();
  String? includeError = "This sub-option needs to include files!";
  final includeFiles = <File>[];
}

final class _OptionState {
  bool expanded = false;
  final nameController = TextEditingController();
  String? nameError = "Name can not be empty!";
  final descriptionController = TextEditingController();
  var imagePathController = TextEditingController();
  bool activeIncludes = false;
  String? includeError = "This option needs to include files or have some sub-options!";
  final includeFiles = <File>[];
  final subOptions = <_SubOptionState>[];

  _OptionState();
}

class _CreatePageState extends State<CreatePage> {
  static final _patchFileRegex = RegExp(r"^[a-z0-9]{16}\.patch_[0-9]+(\.(stream|gpu_resources))?$");
  var _guidController = TextEditingController();
  String? _guidError = "GUID can not be empty!";
  final _nameController = TextEditingController();
  String? _nameError = "Name can not be empty!";
  final _descriptionController = TextEditingController();
  var _iconPathController = TextEditingController();
  final _options = <_OptionState>[];

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        Text(
          "Create",
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        Expanded(
          child: ListView(
            children: [
              Text(
                "Info:",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ListTile(
                leading: Text(
                  "Guid:",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                title: TextField(
                  controller: _guidController,
                  decoration: InputDecoration(
                    errorText: _guidError,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() => _guidError = "GUID can not be empty!");
                      return;
                    }
                    try {
                      UuidValue.withValidation(value);
                    } on FormatException {
                      setState(() => _guidError = "GUID is invalid!");
                      return;
                    } catch (ex) {
                      _guidError = ex.toString();
                      return;
                    }
                    setState(() => _guidError = null);
                  },
                ),
                trailing: IconButton.outlined(
                  onPressed: () => setState(() {
                    _guidController = TextEditingController(text: Uuid().v4());
                    _guidError = null;
                  }),
                  icon: const Icon(Icons.refresh),
                ),
              ),
              ListTile(
                leading: Text(
                  "Name:",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                title: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    errorText: _nameError,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    value = value.trim();
                    if (value.isEmpty) {
                      setState(() => _nameError = "Name can not be empty!");
                      return;
                    }
                    setState(() => _nameError = null);
                  },
                ),
              ),
              ListTile(
                leading: Text(
                  "Description:",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                title: TextField(
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 255,
                ),
              ),
              ListTile(
                leading: Text(
                  "Icon:",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                title: TextField(
                  controller: _iconPathController,
                  readOnly: true,
                  decoration: InputDecoration(
                    suffix: IconButton(
                      onPressed: () => setState(() => _iconPathController = TextEditingController()),
                      icon: const Icon(Icons.backspace_outlined),
                    ),
                  ),
                ),
                trailing: IconButton.outlined(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      dialogTitle: "Pick icon file",
                      type: FileType.image,
                      lockParentWindow: true,
                    );
                    if (result == null) return;
                    setState(() => _iconPathController = TextEditingController(text: result.files[0].path!));
                  },
                  icon: const Icon(Icons.folder_open),
                ),
              ),
              Divider(),
              Text(
                "Options:",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ..._options
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return ExpansionTile(
                    key: ObjectKey(option),
                    initiallyExpanded: option.expanded,
                    onExpansionChanged: (value) => option.expanded = value,
                    leading: Text(
                      "Name:",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    title: TextField(
                      controller: option.nameController,
                      decoration: InputDecoration(
                        errorText: option.nameError,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        value = value.trim();
                        if (value.isEmpty) {
                          setState(() => option.nameError = "Name can not be empty!");
                          return;
                        }
                        setState(() => option.nameError = null);
                      },
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 3,
                      children: [
                        MenuAnchor(
                          builder: (context, controller, child) => IconButton(
                            onPressed: () => controller.isOpen
                              ? controller.close()
                              : controller.open(),
                            icon: const Icon(Icons.more_vert)
                          ),
                          menuChildren: [
                            MenuItemButton(
                              onPressed: index > 0
                                ? () => setState(() {
                                  _options.remove(option);
                                  _options.insert(index - 1, option);
                                })
                                : null,
                              trailingIcon: const Icon(Icons.arrow_upward),
                              child: Text("Move up"),
                            ),
                            MenuItemButton(
                              onPressed: index < _options.length - 1
                                ? () => setState(() {
                                  _options.remove(option);
                                  _options.insert(index + 1, option);
                                })
                                : null,
                              trailingIcon: const Icon(Icons.arrow_downward),
                              child: Text("Move down"),
                            ),
                            MenuItemButton(
                              onPressed: () => setState(() => _options.remove(option)),
                              trailingIcon: const Icon(Icons.delete_outline),
                              child: Text("Remove"),
                            ),
                          ],
                        ),
                        const Icon(Icons.expand_more),
                      ],
                    ),
                    children: [
                      ListTile(
                        leading: Text(
                          "Description:",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        title: TextField(
                          controller: option.descriptionController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          maxLength: 255,
                        ),
                      ),
                      ListTile(
                        leading: Text(
                          "Image:",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        title: TextField(
                          controller: option.imagePathController,
                          readOnly: true,
                          decoration: InputDecoration(
                            suffix: IconButton(
                              onPressed: () => setState(() => option.imagePathController = TextEditingController()),
                              icon: const Icon(Icons.backspace_outlined),
                            ),
                          ),
                        ),
                        trailing: IconButton.outlined(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              dialogTitle: "Pick image file for option: \"${option.nameController.text}\"",
                              type: FileType.image,
                              lockParentWindow: true,
                            );
                            if (result == null) return;
                            setState(() => option.imagePathController = TextEditingController(text: result.files[0].path!));
                          },
                          icon: const Icon(Icons.folder_open),
                        ),
                      ),
                      ListTile(
                        leading: Text(
                          "Include:",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Active",
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            Checkbox(
                              value: option.activeIncludes,
                              onChanged: (value) => setState(() => option.activeIncludes = value ?? false),
                            ),
                          ],
                        ),
                        title: Row(
                          children: [
                            if (option.includeError != null)
                              Text(
                                option.includeError!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            Spacer(),
                            if (option.activeIncludes)
                              IconButton(
                                onPressed: () async {
                                  final result = await FilePicker.platform.pickFiles(
                                    allowMultiple: true,
                                    dialogTitle: "Pick patch files to include in option: \"${option.nameController.text}\"",
                                    type: FileType.any,
                                    lockParentWindow: true,
                                  );
                                  if (result == null) return;
                                  final files = result.files
                                    .where((file) {
                                      if (file.path == null) return false;
                                      final name = path.basename(file.path!);
                                      return _patchFileRegex.hasMatch(name);
                                    })
                                    .map((file) => File(file.path!));
                                  setState(() {
                                    option.includeFiles.addAll(files);
                                    if (option.includeFiles.isEmpty && option.subOptions.isEmpty) {
                                      option.includeError = "This option needs to include files or have some sub-options!";
                                    } else {
                                      option.includeError = null;
                                    }
                                  });
                                },
                                icon: const Icon(Icons.add),
                              ),
                          ],
                        ),
                        isThreeLine: option.activeIncludes,
                        subtitle: option.activeIncludes
                          ? Container(
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).dividerColor),
                            ),
                            child: ListView.builder(
                              itemCount: option.includeFiles.length,
                              itemBuilder: (context, index) {
                                final file = option.includeFiles[index];
                                return ListTile(
                                  title: Text(path.basename(file.path)),
                                  trailing: IconButton(
                                    onPressed: () => setState(() {
                                      option.includeFiles.remove(file);
                                      if (option.includeFiles.isEmpty && option.subOptions.isEmpty) {
                                        option.includeError = "This option needs to include files or have some sub-options!";
                                      } else {
                                        option.includeError = null;
                                      }
                                    }),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                );
                              },
                            ),
                          )
                          : null,
                      ),
                      Row(
                        children: [
                          Text(
                            "Sub-options:",
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () => setState(() {
                              option.subOptions.add(_SubOptionState());
                              if (option.includeFiles.isEmpty && option.subOptions.isEmpty) {
                                option.includeError = "This option needs to include files or have some sub-options!";
                              } else {
                                option.includeError = null;
                              }
                            }),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      ...option.subOptions
                        .asMap()
                        .entries
                        .map((entry) {
                          final index = entry.key;
                          final sub = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(left: 50),
                            child: ExpansionTile(
                              key: ObjectKey(sub),
                              initiallyExpanded: sub.expanded,
                              onExpansionChanged: (value) => sub.expanded = value,
                              leading: Text(
                                "Name:",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              title: TextField(
                                controller: sub.nameController,
                                decoration: InputDecoration(
                                  errorText: sub.nameError,
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  value = value.trim();
                                  if (value.isEmpty) {
                                    setState(() => sub.nameError = "Name can not be empty!");
                                    return;
                                  }
                                  setState(() => sub.nameError = null);
                                },
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 3,
                                children: [
                                  MenuAnchor(
                                    builder: (context, controller, child) => IconButton(
                                      onPressed: () => controller.isOpen
                                        ? controller.close()
                                        : controller.open(),
                                      icon: const Icon(Icons.more_vert)
                                    ),
                                    menuChildren: [
                                      MenuItemButton(
                                        onPressed: index > 0
                                          ? () => setState(() {
                                            option.subOptions.remove(sub);
                                            option.subOptions.insert(index - 1, sub);
                                          })
                                          : null,
                                        trailingIcon: const Icon(Icons.arrow_upward),
                                        child: Text("Move up"),
                                      ),
                                      MenuItemButton(
                                        onPressed: index < option.subOptions.length - 1
                                          ? () => setState(() {
                                            option.subOptions.remove(sub);
                                            option.subOptions.insert(index + 1, sub);
                                          })
                                          : null,
                                        trailingIcon: const Icon(Icons.arrow_downward),
                                        child: Text("Move down"),
                                      ),
                                      MenuItemButton(
                                        onPressed: () => setState(() {
                                          option.subOptions.remove(sub);
                                          if (option.includeFiles.isEmpty && option.subOptions.isEmpty) {
                                            option.includeError = "This option needs to include files or have some sub-options!";
                                          } else {
                                            option.includeError = null;
                                          }
                                        }),
                                        trailingIcon: const Icon(Icons.delete_outline),
                                        child: Text("Remove"),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.expand_more),
                                ],
                              ),
                              children: [
                                ListTile(
                                  leading: Text(
                                    "Description:",
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  title: TextField(
                                    controller: sub.descriptionController,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLength: 255,
                                  ),
                                ),
                                ListTile(
                                  leading: Text(
                                    "Image:",
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  title: TextField(
                                    controller: sub.imagePathController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      suffix: IconButton(
                                        onPressed: () => setState(() => sub.imagePathController = TextEditingController()),
                                        icon: const Icon(Icons.backspace_outlined),
                                      ),
                                    ),
                                  ),
                                  trailing: IconButton.outlined(
                                    onPressed: () async {
                                      final result = await FilePicker.platform.pickFiles(
                                        dialogTitle: "Pick image file for option: \"${sub.nameController.text}\"",
                                        type: FileType.image,
                                        lockParentWindow: true,
                                      );
                                      if (result == null) return;
                                      setState(() => sub.imagePathController = TextEditingController(text: result.files[0].path!));
                                    },
                                    icon: const Icon(Icons.folder_open),
                                  ),
                                ),
                                ListTile(
                                  leading: Text(
                                    "Include:",
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  title: Row(
                                    children: [
                                      if (sub.includeError != null)
                                        Text(
                                          sub.includeError!,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.error,
                                          ),
                                        ),
                                      Spacer(),
                                      IconButton(
                                        onPressed: () async {
                                          final result = await FilePicker.platform.pickFiles(
                                            allowMultiple: true,
                                            dialogTitle: "Pick patch files to include in option: \"${sub.nameController.text}\"",
                                            type: FileType.any,
                                            lockParentWindow: true,
                                          );
                                          if (result == null) return;
                                          final files = result.files
                                            .where((file) {
                                              if (file.path == null) return false;
                                              final name = path.basename(file.path!);
                                              return _patchFileRegex.hasMatch(name);
                                            })
                                            .map((file) => File(file.path!));
                                          setState(() {
                                            sub.includeFiles.addAll(files);
                                            if (sub.includeFiles.isEmpty) {
                                              sub.includeError = "This sub-option needs to include files!";
                                            } else {
                                              sub.includeError = null;
                                            }
                                          });
                                        },
                                        icon: const Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                  subtitle: Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Theme.of(context).dividerColor),
                                    ),
                                    child: ListView.builder(
                                      itemCount: sub.includeFiles.length,
                                      itemBuilder: (context, index) {
                                        final file = sub.includeFiles[index];
                                        return ListTile(
                                          title: Text(path.basename(file.path)),
                                          trailing: IconButton(
                                            onPressed: () => setState(() {
                                              sub.includeFiles.remove(file);
                                              if (sub.includeFiles.isEmpty) {
                                                sub.includeError = "This sub-option needs to include files!";
                                              } else {
                                                sub.includeError = null;
                                              }
                                            }),
                                            icon: const Icon(Icons.delete_outline),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  );
                }),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => setState(() => _options.add(_OptionState())),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          spacing: 5,
          children: [
            TextButton.icon(
              onPressed: _back,
              icon: const Icon(Icons.arrow_back),
              label: Text("Back"),
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: _preview,
              icon: const Icon(Icons.remove_red_eye),
              label: Text("Preview"),
            ),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.open_in_browser),
              label: Text("Load"),
            ),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text("Save"),
            ),
            Spacer(),
            FilledButton.icon(
              onPressed: _compile,
              icon: const Icon(Icons.build),
              label: Text("Compile"),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _back() async {
    if (await showConfirmDialog(
      context,
      title: "Go back?",
      question: "All progress will be lost!",
    )) {
      Navigator.pop(context);
    }
  }

  Future<void> _preview() async {

  }

  Future<void> _load() async {
    
  }

  Future<void> _save() async {

  }

  Future<void> _compile() async {

  }
}