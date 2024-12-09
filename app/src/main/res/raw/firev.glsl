#version 100
precision mediump float;  // Указываем точность для всех типов данных

attribute vec4 a_vertex;      // Позиция вершины
attribute vec2 a_TexCord;     // Текстурные координаты
attribute vec3 a_normal;      // Нормали

// Унитарные переменные
uniform mat4 model;           // Модельная матрица
uniform mat4 view;            // Вида матрица
uniform mat4 projection;      // Проекционная матрица
uniform vec3 u_camera;        // Позиция камеры
uniform float u_time;         // Время для анимации

varying vec2 v_TexCord;
varying vec3 v_normal;
varying vec3 v_vertex;

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

    // Добавление анимации пламени с колебаниями по горизонтали
    // Пламя будет двигаться сильнее в верхней части

    // Мы будем использовать зависимость амплитуды колебания от высоты (y)
    float waveIntensity = smoothstep(0.0, 1.0, a_vertex.y * 0.7); // Гладкая функция для интенсивности

    // Генерация колебаний по осям X и Z с учетом времени и интенсивности
    float waveX = sin(a_vertex.y * 2.0 + u_time * 3.0) * waveIntensity * 0.1; // Синусоидальная волна для движения по X
    float waveZ = sin(a_vertex.x * 2.0 + u_time * 3.0) * waveIntensity * 0.1; // Синусоидальная волна для движения по Z

    // Модификация координат для пламени (горизонтальные колебания)
    vec3 animatedVertex = a_vertex.xyz + vec3(waveX, 0.0, waveZ);

    // Позиция вершины в мировом пространстве передается во фрагментный шейдер
    v_vertex = vec3(model * vec4(animatedVertex, 1.0));

    // Преобразование позиции вершины в пространство экрана
    gl_Position = projection * view * model * vec4(animatedVertex, 1.0);
}
