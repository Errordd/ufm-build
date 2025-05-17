package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import openfl.display.BitmapData;
import sys.FileSystem;
import sys.io.File;
import StringTools;
import openfl.geom.Matrix;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup;
import flixel.input.mouse.FlxMouseEvent;

class ComputerState extends MusicBeatState
{
	private var wallpaperSprite:FlxSprite;
	private var transitionStarted:Bool = false;
	
	private var topCurtain:FlxSprite;
	private var bottomCurtain:FlxSprite;
	private var animationComplete:Bool = false;
	
	private var lockScreenOverlay:FlxSprite;
	private var pcNameText:FlxText;
	private var passwordPrompt:FlxText;
	private var passwordDots:FlxText;
	private var passwordBox:FlxSprite;
	private var enterPrompt:FlxText;
	private var timeText:FlxText;
	private var dateText:FlxText;
	private var isLocked:Bool = true;
	private var passwordChars:String = "";
	private var pcName:String = "User's PC";
	
	private var loadingDots:FlxGroup;
	private var dotTweens:Array<FlxTween> = [];
	private var loadingComplete:Bool = false;
	private var timer:Float = 0;
	
	private var desktopIcon:FlxSprite;
	private var iconLabel:FlxText;
	private var bloxinIcon:FlxSprite;
	private var bloxinLabel:FlxText;
	private var legacyIcon:FlxSprite;
	private var legacyLabel:FlxText;
	private var wallpaperAppIcon:FlxSprite;
	private var wallpaperAppLabel:FlxText;
	private var exitIcon:FlxSprite;
	private var exitLabel:FlxText;
	private var settingsIcon:FlxSprite;
	private var settingsLabel:FlxText;
	private var showingDesktop:Bool = false;
	
	// New variables for the secret password feature
	private var redTintOverlay:FlxSprite;
	private var secretPasswordEntered:Bool = false;
	private var secretIcon:FlxSprite;
	private var secretIconLabel:FlxText;
	
	private var wallpaperWindow:FlxSprite;
	private var wallpaperWindowHeader:FlxSprite;
	private var wallpaperWindowTitle:FlxText;
	private var wallpaperWindowCloseButton:FlxSprite;
	private var wallpaperWindowMaximizeButton:FlxSprite;
	private var wallpaperWindowMinimizeButton:FlxSprite;
	private var wallpaperOptions:Array<FlxSprite> = [];
	private var wallpaperOptionLabels:Array<FlxText> = [];
	private var wallpaperApplyButton:FlxSprite;
	private var wallpaperApplyText:FlxText;
	private var isWallpaperWindowOpen:Bool = false;
	private var selectedWallpaperIndex:Int = 0;
	private var isDraggingWindow:Bool = false;
	private var dragOffsetX:Float = 0;
	private var dragOffsetY:Float = 0;

	private var scanlineOverlay:FlxSprite;
	private var staticOverlay:FlxSprite;
	private var staticTimer:Float = 0;
	private var staticFrames:Array<BitmapData> = [];
	private var currentStaticFrame:Int = 0;
	
	override public function create()
	{
		super.create();
		
		#if windows
		Sys.command('cmd /c mode con: cols=0 lines=0');
		#end

		FlxG.sound.volume = 1.0;
		FlxG.sound.muted = false;

		new FlxTimer().start(0.7, function(tmr:FlxTimer) {
			FlxG.sound.play(Paths.sound('startup'));
		});
		
		wallpaperSprite = new FlxSprite(0, 0);
		wallpaperSprite.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(wallpaperSprite);
		
		loadWallpaper();
		
		topCurtain = new FlxSprite(0, 0).makeGraphic(FlxG.width, Std.int(FlxG.height / 2), FlxColor.BLACK);
		bottomCurtain = new FlxSprite(0, FlxG.height / 2).makeGraphic(FlxG.width, Std.int(FlxG.height / 2), FlxColor.BLACK);
		
		add(topCurtain);
		add(bottomCurtain);
		
		getPCName();
		
		createLockScreen();
		
		createDesktopIcon();
		createBloxinManiaIcon();
		createLegacyIcon();
		createWallpaperAppIcon();
		createExitIcon();
		createSettingsIcon();
		
		// Create the red tint overlay but don't add it yet
		redTintOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
		redTintOverlay.alpha = 0.3;

		createScanlineEffect();
		
		startOpeningAnimation();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Computer Screen", null);
		#end
	}
	
	private function createLockScreen():Void
	{
		lockScreenOverlay = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		lockScreenOverlay.alpha = 0.7;
		add(lockScreenOverlay);
		
		var now = Date.now();
		var hours = now.getHours();
		var minutes = now.getMinutes();
		var timeString = (hours < 10 ? "0" : "") + hours + ":" + (minutes < 10 ? "0" : "") + minutes;
		var dateString = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][now.getDay()] + ", " + 
						 ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][now.getMonth()] + " " + 
						 now.getDate();
		
		timeText = new FlxText(0, FlxG.height * 0.15, FlxG.width, timeString, 48);
		timeText.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, CENTER);
		add(timeText);
		
		dateText = new FlxText(0, FlxG.height * 0.22, FlxG.width, dateString, 24);
		dateText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);
		add(dateText);
		
		pcNameText = new FlxText(0, FlxG.height * 0.35, FlxG.width, pcName, 36);
		pcNameText.setFormat("VCR OSD Mono", 36, FlxColor.WHITE, CENTER);
		add(pcNameText);
		
		passwordPrompt = new FlxText(0, FlxG.height * 0.65, FlxG.width, "Please enter password to sign in", 20);
		passwordPrompt.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, CENTER);
		add(passwordPrompt);
		
		passwordBox = new FlxSprite(FlxG.width * 0.3, FlxG.height * 0.7);
		passwordBox.makeGraphic(Std.int(FlxG.width * 0.4), 40, FlxColor.BLACK);
		passwordBox.alpha = 0.6;
		add(passwordBox);
		
		passwordDots = new FlxText(FlxG.width * 0.31, FlxG.height * 0.705, FlxG.width * 0.38, "", 24);
		passwordDots.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT);
		add(passwordDots);
		
		enterPrompt = new FlxText(0, FlxG.height * 0.76, FlxG.width, "Press ENTER to sign in", 18);
		enterPrompt.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, CENTER);
		add(enterPrompt);
		
		lockScreenOverlay.alpha = 0;
		pcNameText.alpha = 0;
		passwordPrompt.alpha = 0;
		passwordBox.alpha = 0;
		passwordDots.alpha = 0;
		enterPrompt.alpha = 0;
		timeText.alpha = 0;
		dateText.alpha = 0;
	}

	private function createScanlineEffect():Void {
    	scanlineOverlay = new FlxSprite(0, 0);
    	var scanlineBitmap = new BitmapData(FlxG.width, FlxG.height, true, FlxColor.TRANSPARENT);

    	for (y in 0...FlxG.height) {
        	if (y % 2 == 0) {
            	for (x in 0...FlxG.width) {
                	scanlineBitmap.setPixel32(x, y, FlxColor.fromRGB(0, 0, 0, 80));
            	}
        	}
    	}
    
    	scanlineOverlay.loadGraphic(scanlineBitmap);
    	scanlineOverlay.alpha = 0.3;
    	scanlineOverlay.visible = false;
    	add(scanlineOverlay);
    
    	for (i in 0...5) {
        	var staticBitmap = new BitmapData(FlxG.width, FlxG.height, true, FlxColor.TRANSPARENT);
        
        	for (y in 0...FlxG.height) {
            	for (x in 0...FlxG.width) {
                	if (FlxG.random.bool(15)) {
                    	var alpha = FlxG.random.int(30, 100);
                    	staticBitmap.setPixel32(x, y, FlxColor.fromRGB(255, 255, 255, alpha));
                	}
            	}
        	}
        
        	staticFrames.push(staticBitmap);
    	}
    
    	staticOverlay = new FlxSprite(0, 0);
    	staticOverlay.loadGraphic(staticFrames[0]);
    	staticOverlay.alpha = 0.2;
    	staticOverlay.visible = false;
    	add(staticOverlay);
	}

	private function createDesktopIcon():Void
	{
		var iconSize = 64;
		var padding = 20;
		var labelOffset = 5;
		
		desktopIcon = new FlxSprite(padding, padding);
		
		desktopIcon.loadGraphic(Paths.image('ufmicon'));
		
		var originalWidth = desktopIcon.width;
		var originalHeight = desktopIcon.height;
		
		var scaleFactor = iconSize / Math.max(originalWidth, originalHeight);
		
		desktopIcon.scale.set(scaleFactor, scaleFactor);
		desktopIcon.updateHitbox();
		
		desktopIcon.antialiasing = false;
		desktopIcon.alpha = 0;
		add(desktopIcon);
		
		FlxMouseEvent.add(desktopIcon, 
			function(icon:FlxSprite) {
				if (showingDesktop && !transitionStarted) {
					transitionStarted = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					
					var blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					blackScreen.alpha = 0;
					add(blackScreen);
					
					FlxTween.tween(blackScreen, {alpha: 1}, 1, {
						ease: FlxEase.quartInOut,
						onComplete: function(twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
				}
			}, 
			function(icon:FlxSprite) {
				icon.scale.set(scaleFactor * 0.95, scaleFactor * 0.95);
			}, 
			function(icon:FlxSprite) {
				icon.scale.set(scaleFactor, scaleFactor);
			}
		);
		
		var scaledHeight = originalHeight * scaleFactor;
		iconLabel = new FlxText(padding, padding + scaledHeight + labelOffset, iconSize, "UFM.exe", 12);
		iconLabel.setFormat("VCR OSD Mono", 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		iconLabel.borderSize = 1;
		iconLabel.alpha = 0;
		add(iconLabel);
	}
	
	private function createBloxinManiaIcon():Void
	{
		var iconSize = 64;
		var padding = 20;
		var labelOffset = 5;
		
		bloxinIcon = new FlxSprite(padding, padding + iconSize + padding + 20);
		
		bloxinIcon.loadGraphic(Paths.image('bloxinicon'));
		
		var originalWidth = bloxinIcon.width;
		var originalHeight = bloxinIcon.height;
		
		var scaleFactor = iconSize / Math.max(originalWidth, originalHeight);
		
		bloxinIcon.scale.set(scaleFactor, scaleFactor);
		bloxinIcon.updateHitbox();
		
		bloxinIcon.antialiasing = false;
		bloxinIcon.alpha = 0;
		add(bloxinIcon);
		
		FlxMouseEvent.add(bloxinIcon, 
			function(icon:FlxSprite) {
				if (showingDesktop && !transitionStarted) {
					FlxG.sound.play(Paths.sound('confirmMenu'));
				}
			}, 
			function(icon:FlxSprite) {
				icon.scale.set(scaleFactor * 0.95, scaleFactor * 0.95);
			}, 
			function(icon:FlxSprite) {
				icon.scale.set(scaleFactor, scaleFactor);
			}
		);
		
		var scaledHeight = originalHeight * scaleFactor;
		bloxinLabel = new FlxText(padding, bloxinIcon.y + scaledHeight + labelOffset, iconSize, "BloxinMania.exe", 12);
		bloxinLabel.setFormat("VCR OSD Mono", 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		bloxinLabel.borderSize = 1;
		bloxinLabel.alpha = 0;
		add(bloxinLabel);
	}
	
	private function createLegacyIcon():Void
	{
		var iconSize = 64;
		var padding = 20;
		var labelOffset = 5;
		
		legacyIcon = new FlxSprite(padding, padding + iconSize * 2 + padding * 2 + 40);
		
		legacyIcon.loadGraphic(Paths.image('legacyicon'));
		
		var originalWidth = legacyIcon.width;
		var originalHeight = legacyIcon.height;
		
		var scaleFactor = iconSize / Math.max(originalWidth, originalHeight);
		
		legacyIcon.scale.set(scaleFactor, scaleFactor);
		legacyIcon.updateHitbox();
		
		legacyIcon.antialiasing = false;
		legacyIcon.alpha = 0;
		add(legacyIcon);
		
		FlxMouseEvent.add(legacyIcon, 
			function(icon:FlxSprite) {
				if (showingDesktop && !transitionStarted) {
					FlxG.sound.play(Paths.sound('confirmMenu'));
				}
			}, 
			function(icon:FlxSprite) {
				icon.scale.set(scaleFactor * 0.95, scaleFactor * 0.95);
			}, 
			function(icon:FlxSprite) {
				icon.scale.set(scaleFactor, scaleFactor);
			}
		);
		
		var scaledHeight = originalHeight * scaleFactor;
		legacyLabel = new FlxText(padding, legacyIcon.y + scaledHeight + labelOffset, iconSize, "LegacyUFM.exe", 12);
		legacyLabel.setFormat("VCR OSD Mono", 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		legacyLabel.borderSize = 1;
		legacyLabel.alpha = 0;
		add(legacyLabel);
	}
	
	private function createWallpaperAppIcon():Void
	{
		var iconSize = 64;
		var padding = 20;
		var labelOffset = 5;
		
		wallpaperAppIcon = new FlxSprite(padding, padding + iconSize * 3 + padding * 3 + 60);
		
		wallpaperAppIcon.loadGraphic(Paths.image('wallpapericon'));
		
		var originalWidth = wallpaperAppIcon.width;
		var originalHeight = wallpaperAppIcon.height;
		
		var scaleFactor = iconSize / Math.max(originalWidth, originalHeight);
		
		wallpaperAppIcon.scale.set(scaleFactor, scaleFactor);
		wallpaperAppIcon.updateHitbox();
		
		wallpaperAppIcon.antialiasing = false;
		wallpaperAppIcon.alpha = 0;
		add(wallpaperAppIcon);
		
		FlxMouseEvent.add(wallpaperAppIcon, 
			function(icon:FlxSprite) {
				if (showingDesktop && !transitionStarted && !isWallpaperWindowOpen) {
					openWallpaperWindow();
					FlxG.sound.play(Paths.sound('confirmMenu'));
				}
			}, 
			function(icon:FlxSprite) {
				icon.scale.set(scaleFactor * 0.95, scaleFactor * 0.95);
			}, 
			function(icon:FlxSprite) {
				icon.scale.set(scaleFactor, scaleFactor);
			}
		);
		
		var scaledHeight = originalHeight * scaleFactor;
		wallpaperAppLabel = new FlxText(padding, wallpaperAppIcon.y + scaledHeight + labelOffset, iconSize, "Wallpaper.exe", 12);
		wallpaperAppLabel.setFormat("VCR OSD Mono", 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		wallpaperAppLabel.borderSize = 1;
		wallpaperAppLabel.alpha = 0;
		add(wallpaperAppLabel);
	}
	
	private function createExitIcon():Void
	{
		var iconSize = 64;
		var padding = 20;
		var labelOffset = 5;
		
		exitIcon = new FlxSprite(FlxG.width - iconSize - padding, FlxG.height - iconSize - padding - 20);
		
		exitIcon.loadGraphic(Paths.image('exit'));
		
		var originalWidth = exitIcon.width;
		var originalHeight = exitIcon.height;
		
		var scaleFactor = iconSize / Math.max(originalWidth, originalHeight);
		
		exitIcon.scale.set(scaleFactor, scaleFactor);
		exitIcon.updateHitbox();
		
		exitIcon.antialiasing = false;
		exitIcon.alpha = 0;
		add(exitIcon);
		
		FlxMouseEvent.add(exitIcon, 
			function(icon:FlxSprite) {
				if (showingDesktop && !transitionStarted) {
					transitionStarted = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					
					var blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					blackScreen.alpha = 0;
					add(blackScreen);
					
					FlxTween.tween(blackScreen, {alpha: 1}, 1, {
						ease: FlxEase.quartInOut,
						onComplete: function(twn:FlxTween) {
							#if desktop
							Sys.exit(0);
							#else
							openfl.system.System.exit(0);
							#end
						}
					});
				}
			}, 
			function(icon:FlxSprite) {
				icon.scale.set(scaleFactor * 0.95, scaleFactor * 0.95);
			}, 
			function(icon:FlxSprite) {
				icon.scale.set(scaleFactor, scaleFactor);
			}
		);
		
		var scaledHeight = originalHeight * scaleFactor;
		exitLabel = new FlxText(FlxG.width - iconSize - padding, exitIcon.y + scaledHeight + labelOffset, iconSize, "Exit.exe", 12);
		exitLabel.setFormat("VCR OSD Mono", 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		exitLabel.borderSize = 1;
		exitLabel.alpha = 0;
		add(exitLabel);
	}
	
	private function createSettingsIcon():Void
	{
		var iconSize = 64;
		var padding = 20;
		var labelOffset = 5;
		
		settingsIcon = new FlxSprite(padding, FlxG.height - iconSize - padding - 20);
		
		settingsIcon.loadGraphic(Paths.image('settingsicon'));
		
		var originalWidth = settingsIcon.width;
		var originalHeight = settingsIcon.height;
		
		var scaleFactor = iconSize / Math.max(originalWidth, originalHeight);
		
		settingsIcon.scale.set(scaleFactor, scaleFactor);
		settingsIcon.updateHitbox();
		
		settingsIcon.antialiasing = false;
		settingsIcon.alpha = 0;
		add(settingsIcon);
		
		FlxMouseEvent.add(settingsIcon, 
			function(icon:FlxSprite) {
				if (showingDesktop && !transitionStarted) {
					FlxG.sound.play(Paths.sound('confirmMenu'));
				}
			}, 
			function(icon:FlxSprite) {
				icon.scale.set(scaleFactor * 0.95, scaleFactor * 0.95);
			}, 
			function(icon:FlxSprite) {
				icon.scale.set(scaleFactor, scaleFactor);
			}
		);
		
		var scaledHeight = originalHeight * scaleFactor;
		settingsLabel = new FlxText(padding, settingsIcon.y + scaledHeight + labelOffset, iconSize, "Settings.exe", 12);
		settingsLabel.setFormat("VCR OSD Mono", 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		settingsLabel.borderSize = 1;
		settingsLabel.alpha = 0;
		add(settingsLabel);
	}
	
	// Create the secret icon with HaxeFlixel error image
	private function createSecretIcon():Void
	{
		var iconSize = 64;
		var labelOffset = 5;
		
		secretIcon = new FlxSprite((FlxG.width - iconSize) / 2, (FlxG.height - iconSize) / 2);
		
		// Try to load a non-existent image to get the error sprite
		try {
			secretIcon.loadGraphic(Paths.image('this_image_does_not_exist'));
		} catch (e:Dynamic) {
			// If it fails, manually create an error-like sprite
			secretIcon.makeGraphic(iconSize, iconSize, FlxColor.BLACK);
			var errorText = new FlxText(0, 0, iconSize, "?", 32);
			errorText.setFormat(null, 32, FlxColor.WHITE, CENTER);
			errorText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.RED, 2);
			
			var errorBitmap = new BitmapData(iconSize, iconSize, true, FlxColor.TRANSPARENT);
			errorText.drawFrame();
			var matrix = new Matrix();
			matrix.tx = (iconSize - errorText.width) / 2;
			matrix.ty = (iconSize - errorText.height) / 2;
			errorBitmap.draw(errorText.framePixels, matrix);
			
			secretIcon.loadGraphic(errorBitmap);
		}
		
		secretIcon.antialiasing = false;
		secretIcon.alpha = 0;
		
		FlxMouseEvent.add(secretIcon, 
			function(icon:FlxSprite) {
				if (showingDesktop && !transitionStarted) {
					transitionStarted = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					
					var blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					blackScreen.alpha = 0;
					add(blackScreen);
					
					FlxTween.tween(blackScreen, {alpha: 1}, 1, {
						ease: FlxEase.quartInOut,
						onComplete: function(twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
				}
			}, 
			function(icon:FlxSprite) {
				icon.scale.set(0.95, 0.95);
			}, 
			function(icon:FlxSprite) {
				icon.scale.set(1, 1);
			}
		);
		
		secretIconLabel = new FlxText((FlxG.width - iconSize) / 2, secretIcon.y + iconSize + labelOffset, iconSize, ".exe", 12);
		secretIconLabel.setFormat("VCR OSD Mono", 12, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		secretIconLabel.borderSize = 1;
		secretIconLabel.alpha = 0;
	}
	
	private function openWallpaperWindow():Void
	{
		isWallpaperWindowOpen = true;
		
		var windowWidth = FlxG.width * 0.6;
		var windowHeight = FlxG.height * 0.7;
		var windowX = (FlxG.width - windowWidth) / 2;
		var windowY = (FlxG.height - windowHeight) / 2;
		
		wallpaperWindow = new FlxSprite(windowX, windowY);
		wallpaperWindow.makeGraphic(Std.int(windowWidth), Std.int(windowHeight), FlxColor.fromRGB(32, 32, 32));
		wallpaperWindow.alpha = 0;
		add(wallpaperWindow);
		
		var headerHeight = 30;
		wallpaperWindowHeader = new FlxSprite(windowX, windowY);
		wallpaperWindowHeader.makeGraphic(Std.int(windowWidth), headerHeight, FlxColor.fromRGB(50, 50, 50));
		wallpaperWindowHeader.alpha = 0;
		add(wallpaperWindowHeader);
		
		FlxMouseEvent.add(wallpaperWindowHeader, null, 
			function(header:FlxSprite) {
				isDraggingWindow = true;
				dragOffsetX = FlxG.mouse.x - header.x;
				dragOffsetY = FlxG.mouse.y - header.y;
			}, 
			function(header:FlxSprite) {
				isDraggingWindow = false;
			}
		);
		
		wallpaperWindowTitle = new FlxText(windowX + 10, windowY + 5, windowWidth - 100, "Wallpaper Settings", 16);
		wallpaperWindowTitle.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT);
		wallpaperWindowTitle.alpha = 0;
		add(wallpaperWindowTitle);
		
		var buttonSize = 16;
		var buttonPadding = 5;
		
		wallpaperWindowCloseButton = new FlxSprite(windowX + windowWidth - buttonSize - buttonPadding, windowY + (headerHeight - buttonSize) / 2);
		wallpaperWindowCloseButton.makeGraphic(buttonSize, buttonSize, FlxColor.RED);
		wallpaperWindowCloseButton.alpha = 0;
		add(wallpaperWindowCloseButton);
		
		FlxMouseEvent.add(wallpaperWindowCloseButton, 
			function(button:FlxSprite) {
				if (isWallpaperWindowOpen) {
					closeWallpaperWindow();
					FlxG.sound.play(Paths.sound('cancelMenu'));
				}
			}, 
			function(button:FlxSprite) {
				button.color = FlxColor.fromRGB(255, 100, 100);
			}, 
			function(button:FlxSprite) {
				button.color = FlxColor.RED;
			}
		);
		
		wallpaperWindowMaximizeButton = new FlxSprite(wallpaperWindowCloseButton.x - buttonSize - buttonPadding, windowY + (headerHeight - buttonSize) / 2);
		wallpaperWindowMaximizeButton.makeGraphic(buttonSize, buttonSize, FlxColor.fromRGB(0, 200, 0));
		wallpaperWindowMaximizeButton.alpha = 0;
		add(wallpaperWindowMaximizeButton);
		
		wallpaperWindowMinimizeButton = new FlxSprite(wallpaperWindowMaximizeButton.x - buttonSize - buttonPadding, windowY + (headerHeight - buttonSize) / 2);
		wallpaperWindowMinimizeButton.makeGraphic(buttonSize, buttonSize, FlxColor.YELLOW);
		wallpaperWindowMinimizeButton.alpha = 0;
		add(wallpaperWindowMinimizeButton);
		
		var optionWidth = 100;
		var optionHeight = 80;
		var optionSpacing = 20;
		var optionsPerRow = 3;
		var startX = windowX + (windowWidth - (optionWidth * optionsPerRow + optionSpacing * (optionsPerRow - 1))) / 2;
		var startY = windowY + headerHeight + 40;
		
		var wallpaperNames = ["Default", "Blue", "Green", "Red", "Purple"];
		var wallpaperPaths = [
			'wallpapers/default',
			'wallpapers/blue',
			'wallpapers/green',
			'wallpapers/red',
			'wallpapers/purple'
		];
		
		var fallbackColors = [
			FlxColor.BLACK,
			FlxColor.fromRGB(0, 120, 215),
			FlxColor.fromRGB(0, 150, 50),
			FlxColor.fromRGB(200, 30, 30),
			FlxColor.fromRGB(120, 0, 150)
		];
		
		for (i in 0...wallpaperNames.length) {
			var row = Math.floor(i / optionsPerRow);
			var col = i % optionsPerRow;
			
			var optionX = startX + col * (optionWidth + optionSpacing);
			var optionY = startY + row * (optionHeight + optionSpacing + 20);
			
			var option = new FlxSprite(optionX, optionY);
			
			try {
				option.loadGraphic(Paths.image(wallpaperPaths[i]));
				
				var scaleX = optionWidth / option.width;
				var scaleY = optionHeight / option.height;
				var scale = Math.min(scaleX, scaleY);
				
				option.scale.set(scale, scale);
				option.updateHitbox();
				
				option.x = optionX + (optionWidth - option.width) / 2;
				option.y = optionY + (optionHeight - option.height) / 2;
			} catch (e) {
				option.makeGraphic(optionWidth, optionHeight, fallbackColors[i]);
				option.x = optionX;
				option.y = optionY;
			}
			
			option.alpha = 0;
			option.ID = i;
			wallpaperOptions.push(option);
			add(option);
			
			var label = new FlxText(optionX, optionY + optionHeight + 5, optionWidth, wallpaperNames[i], 14);
			label.setFormat("VCR OSD Mono", 14, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			label.borderSize = 1;
			label.alpha = 0;
			wallpaperOptionLabels.push(label);
			add(label);
			
			FlxMouseEvent.add(option, 
				function(opt:FlxSprite) {
					selectWallpaper(opt.ID);
				},
				function(opt:FlxSprite) {
					if (opt.ID != selectedWallpaperIndex) {
						opt.alpha = 0.85;
					}
				},
				function(opt:FlxSprite) {
					if (opt.ID != selectedWallpaperIndex) {
						opt.alpha = 0.7;
					}
				}
			);
		}
		
		var buttonWidth = 120;
		var buttonHeight = 40;
		var buttonX = windowX + (windowWidth - buttonWidth) / 2;
		var buttonY = windowY + windowHeight - buttonHeight - 20;
		
		wallpaperApplyButton = new FlxSprite(buttonX, buttonY);
		wallpaperApplyButton.makeGraphic(Std.int(buttonWidth), Std.int(buttonHeight), FlxColor.fromRGB(0, 120, 215));
		wallpaperApplyButton.alpha = 0;
		add(wallpaperApplyButton);
		
		wallpaperApplyText = new FlxText(buttonX, buttonY + 10, buttonWidth, "Apply", 16);
		wallpaperApplyText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER);
		wallpaperApplyText.alpha = 0;
		add(wallpaperApplyText);
		
		FlxMouseEvent.add(wallpaperApplyButton, 
			function(button:FlxSprite) {
				if (selectedWallpaperIndex >= 0) {
					applyWallpaper(selectedWallpaperIndex);
					FlxG.sound.play(Paths.sound('confirmMenu'));
				}
			},
			function(button:FlxSprite) {
				button.color = FlxColor.fromRGB(0, 150, 255);
			},
			function(button:FlxSprite) {
				button.color = FlxColor.fromRGB(0, 120, 215);
			}
		);
		
		FlxTween.tween(wallpaperWindow, {alpha: 0.95}, 0.3);
		FlxTween.tween(wallpaperWindowHeader, {alpha: 0.95}, 0.3);
		FlxTween.tween(wallpaperWindowTitle, {alpha: 1}, 0.3);
		FlxTween.tween(wallpaperWindowCloseButton, {alpha: 1}, 0.3);
		FlxTween.tween(wallpaperWindowMaximizeButton, {alpha: 1}, 0.3);
		FlxTween.tween(wallpaperWindowMinimizeButton, {alpha: 1}, 0.3);
		FlxTween.tween(wallpaperApplyButton, {alpha: 1}, 0.3);
		FlxTween.tween(wallpaperApplyText, {alpha: 1}, 0.3);
		
		for (i in 0...wallpaperOptions.length) {
			var option = wallpaperOptions[i];
			var label = wallpaperOptionLabels[i];
			
			FlxTween.tween(option, {alpha: 0.7}, 0.3);
			FlxTween.tween(label, {alpha: 1}, 0.3);
		}
		
		selectWallpaper(0);
	}
	
	private function selectWallpaper(index:Int):Void
	{
		selectedWallpaperIndex = index;
		
		for (i in 0...wallpaperOptions.length) {
			var option = wallpaperOptions[i];
			if (i == index) {
				option.alpha = 1.0;
			} else {
				option.alpha = 0.7;
			}
		}
	}
	
	private function applyWallpaper(index:Int):Void
	{
		try {
			var wallpaperPaths = [
				'wallpapers/default',
				'wallpapers/blue',
				'wallpapers/green',
				'wallpapers/red',
				'wallpapers/purple'
			];
			
			wallpaperSprite.loadGraphic(Paths.image(wallpaperPaths[index]));
			
			var scaleX:Float = FlxG.width / wallpaperSprite.width;
			var scaleY:Float = FlxG.height / wallpaperSprite.height;
			var scale:Float = Math.max(scaleX, scaleY);
			
			wallpaperSprite.scale.set(scale, scale);
			wallpaperSprite.updateHitbox();
			
			wallpaperSprite.x = (FlxG.width - wallpaperSprite.width) / 2;
			wallpaperSprite.y = (FlxG.height - wallpaperSprite.height) / 2;
		} catch (e) {
			var color = switch(index) {
				case 0: FlxColor.BLACK;
				case 1: FlxColor.fromRGB(0, 120, 215);
				case 2: FlxColor.fromRGB(0, 150, 50);
				case 3: FlxColor.fromRGB(200, 30, 30);
				case 4: FlxColor.fromRGB(120, 0, 150);
				default: FlxColor.BLACK;
			};
			
			wallpaperSprite.makeGraphic(FlxG.width, FlxG.height, color);
		}
		
		var flash = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		flash.alpha = 0;
		add(flash);
		
		FlxTween.tween(flash, {alpha: 0.3}, 0.1, {
			onComplete: function(twn:FlxTween) {
				FlxTween.tween(flash, {alpha: 0}, 0.1, {
					onComplete: function(twn:FlxTween) {
						remove(flash);
					}
				});
			}
		});
	}
	
	private function closeWallpaperWindow():Void
	{
		if (!isWallpaperWindowOpen) return;
		
		isWallpaperWindowOpen = false;
		
		FlxTween.tween(wallpaperWindow, {alpha: 0}, 0.2, {
			onComplete: function(twn:FlxTween) {
				cleanupWallpaperWindow();
			}
		});
		
		FlxTween.tween(wallpaperWindowHeader, {alpha: 0}, 0.2);
		FlxTween.tween(wallpaperWindowTitle, {alpha: 0}, 0.2);
		FlxTween.tween(wallpaperWindowCloseButton, {alpha: 0}, 0.2);
		FlxTween.tween(wallpaperWindowMaximizeButton, {alpha: 0}, 0.2);
		FlxTween.tween(wallpaperWindowMinimizeButton, {alpha: 0}, 0.2);
		FlxTween.tween(wallpaperApplyButton, {alpha: 0}, 0.2);
		FlxTween.tween(wallpaperApplyText, {alpha: 0}, 0.2);
		
		for (option in wallpaperOptions) {
			FlxTween.tween(option, {alpha: 0}, 0.2);
		}
		
		for (label in wallpaperOptionLabels) {
			FlxTween.tween(label, {alpha: 0}, 0.2);
		}
	}
	
	private function cleanupWallpaperWindow():Void
	{
		if (wallpaperWindow != null) {
			remove(wallpaperWindow);
			wallpaperWindow = null;
		}
		
		if (wallpaperWindowHeader != null) {
			FlxMouseEvent.remove(wallpaperWindowHeader);
			remove(wallpaperWindowHeader);
			wallpaperWindowHeader = null;
		}
		
		if (wallpaperWindowTitle != null) {
			remove(wallpaperWindowTitle);
			wallpaperWindowTitle = null;
		}
		
		if (wallpaperWindowCloseButton != null) {
			FlxMouseEvent.remove(wallpaperWindowCloseButton);
			remove(wallpaperWindowCloseButton);
			wallpaperWindowCloseButton = null;
		}
		
		if (wallpaperWindowMaximizeButton != null) {
			remove(wallpaperWindowMaximizeButton);
			wallpaperWindowMaximizeButton = null;
		}
		
		if (wallpaperWindowMinimizeButton != null) {
			remove(wallpaperWindowMinimizeButton);
			wallpaperWindowMinimizeButton = null;
		}
		
		if (wallpaperApplyButton != null) {
			FlxMouseEvent.remove(wallpaperApplyButton);
			remove(wallpaperApplyButton);
			wallpaperApplyButton = null;
		}
		
		if (wallpaperApplyText != null) {
			remove(wallpaperApplyText);
			wallpaperApplyText = null;
		}
		
		for (option in wallpaperOptions) {
			if (option != null) {
				FlxMouseEvent.remove(option);
				remove(option);
			}
		}
		wallpaperOptions = [];
		
		for (label in wallpaperOptionLabels) {
			if (label != null) {
				remove(label);
			}
		}
		wallpaperOptionLabels = [];
	}
	
	private function getPCName():Void
	{
		#if windows
		try {
			var tempFile = "temp_pc_name.txt";
			
			Sys.command('cmd /c hostname > ' + tempFile + ' 2>nul');
			
			if (FileSystem.exists(tempFile)) {
				var name = StringTools.trim(File.getContent(tempFile));
				if (name != null && name != "") {
					pcName = name;
				}
				FileSystem.deleteFile(tempFile);
			}
		} catch (e:Dynamic) {
			trace("Error getting PC name: " + e);
		}
		#end
	}
	
	private function startOpeningAnimation():Void
	{
		FlxTween.tween(topCurtain, {y: -topCurtain.height}, 2, {
			ease: FlxEase.sineInOut,
			startDelay: 0.5
		});
		
		FlxTween.tween(bottomCurtain, {y: FlxG.height}, 2, {
			ease: FlxEase.sineInOut,
			startDelay: 0.5,
			onComplete: function(twn:FlxTween) {
				remove(topCurtain);
				remove(bottomCurtain);
				
				animationComplete = true;
				
				showLockScreen();
			}
		});
	}
	
	private function showLockScreen():Void
	{
		FlxTween.tween(lockScreenOverlay, {alpha: 0.7}, 0.5);
		FlxTween.tween(pcNameText, {alpha: 1}, 0.5);
		FlxTween.tween(passwordPrompt, {alpha: 1}, 0.5);
		FlxTween.tween(passwordBox, {alpha: 0.6}, 0.5);
		FlxTween.tween(passwordDots, {alpha: 1}, 0.5);
		FlxTween.tween(enterPrompt, {alpha: 1}, 0.5);
		FlxTween.tween(timeText, {alpha: 1}, 0.5);
		FlxTween.tween(dateText, {alpha: 1}, 0.5);
	}
	
	private function createLoadingDots():Void
	{
		loadingDots = new FlxGroup();
		add(loadingDots);
		
		var dotCount = 5;
		var dotSize = 12;
		var dotSpacing = 20;
		var totalWidth = (dotCount - 1) * dotSpacing;
		var startX = (FlxG.width - totalWidth) / 2;
		
		for (i in 0...dotCount) {
			var dot = new FlxSprite(startX + (i * dotSpacing), FlxG.height * 0.5);
			dot.makeGraphic(dotSize, dotSize, FlxColor.WHITE);
			dot.alpha = 0.2;
			loadingDots.add(dot);
			
			var delay = i * 0.15;
			new FlxTimer().start(delay, function(tmr:FlxTimer) {
				animateDot(dot, i);
			});
		}
	}
	
	private function animateDot(dot:FlxSprite, index:Int):Void
	{
		if (loadingComplete) return;
		
		var tween = FlxTween.tween(dot, {alpha: 1}, 0.5, {
			ease: FlxEase.sineInOut,
			onComplete: function(twn:FlxTween) {
				if (loadingComplete) return;
				
				var tween2 = FlxTween.tween(dot, {alpha: 0.2}, 0.5, {
					ease: FlxEase.sineInOut,
					onComplete: function(twn:FlxTween) {
						if (!loadingComplete) {
							animateDot(dot, index);
						}
					}
				});
				
				dotTweens[index * 2 + 1] = tween2;
			}
		});
		
		dotTweens[index * 2] = tween;
	}
	
	private function stopLoadingAnimation():Void
	{
		loadingComplete = true;
		
		for (tween in dotTweens) {
			if (tween != null && !tween.finished) {
				tween.cancel();
			}
		}
		
		for (dot in loadingDots.members) {
			if (dot != null) {
				FlxTween.tween(dot, {alpha: 0}, 0.5);
			}
		}
	}
	
	private function unlockComputer():Void
	{
		isLocked = false;
		dotTweens = [];
		
		// Check for secret password
		if (passwordChars.toUpperCase() == "THEPRICE") {
			secretPasswordEntered = true;
			
			// Create the secret icon
			createSecretIcon();
			
			// Add red tint overlay
			add(redTintOverlay);

			createScanlineEffect();
			
			FlxG.sound.play(Paths.sound('cancelMenu')); // Use a different sound for the secret
		}
		
		FlxTween.tween(lockScreenOverlay, {alpha: 0}, 0.5);
		FlxTween.tween(pcNameText, {alpha: 0}, 0.5);
		FlxTween.tween(passwordPrompt, {alpha: 0}, 0.5);
		FlxTween.tween(passwordBox, {alpha: 0}, 0.5);
		FlxTween.tween(passwordDots, {alpha: 0}, 0.5);
		FlxTween.tween(enterPrompt, {alpha: 0}, 0.5);
		FlxTween.tween(timeText, {alpha: 0}, 0.5);
		FlxTween.tween(dateText, {alpha: 0}, 0.5);
		
		for (member in members) {
			if (member != null && member != wallpaperSprite && member != desktopIcon && member != iconLabel 
				&& member != bloxinIcon && member != bloxinLabel && member != legacyIcon && member != legacyLabel
				&& member != wallpaperAppIcon && member != wallpaperAppLabel
				&& member != exitIcon && member != exitLabel && member != settingsIcon && member != settingsLabel
				&& member != redTintOverlay && member != secretIcon && member != secretIconLabel) {
				FlxTween.tween(member, {alpha: 0}, 0.5);
			}
		}
		
		createLoadingDots();
		
		new FlxTimer().start(3.5, function(tmr:FlxTimer) {
			stopLoadingAnimation();
			if (secretPasswordEntered) {
				showSecretDesktop();
			} else {
				showDesktopIcon();
			}
		});
		
		if (!secretPasswordEntered) {
			FlxG.sound.play(Paths.sound('confirmMenu'));
		}
	}
	
	private function showSecretDesktop():Void
	{
		showingDesktop = true;
		
		// Add the secret icon and label to the stage if not already added
		if (!members.contains(secretIcon)) {
			add(secretIcon);
		}
		if (!members.contains(secretIconLabel)) {
			add(secretIconLabel);
		}
		
		// Show only the secret icon
		FlxTween.tween(secretIcon, {alpha: 1}, 0.5);
		FlxTween.tween(secretIconLabel, {alpha: 1}, 0.5);
		
		// Play a glitch sound or static
		FlxG.sound.play(Paths.sound('static'), 0.3);
	}
	
	private function showDesktopIcon():Void
	{
		showingDesktop = true;
		
		FlxTween.tween(desktopIcon, {alpha: 1}, 0.5);
		FlxTween.tween(iconLabel, {alpha: 1}, 0.5);
		FlxTween.tween(bloxinIcon, {alpha: 1}, 0.5);
		FlxTween.tween(bloxinLabel, {alpha: 1}, 0.5);
		FlxTween.tween(legacyIcon, {alpha: 1}, 0.5);
		FlxTween.tween(legacyLabel, {alpha: 1}, 0.5);
		FlxTween.tween(wallpaperAppIcon, {alpha: 1}, 0.5);
		FlxTween.tween(wallpaperAppLabel, {alpha: 1}, 0.5);
		FlxTween.tween(exitIcon, {alpha: 1}, 0.5);
		FlxTween.tween(exitLabel, {alpha: 1}, 0.5);
		FlxTween.tween(settingsIcon, {alpha: 1}, 0.5);
		FlxTween.tween(settingsLabel, {alpha: 1}, 0.5);
	}
	
	private function loadWallpaper():Void
	{
		#if windows
		try {
			var tempPath = getWallpaperPath();
			
			if (tempPath != null && tempPath != "") {
				var tempWallpaperFile = "temp_wallpaper.bmp";
				
				try {
					if (FileSystem.exists(tempPath)) {
						File.copy(tempPath, tempWallpaperFile);
					} else {
						var psScriptFile = "get_wallpaper.ps1";
						var scriptContent = 
							"$wallpaper = (Get-ItemProperty -Path 'HKCU:\\Control Panel\\Desktop' -Name Wallpaper).Wallpaper\n" +
							"[System.Drawing.Image]::FromFile($wallpaper).Save('" + tempWallpaperFile + "', [System.Drawing.Imaging.ImageFormat]::Bmp)";
						
						File.saveContent(psScriptFile, scriptContent);
						
						Sys.command('cmd /c powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File ' + psScriptFile + ' 2>nul');
						
						if (FileSystem.exists(psScriptFile)) {
							FileSystem.deleteFile(psScriptFile);
						}
					}
					
					if (FileSystem.exists(tempWallpaperFile)) {
						var bitmapData = BitmapData.fromFile(tempWallpaperFile);
						if (bitmapData != null) {
							var pixelSize = 4;
							var pixelatedBitmap = pixelateBitmap(bitmapData, pixelSize);
							
							wallpaperSprite.loadGraphic(pixelatedBitmap);
							
							var scaleX:Float = FlxG.width / wallpaperSprite.width;
							var scaleY:Float = FlxG.height / wallpaperSprite.height;
							
							var scale:Float = Math.max(scaleX, scaleY);
							
							wallpaperSprite.scale.set(scale, scale);
							wallpaperSprite.updateHitbox();
							
							wallpaperSprite.x = (FlxG.width - wallpaperSprite.width) / 2;
							wallpaperSprite.y = (FlxG.height - wallpaperSprite.height) / 2;
							
							wallpaperSprite.antialiasing = false;
							
							var overlay = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
							overlay.alpha = 0.3;
							add(overlay);
						}
						
						try {
							if (FileSystem.exists(tempWallpaperFile)) {
								FileSystem.deleteFile(tempWallpaperFile);
							}
						} catch (e:Dynamic) {
							trace("Error deleting temp wallpaper: " + e);
						}
					}
				} catch (e:Dynamic) {
					trace("Error copying wallpaper: " + e);
				}
			}
		} catch (e:Dynamic) {
			trace("Error loading wallpaper: " + e);
		}
		#end
	}
	
	private function pixelateBitmap(original:BitmapData, pixelSize:Int):BitmapData {
		var w = Std.int(original.width / pixelSize);
		var h = Std.int(original.height / pixelSize);
		
		var result = new BitmapData(original.width, original.height, true, 0);
		var smallVersion = new BitmapData(w, h, true, 0);
		
		smallVersion.draw(original, new Matrix(w / original.width, 0, 0, h / original.height, 0, 0));
		result.draw(smallVersion, new Matrix(pixelSize, 0, 0, pixelSize, 0, 0));
		
		return result;
	}
	
	#if windows
	private function getWallpaperPath():String {
		try {
			var tempFile = "temp_wallpaper_path.txt";
			
			Sys.command('cmd /c powershell -WindowStyle Hidden -command "(Get-ItemProperty -Path \'HKCU:\\Control Panel\\Desktop\' -Name Wallpaper).Wallpaper" > ' + tempFile + ' 2>nul');
			
			if (FileSystem.exists(tempFile)) {
				var path = StringTools.trim(File.getContent(tempFile));
				
				try {
					FileSystem.deleteFile(tempFile);
				} catch (e:Dynamic) {
					trace("Error deleting temp file: " + e);
				}
				
				return path;
			}
		} catch (e:Dynamic) {
			trace("Error getting wallpaper path: " + e);
		}
		
		return null;
	}
	#end

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (secretPasswordEntered && staticOverlay != null) {
        	staticTimer += elapsed;
        	if (staticTimer > 0.05) {
            	staticTimer = 0;
            	currentStaticFrame = (currentStaticFrame + 1) % staticFrames.length;
            	staticOverlay.loadGraphic(staticFrames[currentStaticFrame]);
            
            	if (FlxG.random.bool(20)) {
                	FlxTween.tween(staticOverlay, {alpha: FlxG.random.float(0.1, 0.3)}, 0.1);
            	}
        	}
    	}
		
		if (isDraggingWindow && wallpaperWindowHeader != null) {
			var newX = FlxG.mouse.x - dragOffsetX;
			var newY = FlxG.mouse.y - dragOffsetY;
			
			newX = Math.max(0, Math.min(FlxG.width - wallpaperWindow.width, newX));
			newY = Math.max(0, Math.min(FlxG.height - wallpaperWindow.height, newY));
			
			wallpaperWindowHeader.setPosition(newX, newY);
			wallpaperWindow.setPosition(newX, newY);
			wallpaperWindowTitle.setPosition(newX + 10, newY + 5);
			
			var headerHeight = 30;
			var buttonSize = 16;
			var buttonPadding = 5;
			
			wallpaperWindowCloseButton.setPosition(newX + wallpaperWindow.width - buttonSize - buttonPadding, newY + (headerHeight - buttonSize) / 2);
			wallpaperWindowMaximizeButton.setPosition(wallpaperWindowCloseButton.x - buttonSize - buttonPadding, newY + (headerHeight - buttonSize) / 2);
			wallpaperWindowMinimizeButton.setPosition(wallpaperWindowMaximizeButton.x - buttonSize - buttonPadding, newY + (headerHeight - buttonSize) / 2);
			
			var optionWidth = 100;
			var optionHeight = 80;
			var optionSpacing = 20;
			var optionsPerRow = 3;
			var startX = newX + (wallpaperWindow.width - (optionWidth * optionsPerRow + optionSpacing * (optionsPerRow - 1))) / 2;
			var startY = newY + headerHeight + 40;
			
			for (i in 0...wallpaperOptions.length) {
				var row = Math.floor(i / optionsPerRow);
				var col = i % optionsPerRow;
				
				var optionX = startX + col * (optionWidth + optionSpacing);
				var optionY = startY + row * (optionHeight + optionSpacing + 20);
				
				var option = wallpaperOptions[i];
				
				if (option.scale.x != 1 || option.scale.y != 1) {
					option.setPosition(
						optionX + (optionWidth - option.width) / 2,
						optionY + (optionHeight - option.height) / 2
					);
				} else {
					option.setPosition(optionX, optionY);
				}
				
				wallpaperOptionLabels[i].setPosition(optionX, optionY + optionHeight + 5);
			}
			
			var buttonWidth = 120;
			var buttonHeight = 40;
			var buttonX = newX + (wallpaperWindow.width - buttonWidth) / 2;
			var buttonY = newY + wallpaperWindow.height - buttonHeight - 20;
			
			wallpaperApplyButton.setPosition(buttonX, buttonY);
			wallpaperApplyText.setPosition(buttonX, buttonY + 10);
		}
		
		if (animationComplete) {
			if (isLocked) {
				if (FlxG.keys.justPressed.ANY) {
					if (FlxG.keys.justPressed.BACKSPACE && passwordChars.length > 0) {
						passwordChars = passwordChars.substring(0, passwordChars.length - 1);
						updatePasswordDisplay();
					}
					else if (FlxG.keys.justPressed.ENTER && passwordChars.length > 0) {
						unlockComputer();
					}
					else if (passwordChars.length < 20) {
						var key = "";
						if (FlxG.keys.justPressed.A) key = "A";
						else if (FlxG.keys.justPressed.B) key = "B";
						else if (FlxG.keys.justPressed.C) key = "C";
						else if (FlxG.keys.justPressed.D) key = "D";
						else if (FlxG.keys.justPressed.E) key = "E";
						else if (FlxG.keys.justPressed.F) key = "F";
						else if (FlxG.keys.justPressed.G) key = "G";
						else if (FlxG.keys.justPressed.H) key = "H";
						else if (FlxG.keys.justPressed.I) key = "I";
						else if (FlxG.keys.justPressed.J) key = "J";
						else if (FlxG.keys.justPressed.K) key = "K";
						else if (FlxG.keys.justPressed.L) key = "L";
						else if (FlxG.keys.justPressed.M) key = "M";
						else if (FlxG.keys.justPressed.N) key = "N";
						else if (FlxG.keys.justPressed.O) key = "O";
						else if (FlxG.keys.justPressed.P) key = "P";
						else if (FlxG.keys.justPressed.Q) key = "Q";
						else if (FlxG.keys.justPressed.R) key = "R";
						else if (FlxG.keys.justPressed.S) key = "S";
						else if (FlxG.keys.justPressed.T) key = "T";
						else if (FlxG.keys.justPressed.U) key = "U";
						else if (FlxG.keys.justPressed.V) key = "V";
						else if (FlxG.keys.justPressed.W) key = "W";
						else if (FlxG.keys.justPressed.X) key = "X";
						else if (FlxG.keys.justPressed.Y) key = "Y";
						else if (FlxG.keys.justPressed.Z) key = "Z";
						else if (FlxG.keys.justPressed.ZERO) key = "0";
						else if (FlxG.keys.justPressed.ONE) key = "1";
						else if (FlxG.keys.justPressed.TWO) key = "2";
						else if (FlxG.keys.justPressed.THREE) key = "3";
						else if (FlxG.keys.justPressed.FOUR) key = "4";
						else if (FlxG.keys.justPressed.FIVE) key = "5";
						else if (FlxG.keys.justPressed.SIX) key = "6";
						else if (FlxG.keys.justPressed.SEVEN) key = "7";
						else if (FlxG.keys.justPressed.EIGHT) key = "8";
						else if (FlxG.keys.justPressed.NINE) key = "9";
						else if (FlxG.keys.justPressed.SPACE) key = " ";
						
						if (key != "") {
							passwordChars += key;
							updatePasswordDisplay();
						}
					}
				}
			}
			else if (!showingDesktop) {
				if (controls.ACCEPT && !transitionStarted && loadingComplete) {
					transitionStarted = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					
					var blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					blackScreen.alpha = 0;
					add(blackScreen);
					
					FlxTween.tween(blackScreen, {alpha: 1}, 1, {
						ease: FlxEase.quartInOut,
						onComplete: function(twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
				}
				
				if (controls.BACK && !transitionStarted && loadingComplete) {
					transitionStarted = true;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					
					var blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
					blackScreen.alpha = 0;
					add(blackScreen);
					
					FlxTween.tween(blackScreen, {alpha: 1}, 1, {
						ease: FlxEase.quartInOut,
						onComplete: function(twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
				}
			}
		}
		
		// If we're in secret mode, occasionally add glitch effects
		if (secretPasswordEntered && showingDesktop && !transitionStarted) {
			// Random glitch effect
			if (FlxG.random.bool(0.5)) {
				var glitchOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.RED);
				glitchOverlay.alpha = FlxG.random.float(0.05, 0.1);
				add(glitchOverlay);
				
				FlxTween.tween(glitchOverlay, {alpha: 0}, FlxG.random.float(0.1, 0.3), {
					onComplete: function(twn:FlxTween) {
						remove(glitchOverlay);
					}
				});
			}
		}
	}
	
	private function updatePasswordDisplay():Void {
		var dots = "";
		for (i in 0...passwordChars.length) {
			dots += "•";
		}
		passwordDots.text = dots;
	}
	
	override public function destroy():Void {
		for (bitmap in staticFrames) {
        	if (bitmap != null) {
            	bitmap.dispose();
        	}
    	}
		staticFrames = null;

		if (desktopIcon != null) {
			FlxMouseEvent.remove(desktopIcon);
		}
		
		if (bloxinIcon != null) {
			FlxMouseEvent.remove(bloxinIcon);
		}
		
		if (legacyIcon != null) {
			FlxMouseEvent.remove(legacyIcon);
		}
		
		if (wallpaperAppIcon != null) {
			FlxMouseEvent.remove(wallpaperAppIcon);
		}
		
		if (exitIcon != null) {
			FlxMouseEvent.remove(exitIcon);
		}
		
		if (settingsIcon != null) {
			FlxMouseEvent.remove(settingsIcon);
		}
		
		if (secretIcon != null) {
			FlxMouseEvent.remove(secretIcon);
		}
		
		if (wallpaperWindowHeader != null) {
			FlxMouseEvent.remove(wallpaperWindowHeader);
		}
		
		if (wallpaperWindowCloseButton != null) {
			FlxMouseEvent.remove(wallpaperWindowCloseButton);
		}
		
		if (wallpaperApplyButton != null) {
			FlxMouseEvent.remove(wallpaperApplyButton);
		}
		
		for (option in wallpaperOptions) {
			if (option != null) {
				FlxMouseEvent.remove(option);
			}
		}
		
		super.destroy();
	}
}
