library image_decorator;

import 'dart:html' as dom;
import 'package:angular/angular.dart';

@Decorator(selector: '[imagedecorator]')
class ImageDecorator{
  final dom.Element element;
  
  @NgOneWay('imagedecorator')
  ImageModel displayModel;
  
  dom.Element imagedecElem;
  
  ImageDecorator(this.element){
    element..onMouseDown.listen((_) => _createTemplate())
           ..onMouseUp.listen((_) => _destroyTemplate());
  }
  
  void _createTemplate() {
      assert(displayModel != null);

      imagedecElem = new dom.DivElement();
      dom.ImageElement imgElem = new dom.ImageElement()
          ..width = displayModel.imgWidth
          ..src = displayModel.imgUrl;
      imagedecElem.append(imgElem);

      if (displayModel.text != null) {
        dom.DivElement textSpan = new dom.DivElement()
            ..appendText(displayModel.text)
            ..style.color = "black"
            ..style.fontSize = "smaller"
            ..style.paddingBottom = "5px";

        imagedecElem.append(textSpan);
      }
      imagedecElem.style
              ..padding = "5px"
              ..paddingBottom = "0px"
              ..backgroundColor = "white"
              ..borderRadius = "5px"
              ..width = "${displayModel.imgWidth.toString()}px";

          // position the tooltip.
          var pos = element.offset.topRight;

          imagedecElem.style
              ..position = "absolute"
              ..top = "${pos.y}px"
              ..left = "${pos.x - 150}px";

          // Add the tooltip to the document body. We add it here because we need to position it
          // absolutely, without reference to its parent element.
          dom.document.body.append(imagedecElem);
        }

        void _destroyTemplate() {
          imagedecElem.remove();
        }
 
}
  
class ImageModel {
    final String imgUrl;
    final String text;
    final int imgWidth;

    ImageModel(this.imgUrl, this.text, this.imgWidth);
  }
