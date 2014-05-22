package
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import we.love.Adobe;
	
	public class AdobeLowMemoryTest extends Sprite
	{
		// 1 = 1MB of GPU RAM
		public static const TEXTURE_MULTIPLIER:int = 250;
		
		private var _tempRefs:Array = new Array();
		private var adobe:Adobe = new Adobe();
		private var context3D:Context3D;
		
		public function AdobeLowMemoryTest()
		{
			super();
			
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;	
			stage.frameRate = 60;
			
			var stage3D:Stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			stage3D.requestContext3D(Context3DRenderMode.AUTO);
			setTimeout(Adobe.getInstance().doWorkaround, 20000);
			
			// give the GC something to do
			for(var i:int=0; i<2000; i++) {
				_tempRefs.push({prop:"test"});
			}
		}
	
		protected function onContextCreated(ev:Event): void
		{
			trace("onContextCreated()");
			// Setup context
			var stage3D:Stage3D = stage.stage3Ds[0];
			stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			context3D = stage3D.context3D;            
			context3D.configureBackBuffer(
				stage.stageWidth,
				stage.stageHeight,
				0,
				true
			);
			
			// just to upload to the gpu
			for (var i:int=0; i<TEXTURE_MULTIPLIER; i++)
			{
				var bmd:BitmapData = new BitmapData(512, 512, true, 0x000000);
				var texture:Texture = context3D.createTexture(
					bmd.width,
					bmd.height,
					Context3DTextureFormat.BGRA,
					true
				);
				texture.uploadFromBitmapData(bmd);
				_tempRefs.push(texture);
			}
		}
	}
}