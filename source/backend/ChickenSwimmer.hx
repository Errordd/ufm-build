package backend;

//this file contains all the utilities that i use for my stage, week, and songs.
//this stuff is pretty important to the function of my songs, so please dont remove it.

class ChickenSwimmerUTILS {
    //graphics

    //effects

    //modcharts

    //functions
    public static inline function wait(time:Float, onComplete:()->Void):FlxTimer //STOLEN FROM RELOCATION FAILED!! MUAHAHAHAHAH (i made that game im allowed to do this >:3)
        return new FlxTimer().start(time, (_) -> { onComplete(); });
    //other

}

/**
 * for window movement and management >:)
 */
class ChickenSwimmerWindowManager { //TODO: window transparency somehow.
    public function init(){
        trace('ChickenSwimmer2020 window manager initalized');
    }
}

class ChickenStage extends BaseStage { //* how do stages even work? is it like, it compares a json name to a hardcoded stage or smthn?
    private var WINMANG:ChickenSwimmerWindowManager;
    private var Colors:Array<Int> = []; //for the stageglow bop stuff or smthn //FlxColor but int or smthn
    private var Bar:BGSprite; //bar
    private var backWall:BGSprite; //back wall
    private var StageFloor:FlxSprite; //animated //FlxSprite is easier to add animations too.
    private var TurnTable:FlxSprite; //animated //FlxSprite is easier to add animations too.

    override public function create() {
        //hehe, this is where stuff gets real! (literally XDDDDDD)
        

        Bar = new BGSprite('Chicken/bar', -40, -250, 1.2, 1.2, null, false);
        add(Bar);

        //TODO: move girlfriend to behind the back wall, remove and re-add?

        backWall = new BGSprite('Chicken/back', -40, -250, 1, 1, null, false);
        add(backWall);

        StageFloor = new FlxSprite(0, 0);
        StageFloor.frames = Paths.getSparrowAtlas('Chicken/floor');
        StageFloor.animation.addByPrefix('bop', 'floor bop', 24, false, false, false);
        add(StageFloor);
        StageFloor.animation.play('bop');
    }

    override public function beatHit(){
        StageFloor.animation.play('bop', true);
    }

    override public function update(elapsed:Float){
        super.update(elapsed);
    }
}