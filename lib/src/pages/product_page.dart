import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:products_dashboard/src/models/product_model.dart';
import 'package:products_dashboard/src/providers/products_provider.dart';
import 'package:products_dashboard/src/utils/utils.dart' as utils;

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  ProductModel product = ProductModel();
  final productsProvider = ProductsProvider();
  File? photoFile;

  @override
  Widget build(BuildContext context) {
    final prodArg = ModalRoute.of(context)?.settings.arguments;
    if (prodArg != null) {
      product = prodArg as ProductModel;
    }
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Product Page'),
        actions: [
          IconButton(
            onPressed: () => _proccessImage(ImageSource.gallery),
            icon: const Icon(Icons.image),
          ),
          IconButton(
            onPressed: () => _proccessImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: Form(
              key: formKey,
              child: Column(
                children: [
                  _showPhoto(),
                  _fieldProductName(),
                  _fieldPrice(),
                  _switchAvailable(),
                  const SizedBox(height: 20.0),
                  _buttonSave(context),
                ],
              )),
        ),
      ),
    );
  }

  ElevatedButton _buttonSave(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        if (formKey.currentState != null && formKey.currentState!.validate()) {
          formKey.currentState!.save();
          print(
              'All is ok: ${product.title} - ${product.value} - ${product.available}');

          if (photoFile != null) {
            product.photoUrl =
                await productsProvider.uploadImage(photoFile!) ?? '';
          } else {
            print('No image to upload');
          }

          if (product.id != null) {
            productsProvider.updateProduct(product);
          } else {
            productsProvider.createProduct(product);
          }

          if (!mounted) {
            return;
          }

          ScaffoldMessenger.of(context)
              .showSnackBar(utils.buildSnackbar('Product saved, go back...'));
          Future.delayed(const Duration(milliseconds: 2000), () {
            Navigator.pop(context);
          });
        }
      },
      icon: const Icon(Icons.save),
      label: const Text('Save'),
    );
  }

  Widget _showPhoto() {
    if (product.photoUrl.isNotEmpty) {
      return FadeInImage(
        placeholder: const AssetImage('assets/jar-loading.gif'),
        image: NetworkImage(product.photoUrl),
        height: 300.0,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Image(
        image: AssetImage(photoFile?.path ?? 'assets/no-image.png'),
        height: 300.0,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _switchAvailable() {
    return SwitchListTile.adaptive(
      title: const Text('Available'),
      value: product.available,
      onChanged: (value) {
        setState(() {
          product.available = value;
        });
      },
    );
  }

  Widget _fieldPrice() {
    return TextFormField(
      initialValue: product.value.toString(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Product Price',
      ),
      onSaved: (newValue) {
        product.value = double.parse(newValue ?? '0.0');
      },
      validator: (value) {
        if (value != null && !utils.isNumber(value)) {
          return 'Only numbers are allowed';
        }
        return null;
      },
    );
  }

  Widget _fieldProductName() {
    return TextFormField(
      initialValue: product.title,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Product Name',
      ),
      onSaved: (newValue) {
        product.title = newValue ?? '';
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Product Name is required';
        }
        return null;
      },
    );
  }

  void _proccessImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      photoFile = File(pickedFile.path);
      product.photoUrl = '';
    }
    setState(() {});
  }
}
