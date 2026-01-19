/// List of fun phrases to display during loading
class FunPhrases {
  static const List<String> loadingPhrases = [
    '🎮 Hunting down those hefty games...',
    '🔍 Scanning your digital collection...',
    '⏳ Measuring your gaming empire...',
    '🧹 Dusting off the virtual shelves...',
    '💾 Counting every single byte...',
    '🚀 preparing for launch (or uninstall)...',
    '🐧 Linux magic in progress...',
    '🎩 Pulling rabbits out of proton prefixes...',
    '📦 Unpacking metadata crates...',
    '🕵️‍♂️ Detecting hidden giants...',
    '🎪 Juggling game libraries...',
    '⚡ Powering up the flux capacitor...',
    '🤖 Beep boop, calculating sizes...',
    '🍕 Analyzing storage usage (and ordering pizza)...',
    '🔧 Tightening the graphics bolts...',
    '📂 Organizing your chaos...',
    '🏃‍♂️ Running at 88mph...',
    '🧊 Cooling down the Steam Deck...',
    '🌌 Exploring the storage galaxy...',
    '🎲 Rolling for initiative...',
  ];

  /// Get a random phrase
  static String getRandom() => (loadingPhrases..shuffle()).first;
}
