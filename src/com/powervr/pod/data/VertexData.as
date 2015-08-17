package com.powervr.pod.data {
	public class VertexData {
		public static const eNone:int = 0;
		public static const eFloat:int = 1;
		public static const eInt:int = 2;
		public static const eUnsignedShort:int = 3;
		public static const eRGBA:int = 4;
		public static const eARGB:int = 5;
		public static const eD3DCOLOR:int = 6;
		public static const eUBYTE4:int = 7;
		public static const eDEC3N:int = 8;
		public static const eFixed16_16:int = 9;
		public static const eUnsignedByte:int = 10;
		public static const eShort:int = 11;
		public static const eShortNorm:int = 12;
		public static const eByte:int = 13;
		public static const eByteNorm:int = 14;
		public static const eUnsignedByteNorm:int = 15;
		public static const eUnsignedShortNorm:int = 16;
		public static const eUnsignedInt:int = 17;
		public static const eABGR:int = 18;
		public static const eCustom:int = 1000;

		public var semantic:int = 0;
		public var dataType:int = 0;
		public var numComponents:int = 0;
		public var stride:int = 0;
		public var offset:int = 0;
		public var dataIndex:int = 0;

		public function VertexData(semantic, type, numComponents, stride, offset, dataIndex) {
			this.semantic = semantic;
			this.dataType = type;
			this.numComponents = numComponents;
			this.stride = stride;
			this.offset = offset;
			this.dataIndex = dataIndex;
		}

		public static function pvrVertexDataTypeSize(type:int):int {
			if (type == VertexData.eFloat) {
				return 4;
			}

			if (type == VertexData.eInt || type == VertexData.eUnsignedInt) {
				return 4;
			}

			if (type == VertexData.eShort ||
					type == VertexData.eShortNorm ||
					type == VertexData.eUnsignedShort ||
					type == VertexData.eUnsignedShortNorm
			) {
				return 2;
			}

			if (type == VertexData.eRGBA) {
				return 4;
			}

			if (type == VertexData.eABGR) {
				return 4;
			}

			if (type == VertexData.eARGB) {
				return 4;
			}

			if (type == VertexData.eD3DCOLOR) {
				return 4;
			}

			if (type == VertexData.eUBYTE4) {
				return 4;
			}

			if (type == VertexData.eDEC3N) {
				return 4;
			}

			if (type == VertexData.eFixed16_16) {
				return 4;
			}

			if (type == VertexData.eUnsignedByte ||
					type == VertexData.eUnsignedByteNorm ||
					type == VertexData.eByte ||
					type == VertexData.eByteNorm
			) {
				return 2;
			}

			throw new Error("Unhandled data type");
			return 0;
		}
	}
}
