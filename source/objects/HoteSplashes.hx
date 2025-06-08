package objects;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
class HoteSplashes extends FlxTypedSpriteGroup<FlxSprite>
{
    //public var strumData:Map<String, Vector3>;
    public var holdSprites:Map<String, FlxSprite>;


	public function new()
	{
		super();
		//strumData = new Map<String, Vector3>();
        holdSprites = new Map<String, FlxSprite>();
	}

    /**
     * This initializes your NoteSplashHoldManager.
     * @param strumGroup The group of strums for this manager to manage.
     */
    public function initialize(strumGroup:FlxTypedGroup<StrumNote>, ?allBlue:Bool = false){

        strumGroup.forEachAlive((s:StrumNote) -> {
            // This is useless
            //strumData.set(dirToStr(s.noteData), new Vector3(s.x, s.y, s.noteData));

            // Color of the current direction
            @:privateAccess var color = dirToStr(s.noteData);

            // The sprite for the hold note animation
            var width = 160 * 0.7;
            var holdSprite:FlxSprite = new FlxSprite(s.x - width * 0.95, s.y - width + 15);
		    holdSprite.frames = Paths.getSparrowAtlas('noteSplashes/holdCover$color'); //should work on adding the full anim set
		    holdSprite.animation.addByIndices('hold', 'holdCover$color', [0,1,2,3], "", 24, false, false, false);
            holdSprite.animation.addByIndices('splash', 'holdCover$color', [4,5,6,7,8,9,10,11,12], "", 24, false, false, false);
		    holdSprite.visible = false;
		    add(holdSprite);

            // Sets the hold sprite to its respective colorName
            holdSprites.set(color, holdSprite);
        });
    }

	public function dirToSpr(Direction:Int):FlxSprite
		return holdSprites.get(dirToStr(Direction));
    public function dirToStr(Direction:Int):String
		return Direction == 0 ? 'Purple' : Direction == 1 ? 'Blue' : Direction == 2 ? 'Green' : Direction == 3 ? 'Red' : null;

	public function onNoteHit(note:Note)
	{
        if(!note.noteSplashData.disabled){
		    var hitSprite:FlxSprite = dirToSpr(note.noteData);
			hitSprite.visible = true;

		    if (note.isSustainNote){ //TODO: make smoother and make it properly use the first frame of the hold animation.
                hitSprite.animation.play('hold');
                if(hitSprite.animation.curAnim.curFrame == 3){
                    hitSprite.animation.curAnim.curFrame = 1; //should restart the animation?
                }
            }else
                hitSprite.visible = false;

		    hitSprite.animation.finishCallback = function(bru){
                if(hitSprite.animation.curAnim.name == 'hold')
                    hitSprite.animation.play('splash', true);
                else
                    hitSprite.visible = false;
            };
        }
	}
}