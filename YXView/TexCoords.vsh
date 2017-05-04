attribute vec3 position;
attribute vec2 texcoords;
varying vec4 varyingColor;
varying vec2 texcoord;
void main(){
    gl_Position = vec4(position,1);
    varyingColor = vec4(1,1,1,1);
    texcoord = texcoords;
}
