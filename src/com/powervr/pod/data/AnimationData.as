package com.powervr.pod.data {
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	import com.powervr.pod.enums.EPODAnimation;

	public class AnimationData {
		public var flags:int = 0;
		public var numFrames:int = 0;
		public var positions:Vector.<Number>;
		public var rotations:Vector.<Number>;
		public var scales:Vector.<Number>;
		public var matrices:Vector.<Number>;
		public var positionIndices:Vector.<uint>;
		public var rotationIndices:Vector.<uint>;
		public var scaleIndices:Vector.<uint>;
		public var matrixIndices:Vector.<uint>;

		private var _pos:Vector3D = new Vector3D();
		private var _rot:Vector3D = new Vector3D();
		private var _sca:Vector3D = new Vector3D();
		private var _transformComponents:Vector.<Vector3D>;

		public function AnimationData() {
			_transformComponents = new Vector.<Vector3D>(3, true);
			_transformComponents[0] = _pos;
			_transformComponents[1] = _rot;
			_transformComponents[2] = _sca;
		}

		public function getTranslation(frame:int, interp:Number, result:Vector3D = null):Vector3D {
			if (!result) result = new Vector3D();

			if (positions) {
				if (flags & EPODAnimation.eHasPositionAnimation) {
					var index0:int;
					var index1:int;

					if (positionIndices != null) {
						index0 = positionIndices[frame + 0];
						index1 = positionIndices[frame + 1];
					}
					else {
						index0 = 3 * (frame + 0);
						index1 = 3 * (frame + 1);
					}

					var x0:Number = positions[index0];
					var y0:Number = positions[index0 + 1];
					var z0:Number = positions[index0 + 2];

					var x1:Number = positions[index1];
					var y1:Number = positions[index1 + 1];
					var z1:Number = positions[index1 + 2];

					var x:Number = x0 + (x1 - x0) * interp;
					var y:Number = y0 + (y1 - y0) * interp;
					var z:Number = z0 + (z1 - z0) * interp;

					result.x = x;
					result.y = y;
					result.z = z;
				} else {
					result.x = positions[0];
					result.y = positions[1];
					result.z = positions[2];
				}
			}
			return result;
		}

		public function getRotation(frame:int, interp:Number, result:Vector3D = null):Vector3D {
			if (!result) result = new Vector3D();

			if (rotations) {
				if (flags & EPODAnimation.eHasRotationAnimation) {
					var index0:int;
					var index1:int;

					if (rotationIndices != null) {
						index0 = rotationIndices[frame + 0];
						index1 = rotationIndices[frame + 1];
					} else {
						index0 = 4 * (frame + 0);
						index1 = 4 * (frame + 1);
					}

					sphericalLinearInterpolation(
							rotations[index0 + 0], rotations[index0 + 1], rotations[index0 + 2], rotations[index0 + 3],
							rotations[index1 + 0], rotations[index1 + 1], rotations[index1 + 2], rotations[index1 + 3],
							interp, result);
				} else {
					quaternionToEulerAngles(rotations[0], rotations[1], rotations[2], rotations[3], result);
				}
			}

			return result;
		}

		public function getScale(frame:int, interp:Number, result:Vector3D = null):Vector3D {
			if (!result) result = new Vector3D();

			if (scales) {
				if (flags & EPODAnimation.eHasScaleAnimation) {
					var index0:int;
					var index1:int;
					if (scaleIndices) {
						index0 = scaleIndices[frame + 0];
						index1 = scaleIndices[frame + 1];
					}
					else {
						index0 = 7 * (frame + 0);
						index1 = 7 * (frame + 1);
					}

					var x0:Number = scales[index0];
					var y0:Number = scales[index0 + 1];
					var z0:Number = scales[index0 + 2];

					var x1:Number = scales[index1];
					var y1:Number = scales[index1 + 1];
					var z1:Number = scales[index1 + 2];

					result.x = x0 + (x1 - x0) * interp;
					result.y = y0 + (y1 - y0) * interp;
					result.z = z0 + (z1 - z0) * interp;
				} else {
					result.x = scales[0];
					result.y = scales[1];
					result.z = scales[2];
				}
			}
			return result;
		}

		public function getTransformationMatrix(frame:int, interp:Number, result:Matrix3D = null):Matrix3D {
			if (!result) result = new Matrix3D();
			getTranslation(frame, interp, _pos);
			getScale(frame, interp, _sca);
			getRotation(frame, interp, _rot);
			result.recompose(_transformComponents);
			return result;
		}

		public static function sphericalLinearInterpolation(ax:Number, ay:Number, az:Number, aw:Number, bx:Number, by:Number, bz:Number, bw:Number, f:Number, result:Vector3D):Vector3D {
			if (!result) result = new Vector3D();

			var cosine:int = ax * bx + ay * by + az * bz + aw * bw;
			if (cosine < 0) {
				return sphericalLinearInterpolation(ax, ay, az, aw, -bx, -by, -bz, -bw, f, result);
			}

			// Ensure the cosine is valid
			cosine = Math.min(cosine, 1);

			// Get the angle
			var angle:Number = Math.acos(cosine);
			var p0:Number = 1;
			var p1:Number = 1;

			if (angle > 0) {
				// Calculate resultant quaternion
				p0 = Math.sin((1 - f) * angle) / Math.sin(angle);
				p1 = Math.sin(f * angle) / Math.sin(angle);
			}

			var x:Number = ax * p0 + bx * p1;
			var y:Number = ay * p0 + by * p1;
			var z:Number = az * p0 + bz * p1;
			var w:Number = aw * p0 + bw * p1;

			quaternionToEulerAngles(x, y, z, w, result);
			return result;
		}

		public static function quaternionToEulerAngles(x:Number, y:Number, z:Number, w:Number, target:Vector3D = null):Vector3D {
			if (!target) target = new Vector3D();
			target.x = Math.atan2(2 * (w * x + y * z), 1 - 2 * (x * x + y * y));
			target.y = Math.asin(2 * (w * y - z * x));
			target.z = Math.atan2(2 * (w * z + x * y), 1 - 2 * (y * y + z * z));
			return target;
		}

		public static function createRotationMatrixFromAxisAndAngle(ax:Number, ay:Number, az:Number, angle:Number, result:Matrix3D = null):Matrix3D {
			if (!result) result = new Matrix3D();

			var scale:Number = Math.sin(angle / 2.0);
			ax *= scale;
			ay *= scale;
			az *= scale;
			var aw:Number = Math.cos(angle / 2.0);

			var len:Number = Math.sqrt(ax * ax + ay * ay + az * az + aw * aw);
			len = 1 / len;

			ax = ax * len;
			ay = ay * len;
			az = az * len;
			aw = aw * len;

			var rawData:Vector.<Number> = new Vector.<Number>();

			rawData[0] = 1 - 2 * ay * ay - 2 * az * az;
			rawData[1] = 2 * ax * ay - 2 * az * aw;
			rawData[2] = 2 * ax * az + 2 * ay * aw;
			rawData[3] = 0;

			rawData[4] = 2 * ax * ay + 2 * az * aw;
			rawData[5] = 1 - 2 * ax * ax - 2 * az * az;
			rawData[6] = 2 * ay * az - 2 * ax * aw;
			rawData[7] = 0;

			rawData[8] = 2 * ax * az - 2 * ay * aw;
			rawData[9] = 2 * ay * az + 2 * ax * aw;
			rawData[10] = 1 - 2 * ax * ax - 2 * ay * ay;
			rawData[11] = 0;

			rawData[12] = 0;
			rawData[13] = 0;
			rawData[14] = 0;
			rawData[15] = 1;

			result.rawData = rawData;
			return result;
		}
	}
}
