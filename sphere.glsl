precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;

struct Sphere {
    vec3 pos;
    float r;
};

#define MAX_SPHERES 3
#define MAX_STEPS 64
#define MAX_DIST 100.
#define SURF_DIST 0.001

Sphere spheres[MAX_SPHERES];

void setupSpheres() {
    spheres[0] = Sphere(vec3(cos(u_time), sin(u_time), 0.5), 0.4);
    spheres[1] = Sphere(vec3(sin(u_time), cos(u_time), 0.5), 0.2);
 }

float smin(float a, float b, float k) {
    float res = exp(-k * a) + exp(-k * b);
    return -log(res) / k;
}

float sphereSDF(vec3 p, Sphere sph) {
    return length(p - sph.pos) - sph.r;
}

float sceneSDF(vec3 p) {
    float d = MAX_DIST;
    for(int i = 0; i < MAX_SPHERES; i++) {
        d = smin(d, sphereSDF(p, spheres[i]), 15.);
    }
    return d;
}

float rayMarch(vec3 ro, vec3 rd) {
    float t = 0.;
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + t * rd;
        float d = sceneSDF(p);
        if(d < SURF_DIST) return t;
        if(t > MAX_DIST) break;
        t += d;
    }
    return -1.; 
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.001, 0);
    return normalize(vec3(
        sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy),
        sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy),
        sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)
    ));
}

vec3 lighting(vec3 normals , vec3 lightDir, vec3 color){
    float ambience = .3;
return mix(color + , vec3(0.) + vec3(ambience) , max(1.-dot(normals, lightDir), 0.));
}

void main() {
    setupSpheres();
    float lightIntensity = 1.;
    vec2 uv = (gl_FragCoord.xy / u_resolution) * 2. - 1.;
    uv.x *= u_resolution.x / u_resolution.y;

    vec3 skyColor = mix(vec3(0.4392, 0.5765, 0.698),vec3(0.7922, 0.8039, 0.6784),uv.y);
    vec3 ro = vec3(0, 0, -2);
    vec3 rd = normalize(vec3(uv, 0.7));

    float t = rayMarch(ro, rd);
    vec3 color = skyColor;

    if (t > 0.) {
        vec3 p = ro + t * rd;
        vec3 normal = getNormal(p);
        vec3 lightDir = normalize(vec3(0., 1., 00.));
        float diff = max(lightIntensity*dot(normal, lightDir), 0.0);
        color = lighting(normal, lightDir, vec3(0.28, 0.87, 1.0));
    }

    gl_FragColor = vec4(color, 1.0);
}
