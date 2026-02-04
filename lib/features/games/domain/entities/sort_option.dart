/// Available sort options for the games list
enum SortOption {
  size('Size'),
  name('Name'),
  source('Source');

  const SortOption(this.label);
  final String label;
}
