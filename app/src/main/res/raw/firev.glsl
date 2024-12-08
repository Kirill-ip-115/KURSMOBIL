#version 300 es
precision highp float;

// Атрибуты
layout(location = 0) in vec4 a_position;

// Униформы
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform float time;

// Передача данных во фрагментный шейдер
out float v_time;

void main() {
    // Применение трансформаций к позиции
    gl_Position = projection * view * model * a_position;

    // Задаем размер точки (если рендерим точки)
    gl_PointSize = 70.0;

    // Передаем время во фрагментный шейдер
    v_time = time;
}
