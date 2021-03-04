package com.coffeebreak.utils;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * ...
 * @author gonzos
 */
class BMPFunctions 
{

	public function new() 
	{
		
	}
	
	
	public static function floodFill(bd:BitmapData, x:UInt, y:UInt, color:UInt, tolerance:UInt=0, contiguous:Bool=false):BitmapData{
			// Validates the (x, y) coordinates.
			x = Std.int(Math.min(bd.width-1, x));
			y = Std.int(Math.min(bd.height-1, y));
			// Validates the tolerance.
			tolerance = Std.int(Math.max(0, Math.min(255, tolerance)));
			
			// Gets the color of the selected point.
			var targetColor:UInt = bd.getPixel32(x, y);
			
			if(contiguous){
				// Fills only the connected area.
				var w:UInt = bd.width;
				var h:UInt = bd.height;
				
				// Temporary BitmapData
				var temp_bd:BitmapData = new BitmapData(w, h, false, 0x000000);
				
				// Fills similar pixels with gray.
				temp_bd.lock();
				for (i in 0...w)
				{
					for (k in 0...h)
					{
						var d:Int = BMPFunctions.getColorDifference32(targetColor, bd.getPixel32(i, k));
						if(d <= tolerance){
							temp_bd.setPixel(i, k, 0x333333);
						}
					}
				}
				temp_bd.unlock();
				
				// Fills the connected area with white.
				temp_bd.floodFill(x, y, 0xFFFFFF);
				
				// Use threshold() to get the white pixels only.
				var rect:Rectangle = new Rectangle(0, 0, w, h);
				var pnt:Point = new Point(0, 0);
				temp_bd.threshold(temp_bd, rect, pnt, "<", 0xFF666666, 0xFF000000);
				
				// Gets the colorBoundsRect to minimizes a for loop.
				rect = temp_bd.getColorBoundsRect(0xFFFFFFFF, 0xFFFFFFFF);
				x = Std.int(rect.x);
				y = Std.int(rect.y);
				w = Std.int(x + rect.width);
				h = Std.int(y + rect.height);
				
				// Modifies the original image.
				bd.lock();
				
				for (i in x...w)
				{
					for (k in y...h)
					{
						if (temp_bd.getPixel(i, k) == 0xFFFFFF)
						{
							bd.setPixel32(i, k, color);
						}
					}
				}
				bd.unlock();
			}else{
				// Fills all pixels similar to the targetColor.
				BMPFunctions.replaceColor(bd, targetColor, color, tolerance);
			}// end if else
			
			return bd;
		}// end floodFill
		
		
		public static function replaceColor(bd:BitmapData, c1:UInt, c2:UInt, tolerance:UInt=0):BitmapData{
			// Validates the tolerance.
			tolerance = Std.int(Math.max(0, Math.min(255, tolerance)));
			
			bd.lock();
			var w:UInt = bd.width;
			var h:UInt = bd.height;
			
			for ( i in 0...w)
			{
				for ( k in 0...h)
				{
					var d:Int = BMPFunctions.getColorDifference32(c1, bd.getPixel32(i, k));
					if(d <= tolerance){
						bd.setPixel32(i, k, c2);
					}
				}
			}
			bd.unlock();
			
			return bd;
		}// end replaceColor
		
		
		public static function getColorDifference(c1:UInt, c2:UInt):Int
		{
			var r1:Int = (c1 & 0x00FF0000) >>> 16;
			var g1:Int = (c1 & 0x0000FF00) >>> 8;
			var b1:Int = (c1 & 0x0000FF);
			
			var r2:Int = (c2 & 0x00FF0000) >>> 16;
			var g2:Int = (c2 & 0x0000FF00) >>> 8;
			var b2:Int = (c2 & 0x0000FF);
			
			var r:Int = Std.int(Math.pow((r1-r2), 2));
			var g:Int = Std.int(Math.pow((g1-g2), 2));
			var b:Int = Std.int(Math.pow((b1-b2), 2));
			
			var d:Int = Std.int(Math.sqrt(r + g + b));
			
			// Adjusts the range to 0-255.
			d = Math.floor(d / 441 * 255);
			
			return d;
		}// end getColorDifference
		
		
		public static function getColorDifference32(c1:UInt, c2:UInt):Int{
			var a1:Int = (c1 & 0xFF000000) >>> 24;
			var r1:Int = (c1 & 0x00FF0000) >>> 16;
			var g1:Int = (c1 & 0x0000FF00) >>> 8;
			var b1:Int = (c1 & 0x0000FF);
			
			var a2:Int = (c2 & 0xFF000000) >>> 24;
			var r2:Int = (c2 & 0x00FF0000) >>> 16;
			var g2:Int = (c2 & 0x0000FF00) >>> 8;
			var b2:Int = (c2 & 0x0000FF);
			
			var a:Int = Std.int(Math.pow((a1-a2), 2));
			var r:Int = Std.int(Math.pow((r1-r2), 2));
			var g:Int = Std.int(Math.pow((g1-g2), 2));
			var b:Int = Std.int(Math.pow((b1-b2), 2));
			
			var d:Int = Std.int(Math.sqrt(a + r + g + b));
			
			// Adjusts the range to 0-255.
			d = Math.floor(d / 510 * 255);
			
			return d;
		}// end getColorDifference32
		
	
}