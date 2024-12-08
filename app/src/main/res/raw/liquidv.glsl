precision mediump float;

uniform mat4 model;          // Модельная матрица
uniform mat4 view;           // Вводная матрица вида
uniform mat4 projection;     // Проекционная матрица
uniform vec3 u_camera;       // Позиция камеры

attribute vec3 a_vertex;     // Позиции вершин
attribute vec2 a_TexCord;    // Текстурные координаты
attribute vec3 a_normal;     // Нормали

varying vec3 v_vertex;       // Передача позиции вершины во фрагментный шейдер
varying vec2 v_TexCord;      // Передача текстурных координат во фрагментный шейдер
varying vec3 v_normal;       // Передача нормали во фрагментный шейдер

void main() {
    // Преобразование позиции вершины с помощью матрицы модели и вида
    vec4 viewPosition = view * model * vec4(a_vertex, 1.0);
    gl_Position = projection * viewPosition; // Преобразование в пространстве экрана

    // Передача данных во фрагментный шейдер
    v_vertex = viewPosition.xyz;
    v_TexCord = a_TexCord;
    v_normal = normalize(mat3(model) * a_normal); // Преобразуем нормаль в мировую систему координат
}
