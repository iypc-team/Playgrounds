/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Shader used for game engine sample
*/

#include <metal_stdlib>
#include <simd/simd.h>
#import "ShaderTypes.h"

using namespace metal;

struct PerFrameUniforms {
    // Per Frame Uniforms
    vector_float3 cameraPos;
    
    // Per Mesh Uniforms
    matrix_float4x4 viewMatrix;
    matrix_float4x4 viewProjectionMatrix;
    
    // Per Light Properties
    vector_float3 directionalLightInvDirection;
    vector_float3 lightCol;
};

struct SkyUniforms {
    matrix_float4x4 modelViewProjectionMatrix;
};

struct MeshUniforms {
    matrix_float4x4 worldMatrix;
    matrix_float3x3 normalMatrix;
};

struct MaterialUniforms {
    float4 baseColor;
    float4 irradiatedColor;
    float roughness;
    float metalness;
};

// -- attribute pipline parameters


// -- function pipeline parameters
constant bool has_base_color_map [[ function_constant(kFunctionConstantBaseColorMapIndex) ]];
constant bool has_normal_map [[ function_constant(kFunctionConstantNormalMapIndex) ]];
constant bool has_metallic_map [[ function_constant(kFunctionConstantMetallicMapIndex) ]];
constant bool has_roughness_map [[ function_constant(kFunctionConstantRoughnessMapIndex) ]];
constant bool has_ambient_occlusion_map [[ function_constant(kFunctionConstantAmbientOcclusionMapIndex) ]];
constant bool has_irradiance_map [[ function_constant(kFunctionConstantIrradianceMapIndex) ]];
constant bool has_any_map = has_base_color_map || has_normal_map || has_metallic_map || has_roughness_map || has_ambient_occlusion_map || has_irradiance_map;

constant float PI = 3.1415926535897932384626433832795;

// Per-vertex inputs fed by vertex buffer laid out with MTLVertexDescriptor in Metal API
struct Vertex {
    float3 position      [[attribute(kVertexAttributePosition)]];
    float3 normal        [[attribute(kVertexAttributeNormal)]];
    float2 texCoord      [[attribute(kVertexAttributeTexcoord)]];
    ushort4 jointIndices [[attribute(kVertexAttributeJointIndices)]];
    float4 jointWeights  [[attribute(kVertexAttributeJointWeights)]];
};

// Vertex shader outputs and per-fragmeht inputs.  Includes clip-space position and vertex outputs
//  interpolated by rasterizer and fed to each fragment genterated by clip-space primitives.
struct ColorInOut {
    float4 position [[position]];
    float2 texCoord [[ function_constant(has_any_map) ]];
    float3 worldPos;
    float3 tangent;
    float3 bitangent;
    float3 normal;
};

struct CubeVertex {
    float3 position[[attribute(kVertexAttributePosition)]];
};

struct CubeVertexOut {
    float4 position [[position]];
    float4 texCoord;
};

struct VertexSkinShaderIn {
    float3 position  [[attribute(kVertexAttributePosition)]];
    float3 normal    [[attribute(kVertexAttributeNormal)]];
    float2 texCoord [[attribute(kVertexAttributeTexcoord)]];
    float4 jointWeights [[attribute(kVertexAttributeJointWeights)]];
    ushort4 jointIndices [[attribute(kVertexAttributeJointIndices)]];
};

struct ColorInOutSkinned {
    float4 position [[position]];
    float3 normal;
};


struct LightingParameters {
    float3  lightDir;
    float3  lightCol;
    float3  viewDir;
    float3  halfVector;
    float3  reflectedVector;
    float3  normal;
    float3  reflectedColor;
    float3  irradiatedColor;
    float3  ambientOcclusion;
    float4  baseColor;
    float   nDoth;
    float   nDotv;
    float   nDotl;
    float   hDotl;
    float   metalness;
    float   roughness;
};

constexpr sampler linearSampler (mip_filter::linear,
                                 mag_filter::linear,
                                 address::repeat,
                                 min_filter::linear);

constexpr sampler cubeSampler (min_filter::nearest,
                               mag_filter::linear);


constexpr sampler nearestSampler(min_filter::linear, mag_filter::linear, mip_filter::none, address::repeat);

constexpr sampler mipSampler(address::clamp_to_edge, min_filter::linear, mag_filter::linear, mip_filter::linear);

LightingParameters calculateParameters(ColorInOut in,
                                       constant PerFrameUniforms & uniforms,
                                       constant MaterialUniforms & materialUniforms,
                                       texture2d<float> baseColorMap [[ function_constant(has_base_color_map) ]],
                                       texture2d<float> normalMap [[ function_constant(has_normal_map) ]],
                                       texture2d<float> metallicMap [[ function_constant(has_metallic_map) ]],
                                       texture2d<float> roughnessMap [[ function_constant(has_roughness_map) ]],
                                       texture2d<float> ambientOcclusionMap [[ function_constant(has_ambient_occlusion_map) ]],
                                       texturecube<float> irradianceMap [[ function_constant(has_irradiance_map) ]]);
inline float Fresnel(float dotProduct);
inline float sqr(float a);
float3 computeSpecular(LightingParameters parameters);
float Geometry(float Ndotv, float alphaG);
float3 computeNormalMap(ColorInOut in, texture2d<float> normalMapTexture);
float3 computeDiffuse(LightingParameters parameters);
float Distribution(float NdotH, float roughness);

inline float Fresnel(float dotProduct) {
    return pow(clamp(1.0 - dotProduct, 0.0, 1.0), 5.0);
}

inline float sqr(float a) {
    return a * a;
}

float Geometry(float Ndotv, float alphaG) {
    float a = alphaG * alphaG;
    float b = Ndotv * Ndotv;
    return (float)(1.0 / (Ndotv + sqrt(a + b - a*b)));
}

float3 computeNormalMap(ColorInOut in, texture2d<float> normalMapTexture) {
    float4 normalMap = float4((float4(normalMapTexture.sample(nearestSampler, float2(in.texCoord)).rgb, 0.0)));
    return float3(normalize(in.normal * normalMap.z + in.tangent * normalMap.x + in.bitangent * normalMap.y));
}

float3 computeDiffuse(LightingParameters parameters) {
    float3 diffuseRawValue = float3(((1.0/PI) * parameters.baseColor));
    return diffuseRawValue * parameters.lightCol * parameters.nDotl * parameters.ambientOcclusion;
}

float Distribution(float NdotH, float roughness) {
    if (roughness >= 1.0)
        return 1.0 / PI;
    
    float roughnessSqr = pow(roughness, 2);
    
    float d = (NdotH * roughnessSqr - NdotH) * NdotH + 1;
    return roughnessSqr / (PI * d * d);
}

float3 computeSpecular(LightingParameters parameters) {
    float specularRoughness = parameters.roughness;
    specularRoughness = max(specularRoughness, 0.01f);
    specularRoughness = pow(specularRoughness, 3.0f);
    
    float Ds = Distribution(parameters.nDoth, specularRoughness);

    float alphaG = sqr(specularRoughness * 0.5 + 0.5);
    float Gs = Geometry(parameters.nDotl, alphaG) * Geometry(parameters.nDotv, alphaG);
    float brdf = Ds * Gs * parameters.nDotl;
    float3 specularOutput = (brdf * parameters.irradiatedColor * parameters.lightCol) * mix(float3(1.0f), parameters.baseColor.xyz, parameters.metalness);
    
    return specularOutput * parameters.ambientOcclusion;
}

LightingParameters calculateParameters(ColorInOut in,
                                       constant PerFrameUniforms & uniforms,
                                       constant MaterialUniforms & materialUniforms,
                                       texture2d<float> baseColorMap [[ function_constant(has_base_color_map) ]],
                                       texture2d<float> normalMap [[ function_constant(has_normal_map) ]],
                                       texture2d<float> metallicMap [[ function_constant(has_metallic_map) ]],
                                       texture2d<float> roughnessMap [[ function_constant(has_roughness_map) ]],
                                       texture2d<float> ambientOcclusionMap [[ function_constant(has_ambient_occlusion_map) ]],
                                       texturecube<float> irradianceMap [[ function_constant(has_irradiance_map) ]]) {
    LightingParameters parameters;
    
    parameters.baseColor = has_base_color_map ? (baseColorMap.sample(linearSampler, in.texCoord.xy)) : materialUniforms.baseColor;
    parameters.normal = has_normal_map ? computeNormalMap(in, normalMap) : float3(in.normal);
    
    parameters.viewDir = normalize(uniforms.cameraPos - float3(in.worldPos));
    parameters.reflectedVector = reflect(-parameters.viewDir, parameters.normal);
    
    parameters.roughness = has_roughness_map ? max(roughnessMap.sample(linearSampler, in.texCoord.xy).x, 0.001f) :
                                               materialUniforms.roughness;
    parameters.metalness = has_metallic_map ? metallicMap.sample(linearSampler, in.texCoord.xy).x :
                                              materialUniforms.metalness;
    
    uint8_t mipLevel = parameters.roughness * irradianceMap.get_num_mip_levels();
    parameters.irradiatedColor = has_irradiance_map ? irradianceMap.sample(mipSampler,
                                                                           parameters.reflectedVector, level(mipLevel)).xyz
                                 : materialUniforms.irradiatedColor.xyz;
    parameters.ambientOcclusion = has_ambient_occlusion_map ? ambientOcclusionMap.sample(linearSampler, in.texCoord.xy).x
                                    : 1.0f;
    
    parameters.lightCol = uniforms.lightCol;
    parameters.lightDir = uniforms.directionalLightInvDirection;
    parameters.nDotl = max(0.001f,saturate(dot(parameters.normal, parameters.lightDir)));
    
    parameters.halfVector = normalize(parameters.lightDir + parameters.viewDir);
    parameters.nDoth = max(0.001f,saturate(dot(parameters.normal, parameters.halfVector)));
    parameters.nDotv = max(0.001f,saturate(dot(parameters.normal, parameters.viewDir)));
    parameters.hDotl = max(0.001f,saturate(dot(parameters.lightDir, parameters.halfVector)));

    return parameters;
}

fragment float4 fragmentShader(ColorInOut in [[stage_in]],
                                 constant PerFrameUniforms & uniforms [[ buffer(kBufferIndexPerFrameUniforms) ]],
                                 constant MaterialUniforms & materialUniforms [[ buffer(kBufferIndexMaterialUniforms) ]],
                                 texture2d<float> baseColorMap [[ texture(kTextureIndexBaseColor), function_constant(has_base_color_map) ]],
                                 texture2d<float> normalMap    [[ texture(kTextureIndexNormal), function_constant(has_normal_map) ]],
                                 texture2d<float> metallicMap  [[ texture(kTextureIndexMetallic), function_constant(has_metallic_map) ]],
                                 texture2d<float> roughnessMap  [[ texture(kTextureIndexRoughness), function_constant(has_roughness_map) ]],
                                 texture2d<float> ambientOcclusionMap  [[ texture(kTextureIndexAmbientOcclusion), function_constant(has_ambient_occlusion_map) ]],
                                 texturecube<float> irradianceMap [[texture(kTextureIndexIrradianceMap), function_constant(has_irradiance_map)]]) {
    float4 final_color = float4(0);
    
    LightingParameters parameters = calculateParameters(in,
                                                        uniforms,
                                                        materialUniforms,
                                                        baseColorMap,
                                                        normalMap,
                                                        metallicMap,
                                                        roughnessMap,
                                                        ambientOcclusionMap,
                                                        irradianceMap);

    if(parameters.baseColor.w <= 0.01f)
        discard_fragment();
    
    const float baseReflectance = 0.4f;
    float3 Cspec0 = float3(mix(baseReflectance, 1.0f, parameters.metalness));
    float3 Fs = float3(mix(float3(Cspec0), float3(1), Fresnel(parameters.hDotl)));
    final_color = float4(Fs * computeSpecular(parameters) +
                         computeDiffuse(parameters) * (1.0f - Fs), 1.0f);
    float4 sky = float4(135.0/255.0, 206.0/255.0, 250/255.0, 1.0);
    float dist = 0.0022*in.position.z/in.position.w;
    float factor = 1.0/exp(dist * dist);
    final_color = mix(sky, final_color, factor);
    return final_color;
}

// Vertex function
vertex ColorInOut vertexShader(Vertex in [[stage_in]],
                               constant PerFrameUniforms & uniforms [[ buffer(kBufferIndexPerFrameUniforms) ]],
                               constant MeshUniforms* meshUniforms[[buffer(kBufferIndexPerMeshUniforms)]],
                               constant int &uStartIdx[[buffer(kBufferIndexMeshUniformIndex)]],
                               ushort iid[[instance_id]]) {
    ColorInOut out;

    // Make in.position a float4 to perform 4x4 matrix math on it.
    // Then calculate the position of our vertex in clip space and output for clipping and rasterization
    float4x4 worldMatrix = meshUniforms[iid + uStartIdx].worldMatrix;
    float3x3 normalMatrix = meshUniforms[iid + uStartIdx].normalMatrix;
    out.position = uniforms.viewProjectionMatrix * worldMatrix * float4(in.position, 1.0);

    // Pass along the texture coordinate of our vertex such which we'll use to sample from texture's
    //   in our fragment function, if we need it
    if (has_any_map) {
        out.texCoord = float2(in.texCoord.x, 1.0f - in.texCoord.y);
    }
    
    out.tangent = 0.0f;
    out.bitangent = 0.0f;
    out.normal    = normalize(normalMatrix * float3(in.normal));
    out.worldPos  = (float3)(worldMatrix * float4(in.position, 1.0)).xyz;
    
    return out;
}

// -- skinned vertex shader
vertex ColorInOut vertex_skinned(VertexSkinShaderIn vertices [[stage_in]],
                                 constant PerFrameUniforms &uniforms [[buffer(kBufferIndexPerFrameUniforms)]],
                                 constant float4x4 *palette [[buffer(kBufferIndexMeshPalettes)]],
                                 constant int &pStartIdx [[buffer(kBufferIndexMeshPaletteIndex)]],
                                 constant int &pSize [[buffer(kBufferIndexMeshPaletteSize)]],
                                 constant MeshUniforms* meshUniforms[[buffer(kBufferIndexPerMeshUniforms)]],
                                 constant int &uStartIdx[[buffer(kBufferIndexMeshUniformIndex)]],
                                 ushort iid[[instance_id]]) {
    float4 modelPosition = float4(vertices.position, 1.0f);
    float4 modelNormal = float4(vertices.normal, 0);
    ushort4 jIdx = vertices.jointIndices + pStartIdx + iid * pSize;
    float4 w = vertices.jointWeights;
    float4x4 worldMatrix = meshUniforms[iid + uStartIdx].worldMatrix;
    float3x3 normalMatrix = meshUniforms[iid + uStartIdx].normalMatrix;
    
    float4 skinnedPosition = w[0] * (palette[jIdx[0]] * modelPosition) +
                             w[1] * (palette[jIdx[1]] * modelPosition) +
                             w[2] * (palette[jIdx[2]] * modelPosition) +
                             w[3] * (palette[jIdx[3]] * modelPosition);
    float4 skinnedNormal = w[0] * (palette[jIdx[0]] * modelNormal) +
                           w[1] * (palette[jIdx[1]] * modelNormal) +
                           w[2] * (palette[jIdx[2]] * modelNormal) +
                           w[3] * (palette[jIdx[3]] * modelNormal);
    
    ColorInOut result;
    result.position = uniforms.viewProjectionMatrix * meshUniforms[iid + uStartIdx].worldMatrix * skinnedPosition;
    result.normal = (meshUniforms[iid + uStartIdx].normalMatrix * skinnedNormal.xyz);
    
    // Pass along the texture coordinate of our vertex such which we'll use to sample from texture's
    //   in our fragment function, if we need it
    if (has_any_map) {
        result.texCoord = float2(vertices.texCoord.x, 1.0f - vertices.texCoord.y);
    }
    
    result.tangent = 0.0f;
    result.bitangent = 0.0f;
    result.normal    = normalize(normalMatrix * float3(skinnedNormal));
    result.worldPos  = (float3)(worldMatrix * skinnedPosition).xyz;
    return result;
}

// -- sky rendering functions
vertex CubeVertexOut vertex_sky(CubeVertex vertices [[stage_in]],
                             constant SkyUniforms &uniforms [[buffer(kBufferIndexSkyUniforms)]]) {
    float4 position = float4(vertices.position, 1.0f);
    
    CubeVertexOut outVert;
    outVert.position = uniforms.modelViewProjectionMatrix * position;
    outVert.texCoord = position;
    return outVert;
}

// -- sky rendering functions
fragment half4 fragment_sky(CubeVertexOut vert            [[stage_in]],
                            texturecube<half> cubeTexture [[texture(kTextureIndexSkyMap)]]) {
    float3 texCoords = float3(vert.texCoord.x, vert.texCoord.y, -vert.texCoord.z);
    return cubeTexture.sample(cubeSampler, texCoords);
}

