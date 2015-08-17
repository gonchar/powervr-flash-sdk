package com.powervr.pod.data {
	import com.powervr.pod.enums.EPODMesh;

	public class PrimitiveData {
		public var numVertices:int = 0;
		public var numFaces:int = 0;
		public var numStrips:int = 0;
		public var numPatchesSubdivisions:int = 0;
		public var numPatches:int = 0;
		public var numControlPointsPerPatch:int = 0;
		public var stripLengths:Vector.<uint> = new Vector.<uint>();
		public var primitiveType:int = EPODMesh.eIndexedTriangleList;

	}
}
