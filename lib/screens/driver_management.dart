import 'package:fleet_ease/utils/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fleet_ease/api/driver_functions.dart';
import 'package:fleet_ease/models/driver_model.dart';

class DriverManagementScreen extends ConsumerStatefulWidget {
  const DriverManagementScreen({super.key});

  @override
  ConsumerState<DriverManagementScreen> createState() =>
      _DriverManagementScreenState();
}

class _DriverManagementScreenState extends ConsumerState<DriverManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DriverModel> hiredDrivers = [];
  List<DriverModel> availableDrivers = [];
  bool isLoading = true;
  String? managerId = SharedPrefsHelper.getUserId();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchDrivers();
  }

  Future<void> fetchDrivers() async {
    setState(() => isLoading = true);
    hiredDrivers = await DriverApiService.getDriversByManager(managerId!);
    availableDrivers = await DriverApiService.getUnassignedDrivers();
    setState(() => isLoading = false);
  }

  void hireDriver(String driverId) async {
    bool success = await DriverApiService.addDriverToCompany(driverId);
    if (success) fetchDrivers();
  }

  void removeDriver(String driverId) async {
    bool success = await DriverApiService.removeDriver(driverId);
    if (success) fetchDrivers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _tabBar(),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDriverList(hiredDrivers, true),
                    _buildDriverList(availableDrivers, false),
                  ],
                ),
        ),
      ],
    );
  }

  PreferredSizeWidget _tabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: "Hired Drivers"),
        Tab(text: "Available Drivers"),
      ],
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.blue,
    );
  }

  Widget _buildDriverList(List<DriverModel> drivers, bool isHired) {
    return drivers.isEmpty
        ? const Center(child: Text("No drivers found"))
        : ListView.builder(
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final driver = drivers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: driver.profilePhotoUrl.isNotEmpty
                        ? NetworkImage(driver.profilePhotoUrl)
                        : const AssetImage('assets/placeholder.png')
                            as ImageProvider,
                  ),
                  title: Text(driver.name),
                  subtitle: Text(
                    driver.licenseExpiryDate != null
                        ? "License Expiry: ${DateFormat.yMMMd().format(driver.licenseExpiryDate!)}"
                        : "License Expiry Not Set",
                  ),
                  trailing: isHired
                      ? IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          onPressed: () => removeDriver(driver.id),
                        )
                      : IconButton(
                          icon:
                              const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () => hireDriver(driver.id),
                        ),
                ),
              );
            },
          );
  }
}
