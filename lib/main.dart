import 'package:flutter/material.dart';
import 'package:medstoker/Distributor/DistributerLogin.dart';
import 'package:medstoker/Distributor/addMedicine.dart';
import 'package:medstoker/Distributor/orderScreenDistributor.dart';
import 'package:medstoker/Screens/distributorDetails.dart';
import 'package:medstoker/Screens/home_screen.dart';
import 'package:medstoker/Screens/login_screen.dart';
import 'package:medstoker/Screens/notification_screen.dart';
import 'package:medstoker/Screens/order_screen.dart';
import 'package:medstoker/Screens/stockAnalysis.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medstoker/UserWidget/bottom_navigation_bar.dart';
import 'package:medstoker/Screens/newProfile.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      initialRoute: HomeScreen.id,
      routes: {
        PriceComparisonScreen.id: (context) => PriceComparisonScreen(),
        OrderScreen.id : (context)=> OrderScreen(),
        NotificationScreen.id : (context) => NotificationScreen(),
        StockAnalysis.id : (context) => StockAnalysis(),
        LoginScreen.id : (context) => LoginScreen(),
        NewProfileScreen.id : (context) => NewProfileScreen(),
        OrderScreenDistributer.id :(context) => OrderScreenDistributer(),
        HomeScreen.id : (context) => HomeScreen(),
        DistributerLoginScreen.id : (context) => DistributerLoginScreen(),
        DistributorPage.id :(context) => DistributorPage(),
      },
    );
  }
}