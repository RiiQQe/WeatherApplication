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
    element..onMouseEnter.listen((_) => _createTemplate())
           ..onMouseLeave.listen((_) => _destroyTemplate());
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
            ..style.color = "white"
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
          var elTopRight = element.offset.topRight;

          imagedecElem.style
              ..position = "absolute"
              ..top = "${elTopRight.y}px"
              ..left = "${elTopRight.x + 10}px";

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
