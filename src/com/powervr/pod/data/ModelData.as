package com.powervr.pod.data {
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	import com.powervr.pod.enums.EPODErrorCodes;

	public class ModelData {
		public var clearColour:Vector.<Number>;
		public var ambientColour:Vector.<Number>;

		public var numCameras:int = 0;
		public var cameras:Vector.<CameraData> = new Vector.<CameraData>();

		public var numLights:int = 0;
		public var lights:Vector.<LightData> = new Vector.<LightData>();

		public var numMeshes:int = 0;
		public var meshes:Vector.<MeshData> = new Vector.<MeshData>();

		public var numNodes:int = 0;
		public var numMeshNodes:int = 0;
		public var nodes:Vector.<NodeData> = new Vector.<NodeData>();

		public var numTextures:int = 0;
		public var textures:Vector.<TextureData> = new Vector.<TextureData>();

		public var numMaterials:int = 0;
		public var materials:Vector.<MaterialData> = new Vector.<MaterialData>();

		public var numFrames:int = 0;
		public var currentFrame:int = 0;
		public var fps:int = 0;

		public var userData:Vector.<Number>;

		public var units:int = 0.0;
		public var flags:int = 0;

		public var cache:CacheData = new CacheData();

		public function initCache():int {
			cache.clear();
			return EPODErrorCodes.eNoError;
		}


		public function flushCache():void {
			setCurrentFrame(0);

			for (var i:int = 0; i < numNodes; ++i) {
				var m:Matrix3D = getWorldMatrixNoCache(i);
				cache.worldMatrixFrameZero[i] = m;
				// Set out caches to frame 0
				cache.worldMatrixFrameN[i] = m;
				cache.cachedFrame[i] = 0.0;
			}
		}

		public function setCurrentFrame(frame:int):void {
			if (numFrames > 0) {
				/*
				 Limit animation frames.

				 Example: If there are 100 frames of animation, the highest frame
				 number allowed is 98, since that will blend between frames 98 and
				 99. (99 being of course the 100th frame.)
				 */

				if (frame > (numFrames - 1))
					throw new RangeError;

				cache.frame = Math.floor(frame);
				cache.frameFraction = frame - cache.frame;
			} else {
				if (Math.floor(frame) != 0) {
					throw new RangeError;
				}

				cache.frame = 0;
				cache.frameFraction = 0;
			}

			currentFrame = frame;
		}


		private function getWorldMatrix(id:int):Matrix3D {
			// There is a dedicated cache for frame 0
			if (currentFrame == 0) {
				return cache.worldMatrixFrameZero[id];
			}

			// Has this matrix been calculated and cached?
			if (currentFrame == cache.cachedFrame[id]) {
				return cache.worldMatrixFrameN[id];
			}

			// Calculate the matrix and cache it
			var node:NodeData = nodes[id];
			var m:Matrix3D = cache.worldMatrixFrameN[id] = node.animation.getTransformationMatrix(cache.frame, cache.frameFraction);
			var parentID:int = node.parentIndex;
			if (parentID < 0) {
				cache.worldMatrixFrameN[id] = m;
			} else {
				var parentMatrix:Matrix3D = getWorldMatrix(parentID);
				parentMatrix.prepend(m);
				cache.worldMatrixFrameN[id] = parentMatrix;
			}

			cache.cachedFrame[id] = currentFrame;
			return cache.worldMatrixFrameN[id];
		}

		public function getWorldMatrixNoCache(id:int):Matrix3D {
			var m:Matrix3D = nodes[id].animation.getTransformationMatrix(cache.frame, cache.frameFraction);
			var parentID:int = nodes[id].parentIndex;
			if (parentID < 0) {
				return m;
			}

			var mat:Matrix3D = getWorldMatrixNoCache(parentID);
			mat.prepend(m);
			return mat;
		}

		private const tempData:Vector.<Number> = new Vector.<Number>();
		private const tempData2:Vector.<Number> = new Vector.<Number>();

		public function getCameraProperties(cameraIdx:int):CameraProperties {
			if (cameraIdx < 0 || cameraIdx >= numCameras) {
				throw new RangeError;
			}

			var m:Matrix3D = getWorldMatrix(numMeshNodes + numLights + cameraIdx);
			var props:CameraProperties = new CameraProperties();
			m.copyRawDataTo(tempData);
			var rawData:Vector.<Number> = tempData;

			// View position is 0,0,0,1 transformed by world matrix
			props.from.x = rawData[12];
			props.from.y = rawData[13];
			props.from.z = rawData[14];

			// When you rotate the camera from "straight forward" to "straight down", in OpenGL the UP vector will be [0, 0, -1]
			props.up.x = -rawData[8];
			props.up.y = -rawData[9];
			props.up.z = -rawData[10];

			var camera:CameraData = cameras[cameraIdx];

			// TODO: Experimental!
			if (camera.targetIndex != -1) {

				var targetMatrix:Matrix3D = getWorldMatrix(camera.targetIndex);
				targetMatrix.copyRawDataTo(tempData2);
				var targetRawData:Vector.<Number> = tempData2;
				props.to.x = targetRawData[12];
				props.to.y = targetRawData[13];
				props.to.z = targetRawData[14];

				// Rotate our up vector

				var atTarget:Vector3D = props.to.subtract(props.from);
				atTarget.normalize();

				var atCurrent:Vector3D = props.to.subtract(props.from);
				atCurrent.normalize();

				var axis:Vector3D = atCurrent.crossProduct(atTarget);
				var angle:Number = atCurrent.dotProduct(atTarget);

				var rotationMatrix:Matrix3D = AnimationData.createRotationMatrixFromAxisAndAngle(axis.x, axis.y, axis.z, angle);
				rotationMatrix.transformVector(props.up);
				props.up.normalize();
			}
			else {
				// View direction is 0,-1,0,1 transformed by world matrix
				props.to.x = -rawData[4] + props.from.x;
				props.to.y = -rawData[5] + props.from.y;
				props.to.z = -rawData[6] + props.from.z;
			}

			props.fov = camera.getFov(cache.frame, cache.frameFraction);
			return props;
		}

		public function getLightDirection(lightIdx:int):Vector3D {
			if (lightIdx < 0 || lightIdx >= numLights)
				throw new RangeError;

			var m:Matrix3D = getWorldMatrix(numMeshNodes + lightIdx);
			var targetIndex:int = lights[lightIdx].targetIndex;
			var rawData:Vector.<Number> = m.rawData;
			var directionVector:Vector3D = new Vector3D();
			directionVector.w = 0;
			if (targetIndex != -1) {
				var targetMatrix:Matrix3D = getWorldMatrix(targetIndex);
				var targetMatrixRaw:Vector.<Number> = targetMatrix.rawData;
				directionVector.x = targetMatrixRaw[12] - rawData[12];
				directionVector.y = targetMatrixRaw[13] - rawData[13];
				directionVector.z = targetMatrixRaw[14] - rawData[14];
				directionVector.normalize();
			}
			else {
				directionVector.x = -rawData[4];
				directionVector.y = -rawData[5];
				directionVector.z = -rawData[6];
			}

			return directionVector;
		}
	}
}
