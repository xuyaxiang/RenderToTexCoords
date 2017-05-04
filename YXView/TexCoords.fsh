precision lowp float;
varying vec4 varyingColor;
varying vec2 texcoord;
uniform sampler2D tex;
void main(){
    gl_FragColor = varyingColor * texture2D(tex,texcoord);
}
