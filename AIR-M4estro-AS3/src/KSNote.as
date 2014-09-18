package 
{
	
	/**
	 * ...
	 * @author Jon Ross
	 * See: http://cnx.org/content/m15489/latest/
	 */
	public class KSNote
	{
		public static var SAMPLE_RATE:int = 44100;
		public static var LENGTH:int = SAMPLE_RATE * 2;
		
		private var __x:Vector.<Number> = new Vector.<Number>();
		private var __data:Vector.<Number> = new Vector.<Number>();
		private var __index:int = 0;
		private var __delayBuffer:Vector.<Number> = new Vector.<Number>();
		private var __z:Number = 0;
		private var __delaySamples:int;
		public var __y:Number = 0;
		
		
		public function KSNote(freq:Number, length:Number = 0.005, volume:Number = 0.05) 
		{
			__delaySamples = SAMPLE_RATE / freq;
			for (var i:int; i < SAMPLE_RATE * length; i++ )
			{
				__x.push(volume - (volume * Math.random()));
			}
		}
		
		public function getNextSample():Number
		{
			var xplus:Number = 0;
			if (__index < __x.length)
			{
				xplus = __x[__index];
			}
			var xl:Number = 0;
			while (__delayBuffer.length > __delaySamples)
			{
				xl = __delayBuffer.shift();
			}
			var yl:Number = 0.5 * (xl + __z);
			__z = xl;
			__y = xplus + yl;
			__delayBuffer.push(__y);
			__index++;
			
			return __y* (LENGTH - __index) / LENGTH;
		}
		
		public function get doRemove():Boolean
		{
			return __index >= LENGTH;
		}
		
		
	}
	
}