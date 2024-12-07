precision highp float;

varying float v_time;

float sdfCircle(vec2 p, float r) {
    return length(p) - r;
}

vec2 hash(vec2 x) {
    const vec2 k = vec2(0.3183099, 0.3678794);
    x = x * k + k.yx;
    return -1.0 + 2.0 * fract(16.0 * k * fract(x.x * x.y * (x.x + x.y)));
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    float va = dot(hash(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0));
    float vb = dot(hash(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float vc = dot(hash(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float vd = dot(hash(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));

    return va + u.x * (vb - va) + u.y * (vc - va) + u.x * u.y * (va - vb - vc + vd);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    for (int i = 0; i < 5; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void main() {
    vec2 uv = gl_FragCoord.xy / vec2(800.0, 600.0); // Нормализация координат
    uv.y -= v_time * 0.1; // Анимация огня

    // Шум для пламени
    float n = fbm(uv * 3.0);
    n = pow(n, 3.0); // Усиливаем контраст

    // Цветовая градация для огня
    vec3 color = vec3(1.0, 0.5, 0.0) * n; // Оранжевый базовый
    color = mix(color, vec3(1.0, 0.2, 0.0), n); // Плавный переход

    // Добавляем дым
    float smoke = smoothstep(0.3, 0.8, n) * 0.5;
    color += vec3(0.2, 0.2, 0.2) * smoke;

    // Затухание кверху
    color *= smoothstep(1.0, 0.0, uv.y);

    gl_FragColor = vec4(color, 1.0);
}
