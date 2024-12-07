precision mediump float;  // Указываем точность для float

uniform sampler2D u_Texture; // Текстура, которая будет использоваться

varying vec2 v_TexCoord;  // Получаем текстурные координаты

void main() {
    gl_FragColor = texture2D(u_Texture, v_TexCoord); // Используем текстуру для цвета
}
