attribute vec3 position;
attribute vec4 color;
varying vec4 varyingColor;
void main(){
    gl_Position = vec4(position,1);
    varyingColor = color;
}
