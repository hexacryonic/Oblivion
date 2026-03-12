#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define MY_HIGHP_OR_MEDIUMP highp
#else
	#define MY_HIGHP_OR_MEDIUMP mediump
#endif

// effect adapted from https://www.shadertoy.com/view/3lt3Ws
extern float iTime;
extern float matrix_intensity;
extern float matrix_lines;
extern float block_size;
extern float block_offset;
extern float block_probability;
extern vec2 resolution;
extern vec4 matrix_color;

float random(in float x){
    return fract(sin(x)*43758.5453);
}

float random(in vec2 st){
    return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453);
}

float rchar(in vec2 ipos,in vec2 fpos){
    // num of pixels in individual characters
    float grid=5.;
    // size of black borders to overlay on characters
    vec2 margin=vec2(.2,.05);
    float seed=23.;
    // mask for character borders
    vec2 borders=step(margin,fpos)*step(margin,1.-fpos);
    
    // randomly choose each character pixel to be on or off
    float chardata=random(ipos*seed+floor(fpos*grid));
    return step(.5,chardata)*borders.x*borders.y;
}

vec3 matrix(in vec2 st, float extra_lines){
    float rows=30. + matrix_lines + extra_lines;
    
    // ipos: which character we're displaying
    vec2 ipos=floor(st*rows);
    
    // pick a random brightness
    vec2 ipos2=ipos+vec2(.0,floor((iTime+200.)*10.*random(ipos.x+1.)));
    // mix square and sawtooth waves
    float bright=-(abs((sin(ipos2.y/10.+2.))))*(ipos2.y/10.-floor(ipos2.y/10.))*.7+.2;
    
    // fpos: the position within the character
    vec2 fpos=fract(st*rows);
    vec2 center=(.5-fpos);
    float glow=(1.-dot(center,center)*3.)*2. * matrix_intensity;
    // glow = 1.0;
    
    return vec3(rchar(ipos,fpos)*bright*glow);
}

float highest(vec3 col) {
    return max(max(col.r, col.g), col.b);
}

float highest(vec4 col) {
    return max(max(col.r, col.g), col.b);
}

vec4 maxvec(vec4 a, vec4 b) {
    return vec4(max(a.r, b.r), max(a.g, b.g), max(a.b, b.b), max(a.a, b.a));
}

vec3 maxvec(vec3 a, vec3 b) {
    return vec3(max(a.r, b.r), max(a.g, b.g), max(a.b, b.b));
}

float rtn(float x, float nearest) {
    return floor((x/nearest)+0.5)*nearest;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{

    //before dealing with colours, figure out
    // are we in a chunk that should be offset
    //  im ult spamming here
    // assuming my ult is googling mersenne primes
    //i love normalized positions
    float diff = fract(iTime);
    float rndx = random(rtn(screen_coords.x,block_size+diff));
    float rndy = random(rtn(screen_coords.y,block_size+diff));
    if ((rndx+rndy) <= (block_probability*2)) {
        float dirMod = (rndx + rndy) * 7;

        float x = rtn(cos(iTime+dirMod)*block_offset, 0.5);
        float y = rtn(sin(iTime+dirMod)*block_offset, 0.5);
        vec2 off = vec2(x,y);
        off /= resolution; 
        texture_coords += off;
    }

    vec4 tex = Texel(texture, texture_coords);

    vec3 str = matrix(screen_coords / max(resolution.x, resolution.y), 0)*matrix_color.rgb;
    vec3 str_bg = matrix(screen_coords / max(resolution.x, resolution.y), 25)*(matrix_color.rgb - 0.1);
    str *= 3;
    str_bg *= 2;
    vec4 larger = maxvec(tex, vec4(str,0)+vec4(str_bg,0));

    tex = tex + ((larger - tex)*matrix_intensity);

    tex -= 0.1;
    // tex = normalize(tex);

    return tex*color;
}



#ifdef VERTEX
extern MY_HIGHP_OR_MEDIUMP vec2 mouse_screen_pos;
extern MY_HIGHP_OR_MEDIUMP float hovering;
extern MY_HIGHP_OR_MEDIUMP float screen_scale;

vec4 position( mat4 transform_projection, vec4 vertex_position )
{
    if (hovering <= 0.){
        return transform_projection * vertex_position;
    }
    MY_HIGHP_OR_MEDIUMP float mid_dist = screen_scale*length(vertex_position.xy/screen_scale - 0.5*love_ScreenSize.xy)/length(love_ScreenSize.xy);
    MY_HIGHP_OR_MEDIUMP vec2 mouse_offset = (vertex_position.xy - mouse_screen_pos.xy)/screen_scale;
    MY_HIGHP_OR_MEDIUMP float scale = 0.002*(-0.03 - 0.3*max(0., 0.3-mid_dist))
                *hovering*(length(mouse_offset)*length(mouse_offset))/(2. -mid_dist);

    return transform_projection * vertex_position + vec4(0,0,0,scale);
}
#endif