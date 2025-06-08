package objects;

import flixel.animation.FlxAnimation;

enum AnimState{
    Idle;
    Losing;
}

class AnimatedHealthIcon extends FlxSprite{ //still counts as an flxSprite 
    public var state:AnimState = Idle;
    var target:AnimState = Idle;

    public var sprTracker:FlxSprite;
    private var isOldIcon:Bool = false;
    private var isPlayer:Bool = false;
    private var char:String = '';
    private var iconOffsets:Array<Float> = [0, 0];
    public function new(character:String = 'bf', isPlayer:Bool = false, ?allowGPU:Bool = true){
        super();

        scrollFactor.set();
        this.isPlayer = isPlayer;
        char = character;

        isOldIcon = (character == 'bf-old');

        var name:String = 'icons/' + character;
        if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + character; //Older versions of psych engine's suppor
        if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon

        frames = Paths.getSparrowAtlas(name, allowGPU);
        animation.addByPrefix('Idle', 'idle', 25, false, isPlayer, false);
        animation.addByPrefix('Idle_to_Losing', 'idletodie', 24, false, isPlayer, false);
        animation.addByPrefix('Losing_to_Idle', 'dietoidle', 24, false, isPlayer, false); //somehow play backwards
        animation.addByPrefix('Losing', 'die', 24, false, isPlayer, false);

        animation.play('Idle');

        iconOffsets[0] = (width - 150) / 2;
		iconOffsets[1] = (height - 150) / 2;
		updateHitbox();

		if(character.endsWith('-pixel'))
			antialiasing = false;
		else
			antialiasing = ClientPrefs.data.antialiasing;
    }

    public function decideCurAnim(health:Float):Void{

        if(health > 20){
            target = Idle;
        }else{
            target = Losing;
        }

        if(state != target){
            var transName:String = '${Std.string(state)}_to_${Std.string(target)}';
            if(animation.name != transName){
                animation.play(transName, true);

                animation.finishCallback = function(_) {
                    if(animation.name != transName)
                    state = target;
                    animation.play(Std.string(state));
                };
            }
        }
    }

    
    public function changeIcon(character:String, ?allowGPU:Bool = true){
        var name:String = 'icons/' + character;
        if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + character; //Older versions of psych engine's suppor
        if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon

        frames = Paths.getSparrowAtlas(name, allowGPU);
        animation.addByPrefix('Idle', 'idle', 25, false, isPlayer, false);
        animation.addByPrefix('Idle_to_Losing', 'idletodie', 24, false, isPlayer, false);
        animation.addByPrefix('Losing_to_Idle', 'dietoidle', 24, false, isPlayer, false); //somehow play backwards
        animation.addByPrefix('Losing', 'die', 24, false, isPlayer, false);

        animation.play('Idle');

        iconOffsets[0] = (width - 150) / 2;
		iconOffsets[1] = (height - 150) / 2;
		updateHitbox();

		if(character.endsWith('-pixel'))
			antialiasing = false;
		else
			antialiasing = ClientPrefs.data.antialiasing;
    }

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	override function updateHitbox() {
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}