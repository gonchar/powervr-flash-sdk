package com.powervr.pod.enums {
	public class EPODIdentifiers {

		public static const eFormatVersion:int = 1000;
		public static const eScene:int = 1001;
		public static const eExportOptions:int = 1002;
		public static const eHistory:int = 1003;
		public static const eEndiannessMismatch:int = -402456576;

		// Scene
		public static const eSceneClearColour:int = 2000;
		public static const eSceneAmbientColour:int = 2001;
		public static const eSceneNumCameras:int = 2002;
		public static const eSceneNumLights:int = 2003;
		public static const eSceneNumMeshes:int = 2004;
		public static const eSceneNumNodes:int = 2005;
		public static const eSceneNumMeshNodes:int = 2006;
		public static const eSceneNumTextures:int = 2007;
		public static const eSceneNumMaterials:int = 2008;
		public static const eSceneNumFrames:int = 2009;
		public static const eSceneCamera:int = 2010;		// Will come multiple times
		public static const eSceneLight:int = 2011;		// Will come multiple times
		public static const eSceneMesh:int = 2012;		// Will come multiple times
		public static const eSceneNode:int = 2013;		// Will come multiple times
		public static const eSceneTexture:int = 2014;	    // Will come multiple times
		public static const eSceneMaterial:int = 2015;	    // Will come multiple times
		public static const eSceneFlags:int = 2016;
		public static const eSceneFPS:int = 2017;
		public static const eSceneUserData:int = 2018;
		public static const eSceneUnits:int = 2019;

		// Materials
		public static const eMaterialName:int = 3000;
		public static const eMaterialDiffuseTextureIndex:int = 3001;
		public static const eMaterialOpacity:int = 3002;
		public static const eMaterialAmbientColour:int = 3003;
		public static const eMaterialDiffuseColour:int = 3004;
		public static const eMaterialSpecularColour:int = 3005;
		public static const eMaterialShininess:int = 3006;
		public static const eMaterialEffectFile:int = 3007;
		public static const eMaterialEffectName:int = 3008;
		public static const eMaterialAmbientTextureIndex:int = 3009;
		public static const eMaterialSpecularColourTextureIndex:int = 3010;
		public static const eMaterialSpecularLevelTextureIndex:int = 3011;
		public static const eMaterialBumpMapTextureIndex:int = 3012;
		public static const eMaterialEmissiveTextureIndex:int = 3013;
		public static const eMaterialGlossinessTextureIndex:int = 3014;
		public static const eMaterialOpacityTextureIndex:int = 3015;
		public static const eMaterialReflectionTextureIndex:int = 3016;
		public static const eMaterialRefractionTextureIndex:int = 3017;
		public static const eMaterialBlendingRGBSrc:int = 3018;
		public static const eMaterialBlendingAlphaSrc:int = 3019;
		public static const eMaterialBlendingRGBDst:int = 3020;
		public static const eMaterialBlendingAlphaDst:int = 3021;
		public static const eMaterialBlendingRGBOperation:int = 3022;
		public static const eMaterialBlendingAlphaOperation:int = 3023;
		public static const eMaterialBlendingRGBAColour:int = 3024;
		public static const eMaterialBlendingFactorArray:int = 3025;
		public static const eMaterialFlags:int = 3026;
		public static const eMaterialUserData:int = 3027;

		// Textures
		public static const eTextureFilename:int = 4000;

		// Nodes
		public static const eNodeIndex:int = 5000;
		public static const eNodeName:int = 5001;
		public static const eNodeMaterialIndex:int = 5002;
		public static const eNodeParentIndex:int = 5003;
		public static const eNodePosition:int = 5004;    // Deprecated
		public static const eNodeRotation:int = 5005;    // Deprecated
		public static const eNodeScale:int = 5006;	// Deprecated
		public static const eNodeAnimationPosition:int = 5007;
		public static const eNodeAnimationRotation:int = 5008;
		public static const eNodeAnimationScale:int = 5009;
		public static const eNodeMatrix:int = 5010;	// Deprecated
		public static const eNodeAnimationMatrix:int = 5011;
		public static const eNodeAnimationFlags:int = 5012;
		public static const eNodeAnimationPositionIndex:int = 5013;
		public static const eNodeAnimationRotationIndex:int = 5014;
		public static const eNodeAnimationScaleIndex:int = 5015;
		public static const eNodeAnimationMatrixIndex:int = 5016;
		public static const eNodeUserData:int = 5017;

		// Mesh
		public static const eMeshNumVertices:int = 6000;
		public static const eMeshNumFaces:int = 6001;
		public static const eMeshNumUVWChannels:int = 6002;
		public static const eMeshVertexIndexList:int = 6003;
		public static const eMeshStripLength:int = 6004;
		public static const eMeshNumStrips:int = 6005;
		public static const eMeshVertexList:int = 6006;
		public static const eMeshNormalList:int = 6007;
		public static const eMeshTangentList:int = 6008;
		public static const eMeshBinormalList:int = 6009;
		public static const eMeshUVWList:int = 6010;			// Will come multiple times
		public static const eMeshVertexColourList:int = 6011;
		public static const eMeshBoneIndexList:int = 6012;
		public static const eMeshBoneWeightList:int = 6013;
		public static const eMeshInteravedDataList:int = 6014;
		public static const eMeshBoneBatchIndexList:int = 6015;
		public static const eMeshNumBoneIndicesPerBatch:int = 6016;
		public static const eMeshBoneOffsetPerBatch:int = 6017;
		public static const eMeshMaxNumBonesPerBatch:int = 6018;
		public static const eMeshNumBoneBatches:int = 6019;
		public static const eMeshUnpackMatrix:int = 6020;

		// Light
		public static const eLightTargetObjectIndex:int = 7000;
		public static const eLightColour:int = 7001;
		public static const eLightType:int = 7002;
		public static const eLightConstantAttenuation:int = 7003;
		public static const eLightLinearAttenuation:int = 7004;
		public static const eLightQuadraticAttenuation:int = 7005;
		public static const eLightFalloffAngle:int = 7006;
		public static const eLightFalloffExponent:int = 7007;

		// Camera
		public static const eCameraTargetObjectIndex:int = 8000;
		public static const eCameraFOV:int = 8001;
		public static const eCameraFarPlane:int = 8002;
		public static const eCameraNearPlane:int = 8003;
		public static const eCameraFOVAnimation:int = 8004;

		// Mesh data block
		public static const eBlockDataType:int = 9000;
		public static const eBlockNumComponents:int = 9001;
		public static const eBlockStride:int = 9002;
		public static const eBlockData:int = 9003;
	}
}
