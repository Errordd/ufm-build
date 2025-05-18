package backend;

import flixel.util.FlxGradient;
import openfl.display.BitmapData;

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	var isTransIn:Bool = false;
	var ditherSprite:FlxSprite;
	
	var duration:Float;
	var currentFrame:Int = 0;
	var frameTimer:Float = 0;
	var frameSpeed:Float = 0.12;
	var blockSize:Int = 4;
	
	var patterns:Array<Array<Array<Int>>> = [
		[
			[1,0,1,0],
			[0,0,0,0],
			[1,0,0,0],
			[0,0,0,1]
		],
		[
			[1,0,1,0],
			[0,0,0,1],
			[0,1,0,0],
			[1,0,0,1]
		],
		[
			[1,0,1,0],
			[0,1,0,1],
			[1,0,1,0],
			[0,1,0,1]
		],
		[
			[1,1,1,1],
			[1,1,1,1],
			[1,1,1,1],
			[1,1,1,1]
		]
	];

	var ditherData:BitmapData;

	public function new(duration:Float, isTransIn:Bool) {
		this.duration = duration;
		this.isTransIn = isTransIn;
		super();
	}

	function updateDitherPattern(pattern:Array<Array<Int>>) {
		ditherData.lock();
		ditherData.fillRect(ditherData.rect, 0);
		
		for (y in 0...Std.int(ditherData.height/blockSize)) {
			for (x in 0...Std.int(ditherData.width/blockSize)) {
				var patternX = x % 4;
				var patternY = y % 4;
				if (pattern[patternY][patternX] == 1) {
					for (px in 0...blockSize) {
						for (py in 0...blockSize) {
							ditherData.setPixel32(x * blockSize + px, y * blockSize + py, FlxColor.BLACK);
						}
					}
				}
			}
		}
		ditherData.unlock();
	}

	override function create() {
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
		
		var width:Int = Std.int(FlxG.width / Math.max(camera.zoom, 0.001));
		var height:Int = Std.int(FlxG.height / Math.max(camera.zoom, 0.001));
		
		ditherData = new BitmapData(width, height, true, 0);
		ditherSprite = new FlxSprite().loadGraphic(ditherData);
		ditherSprite.scrollFactor.set();
		ditherSprite.screenCenter(X);
		add(ditherSprite);

		if (isTransIn) {
			currentFrame = patterns.length - 1;
			updateDitherPattern(patterns[patterns.length - 1]);
		}

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		
		frameTimer += elapsed;
		if (frameTimer >= frameSpeed) {
			frameTimer = 0;
			
			if (isTransIn) {
				if (currentFrame >= 0) {
					if (currentFrame < patterns.length) {
						updateDitherPattern(patterns[currentFrame]);
					}
					currentFrame--;
				}
			} else {
                if (currentFrame < patterns.length) {
					updateDitherPattern(patterns[currentFrame]);
					currentFrame++;
				}
			}
		}

		if ((!isTransIn && currentFrame >= patterns.length) || (isTransIn && currentFrame < 0)) {
			close();
			if (finishCallback != null) finishCallback();
			finishCallback = null;
		}
	}

	override function destroy() {
		super.destroy();
		if (ditherData != null) {
			ditherData.dispose();
		}
	}
}
