package backend;

//this file contains all the utilities that i use for my stage, week, and songs.
//this stuff is pretty important to the function of my songs, so please dont remove it.


class ChickenSwimmerUTILS {
    //graphics

    //effects

    //modcharts

    //functions
    public static inline function wait(time:Float, onComplete:()->Void):FlxTimer
        return new FlxTimer().start(time, (_) -> { onComplete(); });
    //other

}