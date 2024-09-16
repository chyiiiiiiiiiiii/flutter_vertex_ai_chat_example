import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:vertex_ai_example/firebase_options.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final initializeFirebaseFuture =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Vertex AI & Chat'),
      ),
      body: FutureBuilder(
        future: initializeFirebaseFuture,
        builder: (context, snapshot) {
          return switch (snapshot.connectionState) {
            ConnectionState.done => const _ChatBody(),
            ConnectionState.none => const Text('Firebase初始化失敗'),
            _ => const CircularProgressIndicator(),
          };
        },
      ),
    );
  }
}

class _ChatBody extends StatefulWidget {
  const _ChatBody({
    super.key,
  });

  @override
  State<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<_ChatBody> {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _promptTextController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();

  final List<({int number, Image? image, String? text, bool fromUser})>
      _generatedContent =
      <({int number, Image? image, String? text, bool fromUser})>[];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-1.5-pro',
    );
    _chat = _model.startChat();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    if (message.isEmpty) {
      _showMessage(message: '請輸入 Prompt');

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      int messageNumber = _generatedContent.length;
      _generatedContent.add(
          (number: messageNumber, image: null, text: message, fromUser: true));
      _scrollDown();

      messageNumber = _generatedContent.length;
      final response = _chat.sendMessageStream(
        Content.text(message),
      );
      await for (final chunk in response) {
        final text = chunk.text ?? '';

        final lastContent = _generatedContent.isNotEmpty
            ? _generatedContent
                .where((element) => element.number == messageNumber)
                .lastOrNull
            : null;
        _generatedContent.remove(lastContent);

        final lastText = (lastContent?.text ?? '') + text;

        setState(() {
          _generatedContent.add((
            number: messageNumber,
            image: lastContent?.image,
            text: lastText,
            fromUser: false
          ));
          _scrollDown();
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _showMessage(message: e.toString(), isError: true);
      setState(() {
        _isLoading = false;
      });
    } finally {
      _promptTextController.clear();
      setState(() {
        _isLoading = false;
      });
      _textFieldFocus.requestFocus();
    }
  }

  Future<void> _sendImagePrompt(String message) async {
    if (message.isEmpty) {
      _showMessage(message: '請輸入 Prompt');

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      ByteData imageBytes = await rootBundle.load('assets/images/ramen.jpg');
      final content = Content.multi([
        TextPart(message),
        // The only accepted mime types are image/*.
        DataPart('image/jpeg', imageBytes.buffer.asUint8List()),
      ]);

      int messageNumber = _generatedContent.length;
      setState(() {
        _generatedContent.add(
          (
            number: messageNumber,
            image: Image.asset('assets/images/ramen.jpg'),
            text: message,
            fromUser: true
          ),
        );
        _scrollDown();
      });

      messageNumber = _generatedContent.length;
      final response = _chat.sendMessageStream(content);
      await for (final chunk in response) {
        final text = chunk.text ?? '';

        final lastContent = _generatedContent.isNotEmpty
            ? _generatedContent
                .where((element) => element.number == messageNumber)
                .lastOrNull
            : null;
        _generatedContent.remove(lastContent);

        final lastText = (lastContent?.text ?? '') + text;

        setState(() {
          _generatedContent.add((
            number: messageNumber,
            image: lastContent?.image,
            text: lastText,
            fromUser: false
          ));
          _scrollDown();
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _showMessage(message: e.toString(), isError: true);
      setState(() {
        _isLoading = false;
      });
    } finally {
      _promptTextController.clear();
      setState(() {
        _isLoading = false;
      });
      _textFieldFocus.requestFocus();
    }
  }

  Future<void> _getPromptToken() async {
    final prompt = _promptTextController.text;
    if (prompt.isEmpty) {
      _showMessage(message: '請輸入 Prompt');

      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await _model.countTokens(
      [Content.text(prompt)],
    );
    _showMessage(
      message:
          '消耗token: ${response.totalTokens}\n計費character: ${response.totalBillableCharacters}',
    );

    setState(() {
      _isLoading = false;
    });
  }

  void _showMessage({
    required String message,
    bool isError = false,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isError ? '錯誤' : '訊息'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _promptTextController.dispose();
    _textFieldFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _MessageListView(
                scrollController: _scrollController,
                generatedContent: _generatedContent),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    focusNode: _textFieldFocus,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(15),
                      hintText: '輸入 prompt...',
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(14),
                        ),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(14),
                        ),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    controller: _promptTextController,
                    onSubmitted: _sendChatMessage,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                if (!_isLoading)
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await _getPromptToken();
                        },
                        icon: Icon(
                          Icons.numbers,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await _sendImagePrompt(_promptTextController.text);
                        },
                        icon: Icon(
                          Icons.image,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await _sendChatMessage(_promptTextController.text);
                        },
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    ],
                  )
                else
                  const CircularProgressIndicator()
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageListView extends StatelessWidget {
  const _MessageListView({
    super.key,
    required ScrollController scrollController,
    required List<({bool fromUser, Image? image, int number, String? text})>
        generatedContent,
  })  : _scrollController = scrollController,
        _generatedContent = generatedContent;

  final ScrollController _scrollController;
  final List<({bool fromUser, Image? image, int number, String? text})>
      _generatedContent;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemBuilder: (context, index) {
        final content = _generatedContent[index];

        return _MessageWidget(
          text: content.text,
          image: content.image,
          isFromUser: content.fromUser,
        );
      },
      itemCount: _generatedContent.length,
    );
  }
}

class _MessageWidget extends StatelessWidget {
  final Image? image;
  final String? text;
  final bool isFromUser;

  const _MessageWidget({
    super.key,
    this.image,
    this.text,
    required this.isFromUser,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(
              left: isFromUser ? 40 : 0,
              right: isFromUser ? 0 : 40,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: isFromUser
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 20,
              ),
              margin: const EdgeInsets.only(bottom: 8),
              child: switch ((text, image)) {
                (final text?, final image?) => Column(
                    crossAxisAlignment: isFromUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: image,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      MarkdownBody(data: text)
                    ],
                  ),
                (final text?, _) => MarkdownBody(data: text),
                (_, final image?) => ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: image,
                  ),
                _ => const SizedBox.shrink()
              },
            ),
          ),
        ),
      ],
    );
  }
}
