import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/provider/product.dart';
import 'package:shop_app/provider/products_provider.dart';

class ProductEditScreen extends StatefulWidget {
  static const routeName = "/edit-screen";
  const ProductEditScreen({Key? key}) : super(key: key);

  @override
  _ProductEditScreenState createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageFocusNode = FocusNode();
  final _imageUrlControler = TextEditingController();
  final _form = GlobalKey<FormState>();
  Product _editedProduct = Product(
    id: '',
    title: '0',
    description: '',
    price: 0.0,
    imageUrl: '',
  );
  String? id = null;
  final _productsToEdit = <String, dynamic>{
    "id": null,
    "title": null,
    "description": null,
    "price": null,
    "imageUrl": null,
    "isFavorite": null,
  };

  bool didInitalized = false;
  bool _isLoading = false;
  static const _formElementSpacing = 10.0;
  @override
  void initState() {
    _imageFocusNode.addListener(_imageUrlFocusCb);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final arguments = ModalRoute.of(context)!.settings.arguments;
    if (arguments != null) {
      id = arguments as String;
    }
    if (!didInitalized && id != null) {
      final item =
          Provider.of<ProductProvider>(context, listen: false).findById(id!);
      _productsToEdit['id'] = item.id;
      _productsToEdit['title'] = item.title;
      _productsToEdit['description'] = item.description;
      _productsToEdit['price'] = item.price.toString();
      _productsToEdit['imageUrl'] = item.imageUrl;
      _productsToEdit["isFavorite"] = item.isFavorite;
      _imageUrlControler.text = item.imageUrl;
    }
    didInitalized = true;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlControler.dispose();
    _imageFocusNode.removeListener(_imageUrlFocusCb);
    _imageFocusNode.dispose();
    super.dispose();
  }

  void _imageUrlFocusCb() {
    if (!_imageFocusNode.hasFocus) {
      if (!RegExp(
        r"(http(s?):)([/|.|\w|\s|-])*",
      ).hasMatch(_imageUrlControler.text)) {
        return;
      }
      setState(() {});
    }
  }

  void _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      if (id != null) {
        _editedProduct = Product(
          id: _productsToEdit['id'],
          title: _editedProduct.title,
          description: _editedProduct.description,
          price: _editedProduct.price,
          imageUrl: _editedProduct.imageUrl,
        );

        try {
          await Provider.of<ProductProvider>(context, listen: false)
              .modifyProduct(
            id!,
            _editedProduct,
          );
        } catch (e) {
          print(e);
        } finally {
          Navigator.of(context).pop();
        }
      } else {
        try {
          await Provider.of<ProductProvider>(context, listen: false)
              .addProduct(_editedProduct);
        } catch (e) {
          print(e);
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "An error occured",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onError),
                ),
                content: Text(
                  'an error occured while uploading product',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onError),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Okay",
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onErrorContainer),
                    ),
                  )
                ],
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
              );
            },
          );
        } finally {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product details"),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _productsToEdit['title'],
                      decoration: InputDecoration(
                        label: Text("Title"),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Product should have Title";
                        }

                        return null;
                      },
                      onSaved: (val) => _editedProduct = Product(
                        id: '',
                        title: val ?? "",
                        description: _editedProduct.description,
                        price: _editedProduct.price,
                        imageUrl: _editedProduct.imageUrl,
                      ),
                    ),
                    SizedBox(
                      height: _formElementSpacing,
                    ),
                    TextFormField(
                      initialValue: _productsToEdit['price'],
                      decoration: InputDecoration(
                        label: Text("Price"),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Product should have Price";
                        }
                        try {
                          final doubleVal = double.parse(val);
                          if (doubleVal <= 0) {
                            return "Product shoud have some price";
                          }
                        } catch (_) {
                          return "Input Should be of type number";
                        }
                        return null;
                      },
                      onSaved: (val) => _editedProduct = Product(
                        id: '',
                        title: _editedProduct.title,
                        description: _editedProduct.description,
                        price: double.parse(val ?? "0.0"),
                        imageUrl: _editedProduct.imageUrl,
                      ),
                    ),
                    SizedBox(
                      height: _formElementSpacing,
                    ),
                    TextFormField(
                      initialValue: _productsToEdit['description'],
                      decoration: InputDecoration(
                        label: Text("Description"),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                      focusNode: _descriptionFocusNode,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Product description should have some content";
                        }

                        return null;
                      },
                      onSaved: (val) => _editedProduct = Product(
                        id: '',
                        title: _editedProduct.title,
                        description: val ?? "",
                        price: _editedProduct.price,
                        imageUrl: _editedProduct.imageUrl,
                      ),
                    ),
                    SizedBox(
                      height: _formElementSpacing,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 2,
                            ),
                            color: Colors.grey.shade300,
                          ),
                          height: 110,
                          width: 110,
                          margin: EdgeInsets.fromLTRB(0, 20, 15, 10),
                          child: _imageUrlControler.text.length > 5
                              ? Image.network(
                                  _imageUrlControler.text,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text("Enter Url"),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              label: Text("Image Url"),
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlControler,
                            onEditingComplete: () => setState(() {}),
                            focusNode: _imageFocusNode,
                            validator: (val) {
                              if (!RegExp(
                                r"(http(s?):)([/|.|\w|\s|-])*",
                              ).hasMatch(val ?? "")) {
                                print("image is not of valid url");
                                return "Enter the valid  url";
                              }

                              return null;
                            },
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (val) => _editedProduct = Product(
                              id: '',
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              price: _editedProduct.price,
                              imageUrl: val ?? "",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
