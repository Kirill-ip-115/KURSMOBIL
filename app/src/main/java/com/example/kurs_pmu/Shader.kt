package com.example.kurs_pmu

import android.opengl.GLES20
import java.nio.FloatBuffer

class Shader(vertexShaderString: String, fragmentShaderString: String) {

    private var programHandle: Int = 0

    init {
        createShader(vertexShaderString, fragmentShaderString)
    }

    private fun createShader(vertexShaderString: String, fragmentShaderString: String) {
        val vertexShaderHandle = GLES20.glCreateShader(GLES20.GL_VERTEX_SHADER)
        GLES20.glShaderSource(vertexShaderHandle, vertexShaderString)
        GLES20.glCompileShader(vertexShaderHandle)

        val fragmentShaderHandle = GLES20.glCreateShader(GLES20.GL_FRAGMENT_SHADER)
        GLES20.glShaderSource(fragmentShaderHandle, fragmentShaderString)
        GLES20.glCompileShader(fragmentShaderHandle)

        programHandle = GLES20.glCreateProgram()
        GLES20.glAttachShader(programHandle, vertexShaderHandle)
        GLES20.glAttachShader(programHandle, fragmentShaderHandle)
        GLES20.glLinkProgram(programHandle)
    }

    fun linkVertex(vertex: FloatBuffer, varName: String, size: Int) {
        GLES20.glUseProgram(programHandle)
        val vHandle = GLES20.glGetAttribLocation(programHandle, varName)
        GLES20.glEnableVertexAttribArray(vHandle)
        GLES20.glVertexAttribPointer(vHandle, size, GLES20.GL_FLOAT, false, 0, vertex)
    }

    fun linkMatrix(MVPMatrix: FloatArray, varName: String) {
        GLES20.glUseProgram(programHandle)
        val vHandle = GLES20.glGetUniformLocation(programHandle, varName)
        GLES20.glUniformMatrix4fv(vHandle, 1, false, MVPMatrix, 0)
    }

    fun linkUniform3f(arr: FloatArray, varName: String) {
        GLES20.glUseProgram(programHandle)
        val vHandle = GLES20.glGetUniformLocation(programHandle, varName)
        GLES20.glUniform3f(vHandle, arr[0], arr[1], arr[2])
    }

    fun linkUniform1f(value: Float, varName: String) {
        GLES20.glUseProgram(programHandle)
        val vHandle = GLES20.glGetUniformLocation(programHandle, varName)
        GLES20.glUniform1f(vHandle, value)
    }

    fun linkUniform1i(id: Int, varName: String) {
        GLES20.glUseProgram(programHandle)
        val vHandle = GLES20.glGetUniformLocation(programHandle, varName)
        GLES20.glUniform1i(vHandle, id)
    }
}
