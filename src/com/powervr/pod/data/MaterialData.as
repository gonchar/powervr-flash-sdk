package com.powervr.pod.data {
	import com.powervr.pod.enums.EPODBlend;

	public class MaterialData {
		public var name:String = "";
		public var diffuseTextureIndex:int = -1;
		public var ambientTextureIndex:int = -1;
		public var specularColourTextureIndex:int = -1;
		public var specularTextureIndex:int = -1;
		public var specularLevelTextureIndex:int = -1;
		public var bumpMapTextureIndex:int = -1;
		public var emissiveTextureIndex:int = -1;
		public var glossinessTextureIndex:int = -1;
		public var opacityTextureIndex:int = -1;
		public var reflectionTextureIndex:int = -1;
		public var refractionTextureIndex:int = -1;
		public var opacity:int = 1;
		public var ambient:Vector.<Number>;
		public var diffuse:Vector.<Number>;
		public var specular:Vector.<Number>;
		public var shininess:int = 0;
		public var effectFile:String = "";
		public var effectName:String = "";
		public var blendSrcRGB:int = EPODBlend.eONE;
		public var blendSrcA:int = EPODBlend.eONE;
		public var blendDstRGB:int = EPODBlend.eZERO;
		public var blendDstA:int = EPODBlend.eZERO;
		public var blendOpRGB:int = EPODBlend.eADD;
		public var blendOpA:int = EPODBlend.eADD;
		public var flags:int = 0;
		public var userData:Vector.<Number>;
		public var blendColour:Vector.<Number>;
		public var blendFactor:Vector.<Number>;
	}
}
