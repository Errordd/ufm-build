package objects;

import flixel.FlxSprite;
import flixel.math.FlxMath;

class MenuItem extends FlxSprite
{
    public var targetY:Float = 0;

    public function new(x:Float, y:Float, weekName:String = '')
    {
        super(x, y);
        loadGraphic(Paths.image('storymenu/' + weekName)); // Assuming this path is correct
        antialiasing = ClientPrefs.data.antialiasing;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        y = FlxMath.lerp((targetY * 120) + 480, y, Math.exp(-elapsed * 10.2));
    }
}
