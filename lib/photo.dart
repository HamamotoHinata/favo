//モデル
class Photo {
  Photo({
    this.id,
    this.imageURL,
    this.imagePath,
    this.isFavorite,
    this.createdAt,
  });

  final String id;
  final String imageURL;
  final String imagePath;
  final bool isFavorite;
  final DateTime createdAt;

  Photo toggleIsFavorite() {
    return Photo(
      id: id,
      imageURL: imageURL,
      imagePath: imagePath,
      isFavorite: !isFavorite,
      createdAt: createdAt,
    );
  }
}
