package com.powervr.pod.data {
	public class CameraData {

		public var targetIndex:int = 0;
		public var far:Number = 0;
		public var near:Number = 0;
		public var numFrames:int = 0;
		public var fovs:Vector.<Number>;

		public function CameraData() {
		}

		public function getFov(frame:int, interp:Number):Number {
			if (fovs) {
				if (numFrames > 1) {
					if (frame >= numFrames - 1)
						throw new RangeError;

					var fov0:Number = fovs[frame + 0];
					var fov1:Number = fovs[frame + 1];
					return fov0 + interp * (fov1 - fov0);
				} else {
					return fovs[0];
				}
			}
			return 0.7;
		}
	}
}
