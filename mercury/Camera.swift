import simd

class Camera {
    var fovY: Float
    var aspect: Float
    var nearZ: Float
    var farZ: Float
    var position: SIMD3<Float> = SIMD3<Float>(0, 0, 5)
    var mvMatrix: matrix_float4x4

    init(fovY: Float, aspect: Float, nearZ: Float, farZ: Float) {
        self.fovY = fovY
        self.aspect = aspect
        self.nearZ = nearZ
        self.farZ = farZ
        self.mvMatrix = matrix_float4x4.init()

        updateMVMatrix()
    }

    func updateMVMatrix() {
        mvMatrix = 
            matrix_float4x4(perspectiveFov: fovY, aspect: aspect, nearZ: nearZ, farZ: farZ)
            * matrix_float4x4(translation: -position)
    }

    func updateAspect(_ newAspect: Float) {
        if (newAspect == aspect) { return }
        aspect = newAspect
        updateMVMatrix()
    }
}
