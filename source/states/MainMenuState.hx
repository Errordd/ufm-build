package states;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.effects.FlxFlicker;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3';
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'options'
	];

	var camFollow:FlxObject;
	var slideSprite:FlxSprite;
	var bg:FlxSprite;
	var pkoverlay:FlxSprite;
	var watermark:FlxSprite;
	var leftSprite:FlxSprite;
	var imageList:Array<String> = [
		'mainmenu/dolpix',
		'mainmenu/gabe',
		'mainmenu/pkk'
	];

	var storyModeTween:FlxTween;
	var freeplayTween:FlxTween;
	var optionsTween:FlxTween;
	
	var bpmBounceScale:Float = 0.03;
	var canBounce:Bool = false;
	var lastBeatHit:Int = 0;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = null;
		transOut = null;

		persistentUpdate = persistentDraw = true;
		
		Conductor.bpm = 102;

		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		pkoverlay = new FlxSprite(0, 0).loadGraphic(Paths.image('pkoverlay'));
		pkoverlay.antialiasing = ClientPrefs.data.antialiasing;
		pkoverlay.alpha = 0;
		add(pkoverlay);

		FlxTween.tween(pkoverlay, {alpha: 0.8}, 0.6, {ease: FlxEase.quartInOut, startDelay: 0.4});

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		slideSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('triangleshit'));
		slideSprite.antialiasing = ClientPrefs.data.antialiasing;
		slideSprite.scrollFactor.set(0, 0);
		slideSprite.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		slideSprite.updateHitbox();
		slideSprite.x += slideSprite.width;
		slideSprite.alpha = 0;
		add(slideSprite);

		FlxTween.tween(slideSprite, {x: 0, alpha: 1}, 1, {
			ease: FlxEase.expoOut,
			startDelay: 1,
			onComplete: function(twn:FlxTween) {
				createMenuItems();
				canBounce = true;
			}
		});

		var randomImage:String = imageList[Std.random(imageList.length)];
		leftSprite = new FlxSprite(-FlxG.width, 0).loadGraphic(Paths.image(randomImage));
		leftSprite.antialiasing = ClientPrefs.data.antialiasing;
		leftSprite.scrollFactor.set(0, 0);
		leftSprite.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		leftSprite.updateHitbox();
		leftSprite.alpha = 0;
		add(leftSprite);

		FlxTween.tween(leftSprite, {x: 0, alpha: 1}, 1, {
			ease: FlxEase.expoOut,
			startDelay: 2
		});

		watermark = new FlxSprite().loadGraphic(Paths.image('yea-idk-man'));
		watermark.antialiasing = ClientPrefs.data.antialiasing;
		watermark.scrollFactor.set();
		watermark.screenCenter();
		watermark.x = FlxG.width - watermark.width;
		watermark.y = FlxG.height - watermark.height;
		add(watermark);

		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);

		super.create();
	}

	function createMenuItems()
	{
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var startX:Float = FlxG.width;
		var startY:Float = 100;

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(startX, startY + (i * 140) + (i * 40));
			menuItem.alpha = 0;
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);

			switch (optionShit[i])
			{
				case 'story_mode':
					menuItem.animation.addByPrefix('idle', 'Symbol 40', 24);
					menuItem.animation.addByPrefix('hover', 'Symbol 4 copy 2', 24);
					menuItem.animation.addByPrefix('selected', 'Symbol 4 copy', 24);
					storyModeTween = FlxTween.tween(menuItem.scale, {x: 1.1, y: 1.1}, 0.6, {ease: FlxEase.backOut, startDelay: 1 + (i * 0.1)});
				case 'freeplay':
					menuItem.animation.addByPrefix('idle', 'Symbol 30', 24);
					menuItem.animation.addByPrefix('hover', 'Symbol 3 copy 2', 24);
					menuItem.animation.addByPrefix('selected', 'Symbol 3 copy', 24);
					freeplayTween = FlxTween.tween(menuItem.scale, {x: 1.1, y: 1.1}, 0.6, {ease: FlxEase.backOut, startDelay: 1 + (i * 0.1)});
				case 'options':
					menuItem.animation.addByPrefix('idle', 'Symbol 20', 24);
					menuItem.animation.addByPrefix('hover', 'Symbol 2 copy 2', 24);
					menuItem.animation.addByPrefix('selected', 'Symbol 2 copy', 24);
					optionsTween = FlxTween.tween(menuItem.scale, {x: 1.1, y: 1.1}, 0.6, {ease: FlxEase.backOut, startDelay: 1 + (i * 0.1)});
			}

			menuItem.animation.play('idle');
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(0, 0);
			menuItem.updateHitbox();

			var targetX:Float = FlxG.width - 300 - (menuItem.width / 2);
			if (optionShit[i] == 'story_mode') {
				targetX += 50;
			} else if (optionShit[i] == 'freeplay') {
				targetX -= 30;
			} else if (optionShit[i] == 'options') {
				targetX -= 100;
			}

			FlxTween.tween(menuItem, {x: targetX, alpha: 1}, 0.8, {
				ease: FlxEase.expoOut,
				startDelay: 0.5 + (i * 0.1)
			});
		}

		changeItem(0);
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin && menuItems != null) {
			var lerpVal:Float = Math.min(Math.max(elapsed * 9.6, 0), 1);
			camFollow.setPosition(FlxMath.lerp(camFollow.x, menuItems.members[curSelected].getGraphicMidpoint().x, lerpVal),
				FlxMath.lerp(camFollow.y, menuItems.members[curSelected].getGraphicMidpoint().y, lerpVal));
				
			if (controls.UI_UP_P) {
				changeItem(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_DOWN_P) {
				changeItem(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.BACK) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				if (menuItems.members[curSelected] != null) {
					FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, false, false);
					menuItems.members[curSelected].animation.play('selected', true);
				}
				
				menuItems.forEach(function(menuItem:FlxSprite) {
					if (menuItem != menuItems.members[curSelected]) {
						FlxTween.tween(menuItem, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween) {
								menuItem.kill();
							}
						});
					} else {
						FlxTween.tween(menuItem.scale, {x: 1.3, y: 1.3}, 0.3, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween) {
								var daChoice:String = optionShit[curSelected];
								
								switch (daChoice) {
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'options':
										MusicBeatState.switchState(new OptionsState());
										OptionsState.onPlayState = false;
										if (PlayState.SONG != null) {
											PlayState.SONG.arrowSkin = null;
											PlayState.SONG.splashSkin = null;
											PlayState.stageUI = 'normal';
										}
								}
							}
						});
					}
				});
			}

			#if desktop
			if (controls.justPressed('debug_1')) {
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}
	
	override function beatHit()
	{
		super.beatHit();
		
		if (!canBounce) return;
		
		if (lastBeatHit >= curBeat) return;
		lastBeatHit = curBeat;
		
		if (leftSprite != null) {
			leftSprite.scale.set(1 + bpmBounceScale, 1 + bpmBounceScale);
			FlxTween.tween(leftSprite.scale, {x: 1, y: 1}, 0.2, {ease: FlxEase.quadOut});
		}
		
		if (bg != null) {
			bg.scale.set(1 + (bpmBounceScale * 0.5), 1 + (bpmBounceScale * 0.5));
			FlxTween.tween(bg.scale, {x: 1.175, y: 1.175}, 0.2, {ease: FlxEase.quadOut});
		}
		
		if (menuItems != null && menuItems.members[curSelected] != null) {
			var selectedItem = menuItems.members[curSelected];
			selectedItem.scale.set(1.1 + (bpmBounceScale * 2), 1.1 + (bpmBounceScale * 2));
			FlxTween.tween(selectedItem.scale, {x: 1.1, y: 1.1}, 0.2, {ease: FlxEase.quadOut});
		}
		
		if (watermark != null) {
			watermark.scale.set(1 + (bpmBounceScale * 0.3), 1 + (bpmBounceScale * 0.3));
			FlxTween.tween(watermark.scale, {x: 1, y: 1}, 0.2, {ease: FlxEase.quadOut});
		}
		
		FlxG.camera.zoom = 1.015;
		FlxTween.tween(FlxG.camera, {zoom: 1}, 0.3, {ease: FlxEase.quadOut});
	}

	function changeItem(huh:Int = 0)
	{
		if (menuItems == null || menuItems.members == null) return;

		if (menuItems.members[curSelected] != null) {
			menuItems.members[curSelected].animation.play('idle');
			menuItems.members[curSelected].scale.set(1, 1);
		}

		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		if (menuItems.members[curSelected] != null) {
			menuItems.members[curSelected].animation.play('hover');

			if (storyModeTween != null) storyModeTween.cancel();
			if (freeplayTween != null) freeplayTween.cancel();
			if (optionsTween != null) optionsTween.cancel();
			
			var currentScale = menuItems.members[curSelected].scale;
			menuItems.members[curSelected].scale.set(currentScale.x, currentScale.y);
			
			FlxTween.tween(menuItems.members[curSelected].scale, {x: 1.1, y: 1.1}, 0.1, {ease: FlxEase.quadOut});
		}
	}
}
