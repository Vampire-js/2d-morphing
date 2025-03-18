precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;


float sphereSDF(vec2 p , vec2 pos, float r){
    return length(p-pos) - r;
}

float smin(float a, float b, float k) {
    float res = exp(-k * a) + exp(-k * b);
    return -log(res) / k;
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + smin(max(d.x,d.y),0.0, 15.);
}

float combineSDF(float d1, float d2){

    return smin(d1, d2, 35.);
}
float lighting(){
    vec3 lightdir = vec3(1.,0.,0.);

    return 2.;
}
void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution;
    vec2 c = uv - 0.5;
    c *= u_resolution.y / u_resolution.x;
    float c1 = sphereSDF(c,vec2(0.,0.) ,.2);
    float c2 = sphereSDF(c,vec2(.4*cos(u_time),.2*sin(u_time)) ,.12 );
    float c3 = sphereSDF(c,vec2(.4*sin(u_time),.3*cos(u_time)) ,.04);
    vec3 color = vec3(smoothstep(0.,0.,combineSDF(combineSDF(c1,c2), sdBox(c, vec2(0.13)))));
    gl_FragColor = vec4(color, 1.);
}