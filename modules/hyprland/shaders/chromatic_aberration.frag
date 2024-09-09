// vim: set ft=glsl:

precision highp float;
varying highp vec2 v_texcoord;
uniform highp sampler2D tex;
uniform float time;

#define MAX_STRENGTH 0.028
#define TIME_IN 0.05
#define TIME_OUT 1.0

void main() {
		vec4 original = texture2D(tex, v_texcoord);

		float strength;
		if (time <= TIME_IN) {
			strength = time * (MAX_STRENGTH / TIME_IN);
		} else if (time <= TIME_IN+TIME_OUT) {
			// at t=0, strength=MAX_STRENGTH. at t=TIME_OUT, strength=0
			// where t is time+TIME_IN
			// thank you desmos :)
			strength = MAX_STRENGTH + 1.0 - exp(pow(TIME_OUT,-1.0)*log(1.0+MAX_STRENGTH)*(time-TIME_IN));
		} else {
			gl_FragColor = vec4(original.r, original.g, original.b, original.a);
			return;
		}

    vec2 center = vec2(0.5, 0.5);
    vec2 offset = (v_texcoord - center) * strength;

    float rSquared = dot(offset, offset);
    float distortion = 1.0 + 1.0 * rSquared;
    vec2 distortedOffset = offset * distortion;

    vec2 redOffset = vec2(distortedOffset.x, distortedOffset.y);
    vec2 blueOffset = vec2(-distortedOffset.x, -distortedOffset.y);

    vec4 redColor = texture2D(tex, v_texcoord + redOffset);
    vec4 blueColor = texture2D(tex, v_texcoord + blueOffset);


		gl_FragColor = vec4(redColor.r, original.g, blueColor.b, original.a);
}
