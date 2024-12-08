#version 100
precision mediump float;  // Указываем точность для всех типов данных

attribute vec4 a_vertex;      // Позиция вершины
attribute vec2 a_TexCord;    // Текстурные координаты
attribute vec3 a_normal;      // Нормали

// Унитарные переменные
uniform mat4 model;           // Модельная матрица
uniform mat4 view;            // Вида матрица
uniform mat4 projection;      // Проекционная матрица
uniform vec3 u_camera;        // Позиция камеры
uniform vec3 u_lightPosition; // Позиция источника света
uniform vec3 u_lightColor;    // Цвет источника света

varying vec2 v_TexCord;
varying vec3 v_normal;
varying vec3 v_vertex;
varying vec3 v_lightDir;
varying vec3 v_viewDir;

mat3 inverseTranspose(mat4 m) {
    mat3 invMat;
    invMat[0] = cross(m[1].xyz, m[2].xyz);
    invMat[1] = cross(m[2].xyz, m[0].xyz);
    invMat[2] = cross(m[0].xyz, m[1].xyz);
    return invMat;
}

void main() {
    // Передача текстурных координат во фрагментный шейдер
    v_TexCord = a_TexCord;

    // Преобразование нормали в мировое пространство
    mat3 normalMatrix = inverseTranspose(model);
    v_normal = normalize(normalMatrix * a_normal);

    // Направление света и направление из камеры
    v_lightDir = normalize(u_lightPosition - vec3(model * a_vertex));
    v_viewDir = normalize(u_camera - vec3(model * a_vertex));

    // Позиция вершины в мировом пространстве передается во фрагментный шейдер
    v_vertex = vec3(model * a_vertex);

    // Преобразование позиции вершины в пространство экрана
    gl_Position = projection * view * model * a_vertex;
}
