import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/pdf_service.dart';
import '../services/socket_service.dart';
import '../services/voice_service.dart';

enum ChatMode { ai, document }

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final List<ChatMessage> messages = [];
  final SocketService socketService = SocketService();

  ChatMode mode = ChatMode.ai;
  bool isLoading = false;
  bool isRecording = false;
  bool isDocumentUploading = false;
  bool socketReady = false;
  String? documentName;
  int? aiMessageIndex;
  StreamSubscription? streamSubscription;

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  Future<void> _initSocket() async {
    try {
      await socketService.connect();
      socketReady = true;

      streamSubscription = socketService.stream.listen(
        (message) {
          if (!mounted) return;

          final chunk = message.toString();
          if (chunk == '[END]') {
            setState(() {
              isLoading = false;
              aiMessageIndex = null;
            });
            return;
          }

          setState(() {
            if (aiMessageIndex == null) {
              messages.add(ChatMessage(text: chunk, isUser: false));
              aiMessageIndex = messages.length - 1;
            } else {
              messages[aiMessageIndex!] = ChatMessage(
                text: messages[aiMessageIndex!].text + chunk,
                isUser: false,
              );
            }
          });
        },
        onError: (_) {
          if (!mounted) return;
          setState(() {
            socketReady = false;
            isLoading = false;
            aiMessageIndex = null;
          });
        },
        onDone: () {
          if (!mounted) return;
          setState(() {
            socketReady = false;
            isLoading = false;
            aiMessageIndex = null;
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => socketReady = false);
    }
  }

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty || isLoading) return;

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true));
      isLoading = true;
    });
    controller.clear();

    if (mode == ChatMode.document) {
      await _sendDocumentQuestion(text);
      return;
    }

    if (socketReady) {
      socketService.sendMessage(text);
      return;
    }

    await _sendAiMessageWithHttp(text);
  }

  Future<void> _sendAiMessageWithHttp(String text) async {
    try {
      final response = await ApiService.sendMessage(text);
      if (!mounted) return;
      setState(() {
        messages.add(ChatMessage(text: response, isUser: false));
        isLoading = false;
      });
    } catch (e) {
      _showAssistantError('Chat failed: $e');
    }
  }

  Future<void> _sendDocumentQuestion(String question) async {
    if (documentName == null) {
      _showAssistantError(
        'Upload a PDF first, then ask your document question.',
      );
      return;
    }

    try {
      final answer = await PDFService.askQuestion(question);
      if (!mounted) return;
      setState(() {
        messages.add(ChatMessage(text: answer, isUser: false));
        isLoading = false;
      });
    } catch (e) {
      _showAssistantError('Document chat failed: $e');
    }
  }

  Future<void> pickAndUploadDocument() async {
    if (isDocumentUploading) return;

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    final path = result?.files.single.path;
    if (path == null) return;

    setState(() => isDocumentUploading = true);

    try {
      await PDFService.uploadPDF(File(path));
      if (!mounted) return;
      setState(() {
        documentName = result!.files.single.name;
        mode = ChatMode.document;
        isDocumentUploading = false;
        messages.add(
          ChatMessage(
            text: 'Document added: ${result.files.single.name}',
            isUser: false,
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isDocumentUploading = false);
      _showAssistantError('Document upload failed: $e');
    }
  }

  Future<void> toggleVoiceAssistant() async {
    if (isLoading) return;

    if (!isRecording) {
      final started = await VoiceService.startRecording();
      if (!mounted) return;

      if (!started) {
        _showAssistantError('Microphone permission denied.');
        return;
      }

      setState(() => isRecording = true);
      return;
    }

    await VoiceService.stopRecording();
    if (!mounted) return;

    setState(() {
      isRecording = false;
      isLoading = true;
    });

    final result = await VoiceService.sendVoiceMessage();
    if (!mounted) return;

    if (result.containsKey('error')) {
      _showAssistantError(result['error'].toString());
      return;
    }

    try {
      final data = jsonDecode(result['data'].toString());
      final transcription = data['transcription']?.toString() ?? '';
      final response = data['response']?.toString() ?? '';

      setState(() {
        if (transcription.isNotEmpty) {
          messages.add(ChatMessage(text: transcription, isUser: true));
        }
        if (response.isNotEmpty) {
          messages.add(ChatMessage(text: response, isUser: false));
        }
        isLoading = false;
      });
    } catch (e) {
      _showAssistantError('Voice response could not be read: $e');
    }
  }

  void _showAssistantError(String message) {
    if (!mounted) return;
    setState(() {
      messages.add(ChatMessage(text: message, isUser: false));
      isLoading = false;
      aiMessageIndex = null;
    });
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    socketService.dispose();
    // Keep VoiceService alive. Disposing it can invalidate the recorder.
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HPAI-OS'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                mode == ChatMode.ai ? 'AI' : 'Document',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (documentName != null)
            Material(
              color: Colors.green.withValues(alpha: 0.12),
              child: ListTile(
                dense: true,
                leading: const Icon(
                  Icons.description,
                  color: Colors.greenAccent,
                ),
                title: Text(documentName!, overflow: TextOverflow.ellipsis),
                trailing: const Text('Ready'),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                return Align(
                  alignment: msg.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: msg.isUser
                            ? Colors.blueAccent
                            : Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        msg.text,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      SegmentedButton<ChatMode>(
                        segments: const [
                          ButtonSegment(
                            value: ChatMode.ai,
                            icon: Icon(Icons.psychology),
                            label: Text('AI'),
                          ),
                          ButtonSegment(
                            value: ChatMode.document,
                            icon: Icon(Icons.description),
                            label: Text('Doc'),
                          ),
                        ],
                        selected: {mode},
                        onSelectionChanged: (selection) {
                          setState(() => mode = selection.first);
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: 'Add document',
                        onPressed: isDocumentUploading
                            ? null
                            : pickAndUploadDocument,
                        icon: isDocumentUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.attach_file),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: isRecording
                            ? 'Stop recording'
                            : 'Voice assistant',
                        onPressed: toggleVoiceAssistant,
                        icon: Icon(isRecording ? Icons.stop : Icons.mic),
                        color: isRecording ? Colors.redAccent : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          minLines: 1,
                          maxLines: 4,
                          onSubmitted: (_) => sendMessage(),
                          decoration: InputDecoration(
                            hintText: mode == ChatMode.ai
                                ? 'Ask HPAI-OS...'
                                : 'Ask about the uploaded document...',
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      FloatingActionButton(
                        onPressed: sendMessage,
                        child: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
