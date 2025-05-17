import modchart.modifiers.*;

function onCreate()
{
    PlayState.instance.skipCountdown = true;
}
function onSongStart()
{
    modchartMgr.renderArrowPaths = true;
    modchartMgr.registerModifier("rotateX", Rotate);
    modchartMgr.addModifier("rotateX");
    modchartMgr.set("rotateX", 0, 60);
    modchartMgr.registerModifier("z", Transform);
    modchartMgr.addModifier("z");
    modchartMgr.set("z", 0, -300);
    modchartMgr.registerModifier("y", Transform);
    modchartMgr.addModifier("y");
    modchartMgr.set("y", 0, 100);
    modchartMgr.registerModifier("drugged", Drugged);
    modchartMgr.addModifier("drugged");
    modchartMgr.set("drugged", 0, 1);
    modchartMgr.registerModifier("tornado", Tornado);
    modchartMgr.addModifier("tornado");
    modchartMgr.set("tornado", 0, 0.3);
}