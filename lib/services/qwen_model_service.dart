import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:executorch_flutter/executorch_flutter.dart';
import '../models/qwen_config.dart';

class QwenModelService {
  ExecuTorchModel? _model;
  QwenConfig? _config;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      print('Loading Qwen model...');
      
      // Load config
      final configData = await rootBundle.loadString('assets/models/qwen_config.json');
      _config = QwenConfig.fromJson(json.decode(configData));
      print('Config loaded: vocab_size=${_config!.vocabSize}');

      // Load model from assets to temporary file
      final modelData = await rootBundle.load('assets/models/qwen.pte');
      final tempDir = await getTemporaryDirectory();
      final modelFile = File('${tempDir.path}/qwen.pte');
      
      print('Copying model to temporary directory...');
      await modelFile.writeAsBytes(modelData.buffer.asUint8List());
      
      print('Loading ExecuTorch model...');
      _model = await ExecuTorchModel.load(modelFile.path);
      
      _isInitialized = true;
      print('Qwen model initialized successfully!');
    } catch (e, stackTrace) {
      print('Error initializing Qwen model: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<String> generateResponse(String prompt) async {
    if (!_isInitialized || _model == null) {
      throw Exception('Model not initialized');
    }

    try {
      print('Generating response for: $prompt');
      
      // Simple tokenization (this is a placeholder - real tokenization needed)
      final tokens = _tokenizeSimple(prompt);
      print('Tokenized input: ${tokens.take(10)}...');

      // Prepare input tensor
      final inputTensor = TensorData(
        shape: [1, tokens.length],
        dataType: TensorType.int32,
        data: _int32ListToBytes(tokens),
      );

      // Run inference
      print('Running inference...');
      final outputs = await _model!.forward([inputTensor]);
      
      if (outputs.isEmpty) {
        throw Exception('No output from model');
      }

      print('Got ${outputs.length} outputs');
      final output = outputs.first;
      print('Output shape: ${output.shape}');
      
      // Simple detokenization (placeholder)
      final response = _detokenizeSimple(output);
      
      return response;
    } catch (e, stackTrace) {
      print('Error during inference: $e');
      print('Stack trace: $stackTrace');
      return 'Error: $e';
    }
  }

  // Placeholder tokenization - converts text to simple token IDs
  List<int> _tokenizeSimple(String text) {
    // This is a very basic tokenization for testing
    // In reality, you'd need proper tokenization matching the model
    final bytes = utf8.encode(text);
    return bytes.map((b) => b % (_config?.vocabSize ?? 32000)).toList();
  }

  // Placeholder detokenization 
  String _detokenizeSimple(TensorData output) {
    try {
      // Extract first few tokens as a simple response
      final bytes = output.data;
      if (bytes.length >= 4) {
        final firstToken = ByteData.sublistView(bytes, 0, 4).getInt32(0, Endian.little);
        return "Model response (token: $firstToken) - Tokenization needs implementation";
      }
      return "Generated response - Need proper tokenizer";
    } catch (e) {
      return "Response generated - Detokenization needs implementation: $e";
    }
  }

  Uint8List _int32ListToBytes(List<int> ints) {
    final byteData = ByteData(ints.length * 4);
    for (int i = 0; i < ints.length; i++) {
      byteData.setInt32(i * 4, ints[i], Endian.little);
    }
    return byteData.buffer.asUint8List();
  }

  Future<void> dispose() async {
    if (_model != null) {
      await _model!.dispose();
      _model = null;
    }
    _isInitialized = false;
  }
}