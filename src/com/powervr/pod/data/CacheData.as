package com.powervr.pod.data {
	import flash.geom.Matrix3D;

	public class CacheData {
		public var worldMatrixFrameZero:Array = [];
		public var cachedFrame:Array = [];
		public var worldMatrixFrameN:Array = [];
		public var frame:int;
		public var frameFraction:Number;

		public function clear():void {
			worldMatrixFrameZero.length = 0;
			cachedFrame.length = 0;
			worldMatrixFrameN.length = 0;
			frame = 0;
			frameFraction = 0;
		}
	}
}
