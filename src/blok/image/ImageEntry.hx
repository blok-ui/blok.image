package blok.image;

import blok.data.Model;

// @todo: rethink this.
class ImageEntry extends Model {
	@:constant public final source:String;
	@:constant public final dest:String;
	@:json(from = ImageSize.ImageSizeTools.fromJson(value), to = value.toJson())
	@:constant public final size:ImageSize;
}
