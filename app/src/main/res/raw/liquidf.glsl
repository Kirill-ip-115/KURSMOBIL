#version 100
precision mediump float;  // Устанавливаем точность для типов данных с плавающей запятой

// Объявление входных uniform-переменных для камеры, источника света, цвета света и текстуры
uniform vec3 u_camera;        // Позиция камеры в мировом пространстве
uniform vec3 u_lightPosition; // Позиция источника света
uniform vec3 u_lightColor;    // Цвет источника света
uniform sampler2D u_TextureUnit; // Текстура, применяемая к объекту

// Объявление varying-переменных, которые передаются из вершинного шейдера
varying vec3 v_vertex;  // Мировые координаты вершины
varying vec2 v_TexCord; // Текстурные координаты для фрагмента
varying vec3 v_normal;  // Нормаль в мировой системе координат

void main() {
    // Включаем амбиентное освещение
    float ambientStrength = 0.125; // Сила амбиентного освещения
    vec3 ambient = ambientStrength * u_lightColor;  // Амбиентный цвет с учетом силы освещения

    // Нормализуем нормаль и вычисляем вектор направления света
    vec3 norm = normalize(v_normal);  // Нормализация нормали
    vec3 lightDir = normalize(u_lightPosition - v_vertex);  // Вектор, указывающий от фрагмента к источнику света
    float diff = max(dot(norm, lightDir), 0.0);  // Факторы диффузного освещения (угол между нормалью и направлением света)
    vec3 diffuse = diff * u_lightColor;  // Цвет диффузного освещения

    // Спекулярное освещение (блики)
    float specularStrength = 0.5;  // Сила спекулярного освещения
    vec3 viewDir = normalize(u_camera - v_vertex);  // Вектор от фрагмента к камере
    vec3 reflectDir = reflect(-lightDir, norm);  // Вектор отражения света от поверхности
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);  // Факторы спекулярного освещения (угол между направлением зрения и направлением отраженного света)
    vec3 specular = specularStrength * spec * u_lightColor;  // Спекулярный цвет

    // Рефракция (преломление) и отражение
    vec3 t = refract(-viewDir, norm, 0.9);  // Преломленный вектор (вычисляется с учетом коэффициента преломления)
    vec3 r = reflect(viewDir, norm);  // Отраженный вектор
    float f = pow(max(0.0, dot(viewDir, norm)), 5.0);  // Угол между направлением зрения и нормалью (для вычисления затухания эффекта отражения)

    // Финальный цвет пикселя
    gl_FragColor = mix(  // Смешиваем два варианта цвета: с освещением и с эффектом отражения/рефракции
        vec4(ambient + diffuse + specular, 1.0) * texture2D(u_TextureUnit, v_TexCord),  // Первое значение — освещенный цвет с текстурой
        texture2D(u_TextureUnit, vec2(r.xy)) * (1.0 - f) + texture2D(u_TextureUnit, vec2(t.xy)) * f,  // Второе значение — эффект отражения/рефракции с текстурой
        0.7  // Применяем коэффициент смешивания (влияет на соотношение между двумя цветами)
    );

    // Устанавливаем альфа-канал цвета, чтобы сделать объект полупрозрачным
    gl_FragColor.a = 0.2;
}
