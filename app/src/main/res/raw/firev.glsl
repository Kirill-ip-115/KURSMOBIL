precision highp float;

attribute vec4 a_position; // Позиция точки
uniform float u_time;      // Текущее время
uniform vec2 u_resolution; // Разрешение экрана
varying float v_time;      // Передаем время во фрагментный шейдер

void main() {
    // Преобразуем координаты в диапазон от -1 до 1
    vec2 normalizedPosition = a_position.xy / u_resolution * 2.0 - 1.0;

    // Инвертируем Y-координату, чтобы соответствовать OpenGL
    normalizedPosition.y = -normalizedPosition.y;

    // Устанавливаем позицию точки
    gl_Position = vec4(normalizedPosition, a_position.z, 1.0);

    // Передаем время
    v_time = u_time;

    // Размер точки для отрисовки
    gl_PointSize = 5.0; // Вы можете настроить размер точки, если нужно
}
