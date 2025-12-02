class QwenConfig {
  final int dim;
  final double ffnDimMultiplier;
  final int hiddenDim;
  final int nHeads;
  final int headDim;
  final int nKvHeads;
  final int nLayers;
  final double normEps;
  final double ropeTheta;
  final bool useScaledRope;
  final int vocabSize;
  final bool useHfRope;
  final bool attentionQkvBias;
  final bool useQkNorm;

  const QwenConfig({
    required this.dim,
    required this.ffnDimMultiplier,
    required this.hiddenDim,
    required this.nHeads,
    required this.headDim,
    required this.nKvHeads,
    required this.nLayers,
    required this.normEps,
    required this.ropeTheta,
    required this.useScaledRope,
    required this.vocabSize,
    required this.useHfRope,
    required this.attentionQkvBias,
    required this.useQkNorm,
  });

  factory QwenConfig.fromJson(Map<String, dynamic> json) {
    return QwenConfig(
      dim: json['dim'] as int,
      ffnDimMultiplier: (json['ffn_dim_multiplier'] as num).toDouble(),
      hiddenDim: json['hidden_dim'] as int,
      nHeads: json['n_heads'] as int,
      headDim: json['head_dim'] as int,
      nKvHeads: json['n_kv_heads'] as int,
      nLayers: json['n_layers'] as int,
      normEps: (json['norm_eps'] as num).toDouble(),
      ropeTheta: (json['rope_theta'] as num).toDouble(),
      useScaledRope: json['use_scaled_rope'] as bool,
      vocabSize: json['vocab_size'] as int,
      useHfRope: json['use_hf_rope'] as bool,
      attentionQkvBias: json['attention_qkv_bias'] as bool,
      useQkNorm: json['use_qk_norm'] as bool,
    );
  }
}