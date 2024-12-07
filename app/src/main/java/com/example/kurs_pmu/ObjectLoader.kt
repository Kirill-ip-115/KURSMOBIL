package com.example.kurs_pmu

import android.content.Context
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStreamReader

class ObjectLoader(context: Context, file: Int, ind: Int) {

    val numFaces: Int
    val normals: FloatArray
    val textureCoordinates: FloatArray
    val positions: FloatArray

    init {
        val vertices = mutableListOf<Float>()
        val normalsList = mutableListOf<Float>()
        val textures = mutableListOf<Float>()
        val faces = mutableListOf<String>()
        var reader: BufferedReader? = null

        try {
            val inStream = InputStreamReader(context.resources.openRawResource(file))
            reader = BufferedReader(inStream)
            var line: String?
            while (reader.readLine().also { line = it } != null) {
                val parts = line!!.split(" ")
                when (parts[0]) {
                    "v" -> {
                        vertices.add(parts[1].toFloat())
                        vertices.add(parts[2].toFloat())
                        vertices.add(parts[3].toFloat())
                    }
                    "vt" -> {
                        textures.add(parts[1].toFloat())
                        textures.add(parts[2].toFloat())
                    }
                    "vn" -> {
                        normalsList.add(parts[1].toFloat())
                        normalsList.add(parts[2].toFloat())
                        normalsList.add(parts[3].toFloat())
                    }
                    "f" -> {
                        faces.add(parts[1])
                        faces.add(parts[2])
                        faces.add(parts[3])
                    }
                }
            }
        } catch (ex: IOException) {
            println(ex.message)
        } finally {
            try {
                reader?.close()
            } catch (ex: IOException) {
                println(ex.message)
            }
        }

        numFaces = faces.size
        normals = FloatArray(numFaces * 3)
        textureCoordinates = FloatArray(numFaces * 2)
        positions = FloatArray(numFaces * 3)

        var positionIndex = 0
        var normalIndex = 0
        var textureIndex = 0

        for (face in faces) {
            val parts = face.split("/")
            var index = 3 * (parts[0].toShort() - 1)
            positions[positionIndex++] = vertices[index++]
            positions[positionIndex++] = vertices[index++]
            positions[positionIndex++] = vertices[index]
            index = 2 * (parts[1].toShort() - 1)
            textureCoordinates[textureIndex++] = textures[index++]
            textureCoordinates[textureIndex++] = textures[index]
            index = 3 * (parts[2].toShort() - 1)
            normals[normalIndex++] = normalsList[index++]
            normals[normalIndex++] = normalsList[index++]
            normals[normalIndex++] = normalsList[index]
        }
    }
}
