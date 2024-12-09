#version 100
precision mediump float;

uniform sampler2D u_TextureUnit; // Текстура

varying vec2 v_TexCord;          // Текстурные координаты
varying vec3 v_vertex;           // Позиция вершины
varying vec3 v_normal;           // Нормаль вершины

// Время для анимации
uniform float u_time;

void main() {
    // Просто берем цвет из текстуры, без воздействия освещения
    vec4 texColor = texture2D(u_TextureUnit, v_TexCord);

    // Финальный цвет
    gl_FragColor = texColor;
}
