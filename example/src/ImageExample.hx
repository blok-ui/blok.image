import blok.html.*;
import blok.image.*;
import blok.ui.*;

class ImageExample extends Component {
	function render():Child {
		return Html.html()
			.child(Html.body()
				.child('Hey world')
				.child(Image.node({
					src: 'example/data/images/test.png',
					size: ImageSize.Crop(50, 100),
					alt: 'test'
				}))
				.child(Image.node({
					src: 'example/data/images/test.png',
					size: ImageSize.Crop(50, 100),
					alt: 'test'
				}))
				.child(Image.node({
					src: 'example/data/images/test.png',
					size: ImageSize.Full,
					alt: 'test'
				}))
				.child(LoadingImage.node({
					src: 'example/data/images/test.png'
				}))
			);
	}
}
