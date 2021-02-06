import 'dart:async';

import 'package:annaistore/utils/universal_variables.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BuildMap extends StatefulWidget {
  @override
  _BuildMapState createState() => _BuildMapState();
}

class _BuildMapState extends State<BuildMap> {
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(8.385209, 77.609389);
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;
  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId(_center.toString()),
      position: _center,
      infoWindow: InfoWindow(
        title: 'Annai Store',
        snippet: 'This is a snippet',
      ),
      icon: BitmapDescriptor.defaultMarker,
    ),
  };

  static final CameraPosition _position1 = CameraPosition(
    bearing: 192.833,
    target: LatLng(8.385209, 77.609389),
    tilt: 59.440,
    zoom: 11.0,
  );

  Future<void> _goToPosition1() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_position1));
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  _onAddMarkerButtonPressed() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(_lastMapPosition.toString()),
          position: _lastMapPosition,
          infoWindow: InfoWindow(
            title: 'Annai Store',
            snippet: 'This is a snippet',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  Widget button(Function function, IconData icon, String heroTag) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: function,
      backgroundColor: Variables.primaryColor,
      child: Icon(
        icon,
        size: 24,
        color: Variables.lightGreyColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          gestureRecognizers: Set()
            ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
            ..add(
                Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
            ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
            ..add(Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer())),
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: _center, zoom: 15.0),
          mapType: _currentMapType,
          markers: _markers,
          onCameraMove: _onCameraMove,
        ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.topRight,
            child: Column(
              children: <Widget>[
                button(_onMapTypeButtonPressed, Icons.map, "btn1"),
                SizedBox(
                  height: 16.0,
                ),
                button(_onAddMarkerButtonPressed, Icons.add_location, "btn2"),
                SizedBox(
                  height: 16.0,
                ),
                button(_goToPosition1, Icons.location_searching, "btn3"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
