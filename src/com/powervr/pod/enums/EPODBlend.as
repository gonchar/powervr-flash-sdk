package com.powervr.pod.enums {
	public class EPODBlend {
		public static const eZERO:int = 0;
		public static const eONE:int = 1;
		public static const eBLEND_FACTOR:int = 2;
		public static const eONE_MINUS_BLEND_FACTOR:int = 3;
		public static const eSRC_COLOR:int = 0x0300;
		public static const eONE_MINUS_SRC_COLOR:int = 0x0301;
		public static const eSRC_ALPHA:int = 0x0302;
		public static const eONE_MINUS_SRC_ALPHA:int = 0x0303;
		public static const eDST_ALPHA:int = 0x0304;
		public static const eONE_MINUS_DST_ALPHA:int = 0x0305;
		public static const eDST_COLOR:int = 0x0306;
		public static const eONE_MINUS_DST_COLOR:int = 0x0307;
		public static const eSRC_ALPHA_SATURATE:int = 0x0308;
		public static const eCONSTANT_COLOR:int = 0x8001;
		public static const eONE_MINUS_CONSTANT_COLOR:int = 0x8002;
		public static const eCONSTANT_ALPHA:int = 0x8003;
		public static const eONE_MINUS_CONSTANT_ALPHA:int = 0x8004;

		public static const eADD:int = 0x8006;
		public static const eMIN:int = 0x8007;
		public static const eMAX:int = 0x8008;
		public static const eSUBTRACT:int = 0x800A;
		public static const eREVERSE_SUBTRACT:int = 0x800B;
	}
}
