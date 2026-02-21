//// ParticleShaders.metal
//
//#include <metal_stdlib>
//#include <metal_atomic>
//using namespace metal;
//
//// Particle state (must match Swift GPUParticle layout)
//struct Particle {
//    float2 pos;    // unit-space (0..1)
//    float2 vel;    // unit-space/sec
//    float  size;   // points (pixels)
//    float  hue;
//    float  age;
//    uint   alive;
//};
//
//// Compute parameters (must match Swift ShaderTypes.ComputeParams)
//struct ComputeParams {
//    float dt;
//    float lifespan;
//    float2 center;           // unit-space center (0..1)
//    float emissionDirectionX;
//    float emissionDirectionY;
//    float spread;
//    float speedMin;
//    float speedMax;
//    float sizeMin;
//    float sizeMax;
//    float hueMin;
//    float hueMax;
//    uint  maxParticles;
//    uint  emitCount;
//    uint  seedBase;
//    float2 viewportSize;     // px width/height
//};
//
//// simple xorshift RNG expansion
//inline uint xorshift(uint s) {
//    s ^= s << 13;
//    s ^= s >> 17;
//    s ^= s << 5;
//    return s;
//}
//inline float rand01(thread uint &seed) {
//    seed = xorshift(seed);
//    return float(seed & 0x00FFFFFFu) / float(0x01000000u);
//}
//
//// Emit kernel: each thread initializes one particle; claims a slot via atomic head index.
//kernel void emitKernel(device Particle *particles         [[buffer(0)]],
//                       device atomic_uint *globalHead     [[buffer(1)]],
//                       device uint *seeds                 [[buffer(2)]],
//                       constant ComputeParams &params     [[buffer(3)]],
//                       uint gid                           [[thread_position_in_grid]])
//{
//    if (gid >= params.emitCount) return;
//    
//    // claim a slot (monotonic head, wrap with modulo)
//    uint idx = atomic_fetch_add_explicit(globalHead, 1u, memory_order_relaxed);
//    idx = idx % params.maxParticles;
//    
//    thread uint seed = seeds[gid] + params.seedBase + gid;
//    float r1 = rand01(seed);
//    float r2 = rand01(seed);
//    float r3 = rand01(seed);
//    
//    float baseAngle = atan2(params.emissionDirectionY, params.emissionDirectionX);
//    float halfSpread = params.spread * 0.5f;
//    float angle = baseAngle + (r1 * 2.0f - 1.0f) * halfSpread;
//    
//    float speed = mix(params.speedMin, params.speedMax, r2);
//    float vx = cos(angle) * speed;
//    float vy = sin(angle) * speed;
//    
//    // small radial nozzle jitter
//    float axisX = params.emissionDirectionX;
//    float axisY = params.emissionDirectionY;
//    float axisLen = sqrt(axisX * axisX + axisY * axisY);
//    if (axisLen == 0.0f) { axisX = 0.0f; axisY = -1.0f; axisLen = 1.0f; }
//    axisX /= axisLen; axisY /= axisLen;
//    float perpX = -axisY;
//    float perpY = axisX;
//    
//    float radialR = (r3 * 2.0f - 1.0f) * 0.006f; // matches CPU default radialEmissionRadius
//    float px = params.center.x + perpX * radialR;
//    float py = params.center.y + perpY * radialR;
//    
//    float size = mix(params.sizeMin, params.sizeMax, rand01(seed));
//    float hue  = mix(params.hueMin, params.hueMax, rand01(seed));
//    
//    particles[idx].pos  = float2(px, py);
//    particles[idx].vel  = float2(vx, vy);
//    particles[idx].size = size;
//    particles[idx].hue  = hue;
//    particles[idx].age  = 0.0f;
//    particles[idx].alive = 1u;
//}
//
//// Integrate kernel: update all particles
//kernel void integrateKernel(device Particle *particles     [[buffer(0)]],
//                            constant ComputeParams &params [[buffer(1)]],
//                            uint gid                       [[thread_position_in_grid]])
//{
//    if (gid >= params.maxParticles) return;
//    Particle p = particles[gid];
//    if (p.alive == 0u) return;
//    
//    // integrate position in unit-space
//    p.pos += p.vel * params.dt;
//    p.age += params.dt;
//    
//    // light drag
//    const float drag = pow(0.995f, params.dt * 60.0f);
//    p.vel *= drag;
//    
//    // lifespan
//    if (p.age >= params.lifespan) {
//        p.alive = 0u;
//    }
//    
//    // always write back
//    particles[gid] = p;
//}
//
//// Vertex input: a simple unit quad vertex attribute
//struct VertexIn {
//    float2 position [[attribute(0)]];
//};
//
//// Vertex -> outputs clip-space position, UV, hue
//struct VSOut {
//    float4 position [[position]];
//    float2 uv;
//    float hue;
//    float alive; // float flag for fragment
//};
//
//vertex VSOut particleVertex(VertexIn vin [[stage_in]],
//                            device Particle *particles [[buffer(1)]],
//                            constant ComputeParams &params [[buffer(2)]],
//                            uint vid [[vertex_id]],
//                            uint iid [[instance_id]])
//{
//    VSOut out;
//    Particle p = particles[iid];
//    
//    if (p.alive == 0u) {
//        out.position = float4(-2.0, -2.0, 0.0, 1.0); // off-screen
//        out.uv = float2(0.0);
//        out.hue = p.hue;
//        out.alive = 0.0;
//        return out;
//    }
//    
//    // convert unit-space pos to clip space [-1,1]
//    float2 posClip;
//    posClip.x = p.pos.x * 2.0f - 1.0f;
//    posClip.y = 1.0f - p.pos.y * 2.0f; // flip y
//    
//    // convert size in points -> clip-space extents
//    float2 vp = params.viewportSize; // width, height in pixels
//    float halfX = (p.size * 0.5f) / vp.x * 2.0f;
//    float halfY = (p.size * 0.5f) / vp.y * 2.0f;
//    
//    // vin.position is in [-1..1] quad-space; scale by half extents
//    float2 offset = float2(vin.position.x * halfX, vin.position.y * halfY);
//    float2 vertexPos = posClip + offset;
//    
//    out.position = float4(vertexPos, 0.0f, 1.0f);
//    // uv from vertex coords: map [-1..1] -> [0..1]
//    out.uv = vin.position * 0.5f + 0.5f;
//    out.hue = p.hue;
//    out.alive = 1.0;
//    return out;
//}
//
//fragment float4 particleFragment(VSOut in [[stage_in]],
//                                 texture2d<float> glowTex [[texture(0)]],
//                                 sampler smp [[sampler(0)]])
//{
//    if (in.alive < 0.5f) return float4(0.0);
//    
//    const float4 t = glowTex.sample(smp, in.uv);
//    float alpha = t.a;
//    float core = t.r; // radial brightness (center)
//    float glow = t.a;
//    
//    // simple HSV -> RGB (approx) using in.hue
//    float h = in.hue;
//    float s = 0.95f;
//    float v = 0.95f;
//    float c = v * s;
//    float hp = h * 6.0f;
//    float x = c * (1.0f - fabs(fmod(hp, 2.0f) - 1.0f));
//    float3 rgb;
//    if (0.0f <= hp && hp < 1.0f) rgb = float3(c, x, 0);
//    else if (1.0f <= hp && hp < 2.0f) rgb = float3(x, c, 0);
//    else if (2.0f <= hp && hp < 3.0f) rgb = float3(0, c, x);
//    else if (3.0f <= hp && hp < 4.0f) rgb = float3(0, x, c);
//    else if (4.0f <= hp && hp < 5.0f) rgb = float3(x, 0, c);
//    else rgb = float3(c, 0, x);
//    float m = v - c;
//    rgb += float3(m);
//    
//    // mix white core and colored glow
//    float3 color = mix(rgb * glow, float3(1.0f, 1.0f, 1.0f) * core, 0.7f);
//    return float4(color, alpha);
//}
