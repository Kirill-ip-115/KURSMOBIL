precision highp float;
varying float v_time;
float sdfCircle(vec2 p, float r) {
    return length(p) - r;
}
vec2 hash(vec2 x) {
    const vec2 k = vec2(0.3183099, 0.3678794);
    x = x * k + k.yx;
    return -1.0 + 2.0 * fract( 16.0 * k * fract(x.x * x.y * (x.x + x.y)));
}
vec3 calcNoise(vec2 p) {
    vec2 i = floor( p );
    vec2 f = fract( p );
    vec2 u = f*f*(3.0-2.0*f);
    vec2 du = 6.0*f*(1.0-f);
    vec2 ga = hash( i + vec2(0.0,0.0) );
    vec2 gb = hash( i + vec2(1.0,0.0) );
    vec2 gc = hash( i + vec2(0.0,1.0) );
    vec2 gd = hash( i + vec2(1.0,1.0) );
    float va = dot( ga, f - vec2(0.0,0.0) );
    float vb = dot( gb, f - vec2(1.0,0.0) );
    float vc = dot( gc, f - vec2(0.0,1.0) );
    float vd = dot( gd, f - vec2(1.0,1.0) );
    return vec3( va + u.x*(vb-va) + u.y*(vc-va) + u.x*u.y*(va-vb-vc+vd),
    ga + u.x*(gb-ga) + u.y*(gc-ga) + u.x*u.y*(ga-gb-gc+gd) +
    du * (u.yx*(va-vb-vc+vd) + vec2(vb,vc) - va));
}
void main() {
    float octaves = 8.0;
    float noiseAmount = calcNoise(vec2(octaves * gl_PointCoord.x, octaves *
    gl_PointCoord.y + v_time * 0.1)).x;
    float yGradient = clamp(0.7 - gl_PointCoord.y, 0.0, 1.0) * 0.6;
    vec2 sdfNoise = vec2(noiseAmount * 0.1, noiseAmount * 2.5 * yGradient);
    vec2 p1 = (gl_PointCoord - vec2(0.5, 0.7)) + sdfNoise;
    vec2 p2 = (gl_PointCoord - vec2(0.5, 0.775)) + sdfNoise;
    vec2 p3 = (gl_PointCoord - vec2(0.5, 0.85)) + sdfNoise;
    float amountOuter = step(sdfCircle(p1, 0.25), 0.0);
    float amountInner = step(sdfCircle(p2, 0.175), 0.0);
    float amountCenter = step(sdfCircle(p3, 0.1), 0.0);
    vec3 outer = vec3(1, 0.5, 0) * amountOuter;
    vec3 inner = vec3(1, 1, 0) * amountInner;
    vec3 center = vec3(1, 1, 1) * amountCenter;
    vec4 color = vec4(outer + inner + center, amountOuter);
    if (color.r <= 0.0) {
        gl_FragColor = vec4(0, 0, 0, 0);
    return;
    }
    gl_FragColor = color;
}