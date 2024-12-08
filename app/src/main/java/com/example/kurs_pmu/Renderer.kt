package com.example.kurs_pmu

import android.content.Context
import android.content.res.Resources
import android.graphics.BitmapFactory
import android.opengl.*
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStreamReader
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

class Renderer(private val context: Context) : GLSurfaceView.Renderer {

    private val cameraPos = floatArrayOf(0.0f, 1.5f, 2.7f)
    private val lightPos = floatArrayOf(0.0f, 1f, 1.025f)
    private val mMVPMatrix = FloatArray(16)
    private val mMMatrix = FloatArray(16)
    private val mVMatrix = FloatArray(16)
    private val mProjMatrix = FloatArray(16)
    private var time = 0.0f

    private lateinit var shader: Shader
    private lateinit var liquid: Shader
    private lateinit var fire: Shader

    private val models = mutableListOf<List<FloatBuffer>>()
    private val numFaces = mutableListOf<Int>()

    init {
        Matrix.setLookAtM(mVMatrix, 0, cameraPos[0], cameraPos[1], cameraPos[2], 0f, 0f, 0f, 0f, 1f, 0f)
        loadModels(intArrayOf(R.raw.table, R.raw.app, R.raw.ba, R.raw.le, R.raw.pu, R.raw.cup, R.raw.plo, R.raw.candle))
    }

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        GLES20.glEnable(GLES20.GL_DEPTH_TEST)
        GLES20.glEnable(GLES20.GL_CULL_FACE)

        fire = Shader(
            loadShaderFromFile(context, R.raw.firev),
            loadShaderFromFile(context, R.raw.firef)
        )

        liquid = Shader(
            loadShaderFromFile(context, R.raw.liquidv),
            loadShaderFromFile(context, R.raw.liquidf)
        )

        shader = Shader(
            loadShaderFromFile(context, R.raw.vertex),
            loadShaderFromFile(context, R.raw.fragment)
        )

        loadTextures(
            intArrayOf(
                R.drawable.table,
                R.drawable.ap,
                R.drawable.ban,
                R.drawable.lemon,
                R.drawable.pu,
                R.drawable.cup,
                R.drawable.w
            ),  gl ?: return
        )
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        GLES20.glViewport(0, 0, width, height)

        val ratio = width.toFloat() / height
        val k = 0.055f
        val left = -k * ratio
        val right = k * ratio
        val bottom = -k
        val top = k
        val near = 0.1f
        val far = 10.0f

        Matrix.frustumM(mProjMatrix, 0, left, right, bottom, top, near, far)
    }


    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT or GLES20.GL_DEPTH_BUFFER_BIT)
        val n = 6

        Matrix.setIdentityM(mMMatrix, 0)
        liquid.linkVertex(models[n][0], "a_vertex", 3)
        liquid.linkMatrix(mMMatrix, "model")
        liquid.linkMatrix(mVMatrix, "view")
        liquid.linkMatrix(mProjMatrix, "projection")
        liquid.linkVertex(models[n][1], "a_TexCord", 2)
        liquid.linkVertex(models[n][2], "a_normal", 3)
        liquid.linkUniform3f(cameraPos, "u_camera")
        liquid.linkUniform3f(lightPos, "u_lightPosition")
        liquid.linkUniform3f(floatArrayOf(1f, 1f, 1f), "u_lightColor")
        liquid.linkUniform1i(9, "u_TextureUnit")
        GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, numFaces[n])

        Matrix.setIdentityM(mMMatrix, 0)

        val p: FloatBuffer = ByteBuffer.allocateDirect(lightPos.size * 4)
            .order(ByteOrder.nativeOrder())
            .asFloatBuffer().apply {
                put(lightPos)
                position(0)
            }

        fire.linkVertex(p, "position", 4)
        fire.linkUniform1f(time, "time")
        fire.linkMatrix(mMMatrix, "model")
        fire.linkMatrix(mVMatrix, "view")
        fire.linkMatrix(mProjMatrix, "projection")

        time += 2.0f

        GLES20.glEnable(GLES20.GL_BLEND)
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA)
        GLES20.glDrawArrays(GLES20.GL_POINTS, 0, 1)


        // Draw Table
        drawScaledTranslatedModel(0, 0, gl, 0.6f, 0.6f, 0.6f, 0.0f, 0f, 0f)
        //Draw APPLE
        drawScaledTranslatedModel(1, 1, gl, 3f, 3f, 3f, 0.1f, 0.02f, -0.1f)
        //Draw Banan
        drawScaledTranslatedModel(2, 2, gl, 2f, 2f, 2f, 0.15f, 0.05f, 0.0f)

        drawScaledTranslatedModel(3, 3, gl, 2f, 2f, 2f, -0.2f, 0.06f, 0.15f)

        drawScaledTranslatedModel(4, 4, gl, 2f, 2f, 2f, 0.15f, 0.1f, 0.15f)
        // CUP
        drawScaledTranslatedModel(5, 5, gl, 0.1f, 0.1f, 0.1f, -2.5f, 0.6f, -2.5f)
        Matrix.scaleM(mMMatrix, 0, 1f, 1f, 1f)
        drawModel(6, 6, gl)

        drawScaledTranslatedModel(7, 5, gl, 2f, 2f, 0.8f, 0f, 0.14f, 0f)

    }

    private fun drawScaledTranslatedModel(index: Int, subIndex: Int, gl: GL10?, sx: Float, sy: Float, sz: Float, tx: Float, ty: Float, tz: Float) {
        Matrix.setIdentityM(mMMatrix, 0)
        Matrix.scaleM(mMMatrix, 0, sx, sy, sz)
        Matrix.translateM(mMMatrix, 0, tx, ty, tz)
        drawModel(index, subIndex, gl)
    }

    private fun drawModel(modelId: Int, textureId: Int, gl: GL10?) {
        val lightColor = floatArrayOf(1f, 1f, 1f)

        shader.linkVertex(models[modelId][0], "a_vertex", 3)
        shader.linkMatrix(mMMatrix, "model")
        shader.linkMatrix(mVMatrix, "view")
        shader.linkMatrix(mProjMatrix, "projection")
        shader.linkVertex(models[modelId][1], "a_TexCord", 2)
        shader.linkVertex(models[modelId][2], "a_normal", 3)
        shader.linkUniform3f(cameraPos, "u_camera")
        shader.linkUniform3f(lightPos, "u_lightPosition")
        shader.linkUniform3f(lightColor, "u_lightColor")
        shader.linkUniform1i(textureId, "u_TextureUnit")

        GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, numFaces[modelId])
    }

    private fun loadShaderFromFile(context: Context, idRes: Int): String {
        val stringBuilder = StringBuilder()
        try {
            context.resources.openRawResource(idRes).use { input ->
                BufferedReader(InputStreamReader(input)).use { bufReader ->
                    var line: String?
                    while (bufReader.readLine().also { line = it } != null) {
                        stringBuilder.append(line).append("\n")
                    }
                }
            }
        } catch (ex: IOException) {
            ex.printStackTrace()
        } catch (ex: Resources.NotFoundException) {
            ex.printStackTrace()
        }
        return stringBuilder.toString()
    }

    private fun loadModels(modelsId: IntArray) {
        var ind = 0
        for (i in modelsId) {
            val objectLoader = ObjectLoader(context, i, ind)
            ind++

            val vBuf: FloatBuffer = ByteBuffer.allocateDirect(objectLoader.positions.size * 4)
                .order(ByteOrder.nativeOrder())
                .asFloatBuffer()
            vBuf.put(objectLoader.positions).position(0)

            val tBuf: FloatBuffer = ByteBuffer.allocateDirect(objectLoader.textureCoordinates.size * 4)
                .order(ByteOrder.nativeOrder())
                .asFloatBuffer()
            tBuf.put(objectLoader.textureCoordinates).position(0)

            val nBuf: FloatBuffer = ByteBuffer.allocateDirect(objectLoader.normals.size * 4)
                .order(ByteOrder.nativeOrder())
                .asFloatBuffer()
            nBuf.put(objectLoader.normals).position(0)

            val t = mutableListOf<FloatBuffer>()
            t.add(vBuf)
            t.add(tBuf)
            t.add(nBuf)

            models.add(t)
            numFaces.add(objectLoader.numFaces)
        }
    }


    private fun loadTextures(resourceId: IntArray, gl: GL10) {
        val textureIds = IntArray(resourceId.size)
        gl.glGenTextures(resourceId.size, textureIds, 0)

        for (i in textureIds.indices) {
            val bmp = BitmapFactory.decodeResource(context.resources, resourceId[i])

            GLES20.glActiveTexture(GLES20.GL_TEXTURE0 + i)
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureIds[i])

            GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST.toFloat())
            GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR.toFloat())
            GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_REPEAT.toFloat())
            GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_REPEAT.toFloat())

            GLUtils.texImage2D(GLES20.GL_TEXTURE_2D, 0, bmp, 0)

            bmp.recycle()
        }
    }
}