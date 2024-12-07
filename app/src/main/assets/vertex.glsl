attribute vec4 a_Position;  // Позиция вершины
attribute vec2 a_TexCoord;  // Текстурные координаты

varying vec2 v_TexCoord;    // Передаем текстурные координаты во фрагментный шейдер

void main() {
    v_TexCoord = a_TexCoord;  // Передаем текстурные координаты
    gl_Position = a_Position; // Устанавливаем позицию вершины
}
