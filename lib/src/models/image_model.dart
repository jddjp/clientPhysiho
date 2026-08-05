
class ImageModel {
  String path;
  String url;

  ImageModel({String? path, String? url})
      : path = path ?? '',
        url = url ?? '';

  ImageModel.fromJSON(Map<String, dynamic> json)
      : path = (json['path'] ?? '').toString(),
        url = (json['url'] ?? '').toString();

  @override
  String toString() => 'ImageModel(path: $path, url: $url)';
}