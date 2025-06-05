import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:json5/json5.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:archive/archive_io.dart';

import '../helpers/dialog.dart';
import '../helpers/file_converter.dart';
import '../helpers/text_converter.dart';
import '../models/mod_manifest.dart';

part 'create.g.dart';

@JsonSerializable(
  checked: true,
  disallowUnrecognizedKeys: true,
)
final class _SubOptionState {
  bool expanded;
  @TextEditingControllerConverter()
  final TextEditingController nameController;
  String? nameError;
  @TextEditingControllerConverter()
  final TextEditingController descriptionController;
  @TextEditingControllerConverter()
  TextEditingController imagePathController;
  String? includeError;
  @FileConverter()
  final List<File> includeFiles;

  _SubOptionState(
    this.expanded,
    this.nameController,
    this.nameError,
    this.descriptionController,
    this.imagePathController,
    this.includeError,
    this.includeFiles,
  );

  _SubOptionState.empty()
    : expanded = false,
    nameController = TextEditingController(),
    nameError = "Name can not be empty!",
    descriptionController = TextEditingController(),
    imagePathController = TextEditingController(),
    includeError = "This sub-option needs to include files!",
    includeFiles = <File>[];
  
  factory _SubOptionState.fromJson(Map<String, dynamic> json) => _$SubOptionStateFromJson(json);

  Map<String, dynamic> toJson() => _$SubOptionStateToJson(this);
}

@JsonSerializable(
  checked: true,
  disallowUnrecognizedKeys: true,
)
final class _OptionState {
  bool expanded;
  @TextEditingControllerConverter()
  final TextEditingController nameController;
  String? nameError;
  @TextEditingControllerConverter()
  final TextEditingController descriptionController;
  @TextEditingControllerConverter()
  TextEditingController imagePathController;
  bool activeIncludes;
  String? includeError;
  @FileConverter()
  final List<File> includeFiles;
  final List<_SubOptionState> subOptions;

  _OptionState(
    this.expanded,
    this.nameController,
    this.nameError,
    this.descriptionController,
    this.imagePathController,
    this.activeIncludes,
    this.includeError,
    this.includeFiles,
    this.subOptions,
  );

  _OptionState.empty()
    : expanded = false,
    nameController = TextEditingController(),
    nameError = "Name can not be empty!",
    descriptionController = TextEditingController(),
    imagePathController = TextEditingController(),
    activeIncludes = false,
    includeError = "This option needs to include files or have some sub-options!",
    includeFiles = <File>[],
    subOptions = <_SubOptionState>[];
  
  factory _OptionState.fromJson(Map<String, dynamic> json) => _$OptionStateFromJson(json);

  Map<String, dynamic> toJson() => _$OptionStateToJson(this);
}

@JsonSerializable(
  checked: true,
  disallowUnrecognizedKeys: true,
)
final class _ModProject {
  @TextEditingControllerConverter()
  TextEditingController guidController;
  String? guidError;
  @TextEditingControllerConverter()
  final TextEditingController nameController;
  String? nameError;
  @TextEditingControllerConverter()
  final TextEditingController descriptionController;
  @TextEditingControllerConverter()
  TextEditingController iconPathController;
  final List<_OptionState> options;

  _ModProject(
    this.guidController,
    this.guidError,
    this.nameController,
    this.nameError,
    this.descriptionController,
    this.iconPathController,
    this.options,
  );

  _ModProject.empty()
    : guidController = TextEditingController(),
    guidError = "GUID can not be empty!",
    nameController = TextEditingController(),
    nameError = "Name can not be empty!",
    descriptionController = TextEditingController(),
    iconPathController = TextEditingController(),
    options = <_OptionState>[];
  
  factory _ModProject.fromJson(Map<String, dynamic> json) => _$ModProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ModProjectToJson(this);
}

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  static final _patchFileRegex = RegExp(r"^[a-z0-9]{16}\.patch_[0-9]+(\.(stream|gpu_resources))?$");
  static final _nameRegex = RegExp(r"[A-Za-z0-9._\- ()]+");
  final _log = Logger("CreatePage");
  var _mod = _ModProject.empty();

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
                  controller: _mod.guidController,
                  decoration: InputDecoration(
                    errorText: _mod.guidError,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() => _mod.guidError = "GUID can not be empty!");
                      return;
                    }
                    try {
                      UuidValue.withValidation(value);
                    } on FormatException {
                      setState(() => _mod.guidError = "GUID is invalid!");
                      return;
                    } catch (ex) {
                      _mod.guidError = ex.toString();
                      return;
                    }
                    setState(() => _mod.guidError = null);
                  },
                ),
                trailing: IconButton.outlined(
                  onPressed: () => setState(() {
                    _mod.guidController = TextEditingController(text: Uuid().v4());
                    _mod.guidError = null;
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
                  controller: _mod.nameController,
                  decoration: InputDecoration(
                    errorText: _mod.nameError,
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(_nameRegex),
                  ],
                  onChanged: (value) {
                    value = value.trim();
                    if (value.isEmpty) {
                      setState(() => _mod.nameError = "Name can not be empty!");
                      return;
                    }
                    setState(() => _mod.nameError = null);
                  },
                ),
              ),
              ListTile(
                leading: Text(
                  "Description:",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                title: TextField(
                  controller: _mod.descriptionController,
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
                title: Row(
                  spacing: 5,
                  children: [
                    if (_mod.iconPathController.text.isNotEmpty)
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.file(
                          File(_mod.iconPathController.text),
                          fit: BoxFit.contain,
                        ),
                      ),
                    Expanded(
                      child: TextField(
                        controller: _mod.iconPathController,
                        readOnly: true,
                        decoration: InputDecoration(
                          suffix: IconButton(
                            onPressed: () => setState(() => _mod.iconPathController = TextEditingController()),
                            icon: const Icon(Icons.backspace_outlined),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: IconButton.outlined(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      dialogTitle: "Pick icon file",
                      type: FileType.image,
                      lockParentWindow: true,
                    );
                    if (result == null) return;
                    setState(() => _mod.iconPathController = TextEditingController(text: result.files[0].path!));
                  },
                  icon: const Icon(Icons.folder_open),
                ),
              ),
              Divider(),
              Text(
                "Options:",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ..._mod.options
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return ExpansionTile(
                    key: ObjectKey(option),
                    initiallyExpanded: option.expanded,
                    onExpansionChanged: (value) => setState(() => option.expanded = value),
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
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(_nameRegex),
                      ],
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
                                  _mod.options.remove(option);
                                  _mod.options.insert(index - 1, option);
                                })
                                : null,
                              trailingIcon: const Icon(Icons.arrow_upward),
                              child: Text("Move up"),
                            ),
                            MenuItemButton(
                              onPressed: index < _mod.options.length - 1
                                ? () => setState(() {
                                  _mod.options.remove(option);
                                  _mod.options.insert(index + 1, option);
                                })
                                : null,
                              trailingIcon: const Icon(Icons.arrow_downward),
                              child: Text("Move down"),
                            ),
                            MenuItemButton(
                              onPressed: () => setState(() => _mod.options.remove(option)),
                              trailingIcon: const Icon(Icons.delete_outline),
                              child: Text("Remove"),
                            ),
                          ],
                        ),
                        if(option.expanded)
                          const Icon(Icons.expand_less)
                        else
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
                        title: Row(
                          children: [
                            if (option.imagePathController.text.isNotEmpty)
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: Image.file(
                                  File(option.imagePathController.text),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            Expanded(
                              child: TextField(
                                controller: option.imagePathController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  suffix: IconButton(
                                    onPressed: () => setState(() => option.imagePathController = TextEditingController()),
                                    icon: const Icon(Icons.backspace_outlined),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                          TextButton.icon(
                            onPressed: () => setState(() {
                              option.subOptions.add(_SubOptionState.empty());
                              if (option.includeFiles.isEmpty && option.subOptions.isEmpty) {
                                option.includeError = "This option needs to include files or have some sub-options!";
                              } else {
                                option.includeError = null;
                              }
                            }),
                            icon: const Icon(Icons.add),
                            label: Text("Add Sub-Option"),
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
                              onExpansionChanged: (value) => setState(() => sub.expanded = value),
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
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(_nameRegex),
                                ],
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
                                  if (sub.expanded)
                                    const Icon(Icons.expand_less)
                                  else
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
                                  title: Row(
                                    children: [
                                      if (sub.imagePathController.text.isNotEmpty)
                                        SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: Image.file(
                                            File(sub.imagePathController.text),
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      Expanded(
                                        child: TextField(
                                          controller: sub.imagePathController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            suffix: IconButton(
                                              onPressed: () => setState(() => sub.imagePathController = TextEditingController()),
                                              icon: const Icon(Icons.backspace_outlined),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
                  TextButton.icon(
                    onPressed: () => setState(() => _mod.options.add(_OptionState.empty())),
                    icon: const Icon(Icons.add),
                    label: Text("Add Option"),
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
              onPressed: null, //_preview,
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
    //TODO: preview
  }

  Future<void> _load() async {
    if (!await showConfirmDialog(
      context,
      title: "Load?",
      question: "All current progress will be lost!",
    )) {
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: const [ "mm2proj" ],
      dialogTitle: "Load project",
      lockParentWindow: true,
      type: FileType.custom,
    );

    final fileName = result?.files[0].path;
    if (fileName == null) return;

    showWaitDialog(
      context,
      title: "Loading",
    );
    
    final content = await File(fileName).readAsString();
    final json = json5Decode(content) as Map<String, dynamic>;
    final project = _ModProject.fromJson(json);

    setState(() => _mod = project);

    closeDialog(context);
  }

  Future<void> _save() async {
    var result = await FilePicker.platform.saveFile(
      allowedExtensions: const [ "mm2proj" ],
      dialogTitle: "Save project",
      lockParentWindow: true,
      type: FileType.custom,
    );
    if (result == null) return;

    showWaitDialog(
      context,
      title: "Saving",
    );

    if (path.extension(result) != ".mm2proj") {
      result += ".mm2proj";
    }
    
    final json = _mod.toJson();
    final content = jsonEncode(json);
    await File(result).writeAsString(content);

    closeDialog(context);
  }

  Future<void> _compile() async {
    final error = _check();
    if (error != null) {
      showNotificationDialog(
        context,
        text: error,
        type: NotificationType.error,
      );
      return;
    }

    var result = await FilePicker.platform.saveFile(
      allowedExtensions: const [ "zip" ],
      dialogTitle: "Save project",
      lockParentWindow: true,
      type: FileType.custom,
    );
    if (result == null) return;

    showWaitDialog(
      context,
      title: "Compiling",
    );

    if (path.extension(result) != ".zip") {
      result += ".zip";
    }
    
    final tmpPath = path.withoutExtension(result);
    final tmpDir = Directory(tmpPath);
    if (await tmpDir.exists()) await tmpDir.delete(recursive: true);
    await tmpDir.create(recursive: true);

    try {
      String? iconPath;
      final options = <ModOption>[];

      if (_mod.iconPathController.text.isNotEmpty) {
        iconPath = path.basename(_mod.iconPathController.text);
        final iconFile = File(_mod.iconPathController.text);
        await iconFile.copy(path.join(tmpPath, path.basename(iconFile.path)));
      }

      for (final opt in _mod.options) {
        final optName = opt.nameController.text.trim();
        String? optImage;
        final optIncludes = <String>[];
        final subOptions = <ModSubOption>[];

        final optDir = Directory(path.join(tmpPath, optName));
        await optDir.create(recursive: true);
        
        if (opt.imagePathController.text.isNotEmpty) {
          final imageFile = File(opt.imagePathController.text);
          optImage = path.join(optName, path.basename(imageFile.path));
          await imageFile.copy(path.join(tmpPath, optImage));
        }

        if (opt.activeIncludes) {
          for (final incFile in opt.includeFiles) {
            final incPath = path.join(optName);
            await incFile.copy(path.join(tmpPath, incPath, path.basename(incFile.path)));
            optIncludes.add(incPath);
          }
        }

        for (final sub in opt.subOptions) {
          final subName = sub.nameController.text.trim();
          String? subImage;
          final subIncludes = <String>[];

          final subDir = Directory(path.join(tmpPath, optName, subName));
          await subDir.create(recursive: true);

          if (sub.imagePathController.text.isNotEmpty) {
            final imageFile = File(sub.imagePathController.text);
            subImage = path.join(optName, subName, path.basename(imageFile.path));
            await imageFile.copy(path.join(tmpPath, subImage));
          }

          for (final incFile in sub.includeFiles) {
            final incPath = path.join(optName, subName);
            await incFile.copy(path.join(tmpPath, incPath, path.basename(incFile.path)));
            subIncludes.add(incPath);
          }

          subOptions.add(ModSubOption(
            name: subName,
            description: sub.descriptionController.text,
            image: subImage,
            include: subIncludes,
          ));
        }

        options.add(ModOption(
          name: optName,
          description: opt.descriptionController.text,
          image: optImage,
          include: optIncludes.isEmpty ? null : optIncludes,
          subOptions: subOptions.isEmpty ? null : subOptions,
        ));
      }

      final manifest = ModManifestV1(
        guid: UuidValue.withValidation(_mod.guidController.text, ValidationMode.nonStrict),
        name: _mod.nameController.text,
        description: _mod.descriptionController.text,
        iconPath: iconPath,
        options: options.isEmpty ? null : options,
      );

      final json = manifest.toJson();
      final content = jsonEncode(json);
      await File(path.join(tmpPath, "manifest.json")).writeAsString(content);
    } on Exception catch (e) {
      closeDialog(context);
      _log.severe("Compile error!", e);
      showNotificationDialog(
        context,
        text: "Compile error!\n$e",
        type: NotificationType.error,
      );
      return;
    }

    final archive = createArchiveFromDirectory(tmpDir, includeDirName: false);
    final encoder = ZipEncoder();
    final zipData = encoder.encodeBytes(archive);
    await archive.clear();

    await File(result).writeAsBytes(zipData);

    await tmpDir.delete(recursive: true);
    closeDialog(context);

    showNotificationDialog(
      context,
      text: "Compiled successfully!\nMod written to: \"$result\"",
    );
  }

  String? _check() {
    if (_mod.guidError != null) return _mod.guidError;
    if (_mod.nameError != null) return _mod.nameError;
    for (final opt in _mod.options) {
      if (opt.nameError != null) return opt.nameError;
      if (opt.includeError != null) return opt.includeError;
      for (final sub in opt.subOptions) {
        if (sub.nameError != null) return sub.nameError;
        if (sub.includeError != null) return sub.includeError; 
      }
    }
    return null;
  }
}