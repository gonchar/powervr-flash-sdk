package com.powervr.pod.data {
	import com.powervr.pod.enums.EPODErrorCodes;

	public class MeshData {
		public var unpackMatrix:Vector.<Number>;
		public var vertexElementData:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();
		public var vertexElements:Object = {};

		public var primitiveData:PrimitiveData = new PrimitiveData();
		public var boneBatches:BoneBatchesData = new BoneBatchesData();
		public var faces:FacesData = new FacesData();

		public function MeshData() {
		}

		public function addFaces(data:Vector.<uint>, type:int):int {
			faces.indexType = type;
			faces.data = data;
			if (data.length > 0) {
				primitiveData.numFaces = data.length / 3;
			} else {
				primitiveData.numFaces = 0;
			}
			return EPODErrorCodes.eNoError;
		}

		public function addElement(semantic:String, type:int, numComponents:int, stride:int, offset:int, dataIndex:int):int {
			if (vertexElements[semantic]) {
				return EPODErrorCodes.eKeyAlreadyExists;
			}

			vertexElements[semantic] = new VertexData(semantic, type, numComponents, stride, offset, dataIndex);

			return EPODErrorCodes.eNoError;
		}

		public function addData(data:Vector.<Number>):int {
			vertexElementData.push(data);
			return vertexElementData.length - 1;
		}

		public function getNumElementsOfSemantic(semantic:String):int {
			var count:int = 0;
			for (var k:String in vertexElements) {
				if (semantic == k) {
					count++;
				}
			}
			return count;
		}
	}
}
