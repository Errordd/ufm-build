package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween; 

import objects.MenuItem;
import objects.MenuCharacter;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var overlaySprite:FlxSprite;
	var backgroundOverlay:FlxSprite;
	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	private static var curWeek:Int = 0;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var loadedWeeks:Array<WeekData> = [];
	var whiteBackground:FlxSprite;
	
	var weekCharacter:FlxSprite;
	var noxxWeekCharacter:FlxSprite;
	var characterTween:FlxTween;
	var hasAnimatedCharacter:Bool = false;
	
	var titleCard:FlxSprite;
	var titleCardTween:FlxTween;
	var hasAnimatedTitleCard:Bool = false;
	
	var maxWeeks:Int = 3;
	
	var difficultyOverlay:FlxSprite;
	var difficultyText:FlxText;
	var inDifficultySelection:Bool = false;
	var difficultyContainer:FlxGroup;
	
	var checkerboardBG:FlxSprite;
	var checkerboardBG2:FlxSprite;
	var scrollSpeed:Float = 60;

	var pulseEffect:FlxTween;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		inDifficultySelection = false;
		hasAnimatedCharacter = false;
		hasAnimatedTitleCard = false;
		movedBack = false;
		selectedWeek = false;
		stopspamming = false;

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		whiteBackground = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		add(whiteBackground);
		
		backgroundOverlay = new FlxSprite(0, 0).loadGraphic(Paths.image('pkoverlay'));
		backgroundOverlay.setGraphicSize(FlxG.width, FlxG.height);
		backgroundOverlay.updateHitbox();
		backgroundOverlay.antialiasing = ClientPrefs.data.antialiasing;
		backgroundOverlay.alpha = 0;
		add(backgroundOverlay);
		
		FlxTween.tween(backgroundOverlay, {alpha: 1}, 1.2, {
			ease: FlxEase.quartInOut,
			onComplete: function(twn:FlxTween) {
				pulseEffect = FlxTween.tween(backgroundOverlay, {alpha: 0.85}, 2.5, {
					ease: FlxEase.sineInOut,
					type: PINGPONG
				});
			}
		});

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		var weekCount = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			if (weekCount >= maxWeeks) break;
			
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				weekCount++;
			}
		}

		overlaySprite = new FlxSprite(-1920, -200).loadGraphic(Paths.image('overlayshit'));
		overlaySprite.setGraphicSize(1920, 1080);
		overlaySprite.updateHitbox();
		overlaySprite.antialiasing = ClientPrefs.data.antialiasing;
		add(overlaySprite);
		
		FlxTween.tween(overlaySprite, {x: 0}, 1, {
			ease: FlxEase.quartOut,
			startDelay: 0.3
		});
		
		weekCharacter = new FlxSprite(-800, 50);
		weekCharacter.frames = Paths.getSparrowAtlas('pkweekchar');
		weekCharacter.animation.addByPrefix('idle', 'pk', 24, true);
		weekCharacter.animation.play('idle');
		weekCharacter.antialiasing = ClientPrefs.data.antialiasing;
		add(weekCharacter);
		
		noxxWeekCharacter = new FlxSprite(-800, 50);
		noxxWeekCharacter.frames = Paths.getSparrowAtlas('noxxweekchar');
		noxxWeekCharacter.animation.addByPrefix('idle', 'Symbol 1', 24, true);
		noxxWeekCharacter.animation.play('idle');
		noxxWeekCharacter.antialiasing = ClientPrefs.data.antialiasing;
		noxxWeekCharacter.visible = false;
		add(noxxWeekCharacter);
		
		titleCard = new FlxSprite(FlxG.width + 200, 100);
		titleCard.frames = Paths.getSparrowAtlas('pkweektitlecard');
		titleCard.animation.addByPrefix('idle', 'weekthesubway', 24, true);
		titleCard.animation.play('idle');
		titleCard.antialiasing = ClientPrefs.data.antialiasing;
		add(titleCard);
		
		checkerboardBG = new FlxSprite(0, 0).loadGraphic(Paths.image('checkerboarduno'));
		checkerboardBG.setGraphicSize(1920, 1080);
		checkerboardBG.updateHitbox();
		checkerboardBG.antialiasing = ClientPrefs.data.antialiasing;
		checkerboardBG.alpha = 0.5;
		checkerboardBG.visible = false;
		add(checkerboardBG);
		
		checkerboardBG2 = new FlxSprite(0, -1080).loadGraphic(Paths.image('checkerboarduno'));
		checkerboardBG2.setGraphicSize(1920, 1080);
		checkerboardBG2.updateHitbox();
		checkerboardBG2.antialiasing = ClientPrefs.data.antialiasing;
		checkerboardBG2.alpha = 0.5;
		checkerboardBG2.visible = false;
		add(checkerboardBG2);
		
		difficultyOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		difficultyOverlay.alpha = 0;
		difficultyOverlay.visible = false;
		add(difficultyOverlay);
		
		difficultyContainer = new FlxGroup();
		add(difficultyContainer);
		
		difficultyText = new FlxText(0, FlxG.height * 0.25, FlxG.width, "Select your difficulty");
		difficultyText.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, CENTER);
		difficultyText.alpha = 0;
		difficultyContainer.add(difficultyText);
		
		leftArrow = new FlxSprite(FlxG.width * 0.3, FlxG.height * 0.5);
		leftArrow.antialiasing = ClientPrefs.data.antialiasing;
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.alpha = 0;
		difficultyContainer.add(leftArrow);
		
		Difficulty.resetList();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = Difficulty.getDefault();
		}
		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
		
		sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.antialiasing = ClientPrefs.data.antialiasing;
		sprDifficulty.alpha = 0;
		difficultyContainer.add(sprDifficulty);
		
		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.antialiasing = ClientPrefs.data.antialiasing;
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.alpha = 0;
		difficultyContainer.add(rightArrow);
		
		var confirmText = new FlxText(0, FlxG.height * 0.7, FlxG.width, "Press ENTER to confirm");
		confirmText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER);
		confirmText.alpha = 0;
		difficultyContainer.add(confirmText);
		
		var backText = new FlxText(0, FlxG.height * 0.75, FlxG.width, "Press ESCAPE to go back");
		backText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		backText.alpha = 0;
		difficultyContainer.add(backText);
		
		difficultyContainer.visible = false;

		changeWeek();
		changeDifficulty();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menus", null);
		#end

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		if (checkerboardBG.visible) {
			checkerboardBG.y += scrollSpeed * elapsed;
			checkerboardBG2.y += scrollSpeed * elapsed;
			
			if (checkerboardBG.y >= 1080) {
				checkerboardBG.y = checkerboardBG2.y - checkerboardBG.height;
			}
			if (checkerboardBG2.y >= 1080) {
				checkerboardBG2.y = checkerboardBG.y - checkerboardBG2.height;
			}
		}
		
		if (!movedBack && !selectedWeek)
		{
			if (!inDifficultySelection)
			{
				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;
				if (upP)
				{
					changeWeek(-1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}

				if (downP)
				{
					changeWeek(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}

				if(FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					changeWeek(-FlxG.mouse.wheel);
					changeDifficulty();
				}

				if(FlxG.keys.justPressed.CONTROL)
				{
					persistentUpdate = false;
					openSubState(new GameplayChangersSubstate());
				}
				else if(controls.RESET)
				{
					persistentUpdate = false;
					openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				}
				else if (controls.ACCEPT)
				{
					showDifficultySelectors();
				}
			}
			else
			{
				if (controls.UI_RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.UI_LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.UI_RIGHT_P)
					changeDifficulty(1);
				else if (controls.UI_LEFT_P)
					changeDifficulty(-1);
					
				if (controls.ACCEPT)
				{
					selectWeek();
				}
				
				if (controls.BACK)
				{
					hideDifficultySelectors();
					FlxG.sound.play(Paths.sound('cancelMenu'));
				}
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek && !inDifficultySelection)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;
	
	function showDifficultySelectors()
	{
		inDifficultySelection = true;
		
		FlxG.sound.play(Paths.sound('confirmation'));
		
		checkerboardBG.visible = true;
		checkerboardBG2.visible = true;
		checkerboardBG.y = 0;
		checkerboardBG2.y = -1080;
		checkerboardBG.alpha = 0;
		checkerboardBG2.alpha = 0;

		FlxTween.tween(checkerboardBG, {alpha: 0.2}, 0.6, {ease: FlxEase.quartInOut});
		FlxTween.tween(checkerboardBG2, {alpha: 0.2}, 0.6, {ease: FlxEase.quartInOut});
		
		difficultyOverlay.alpha = 0;
		difficultyOverlay.visible = true;
		FlxTween.tween(difficultyOverlay, {alpha: 0.3}, 0.5, {ease: FlxEase.quartInOut});
		
		difficultyContainer.visible = true;
		
		for (member in difficultyContainer.members)
		{
			if (member != null && Std.isOfType(member, FlxSprite))
			{
				var sprite:FlxSprite = cast member;
				sprite.alpha = 0;
				FlxTween.tween(sprite, {alpha: 1}, 0.6, {
					ease: FlxEase.quartInOut,
					startDelay: 0.1
				});
			}
		}
		
		updateDifficultySprite();
	}
	
	function updateDifficultySprite()
	{
		sprDifficulty.x = (FlxG.width / 2) - (sprDifficulty.width / 2);
		sprDifficulty.y = leftArrow.y;
		
		leftArrow.x = sprDifficulty.x - leftArrow.width - 20;
		rightArrow.x = sprDifficulty.x + sprDifficulty.width + 20;
	}
	
	function hideDifficultySelectors()
	{
		inDifficultySelection = false;
		
		FlxTween.cancelTweensOf(difficultyOverlay);
		
		FlxTween.tween(difficultyOverlay, {alpha: 0}, 0.5, {
			ease: FlxEase.quartInOut,
			onComplete: function(twn:FlxTween) {
				difficultyOverlay.visible = false;
			}
		});
		
		for (member in difficultyContainer.members)
		{
			if (member != null && Std.isOfType(member, FlxSprite))
			{
				var sprite:FlxSprite = cast member;
				FlxTween.cancelTweensOf(sprite);
				FlxTween.tween(sprite, {alpha: 0}, 0.5, {
					ease: FlxEase.quartInOut
				});
			}
		}
		
		new FlxTimer().start(0.5, function(tmr:FlxTimer) {
			difficultyContainer.visible = false;
			checkerboardBG.visible = false;
			checkerboardBG2.visible = false;
		});
	}

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			try
			{
				PlayState.storyPlaylist = songArray;
				PlayState.isStoryMode = true;
				selectedWeek = true;
	
				var diffic = Difficulty.getFilePath(curDifficulty);
				if(diffic == null) diffic = '';
	
				PlayState.storyDifficulty = curDifficulty;
	
				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');
				return;
			}
			
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				stopspamming = true;
			}

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
			
			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		}
		else FlxG.sound.play(Paths.sound('cancelMenu'));
	}

	var tweenDifficulty:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = Difficulty.getString(curDifficulty);
		var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff));

		if(sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);
			updateDifficultySprite();

			if(tweenDifficulty != null) tweenDifficulty.cancel();
			sprDifficulty.alpha = 0;
			
			if (inDifficultySelection) {
				tweenDifficulty = FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07, {onComplete: function(twn:FlxTween)
				{
					tweenDifficulty = null;
				}});
				
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}
		lastDifficultyName = diff;
	}

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);
		PlayState.storyWeek = curWeek;

		Difficulty.loadFromWeek();

		if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		
		updateWeekCharacter();
		updateTitleCard();
	}
	
	function updateWeekCharacter():Void
	{
		if(characterTween != null) {
			characterTween.cancel();
			characterTween = null;
		}
		
		weekCharacter.visible = false;
		noxxWeekCharacter.visible = false;
		
		var targetCharacter:FlxSprite;
		var targetX:Float = 40;
		
		if(curWeek == 0) {
			targetCharacter = weekCharacter;
		} else if(curWeek == 2) {
			targetCharacter = weekCharacter;
		} else {
			targetCharacter = weekCharacter;
		}
		
		targetCharacter.visible = true;
		
		if(!hasAnimatedCharacter) {
			targetCharacter.x = -800;
			
			characterTween = FlxTween.tween(targetCharacter, {x: targetX}, 0.8, {
				ease: FlxEase.quartOut,
				onComplete: function(twn:FlxTween) {
					characterTween = null;
				}
			});
			
			hasAnimatedCharacter = true;
		}
	}
	
	function updateTitleCard():Void
	{
		if(titleCardTween != null) {
			titleCardTween.cancel();
			titleCardTween = null;
		}
		
		if(curWeek == 0 || curWeek == 2) {
			titleCard.visible = true;
			
			if(!hasAnimatedTitleCard) {
				titleCard.x = FlxG.width + 200;
				
				titleCardTween = FlxTween.tween(titleCard, {x: FlxG.width - titleCard.width - 20}, 0.8, {
					ease: FlxEase.quartOut,
					onComplete: function(twn:FlxTween) {
						titleCardTween = null;
					}
				});
				
				hasAnimatedTitleCard = true;
			}
		} else {
			titleCard.visible = false;
		}
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}
}
