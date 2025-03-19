precision mediump float;

uniform float u_time;
uniform vec2 u_resolution;

struct Sphere {
    vec3 pos;
    float r;
};

struct Cube{
    vec3 pos; 
    vec3 b;
};


#define MAX_STEPS 64
#define MAX_DIST 100.
#define SURF_DIST 0.01
#define MAX_SPHERES 2
#define MAX_CUBES 3
#define butterness 7.

Sphere spheres[MAX_SPHERES];
Cube cubes[MAX_CUBES];

void setupSpheres() {
    spheres[0] = Sphere(vec3(.9*cos(u_time), .8*sin(u_time), -0.3), 0.3);
    spheres[1] = Sphere(vec3(.9*sin(u_time), .8*cos(u_time), -0.), 0.3);

    cubes[0] = Cube(vec3(0.0, 0.0, 0.0), vec3(0.7882, 0.4314, 0.4));
}

float smin(float a, float b, float k) {
    float res = exp(-k * a) + exp(-k * b);
    return -log(res) / k;
}

float sphereSDF(vec3 p, Sphere sph) {
    return length(p - sph.pos) - sph.r;
}

float sdBox( vec3 p, Cube c )
{
  vec3 q = abs(p - c.pos) - c.b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sceneSDF(vec3 p) {
    float d = MAX_DIST;
    for(int i = 0; i < MAX_SPHERES; i++) {
        d = smin(d, sphereSDF(p, spheres[i]), butterness);
    }
    for(int i=0; i<MAX_CUBES; i++){
        d = smin(d , sdBox(p, cubes[i]) ,butterness);
    }
    return d;
}

float rayMarch(vec3 ro, vec3 rd) {
    float t = 0.;
    for(int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + t * rd;
        float d = sceneSDF(p);
        if(d < SURF_DIST)
            return t;
        if(t > MAX_DIST)
            break;
        t += d;
    }
    return -1.;
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.001, 0);
    return normalize(vec3(sceneSDF(p + e.xyy) - sceneSDF(p - e.xyy), sceneSDF(p + e.yxy) - sceneSDF(p - e.yxy), sceneSDF(p + e.yyx) - sceneSDF(p - e.yyx)));
}

vec3 lighting(vec3 normals, vec3 lightDir, vec3 color) {
    float ambience = .4;
    return mix(color + vec3(ambience), vec3(0.) + vec3(ambience), max(1. - dot(normals, lightDir), 0.));
}

mat3 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat3(
        oc * axis.x * axis.x + c,       oc * axis.x * axis.y - axis.z * s,  oc * axis.x * axis.z + axis.y * s,
        oc * axis.y * axis.x + axis.z * s,  oc * axis.y * axis.y + c,       oc * axis.y * axis.z - axis.x * s,
        oc * axis.z * axis.x - axis.y * s,  oc * axis.z * axis.y + axis.x * s,  oc * axis.z * axis.z + c
    );
}

void main() {
    setupSpheres();
    float lightIntensity = 1.;
    vec2 uv = (gl_FragCoord.xy / u_resolution) * 2. - 1.;
    uv.x *= u_resolution.x / u_resolution.y;

    vec3 skyColor = mix(vec3(0.7137, 0.698, 0.698), vec3(1.0, 1.0, 1.0), uv.y);
    vec3 ro = vec3(-1., 1.3, -2);
    vec3 rd = rotationMatrix(vec3(0,1.,0), 81.)*normalize(vec3(uv, 0.7));

    float t = rayMarch(ro, rd);
    vec3 color = skyColor;

    if(t > 0.) {
        vec3 p = ro + t * rd;
        vec3 normal = getNormal(p);
        vec3 lightDir = normalize(vec3(0., 1., 00.));
        // float diff = max(lightIntensity * dot(normal, lightDir), 0.0);
        color = lighting(normal, lightDir, vec3(1.0));
    }

    gl_FragColor = vec4(color, 1.0);
}
