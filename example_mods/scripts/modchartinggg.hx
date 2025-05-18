import modchart.modifiers.*;
import modchart.modifiers.false_paradise.*;

//function onCreate()
//{
//    PlayState.instance.skipCountdown = true;
//}

function onCreatePost()
{
    modchartMgr.renderArrowPaths = true;
    rotateStrums();
}

function rotateStrums()
{
    modchartMgr.registerModifier("rotateX", Rotate);
    modchartMgr.addModifier("rotateX");
    modchartMgr.setPercent("rotateX", 60);
    if (ClientPrefs.data.downScroll)
    {
        modchartMgr.registerModifier("z", Transform);
        modchartMgr.addModifier("z");
        modchartMgr.setPercent("z", -300);
        modchartMgr.registerModifier("y", Transform);
        modchartMgr.addModifier("y");
        modchartMgr.setPercent("y", 100);
    }else{
        modchartMgr.registerModifier("z", Transform);
        modchartMgr.addModifier("z");
        modchartMgr.setPercent("z", -500);
    }
}