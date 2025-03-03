import 'package:flutter/material.dart';
import 'package:flutter_admin_dashboard/providers/BiddersProvider.dart';
import 'package:flutter_admin_dashboard/providers/BiddingsHandler.dart';
import 'package:flutter_admin_dashboard/providers/productsProvider.dart';
import 'package:flutter_admin_dashboard/providers/side_menu_provider.dart';
import 'package:flutter_admin_dashboard/ui/shared/navbar.dart';
import 'package:flutter_admin_dashboard/ui/shared/sidebar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DashboardLayout extends StatefulWidget {
  final Widget child;

  const DashboardLayout({super.key, required this.child});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    //  yahan pr logic lgaon jis jis ko dashboard screen show hogi   true ki jgh
    if (true) {
      // context.read<BidderProvider>().getProducts();
      // bidderProvider ??= context.read<BidderProvider>();
      BidderProvider bidderProvider = context.read<BidderProvider>();
      if (bidderProvider.auctionTimer != null) {
        bidderProvider.auctionTimer!.cancel();
      }
      bidderProvider.getAuction();
    }
    // Get.put(BiddingHandler()).startListening();
    SideMenuProvider.menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

//////
    //bidderProvider ??= context.read<BidderProvider>();

    //bidderProvider!.getAuction();
    //bidderProvider!.getBidders(widget.product.id);
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   try {
  //     bidderProvider!.auctionTimer!.cancel();
  //     bidderProvider!.timer!.cancel();
  //   } catch (e) {}
  //   super.dispose();
  // }

  late Productprovider productprovider;
  BidderProvider? bidderProvider;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffedf1f2),
        body: Stack(
          children: [
            Row(
              children: [
                // Admin Panel (Logo) y MenuItems (ListView de Iconos)
                if (size.width >= 600) Sidebar(),

                Expanded(
                  child: Column(
                    children: [
                      // Navbar
                      const Navbar(),

                      // View (Vista de la pagina)
                      Expanded(
                        child: widget.child,
                      ),
                    ],
                  ),
                )
              ],
            ),
            if (size.width < 600)
              AnimatedBuilder(
                animation: SideMenuProvider.menuController,
                builder: (context, _) => Stack(
                  children: [
                    if (SideMenuProvider.isOpen)
                      Opacity(
                        opacity: SideMenuProvider.opacity.value,
                        child: GestureDetector(
                          onTap: () => SideMenuProvider.closeMenu(),
                          child: Container(
                            width: size.width,
                            height: size.height,
                            color: Colors.black26,
                          ),
                        ),
                      ),

                    // SideBar
                    Transform.translate(
                      offset: Offset(SideMenuProvider.movement.value, 0),
                      child: Sidebar(),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
