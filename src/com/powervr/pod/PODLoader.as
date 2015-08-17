package com.powervr.pod {
	import flash.utils.ByteArray;

	import com.powervr.pod.data.AnimationData;
	import com.powervr.pod.data.CameraData;
	import com.powervr.pod.data.LightData;
	import com.powervr.pod.data.MaterialData;
	import com.powervr.pod.data.MeshData;
	import com.powervr.pod.data.ModelData;
	import com.powervr.pod.data.NodeData;
	import com.powervr.pod.data.TextureData;
	import com.powervr.pod.data.VertexData;
	import com.powervr.pod.enums.EPODAnimation;
	import com.powervr.pod.enums.EPODDefines;
	import com.powervr.pod.enums.EPODErrorCodes;
	import com.powervr.pod.enums.EPODFaceData;
	import com.powervr.pod.enums.EPODIdentifiers;
	import com.powervr.pod.enums.EPODMesh;
	import com.powervr.pod.enums.EPODSemantic;

	public class PODLoader {

		public function PODLoader() {
		}

		public function readTag(stream:ByteArray, tag:PODTag):Boolean {
			tag.identifier = stream.readInt();
			tag.dataLength = stream.readInt();
			return true;
		}

		public function readVertexIndexData(stream:ByteArray, mesh:MeshData):int {
			var tag:PODTag = new PODTag();

			var size:int = 0;
			var data:Vector.<uint> = null;
			var type:int = EPODFaceData.e16Bit;

			var result:int = EPODErrorCodes.eNoError;

			while (readTag(stream, tag)) {
				if (tag.identifier == (EPODIdentifiers.eMeshVertexIndexList | EPODDefines.endTagMask)) {
					return mesh.addFaces(data, type);
				}

				if (tag.identifier == EPODIdentifiers.eBlockDataType) {
					var tmp:int = stream.readUnsignedInt();
					if (tmp == VertexData.eUnsignedInt) {
						type = EPODFaceData.e32Bit;
					} else if (tmp = VertexData.eUnsignedShort) {
						type = EPODFaceData.e16Bit;
					} else {
						throw new Error("UnhandledFaceType");
					}
				} else if (tag.identifier == EPODIdentifiers.eBlockData) {

					if (type == EPODFaceData.e16Bit) {

						data =
								data = readUint16Array(stream, tag.dataLength / 2);
					} else if (type == EPODFaceData.e32Bit) {
						data = readUint32Array(stream, tag.dataLength / 4);
					}

					size = tag.dataLength;
				} else {
					// Unhandled data, skip it
					if (stream.position + tag.dataLength > stream.length) {
						result = EPODErrorCodes.eStreamError;
					} else {
						stream.position += tag.dataLength;
					}
				}

				if (result != EPODErrorCodes.eNoError) {
					break;
				}
			}

			return result;
		}

		public function readVertexData(stream:ByteArray, mesh:MeshData, semanticName:String, blockIdentifier:int, dataIndex:int):int {
			var result:int = EPODErrorCodes.eNoError;
			var tag:PODTag = new PODTag();
			var numComponents:int = 0;
			var stride:int = 0;
			var offset:int = 0;
			var type:int = VertexData.eNone;

			while (readTag(stream, tag)) {
				if (tag.identifier == (blockIdentifier | EPODDefines.endTagMask)) {
					if (numComponents != 0) // Is there a vertex element to add?
						return mesh.addElement(semanticName, type, numComponents, stride, offset, dataIndex);
					else
						return EPODErrorCodes.eNoError;
				}

				switch (tag.identifier) {
					case EPODIdentifiers.eBlockDataType:
						type = stream.readUnsignedInt();
						continue;
					case EPODIdentifiers.eBlockNumComponents:
						numComponents = stream.readInt();
						break;
					case EPODIdentifiers.eBlockStride:
						stride = stream.readInt();
						break;
					case EPODIdentifiers.eBlockData:
						if (dataIndex == -1) // This POD file isn't using interleaved data so this data block must be valid vertex data
						{
							var data:Vector.<Number>;
							switch (type) {
								default:
									throw new Error("Unhandled data type");
									return 0;
								case VertexData.eFloat:
									data = readFloat32Array(stream, tag.dataLength / 4);
									break;
								case VertexData.eInt:
									data = readInt32ArrayNumber(stream, tag.dataLength / 4);
									break;
								case VertexData.eShort:
								case VertexData.eShortNorm:
									data = readInt16ArrayNumber(stream, tag.dataLength / 2);
									break;
								case VertexData.eUnsignedShort:
								case VertexData.eUnsignedShortNorm:
									data = readUint16ArrayNumber(stream, tag.dataLength / 2);
									break;
								case VertexData.eUnsignedInt:
								case VertexData.eRGBA:
								case VertexData.eABGR:
								case VertexData.eARGB:
								case VertexData.eD3DCOLOR:
								case VertexData.eUBYTE4:
								case VertexData.eDEC3N:
								case VertexData.eFixed16_16:
									data = readUint32ArrayNumber(stream, tag.dataLength / 4);
									break;
								case VertexData.eUnsignedByte:
								case VertexData.eUnsignedByteNorm:
									data = readByteArrayNumber(stream, tag.dataLength);
									break;
								case VertexData.eByte:
								case VertexData.eByteNorm:
									data = readSignedByteArrayNumber(stream, tag.dataLength);
									break;
							}

							dataIndex = mesh.addData(data);

						}
						else {
							offset = stream.readUnsignedInt();
						}
						break;
					default:

						// Unhandled data, skip it
						if (stream.position + tag.dataLength > stream.length) {
							result = EPODErrorCodes.eStreamError;
						} else {
							stream.position += tag.dataLength;
						}
				}

				if (result != EPODErrorCodes.eNoError)
					return result;
			}

			return result;
		}

		public function readCameraBlock(stream:ByteArray, camera:CameraData):int {
			var result:int = EPODErrorCodes.eNoError;
			var tag:PODTag = new PODTag();

			while (readTag(stream, tag)) {
				switch (tag.identifier) {
					case EPODIdentifiers.eSceneCamera | EPODDefines.endTagMask:
						return EPODErrorCodes.eNoError;
					case EPODIdentifiers.eCameraTargetObjectIndex | EPODDefines.startTagMask:
						camera.targetIndex = stream.readInt();
						break;
					case EPODIdentifiers.eCameraFOV | EPODDefines.startTagMask:
						if (camera.fovs) {
							stream.position += tag.dataLength;
						}
						else {
							camera.fovs = readFloat32Array(stream, 1);
							camera.numFrames = 1;
						}
						break;

					case EPODIdentifiers.eCameraFarPlane | EPODDefines.startTagMask:
						camera.far = stream.readFloat();
						break;
					case EPODIdentifiers.eCameraNearPlane | EPODDefines.startTagMask:
						camera.near = stream.readFloat();
						break;
					case EPODIdentifiers.eCameraFOVAnimation | EPODDefines.startTagMask:
						camera.numFrames = tag.dataLength / 4; // sizeof(float)
						camera.fovs = readFloat32Array(stream, camera.numFrames);
						break;
					default:
						// Unhandled data, skip it
						if (stream.position + tag.dataLength > stream.length) {
							result = EPODErrorCodes.eStreamError;
						} else {
							stream.position += tag.dataLength;
						}
				}

				if (result != EPODErrorCodes.eNoError)
					return result;
			}

			return result;
		}


		public function readLightBlock(stream:ByteArray, light:LightData):int {
			var result:int = EPODErrorCodes.eNoError;
			var tag:PODTag = new PODTag();

			while (readTag(stream, tag)) {
				switch (tag.identifier) {
					case EPODIdentifiers.eSceneLight | EPODDefines.endTagMask:
						return EPODErrorCodes.eNoError;
					case EPODIdentifiers.eLightTargetObjectIndex | EPODDefines.startTagMask:
						light.targetIndex = stream.readInt();
						break;
					case EPODIdentifiers.eLightColour | EPODDefines.startTagMask:
						light.colour = readFloat32Array(stream, 3);
						break;
					case EPODIdentifiers.eLightType | EPODDefines.startTagMask:
						light.type = stream.readUnsignedInt();
						break;
					case EPODIdentifiers.eLightConstantAttenuation | EPODDefines.startTagMask:
						light.constantAttenuation = stream.readFloat();
						break;
					case EPODIdentifiers.eLightLinearAttenuation | EPODDefines.startTagMask:
						light.linearAttenuation = stream.readFloat();
						break;
					case EPODIdentifiers.eLightQuadraticAttenuation | EPODDefines.startTagMask:
						light.quadraticAttenuation = stream.readFloat();
						break;
					case EPODIdentifiers.eLightFalloffAngle | EPODDefines.startTagMask:
						light.falloffAngle = stream.readFloat();
						break;
					case EPODIdentifiers.eLightFalloffExponent | EPODDefines.startTagMask:
						light.falloffExponent = stream.readFloat();
						break;
					default:
					{
						// Unhandled data, skip it
						if (stream.position + tag.dataLength > stream.length) {
							result = EPODErrorCodes.eStreamError;
						} else {
							stream.position += tag.dataLength;
						}
					}
				}

				if (result != EPODErrorCodes.eNoError)
					return result;
			}

			return result;
		}

		public function readMeshBlock(stream:ByteArray, mesh:MeshData):int {
			var result:int = EPODErrorCodes.eNoError;
			var tag:PODTag = new PODTag();

			var numUVWs:int = 0;
			var podUVWs:int = 0;
			var interleavedDataIndex:int = -1;

			while (readTag(stream, tag)) {
				switch (tag.identifier) {
					case EPODIdentifiers.eSceneMesh | EPODDefines.endTagMask:

						if (mesh.faces.data.length > 0) {
							if (mesh.primitiveData.numStrips) {
								mesh.primitiveData.primitiveType = EPODMesh.eIndexedTriangleStrips;
							} else {
								mesh.primitiveData.primitiveType = EPODMesh.eIndexedTriangleList;
							}
						}
						else {
							if (mesh.primitiveData.numStrips) {
								mesh.primitiveData.primitiveType = EPODMesh.eTriangleStrips;
							} else {
								mesh.primitiveData.primitiveType = EPODMesh.eTriangleList;
							}

						}

						if (numUVWs != podUVWs || numUVWs != mesh.getNumElementsOfSemantic(EPODSemantic.UV0))  // TODO
							return EPODErrorCodes.eUnknown;

						return EPODErrorCodes.eNoError;
						break;
					case EPODIdentifiers.eMeshNumVertices | EPODDefines.startTagMask:
						mesh.primitiveData.numVertices = stream.readUnsignedInt();
						break;
					case EPODIdentifiers.eMeshNumFaces | EPODDefines.startTagMask:
						mesh.primitiveData.numFaces = stream.readUnsignedInt();
						break;
					case EPODIdentifiers.eMeshNumUVWChannels | EPODDefines.startTagMask:
						podUVWs = stream.readInt();
						break;
					case EPODIdentifiers.eMeshStripLength | EPODDefines.startTagMask:
						mesh.primitiveData.stripLengths = readUint32Array(stream, tag.dataLength / 4);
						break;
					case EPODIdentifiers.eMeshNumStrips | EPODDefines.startTagMask:
						mesh.primitiveData.numStrips = stream.readUnsignedInt();
						break;
					case EPODIdentifiers.eMeshInteravedDataList | EPODDefines.startTagMask:

						var data:Vector.<Number> = readByteArrayNumber(stream, tag.dataLength);

						interleavedDataIndex = mesh.addData(data);

						if (interleavedDataIndex == -1)
							return EPODErrorCodes.eUnknown;

						break;

					case EPODIdentifiers.eMeshBoneBatchIndexList | EPODDefines.startTagMask:
						mesh.boneBatches.batches = readUint32Array(stream, tag.dataLength / 4);
						break;
					case EPODIdentifiers.eMeshNumBoneIndicesPerBatch | EPODDefines.startTagMask:
						mesh.boneBatches.boneCounts = readUint32Array(stream, tag.dataLength / 4);
						break;
					case EPODIdentifiers.eMeshBoneOffsetPerBatch | EPODDefines.startTagMask:
						mesh.boneBatches.offsets = readUint32Array(stream, tag.dataLength / 4);
						break;
					case EPODIdentifiers.eMeshMaxNumBonesPerBatch | EPODDefines.startTagMask:
						mesh.boneBatches.boneMax = stream.readUnsignedInt();
						break;
					case EPODIdentifiers.eMeshNumBoneBatches | EPODDefines.startTagMask:
						mesh.boneBatches.count = stream.readUnsignedInt();
						break;
					case EPODIdentifiers.eMeshUnpackMatrix | EPODDefines.startTagMask:
						mesh.unpackMatrix = readFloat32Array(stream, 16);
						break;
					case EPODIdentifiers.eMeshVertexIndexList | EPODDefines.startTagMask:
						result = readVertexIndexData(stream, mesh);
						break;
					case EPODIdentifiers.eMeshVertexList | EPODDefines.startTagMask:
						result = readVertexData(stream, mesh, EPODSemantic.POSITION0, tag.identifier, interleavedDataIndex);
						break;
					case EPODIdentifiers.eMeshNormalList | EPODDefines.startTagMask:
						result = readVertexData(stream, mesh, EPODSemantic.NORMAL0, tag.identifier, interleavedDataIndex);
						break;
					case EPODIdentifiers.eMeshTangentList | EPODDefines.startTagMask:
						result = readVertexData(stream, mesh, EPODSemantic.TANGENT0, tag.identifier, interleavedDataIndex);
						break;
					case EPODIdentifiers.eMeshBinormalList | EPODDefines.startTagMask:
						result = readVertexData(stream, mesh, EPODSemantic.BINORMAL0, tag.identifier, interleavedDataIndex);
						break;
					case EPODIdentifiers.eMeshUVWList | EPODDefines.startTagMask:

						var semantic:String = "UV" + numUVWs++;
						result = readVertexData(stream, mesh, semantic, tag.identifier, interleavedDataIndex);
						break;

					case EPODIdentifiers.eMeshVertexColourList | EPODDefines.startTagMask:
						result = readVertexData(stream, mesh, EPODSemantic.VERTEXCOLOR0, tag.identifier, interleavedDataIndex);
						break;
					case EPODIdentifiers.eMeshBoneIndexList | EPODDefines.startTagMask:
						result = readVertexData(stream, mesh, EPODSemantic.BONEINDEX0, tag.identifier, interleavedDataIndex);
						break;
					case EPODIdentifiers.eMeshBoneWeightList | EPODDefines.startTagMask:
						result = readVertexData(stream, mesh, EPODSemantic.BONEWEIGHT0, tag.identifier, interleavedDataIndex);
						break;

					default:
						// Unhandled data, skip it
						if (stream.position + tag.dataLength > stream.length) {
							result = EPODErrorCodes.eStreamError;
						} else {
							stream.position += tag.dataLength;
						}
						break;
				}

				if (result != EPODErrorCodes.eNoError)
					return result;
			}

			return result;
		}

		public function readNodeBlock(stream:ByteArray, node:NodeData):int {
			var result:int = EPODErrorCodes.eNoError;
			var tag:PODTag = new PODTag();

			var isOldFormat:Boolean = false;
			var pos:Vector.<Number>;
			var rotation:Vector.<Number>;
			var scale:Vector.<Number>;
			var matrix:Vector.<Number>;

			var animation:AnimationData = node.animation;

			while (readTag(stream, tag)) {
				switch (tag.identifier) {
					case EPODIdentifiers.eSceneNode | EPODDefines.endTagMask:
						if (isOldFormat) {
							if (animation.positions) {
								animation.flags |= EPODAnimation.eHasPositionAnimation;
							} else {
								animation.positions = pos;
							}

							if (animation.rotations) {
								animation.flags |= EPODAnimation.eHasRotationAnimation;
							} else {
								animation.rotations = rotation;
							}

							if (animation.scales) {
								animation.flags |= EPODAnimation.eHasScaleAnimation;
							} else {
								animation.scales = scale;
							}

							if (animation.matrices) {
								animation.flags |= EPODAnimation.eHasMatrixAnimation;
							} else {
								animation.matrices = matrix;
							}
						}
						return EPODErrorCodes.eNoError;
						break;
					case EPODIdentifiers.eNodeIndex | EPODDefines.startTagMask:
						node.index = stream.readInt();
						break;
					case EPODIdentifiers.eNodeName | EPODDefines.startTagMask:
						node.name = stream.readUTFBytes(tag.dataLength);
						break;
					case EPODIdentifiers.eNodeMaterialIndex | EPODDefines.startTagMask:
						node.materialIndex = stream.readInt();
						break;
					case EPODIdentifiers.eNodeParentIndex | EPODDefines.startTagMask:
						node.parentIndex = stream.readInt();
						break;
					case EPODIdentifiers.eNodePosition | EPODDefines.startTagMask:  // Deprecated
						pos = readFloat32Array(stream, 3);
						isOldFormat = true;
						break;
					case EPODIdentifiers.eNodeRotation | EPODDefines.startTagMask:  // Deprecated
						rotation = readFloat32Array(stream, 4);
						isOldFormat = true;
						break;
					case EPODIdentifiers.eNodeScale | EPODDefines.startTagMask:     // Deprecated
						scale = readFloat32Array(stream, 3);
						isOldFormat = true;
						break;
					case EPODIdentifiers.eNodeMatrix | EPODDefines.startTagMask:	// Deprecated
						matrix = readFloat32Array(stream, 16);
						isOldFormat = true;
						break;
					case EPODIdentifiers.eNodeAnimationPosition | EPODDefines.startTagMask:
						animation.positions = readFloat32Array(stream, tag.dataLength / 4);// sizeof(float)
						break;
					case EPODIdentifiers.eNodeAnimationRotation | EPODDefines.startTagMask:
						animation.rotations = readFloat32Array(stream, tag.dataLength / 4); // sizeof(float)
						break;
					case EPODIdentifiers.eNodeAnimationScale | EPODDefines.startTagMask:
						animation.scales = readFloat32Array(stream, tag.dataLength / 4); // sizeof(float)
						break;
					case EPODIdentifiers.eNodeAnimationMatrix | EPODDefines.startTagMask:
						animation.matrices = readFloat32Array(stream, tag.dataLength / 4); // sizeof(float)
						break;
					case EPODIdentifiers.eNodeAnimationFlags | EPODDefines.startTagMask:
						animation.flags = stream.readUnsignedInt();
						break;
					case EPODIdentifiers.eNodeAnimationPositionIndex | EPODDefines.startTagMask:
						animation.positionIndices = readUint32Array(stream, tag.dataLength / 4); // sizeof(Uint32)
						break;
					case EPODIdentifiers.eNodeAnimationRotationIndex | EPODDefines.startTagMask:
						animation.rotationIndices = readUint32Array(stream, tag.dataLength / 4); // sizeof(Uint32)
						break;
					case EPODIdentifiers.eNodeAnimationScaleIndex | EPODDefines.startTagMask:
						animation.scaleIndices = readUint32Array(stream, tag.dataLength / 4); // sizeof(Uint32)
						break;
					case EPODIdentifiers.eNodeAnimationMatrixIndex | EPODDefines.startTagMask:
						animation.matrixIndices = readUint32Array(stream, tag.dataLength / 4); // sizeof(Uint32)
						break;
					case EPODIdentifiers.eNodeUserData | EPODDefines.startTagMask:
						node.userData = readByteArrayNumber(stream, tag.dataLength);
						break;

					default:

						// Unhandled data, skip it
						if (stream.position + tag.dataLength > stream.length) {
							result = EPODErrorCodes.eStreamError;
						} else {
							stream.position += tag.dataLength;
						}

				}

				if (result != EPODErrorCodes.eNoError)
					return result;
			}

			return result;
		}

		public function readTextureBlock(stream:ByteArray, texture:TextureData):int {
			var result:int = EPODErrorCodes.eNoError;
			var tag:PODTag = new PODTag();

			while (readTag(stream, tag)) {
				switch (tag.identifier) {
					case EPODIdentifiers.eSceneTexture | EPODDefines.endTagMask:
						return EPODErrorCodes.eNoError;
					case EPODIdentifiers.eTextureFilename | EPODDefines.startTagMask:
						texture.name = stream.readUTFBytes(tag.dataLength);
						break;
					default:
						// Unhandled data, skip it
						if (stream.position + tag.dataLength > stream.length) {
							result = EPODErrorCodes.eStreamError;
						} else {
							stream.position += tag.dataLength;
						}
				}

				if (result != EPODErrorCodes.eNoError)
					return result;
			}

			return result;
		}

		public function readMaterialBlock(stream:ByteArray, material:MaterialData):int {
			var result:int = EPODErrorCodes.eNoError;
			var tag:PODTag = new PODTag();

			while (readTag(stream, tag)) {
				switch (tag.identifier) {
					case EPODIdentifiers.eSceneMaterial | EPODDefines.endTagMask:
						return EPODErrorCodes.eNoError;
					case EPODIdentifiers.eMaterialName | EPODDefines.startTagMask:
						material.name = stream.readUTFBytes(tag.dataLength);
						break;
					case EPODIdentifiers.eMaterialDiffuseTextureIndex | EPODDefines.startTagMask:
						material.diffuseTextureIndex = stream.readInt();
						break;
					case EPODIdentifiers.eMaterialOpacity | EPODDefines.startTagMask:
						material.opacity = stream.readFloat();
						break;
					case EPODIdentifiers.eMaterialAmbientColour | EPODDefines.startTagMask:
						material.ambient = readFloat32Array(stream, 3);
						break;
					case EPODIdentifiers.eMaterialDiffuseColour | EPODDefines.startTagMask:
						material.diffuse = readFloat32Array(stream, 3);
						break;
					case EPODIdentifiers.eMaterialSpecularColour | EPODDefines.startTagMask:
						material.specular = readFloat32Array(stream, 3);
						break;
					case EPODIdentifiers.eMaterialShininess | EPODDefines.startTagMask:
						material.shininess = stream.readFloat();
						break;
					case EPODIdentifiers.eMaterialEffectFile | EPODDefines.startTagMask:
						material.effectFile = stream.readUTFBytes(tag.dataLength);
						break;
					case EPODIdentifiers.eMaterialEffectName | EPODDefines.startTagMask:
						material.effectName = stream.readUTFBytes(tag.dataLength);
						break;
					case EPODIdentifiers.eMaterialAmbientTextureIndex | EPODDefines.startTagMask:
						material.ambientTextureIndex = stream.readInt();
						break;
					case EPODIdentifiers.eMaterialSpecularColourTextureIndex | EPODDefines.startTagMask:
						material.specularColourTextureIndex = stream.readInt();
						break;
					case EPODIdentifiers.eMaterialSpecularLevelTextureIndex | EPODDefines.startTagMask:
						material.specularLevelTextureIndex = stream.readInt();
						break;
					case EPODIdentifiers.eMaterialBumpMapTextureIndex | EPODDefines.startTagMask:
						material.bumpMapTextureIndex = stream.readInt();
						break;
					case EPODIdentifiers.eMaterialEmissiveTextureIndex | EPODDefines.startTagMask:
						material.emissiveTextureIndex = stream.readInt();
						break;
					case EPODIdentifiers.eMaterialGlossinessTextureIndex | EPODDefines.startTagMask:
						material.glossinessTextureIndex = stream.readInt();
						break;
					case EPODIdentifiers.eMaterialOpacityTextureIndex | EPODDefines.startTagMask:
						material.opacityTextureIndex = stream.readInt();
						break;
					case EPODIdentifiers.eMaterialReflectionTextureIndex | EPODDefines.startTagMask:
						material.reflectionTextureIndex = stream.readInt();
						break;
					case EPODIdentifiers.eMaterialRefractionTextureIndex | EPODDefines.startTagMask:
						material.refractionTextureIndex = stream.readInt();
						break;
					case EPODIdentifiers.eMaterialBlendingRGBSrc | EPODDefines.startTagMask:
						material.blendSrcRGB = stream.readUnsignedInt();
						break;
					case EPODIdentifiers.eMaterialBlendingAlphaSrc | EPODDefines.startTagMask:
						material.blendSrcA = stream.readUnsignedInt();
						break;
					case EPODIdentifiers.eMaterialBlendingRGBDst | EPODDefines.startTagMask:
						material.blendDstRGB = stream.readUnsignedInt();
						break;
					case EPODIdentifiers.eMaterialBlendingAlphaDst | EPODDefines.startTagMask:
						material.blendDstA = stream.readUnsignedInt();
						break;
					case EPODIdentifiers.eMaterialBlendingRGBOperation | EPODDefines.startTagMask:
						material.blendOpRGB = stream.readUnsignedInt();
						break;
					case EPODIdentifiers.eMaterialBlendingAlphaOperation | EPODDefines.startTagMask:
						material.blendOpA = stream.readUnsignedInt();
						break;
					case EPODIdentifiers.eMaterialBlendingRGBAColour | EPODDefines.startTagMask:
						material.blendColour = readFloat32Array(stream, 4);
						break;
					case EPODIdentifiers.eMaterialBlendingFactorArray | EPODDefines.startTagMask:
						material.blendFactor = readFloat32Array(stream, 4);
						break;
					case EPODIdentifiers.eMaterialFlags | EPODDefines.startTagMask:
						material.flags = stream.readUnsignedInt();
						break;
					case EPODIdentifiers.eMaterialUserData | EPODDefines.startTagMask:
						material.userData = readByteArrayNumber(stream, tag.dataLength);
						break;
					default:

						// Unhandled data, skip it
						if (stream.position + tag.dataLength > stream.length) {
							result = EPODErrorCodes.eStreamError;
						} else {
							stream.position += tag.dataLength;
						}
				}

				if (result != EPODErrorCodes.eNoError)
					return result;
			}

			return result;
		}

		public function readSceneBlock(stream:ByteArray, model:ModelData):int {
			var result:int = EPODErrorCodes.eNoError;
			var tag:PODTag = new PODTag();
			var numCameras:int = 0;
			var numLights:int = 0;
			var numMaterials:int = 0;
			var numMeshes:int = 0;
			var numTextures:int = 0;
			var numNodes:int = 0;

			while (readTag(stream, tag)) {
				switch (tag.identifier) {
					case EPODIdentifiers.eScene | EPODDefines.endTagMask:
						if (numCameras != model.numCameras) {
							return EPODErrorCodes.eUnknown;
						}

						if (numLights != model.numLights) {
							return EPODErrorCodes.eUnknown;
						}


						if (numMaterials != model.numMaterials) {
							return EPODErrorCodes.eUnknown;
						}


						if (numMeshes != model.numMeshes) {
							return EPODErrorCodes.eUnknown;
						}


						if (numTextures != model.numTextures) {
							return EPODErrorCodes.eUnknown;
						}


						if (numNodes != model.numNodes) {
							return EPODErrorCodes.eUnknown;
						}

						return EPODErrorCodes.eNoError;

					case EPODIdentifiers.eSceneClearColour | EPODDefines.startTagMask:
						model.clearColour = readFloat32Array(stream, 3);
						break;

					case EPODIdentifiers.eSceneAmbientColour | EPODDefines.startTagMask:
						model.ambientColour = readFloat32Array(stream, 3);
						break;

					case EPODIdentifiers.eSceneNumCameras | EPODDefines.startTagMask:
						model.numCameras = stream.readInt();
						break;

					case EPODIdentifiers.eSceneNumLights | EPODDefines.startTagMask:
						model.numLights = stream.readInt();
						break;

					case EPODIdentifiers.eSceneNumMeshes | EPODDefines.startTagMask:
						model.numMeshes = stream.readInt();
						break;

					case EPODIdentifiers.eSceneNumNodes | EPODDefines.startTagMask:
						model.numNodes = stream.readInt();
						break;

					case EPODIdentifiers.eSceneNumMeshNodes | EPODDefines.startTagMask:
						model.numMeshNodes = stream.readInt();
						break;

					case EPODIdentifiers.eSceneNumTextures | EPODDefines.startTagMask:
						model.numTextures = stream.readInt();
						break;

					case EPODIdentifiers.eSceneNumMaterials | EPODDefines.startTagMask:
						model.numMaterials = stream.readInt();
						break;

					case EPODIdentifiers.eSceneNumFrames | EPODDefines.startTagMask:
						model.numFrames = stream.readInt();
						break;

					case EPODIdentifiers.eSceneFlags | EPODDefines.startTagMask:
						model.flags = stream.readInt();
						break;

					case EPODIdentifiers.eSceneFPS | EPODDefines.startTagMask:
						model.fps = stream.readInt();
						break;

					case EPODIdentifiers.eSceneUserData | EPODDefines.startTagMask:
						model.userData = readByteArrayNumber(stream, tag.dataLength);
						break;

					case EPODIdentifiers.eSceneUnits | EPODDefines.startTagMask:
						model.units = stream.readInt();
						break;

					case EPODIdentifiers.eSceneCamera | EPODDefines.startTagMask:
						var camera:CameraData = new CameraData();
						result = readCameraBlock(stream, camera);
						model.cameras.push(camera);
						numCameras++;
						break;

					case EPODIdentifiers.eSceneLight | EPODDefines.startTagMask:
						var light:LightData = new LightData();
						result = readLightBlock(stream, light);
						model.lights.push(light);
						numLights++;
						break;

					case EPODIdentifiers.eSceneMesh | EPODDefines.startTagMask:
						var mesh:MeshData = new MeshData();
						result = readMeshBlock(stream, mesh);
						model.meshes.push(mesh);
						numMeshes++;
						break;

					case EPODIdentifiers.eSceneNode | EPODDefines.startTagMask:
						var anim:AnimationData = new AnimationData();
						var node:NodeData = new NodeData();
						node.animation = anim;
						result = readNodeBlock(stream, node);
						model.nodes.push(node);
						numNodes++;
						break;

					case EPODIdentifiers.eSceneTexture | EPODDefines.startTagMask:
						var texture:TextureData = new TextureData();
						result = readTextureBlock(stream, texture);
						model.textures.push(texture);
						numTextures++;
						break;

					case EPODIdentifiers.eSceneMaterial | EPODDefines.startTagMask:
						var material:MaterialData = new MaterialData();
						result = readMaterialBlock(stream, material);
						model.materials.push(material);
						numMaterials++;
						break;

					default:
						// Unhandled data, skip it
						if (stream.position + tag.dataLength > stream.length) {
							result = EPODErrorCodes.eStreamError;
						} else {
							stream.position += tag.dataLength;
						}
				}

				if (result != EPODErrorCodes.eNoError)
					return result;
			}

			return result;
		}


		public function load(stream:ByteArray, model:ModelData):int {
			if (!stream.bytesAvailable) {
				return EPODErrorCodes.eDataIsEmpty;
			}

			var result:int = EPODErrorCodes.eNoError;
			var tag:PODTag = new PODTag();
			while (readTag(stream, tag)) {
				switch (tag.identifier) {
					case EPODIdentifiers.eFormatVersion | EPODDefines.startTagMask:

						// Is the version string in the file the same length as ours?
						if (tag.dataLength != EPODDefines.PODFormatVersionLen)
							return EPODErrorCodes.eVersionMismatch;

						// ... it is. Check to see if the string matches
						var version:String = stream.readUTFBytes(tag.dataLength);
						if (version != EPODDefines.PODFormatVersion)
							return EPODErrorCodes.eVersionMismatch;

						break;

					case EPODIdentifiers.eScene | EPODDefines.startTagMask:

						result = readSceneBlock(stream, model);
						if (result == EPODErrorCodes.eNoError) {
							result = model.initCache();
						}
						return result;

					default:

						// Unhaondled data, skip it
						if (stream.position + tag.dataLength > stream.length) {
							result = EPODErrorCodes.eStreamError;
						} else {
							stream.position += tag.dataLength;
						}

				}
			}

			return EPODErrorCodes.eNoError;
		}

		private static function readFloat32Array(stream:ByteArray, length:int):Vector.<Number> {
			var result:Vector.<Number> = new Vector.<Number>();
			for (var i:int = 0; i < length; i++) {
				result.push(stream.readFloat());
			}
			return result;
		}

		private static function readSignedByteArray(stream:ByteArray, length:int):Vector.<int> {
			var result:Vector.<int> = new Vector.<int>();
			for (var i:int = 0; i < length; i++) {
				result.push(stream.readByte());
			}
			return result;
		}

		private static function readByteArray(stream:ByteArray, length:int):Vector.<uint> {
			var result:Vector.<uint> = new Vector.<uint>();
			for (var i:int = 0; i < length; i++) {
				result.push(stream.readUnsignedByte());
			}
			return result;
		}

		private static function readInt16Array(stream:ByteArray, length:int):Vector.<int> {
			var result:Vector.<int> = new Vector.<int>();
			for (var i:int = 0; i < length; i++) {
				result.push(stream.readShort());
			}
			return result;
		}

		private static function readInt32Array(stream:ByteArray, length:int):Vector.<int> {
			var result:Vector.<int> = new Vector.<int>();
			for (var i:int = 0; i < length; i++) {
				result.push(stream.readInt());
			}
			return result;
		}

		private static function readUint16Array(stream:ByteArray, length:int):Vector.<uint> {
			var result:Vector.<uint> = new Vector.<uint>();
			for (var i:int = 0; i < length; i++) {
				result.push(stream.readUnsignedShort());
			}
			return result;
		}

		private static function readUint32Array(stream:ByteArray, length:int):Vector.<uint> {
			var result:Vector.<uint> = new Vector.<uint>();
			for (var i:int = 0; i < length; i++) {
				result.push(stream.readUnsignedInt());
			}
			return result;
		}

		private static function readSignedByteArrayNumber(stream:ByteArray, length:int):Vector.<Number> {
			var result:Vector.<Number> = new Vector.<Number>();
			for (var i:int = 0; i < length; i++) {
				result.push(stream.readByte());
			}
			return result;
		}

		private static function readByteArrayNumber(stream:ByteArray, length:int):Vector.<Number> {
			var result:Vector.<Number> = new Vector.<Number>();
			for (var i:int = 0; i < length; i++) {
				result.push(stream.readUnsignedByte());
			}
			return result;
		}

		private static function readInt16ArrayNumber(stream:ByteArray, length:int):Vector.<Number> {
			var result:Vector.<Number> = new Vector.<Number>();
			for (var i:int = 0; i < length; i++) {
				result.push(stream.readShort());
			}
			return result;
		}

		private static function readInt32ArrayNumber(stream:ByteArray, length:int):Vector.<Number> {
			var result:Vector.<Number> = new Vector.<Number>();
			for (var i:int = 0; i < length; i++) {
				result.push(stream.readInt());
			}
			return result;
		}

		private static function readUint16ArrayNumber(stream:ByteArray, length:int):Vector.<Number> {
			var result:Vector.<Number> = new Vector.<Number>();
			for (var i:int = 0; i < length; i++) {
				result.push(stream.readUnsignedShort());
			}
			return result;
		}

		private static function readUint32ArrayNumber(stream:ByteArray, length:int):Vector.<Number> {
			var result:Vector.<Number> = new Vector.<Number>();
			for (var i:int = 0; i < length; i++) {
				result.push(stream.readUnsignedInt());
			}
			return result;
		}
	}
}
