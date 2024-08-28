package blok.image;

@:using(ImageSize.ImageSizeTools)
enum ImageSize {
	Full;
	Constrain(side:Side, size:Int);
	Crop(x:Int, y:Int);
}

enum abstract Side(String) to String from String {
	final X;
	final Y;
}

class ImageSizeTools {
	public static function fromJson(json:Dynamic):ImageSize {
		return switch Reflect.field(json, 'type') {
			case 'Full': Full;
			case 'Constrain': Constrain(Reflect.field('json', 'side'), Reflect.field('json', 'size'));
			default: Crop(Reflect.field(json, 'x'), Reflect.field(json, 'y'));
		}
	}

	public static function toJson(image:ImageSize):Dynamic {
		return switch image {
			case Full: {kind: 'Full'};
			case Constrain(side, size): {kind: 'Constrain', side: side, size: size};
			case Crop(x, y): {kind: 'Crop', x: x, y: y};
		}
	}
}

// @:using(ImageSize.ImageSizeTools)
// enum ImageSize {
// 	Full;
// 	Medium;
// 	Thumbnail;
// 	Custom(x:Int, y:Int);
// }
// class ImageSizeTools {
// 	public static function fromJson(json:Dynamic):ImageSize {
// 		return switch json {
// 			case 'Full': Full;
// 			case 'Medium': Medium;
// 			case 'Thumbnail': Thumbnail;
// 			case obj if (Reflect.hasField(obj, 'x') && Reflect.hasField(obj, 'y')):
// 				Custom(Reflect.field(obj, 'x'), Reflect.field(obj, 'y'));
// 			default: Full;
// 		}
// 	}
// 	public static function toJson(image:ImageSize):Dynamic {
// 		return switch image {
// 			case Full: 'Full';
// 			case Medium: 'Medium';
// 			case Thumbnail: 'Thumbnail';
// 			case Custom(x, y): {x: x, y: y};
// 		}
// 	}
// }
