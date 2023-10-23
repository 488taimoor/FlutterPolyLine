import 'dart:convert';

import 'package:bgroundservie/constants.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'config/config.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

var userLat;
var userLng;

class HomePAge extends StatefulWidget {
  const HomePAge({super.key});

  @override
  State<HomePAge> createState() => _HomePAgeState();
}

class _HomePAgeState extends State<HomePAge> {
  static const LatLng sourceLocation = LatLng(31.535785, 74.456315);
  static const LatLng destination = LatLng(31.528718, 74.445084);
  TextEditingController _currentPlaceController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  bool field = true;
  List<LatLng> polylineCoordinates = [];
  LocationPermission? permission;
  Position? _curentPosition;
  String? _curentAddress;
  List<dynamic> _placeList = [];
  String? _sessionToken;
  var selectedLat;
  var selectedLng;
  // String Home = "";
  Uuid uuid = new Uuid();
  @override
  void initState() {
    // TODO: implement initState
    // myMarkers.addAll(markerList);
    _getCurrentLocation();
    // getPolyPoints();
    super.initState();
    // for (int i = 0; i < myPoints.length; i++) {
    //   myMarkers.add(Marker(
    //       markerId: MarkerId(i.toString()),
    //       position: myPoints[i],
    //       // infoWindow: InfoWindow(title: 'adventure'),
    //       icon: BitmapDescriptor.defaultMarker));
    // }
    setState(() {
      _myPolyline.add(Polyline(
          polylineId: const PolylineId('first'),
          points: myPoints,
          color: Colors.red,
          width: 2));
    });
  }

  Future _getCurrentLocation() async {
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      await Geolocator.openLocationSettings();
      Fluttertoast.showToast(msg: "Location permissions are  denind");
      if (permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(
            msg: "Location permissions are permanently denind");
      }
    }
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _curentPosition = position;
        print(_curentPosition!.latitude);
        userLat = _curentPosition!.latitude;
        userLng = _curentPosition!.longitude;
        print('+++${userLat} ${userLng}');
        LatLng currentLatLong = LatLng(userLat, userLng);
        // myPoints.add(currentLatLong);
        myMarkers.add(Marker(
            markerId: MarkerId("1"),
            position: currentLatLong,
            // infoWindow: InfoWindow(title: 'adventure'),
            icon: BitmapDescriptor.defaultMarker));

        _getAddressFromLatLon();
      });
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  _getAddressFromLatLon() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _curentPosition!.latitude, _curentPosition!.longitude);

      Placemark place = placemarks[0];
      setState(() {
        _curentAddress =
            "${place.locality},${place.subLocality},${place.street}";
        _currentPlaceController.text = _curentAddress!;
        print('this is current location$_curentAddress');
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void getPolyPoints(String Place) async {
    List<Location> locations = await locationFromAddress(Place);
    print('locations ${locations}');
//     final query = "1600 Amphiteatre Parkway, Mountain View";
// var addresses = await Geocoder.local.findAddressesFromQuery(query);
    var first = locations.first;
    selectedLat = first.latitude;
    selectedLng = first.longitude;
    print("featuring everything ${selectedLat} : ${selectedLng}");
    PolylinePoints polylinePoints = PolylinePoints();
    PointLatLng current = PointLatLng(userLat, userLng);
    PointLatLng destination = PointLatLng(selectedLat, selectedLng);

    LatLng destinationLatLong = LatLng(selectedLat, selectedLng);
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GOOGLE_API_KEY,
      current,
      destination,
      travelMode: TravelMode.driving,
    );
    myMarkers.add(Marker(
        markerId: MarkerId("2"),
        position: destinationLatLong,
        // infoWindow: InfoWindow(title: 'adventure'),
        icon: BitmapDescriptor.defaultMarker));
    // dynamic result = await polylinePoints.getRouteWithAlternatives(
    //     request: PolylineRequest(
    //         apiKey: 'AIzaSyBvzWwukb4Xaci6v7Quk1BmSh-kYz558Q8',
    //         origin:
    //             PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
    //         destination:
    //             PointLatLng(destination.latitude, destination.longitude),
    //         mode: TravelMode.driving,
    //         alternatives: true,
    //         avoidFerries: true,
    //         avoidHighways: true,
    //         avoidTolls: false,
    //         optimizeWaypoints: true,
    //         wayPoints: ,
    //         arrivalTime: null,
    //         departureTime: null,
    //         transitMode: null)
    //   'AIzaSyBvzWwukb4Xaci6v7Quk1BmSh-kYz558Q8', // Your Google Map Key
    //   PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
    //   PointLatLng(destination.latitude, destination.longitude),
    // );
    print('this is result ${result}');
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );

      setState(() {
        // Your state change code goes here
      });
    }
  }

//  myPoints for showing marker 1 for user location and 2 for destination
  final Set<Marker> myMarkers = {};
  final List<LatLng> myPoints = [
    //   // LatLng(userLat, userLng),
    //   const LatLng(31.51581205411415, 74.33061258947265),
    //   // const LatLng(24.860966, 66.990501),
    //   LatLng(31.528718, 74.445084),
    //   // Marker(
    //   //     markerId: MarkerId('first'),
    //   //     position: LatLng(31.535785, 74.456315),
    //   //     infoWindow: InfoWindow(title: 'My position')),
    //   // Marker(
    //   //     markerId: MarkerId('second'),
    //   //     position: LatLng(31.51581205411415, 74.33061258947265),
    //   //     infoWindow: InfoWindow(title: 'office'))
  ];
  dynamic markerList = [];
  final Set<Polyline> _myPolyline = {};
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition initialPosition =
      CameraPosition(target: sourceLocation, zoom: 10);

  void getLocationResults(String input) async {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    String type = "(regions)";

    String baseURL =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    String request =
        "$baseURL?input=$input&key=$GOOGLE_API_KEY&sessiontoken=$_sessionToken";
    print("this is request $request");
    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      print("these are places ${json.decode(response.body)["predictions"]}");
      dynamic predictions = json.decode(response.body)["predictions"];
      setState(() {
        _placeList = json.decode(response.body)["predictions"];
      });
    } else {
      throw Exception("Failed to load predictions");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Column(
          children: [
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: initialPosition,
                markers: myMarkers,
                // polylines: _myPolyline,
                polylines: {
                  Polyline(
                    polylineId: const PolylineId("route"),
                    points: polylineCoordinates,
                    color: polyLineColor,
                    width: 4,
                  ),
                },
                onMapCreated: (GoogleMapController controller) =>
                    _controller.complete(controller),
              ),
            ),
          ],
        ),
        Positioned(
          child: Padding(
            padding: const EdgeInsets.only(left: 36, right: 36, top: 50),
            child: Column(
              children: [
                Container(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/burgermenu.svg',
                        height: 40,
                        width: 40,
                      ),
                      Image.asset('assets/logo.png'),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(75.0),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80',
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    // height: 83,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                    enabled: false,
                                    controller: _currentPlaceController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Skate Park",
                                      hintStyle: TextStyle(
                                        fontFamily: font_Family,
                                        fontSize: 14,
                                      ),
                                      prefixIcon: SvgPicture.asset(
                                          'assets/round.svg',
                                          height: 5,
                                          width: 5,
                                          fit: BoxFit.scaleDown),
                                    )),
                                Container(
                                  height: 1,
                                  color: lightgrey,
                                ),
                                TextField(
                                    controller: _destinationController,
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        getLocationResults(value);
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Select your destination",
                                      hintStyle: TextStyle(
                                        fontFamily: font_Family,
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      prefixIcon: SvgPicture.asset(
                                          'assets/ic_pin.svg',
                                          height: 5,
                                          width: 5,
                                          fit: BoxFit.scaleDown),
                                    )),
                              ],
                            ),
                          ),
                          Container(
                            width: 68,
                            height: 36,
                            decoration: BoxDecoration(
                              color: fillColor,
                              border: Border.all(color: lightgrey),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/add.svg',
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    'Add',
                                    style: TextStyle(
                                      color: Color(0xFF656565),
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )),
                SizedBox(
                  height: 4,
                ),
                _placeList.length == 0
                    ? SizedBox()
                    : Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: fillColor,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _placeList.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () async {
                                setState(() {
                                  _destinationController.text =
                                      _placeList[index]["description"];
                                  _placeList.clear();
                                  print(
                                      'this is destination ${_destinationController.text}');
                                });
                                getPolyPoints(_destinationController.text);
                              },
                              child: ListTile(
                                leading: Icon(Icons.location_on_outlined),
                                title: Text(_placeList[index]["description"]),
                              ),
                            );
                          },
                        ),
                      )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
