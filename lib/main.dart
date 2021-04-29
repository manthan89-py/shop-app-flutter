import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './helpers/custom_route.dart';
import './screens/splash_screen.dart';

import './providers/orders.dart';
import './providers/cart.dart';
import './providers/product_provider.dart';
import './providers/auth.dart';

import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './screens/user_product_screen.dart';
import './screens/orders_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/product_overview_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductProvider>(
          // create: (ctx) => ProductProvider(),
          update: (ctx, auth, previousProduct) => ProductProvider(
              auth.token,
              auth.userId,
              previousProduct == null ? [] : previousProduct.items),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          // create: (ctx) => Orders(),
          update: (ctx, auth, previousOrders) => Orders(auth.token, auth.userId,
              previousOrders == null ? [] : previousOrders.orders),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
          ),
          home: auth.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResult) =>
                      authResult.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrderScreen.routeName: (ctx) => OrderScreen(),
            UsersProductScreen.routeName: (ctx) => UsersProductScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen()
          },
        ),
      ),
    );
  }
}
