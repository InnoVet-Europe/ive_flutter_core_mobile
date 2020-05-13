import 'dart:io' as platform;

import 'package:flutter/material.dart';

import 'package:photo_view/photo_view.dart';

class ZoomableImagePage extends StatelessWidget {
  const ZoomableImagePage({this.image, this.pageTitle, this.imageUrl, this.appBarBackgroundColor, this.background});

  final platform.File image;
  final String pageTitle;
  final String imageUrl;
  final Color appBarBackgroundColor;
  final BoxDecoration background;


  @override
  Widget build(BuildContext context) {
    final AppBar appBar = AppBar(
      centerTitle: true,
      backgroundColor: appBarBackgroundColor,
      title: Text(
        pageTitle ?? 'Image',
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );

    return Scaffold(
      //key: scaffoldKey,
      appBar: appBar,
      body: Container(
          decoration: background,
          child: image != null
              ? PhotoView(
                  imageProvider: FileImage(image),
                  minScale: 0.1,
                  maxScale: 100.0,
                  // backgroundColor: Colors.transparent,
                )
              : PhotoView(
                  imageProvider: NetworkImage(
                    imageUrl,
                    // errorWidget:
                    //     (BuildContext context, String url, Exception error) =>
                    //         const  Icon(Icons.error),
                  ),
                  minScale: 0.1,
                  maxScale: 100.0,
                  // backgroundColor: Colors.transparent,
                )),
    );
  }
}
