import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_admin_dashboard/models/DetailModel.dart';
import 'package:flutter_admin_dashboard/models/Donation_Model.dart';
import 'package:flutter_admin_dashboard/providers/BiddingsHandler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' as g;
import 'package:image_picker/image_picker.dart';
import '../api/ApiHandler.dart';
import '../models/Product_Model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

double? donationAmount, salesAmount = 0;

class Productprovider extends ChangeNotifier {
  List<Product> products = [];
  List<donate> donation = [];
  bool isGettingProducts = true;
  bool isGettingDonations = true;
  Details? details;
  List<Product> filteredProducts = [];
  List<XFile> pickedFiles = [];
  getProducts() async {
    try {
      getDetailForAdmin();
      isGettingProducts = true;
      notifyListeners();
      var response = await Dio().get(getProduct);
      print(response);
      if (response.statusCode == 200) {
        products.clear();
        var data = jsonDecode(response.data);
        for (var element in data) {
          Product p = Product.fromMap(element);
          try {
            // var images = await FirebaseFirestore.instance
            //     .collection('ProductsImages')
            //     .where('Pid', isEqualTo: p.id)
            //     .get();
            // for (var element in images.docs) {
            //   p.images.add(element['url']);
            // }
          } catch (e) {
            SnackBar(content: Text(e.toString()));
          }
          products.add(p);
        }
        filteredProducts = products;
        g.Get.find<BiddingHandler>().products = products;
      }
    } catch (e) {
      print(e);
      SnackBar(content: Text(e.toString()));
    }
    isGettingProducts = false;
    notifyListeners();
  }

  getDonationapiCall() async {
    try {
      var response = await Dio().get(getDonationsip);
      if (response.statusCode == 200) {
        print(response);
        donation.clear();
        for (var element in response.data) {
          donation.add(donate.fromMap(element));
        }
        donation.sort((a, b) => b.date!.compareTo(a.date!));
        isGettingDonations = false;
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  addProduct(Product product, List<XFile> images) async {
    try {
      // var data = await FirebaseFirestore.instance
      //     .collection('Products')
      //     .add(product.toMap());
      FormData formData = FormData.fromMap(product.toMap());
      var data = await Dio().post(addProductIp,
          data: formData,
          options: Options(headers: {'Content-Type': 'application/json'}));
      if (data.statusCode == 200) {
        // EasyLoading.showToast('Product Saved Successfully!');
        var d = jsonDecode(data.data);
        for (XFile e in images) {
          try {
            // String filename = e.relativePath!.split('/').last;

            FormData imageFormData = FormData.fromMap({
              'pid': int.parse(d[0]),
              'image': base64Encode(await e.readAsBytes())
            });
            product.id = int.parse(d[0]);

            var res = await Dio().post(addProductImageIp,
                data: imageFormData,
                options:
                    Options(headers: {'Content-Type': 'multipart/form-data'}));
            if (res.statusCode == 200) {
              print(res.data);
              product.image_urls.add(res.data[0]);
            }
          } catch (e) {
            print(e);
          }
        }
        pickedFiles.clear();

        products.add(product);
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  addDonation(donate donation) async {
    try {
      FormData formData = FormData.fromMap(donation.toMap());
      var response =
          await Dio().post(addDonationIp, data: formData, options: option);
      if (response.statusCode == 200) {
        print(response.data);
        await getDetailForAdmin();
        await getDonationapiCall();
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  updatedonationType({required String isAnounced, required String did}) async {
    try {
      var response = await Dio().post(changeDoantionTypeIp,
          options: option,
          data: FormData.fromMap({'did': did, 'isAnounced': isAnounced}));
      if (response.statusCode == 200) {
        int index = donation.indexWhere((element) => element.id == did);
        donation[index].isAnounced = isAnounced;
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  applyFilter({required String toFilter}) async {
    try {
      if (toFilter == 'All Items') {
        filteredProducts = products;
        g.Get.find<BiddingHandler>().products = products;
      } else {
        filteredProducts = products
            .where((element) =>
                element.productType.toLowerCase() ==
                toFilter.toLowerCase().split(' ')[0])
            .toList();

        g.Get.find<BiddingHandler>().products = filteredProducts;
      }
      notifyListeners();
    } catch (e) {}
  }

  deleteProduct(int id) async {
    try {
      var response = await Dio().delete(
        deleteProductApi,
        options: option,
        queryParameters: {'id': id},
      );
      print("Delete Product Api response======> $response");
      if (response.statusCode == 200) {
        notifyListeners();
        print('Product deleted successfully');
        // Handle success, e.g., show a message or update the UI
      } else {
        print('Failed to delete product: ${response.statusCode}');
        // Handle failure, e.g., show an error message
      }
    } catch (error) {
      print('Error deleting product: $error');
      // Handle error, e.g., show an error message
    }
  }

  updateProduct(Product p) async {
    try {
      var response =
          await Dio().post(updateProductApi, options: option, data: p.toMap());
      if (response.statusCode == 200) {
        // int index = products.indexWhere((element) => element.id == p.id);
        // products.removeAt(index);
        // products.insert(index, p);
        EasyLoading.showToast('Updated');
        await getProducts();
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  updateType({required String type, required int pid}) async {
    try {
      var response = await Dio().post(changeProductTypeIp,
          options: option,
          data: FormData.fromMap({'pid': pid, 'productType': type}));
      if (response.statusCode == 200) {
        int index = products.indexWhere((element) => element.id == pid);
        products[index].productType = type;
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  updateVisibility({required String isVisible, required int pid}) async {
    try {
      var response = await Dio().post(updateVisibleApi,
          options: option,
          data: FormData.fromMap({'pid': pid, 'isVisible': isVisible}));
      if (response.statusCode == 200) {
        int index = products.indexWhere((element) => element.id == pid);
        products[index].isVisible = isVisible;
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  getDetailForAdmin() async {
    try {
      var response = await Dio().get(getAdminDetail);
      if (response.statusCode == 200) {
        details = Details(
          auction_time: response.data['auction_time'],
          auctionCount: response.data['auction_count'],
          lastWeekSales: LastWeekSales(
              productCount: response.data['last_week_sales']['product_count'],
              totalPrice: response.data['last_week_sales']['total_price']),
          teleCount: response.data['tele_count'],
          totalProducts: response.data['total_products'],
          totalSales: response.data['total_sales'],
          totaldonations: response.data['total_donation'] ?? '0',
        );
        salesAmount = double.parse(details!.lastWeekSales!.totalPrice ?? "0");
        donationAmount = double.parse(details!.totaldonations ?? "0");

        print('£: ${(donationAmount ?? 0) + (salesAmount ?? 0)}');
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  addAuctionTime(pid) async {
    try {
      var response =
          await Dio().get('$addTimerApi${DateTime.now().toString()}&pid=$pid');
      if (response.statusCode == 200) {}
      EasyLoading.showToast('Auction started');
    } catch (e) {
      print(e);
    }
  }
}
