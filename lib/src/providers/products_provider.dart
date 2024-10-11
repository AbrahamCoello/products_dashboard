import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:products_dashboard/src/models/product_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ProductsProvider {
  final String _urlBase =
      'https://flutter-test-applications-default-rtdb.firebaseio.com';

  Future<bool> createProduct(ProductModel product) async {
    final url = '$_urlBase/products.json';
    final response =
        await http.post(Uri.parse(url), body: productModelToJson(product));
    final decodedData = json.decode(response.body);
    print(decodedData);
    return true;
  }

  Future<List<ProductModel>> loadProducts() async {
    final url = '$_urlBase/products.json';
    final response = await http.get(Uri.parse(url));
    final Map<String, dynamic> decodedData = json.decode(response.body);

    if (decodedData.keys.isEmpty) return [];

    final List<ProductModel> products = [];
    decodedData.forEach((key, value) {
      final product = ProductModel.fromJson(value);
      product.id = key;
      products.add(product);
    });
    return products;
  }

  Future<bool> deleteProduct(String id) async {
    final url = '$_urlBase/products/$id.json';
    final response = await http.delete(Uri.parse(url));
    final decodedData = json.decode(response.body);
    print('- Deleted: $decodedData');
    return true;
  }

  Future<bool> updateProduct(ProductModel product) async {
    final url = '$_urlBase/products/${product.id}.json';
    final response =
        await http.put(Uri.parse(url), body: productModelToJson(product));
    final decodedData = json.decode(response.body);
    print('- Updated: $decodedData');
    return true;
  }

  Future<String?> uploadImage(File image) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dmjmqazps/image/upload?upload_preset=dsekikoc');
    final mimeType = lookupMimeType(image.path)?.split('/');
    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', image.path,
        contentType: MediaType(mimeType![0], mimeType[1]));

    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final response = await http.Response.fromStream(streamResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Error to upload image: ${response.body}');
      return null;
    }

    final responseDecoded = json.decode(response.body);

    return responseDecoded['secure_url'];
  }
}
