package com.powervr.pod.data {
	public class LightData {
		public static const ePoint:int = 0;
		public static const eDirectional:int = 1;
		public static const eSpot:int = 2;

		public var targetIndex:int = -1;
		public var colour:Vector.<Number>;
		public var type:int = ePoint;
		public var constantAttenuation:Number = 1.0;
		public var linearAttenuation:Number = 0.0;
		public var quadraticAttenuation:Number = 0.0;
		public var falloffAngle:Number = Math.PI;
		public var falloffExponent:Number = 0.0;
	}
}
