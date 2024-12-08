precision mediump float;
uniform vec3 u_camera;
uniform vec3 u_lightPosition;
uniform vec3 u_lightColor;
varying vec3 v_vertex;
varying vec2 v_TexCord;
uniform sampler2D u_TextureUnit;
varying vec3 v_normal;
void main() {
    float ambientStrength = 0.125;
    vec3 ambient = ambientStrength * u_lightColor;
    vec3 norm = normalize(v_normal);
    vec3 lightDir = normalize(u_lightPosition - v_vertex);
    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * u_lightColor;
    float specularStrength = 0.5;
    vec3 viewDir = normalize(u_camera - v_vertex);
    vec3 reflectDir = reflect(-lightDir, norm);
    float k_specular=0.5;
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);
    vec3 specular = specularStrength * spec * u_lightColor;
    gl_FragColor = vec4(ambient + diffuse + specular, 1.0) * texture2D(u_TextureUnit, v_TexCord);
}