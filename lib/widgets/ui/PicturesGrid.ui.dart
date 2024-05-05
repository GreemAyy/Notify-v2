import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../app_settings/const.dart';
import 'Skeleton.ui.dart';

class PicturesGrid extends StatelessWidget{
  const PicturesGrid({
    super.key,
    required this.imagesId,
    required this.imageHeight,
    required this.imageWidth,
    this.showFirst = true
  });
  final List<int> imagesId;
  final double imageHeight;
  final double imageWidth;
  final bool showFirst;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if(showFirst)
          ImagePlaceholder(
              imageId: imagesId[0],
              imageHeight: imageHeight,
              imageWidth: imageWidth
          ),
        const SizedBox(width: 5),
        if(imagesId.length>1)
          Column(
            children: [
              ImagePlaceholder(
                  imageId: imagesId[1],
                  imageHeight: imageHeight/2,
                  imageWidth: imageWidth/2
              ),
              const SizedBox(height: 5),
              if(imagesId.length>=3)
                ImagePlaceholder(
                    imageId: imagesId[2],
                    imageHeight: imageHeight/2,
                    imageWidth: imageWidth/2
                )
            ]
          ),
        const SizedBox(width: 5),
        if(imagesId.length>3)
          Text(
            '+${imagesId.length-3}',
            style: theme.textTheme.bodyLarge
          )
      ]
    );
  }
}

class ImagePlaceholder extends StatelessWidget{
  const ImagePlaceholder({
    super.key,
    required this.imageId,
    required this.imageHeight,
    required this.imageWidth,
    this.fit = BoxFit.fitWidth,
    this.radius = 10
  });
  final int imageId;
  final double imageHeight;
  final double imageWidth;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CachedNetworkImage(
      imageUrl: '$URL_MAIN/api/images/$imageId',
      imageBuilder: (context, image){
        return ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image(
                image: image,
                height: imageHeight,
                width: imageWidth,
                fit: fit
            )
        );
      },
      placeholder: (context, _) =>
        Skeleton(
            height: imageHeight,
            width: imageWidth,
            borderRadius: 10,
            colorFrom: theme.textTheme.bodyMedium!.color!.withOpacity(.2),
            colorTo: theme.textTheme.bodyMedium!.color!.withOpacity(.5),
            setWidthFromScreenParams: false
        ),
      errorWidget: (context, _, __) =>
        SizedBox(
          width: imageWidth,
          height: imageHeight,
          child: Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.no_photography,
              size: (imageWidth+imageHeight)/2/2,
            )
          )
        )
    );
  }
}