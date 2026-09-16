import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/map_location_model.dart';
import '../../map_dependencies.dart';

class MapPage extends StatefulWidget { const MapPage({super.key}); @override State<MapPage> createState() => _MapPageState(); }
class _MapPageState extends State<MapPage> {
  final MapController _controller = MapController();
  List<MapLocationModel> _locations = const []; bool _loading = true; String? _error;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async { try { final items=await MapDependencies.getLocations(); if(mounted)setState(()=>_locations=items); } catch(e){if(mounted)setState(()=>_error=e.toString().replaceFirst('Exception: ',''));} finally{if(mounted)setState(()=>_loading=false);} }
  LatLng get _center => _locations.isNotEmpty ? LatLng(_locations.first.latitude,_locations.first.longitude) : const LatLng(25.2048,55.2708);
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Map')), body: Stack(children: [FlutterMap(mapController:_controller, options:MapOptions(initialCenter:_center,initialZoom:11,minZoom:2,maxZoom:18), children:[TileLayer(urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',userAgentPackageName:'com.vibelocate.ai'),MarkerLayer(markers:_locations.map((m)=>Marker(point:LatLng(m.latitude,m.longitude),width:48,height:48,child:GestureDetector(onTap:()=>_show(m),child:Container(decoration:BoxDecoration(color:Theme.of(context).colorScheme.primary,shape:BoxShape.circle,border:Border.all(color:Colors.white,width:3)),child:Icon(Icons.home_rounded,color:Theme.of(context).colorScheme.onPrimary,size:22))))).toList())]), if(_loading) const Center(child:CircularProgressIndicator()), if(_error!=null) Positioned(bottom:20,left:20,right:20,child:Card(child:Padding(padding:const EdgeInsets.all(14),child:Text(_error!))))]));
  void _show(MapLocationModel m){ showModalBottomSheet(context:context,builder:(_)=>SafeArea(child:Padding(padding:const EdgeInsets.all(20),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(m.title.isEmpty?'Property':m.title,style:Theme.of(context).textTheme.titleLarge),if(m.address.isNotEmpty) ...[const SizedBox(height:6),Text(m.address)],if(m.price.isNotEmpty) ...[const SizedBox(height:10),Text(m.price,style:Theme.of(context).textTheme.titleMedium?.copyWith(color:Theme.of(context).colorScheme.primary))],const SizedBox(height:16),if(m.propertyId!=null) FilledButton(onPressed:()=>Navigator.pushNamed(context,'/property-details',arguments:m.propertyId),child:const Text('View property'))])))); }
}
