package com.powervr.pod.data {
	import flash.geom.Vector3D;

	public class CameraProperties {

		public var from:Vector3D = new Vector3D();
		public var up:Vector3D = new Vector3D();
		public var to:Vector3D = new Vector3D();

		public var fov:Number;

		public function CameraProperties() {
		}
	}
}
