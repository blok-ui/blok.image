// THIS IS A GENERATED FILE.
// DO NOT EDIT.
function main() {
	#if !blok.client
	var fs = new kit.file.FileSystem(new kit.file.adaptor.SysAdaptor(Sys.getCwd()));
	var app = new blok.bridge.App({
		fs: fs,
		output: fs.directory("dist/www"),
		version: "0.0.1",
		paths: new blok.bridge.Paths({
			assetPrefix: "assets", 
			clientApp: "/assets/app-v0_0_1.js"
		})
	});
	blok.bridge.Bridge.generate(app, () -> ImageExample.node({}), [
		blok.image.bridge.ProcessImages.fromJson({"destination":"/assets/images","engine":"vips","thumbSize":200,"mediumSize":800}),
    new blok.bridge.plugin.IncludeClientApp({src: "/assets/app-v0_0_1.js", minify: false}),
    new blok.bridge.plugin.OutputHtml({strategy: DirectoryWithIndexHtmlFile})
	]);
	#end
}
