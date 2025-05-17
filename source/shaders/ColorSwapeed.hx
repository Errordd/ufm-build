package shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class ColorSwapeed extends FlxShader {
    @:glFragmentSource('
        #pragma header
        
        uniform vec4 leftColor;
        uniform vec4 rightColor;
        uniform float dividePoint;
        
        void main() {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
            
            if (color.a > 0.0) {
                if (openfl_TextureCoordv.x < dividePoint) {
                    // Left side - opponent color
                    color = vec4(leftColor.rgb, color.a);
                } else {
                    // Right side - player color
                    color = vec4(rightColor.rgb, color.a);
                }
            }
            
            gl_FragColor = color;
        }
    ')
    
    public function new() {
        super();
        
        // Default colors (white)
        this.leftColor.value = [1.0, 1.0, 1.0, 1.0];
        this.rightColor.value = [1.0, 1.0, 1.0, 1.0];
        this.dividePoint.value = [0.5]; // Default to middle
    }
    
    public function setColors(leftColor:FlxColor, rightColor:FlxColor) {
        this.leftColor.value = [
            leftColor.redFloat,
            leftColor.greenFloat,
            leftColor.blueFloat,
            leftColor.alphaFloat
        ];
        
        this.rightColor.value = [
            rightColor.redFloat,
            rightColor.greenFloat,
            rightColor.blueFloat,
            rightColor.alphaFloat
        ];
    }
    
    public function setDividePoint(point:Float) {
        this.dividePoint.value = [point];
    }
}
