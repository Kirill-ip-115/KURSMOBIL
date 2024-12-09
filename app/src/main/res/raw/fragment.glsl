#version 100
precision mediump float;
uniform vec3 u_camera;        // Позиция камеры
uniform vec3 u_lightPosition; // Позиция источника света
uniform vec3 u_lightColor;    // Цвет источника света

varying vec3 v_vertex; // Позиция вершины
varying vec2 v_TexCord; // Текстурные координаты
varying vec3 v_normal; // Нормаль вершины

uniform sampler2D u_TextureUnit; // Текстура

void main() {
    // Ambient
    float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * u_lightColor;

    // Диффузное освещение
    vec3 norm = normalize(v_normal);
    vec3 lightDir = normalize(u_lightPosition - v_vertex);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * u_lightColor;

    // Спекулярное освещение
    float specularStrength = 0.5;
    vec3 viewDir = normalize(u_camera - v_vertex);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0); // Блик
    vec3 specular = specularStrength * spec * u_lightColor;

    // Рассчитываем расстояние от фрагмента до источника света
    float distance = length(u_lightPosition - v_vertex);

    // Ослабление света по закону обратного квадрата
    float attenuation = 1.0 / (distance * distance);

    // Минимальное ослабление, чтобы избежать слишком темных участков
    attenuation = max(attenuation, 0.1);

    // Итоговый цвет (с учетом ослабления света)
    vec4 texColor = texture2D(u_TextureUnit, v_TexCord);
    vec3 result = (ambient + diffuse + specular) * texColor.rgb * attenuation;

    gl_FragColor = vec4(result, texColor.a);
}
