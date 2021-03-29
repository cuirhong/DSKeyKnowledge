
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
class DSStarRating extends StatefulWidget {
  /// 高亮的值
  final double rating;
  /// 最大的高亮值
  final double maxRating;
  /// 多少个
  final int count;
  /// 一个star的size
  final double size;
  /// 未选中的颜色
  final Color unselectColor;
  /// 选中的颜色
  final Color selectColor;
  /// 未选中的图片
  final Widget unselectImage;
  /// 选中的图片
  final Widget selectImage;

  /// 构造方法
  DSStarRating({
    @required this.rating,
    this.maxRating = 10,
    this.count = 5,
    this.size = 30,
    this.unselectColor = const Color(0xffbbbbbb),
    this.selectColor =  Colors.red,
    Widget unselectImage,
    Widget selectImage
  }):unselectImage = unselectImage ?? Icon(Icons.star_border,color: unselectColor,size: size),
        selectImage = selectImage ?? Icon(Icons.star,color: selectColor,size: size);


  @override
  _DSStarRatingState createState() => _DSStarRatingState();
}

class _DSStarRatingState extends State<DSStarRating> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Row(
            mainAxisSize: MainAxisSize.min,
            children: buildUnselectedStar()
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: buildSelectedStar(),
        )
      ],
    );
  }


  List<Widget> buildUnselectedStar(){
    return List.generate(widget.count, (index){
      return widget.unselectImage;
    });
  }

  List<Widget> buildSelectedStar(){
    // 1. 创建stars
    List<Widget> stars = [];
    final star = widget.selectImage;
    // 2.构造满填充的star
    double oneValue = widget.maxRating / widget.count;

    int entireCount = (widget.rating / oneValue).floor();
    for (var i = 0 ; i < entireCount;i++){
      stars.add(star);
    }
    // 3.构建部分填充star
    double leftWidth = ((widget.rating / oneValue) - entireCount) * widget.size;

    final halfStar = ClipRect(
        clipper: DSStarClipper(leftWidth),
        child: star
    );
    stars.add(halfStar);

    return stars;
  }
}

///
class DSStarClipper extends CustomClipper<Rect>{
  ///宽度
  double width;
  ///
  DSStarClipper(this.width);

  @override
  Rect getClip(Size size) {
    // TODO: implement getClip
    return Rect.fromLTRB(0, 0, this.width, size.height);
  }

  @override
  bool shouldReclip(DSStarClipper oldClipper) {
    // TODO: implement shouldReclip
    return oldClipper.width != this.width;
  }
}
