import net.mikekohn.java_grinder.Lionsys;

public class pacman
{
//<canvas width=224 height=248 id=cnv style='background-color:#000'></canvas>
//<script>
static int paused=0;
static int key=0;
//c=document.getElementById('cnv')
////ctx=c.getContext('2d');
//c.width*=2;c.height*=2;ctx.scale(2,2)
//ctx.mozImageSmoothingEnabled=false;
//ctx.webkitImageSmoothingEnabled=false;
//ctx.imageSmoothingEnabled=false;

//0 = empty
//1 = wall
//2 = food
//3 = energizer
static int RAND=17;
//static float ff = 1.0f;

/* static float[] cost = { 1f, 0.9238f, 0.7071f, 0.3827f, 0f, -0.3827f, -0.7071f, -0.9238f, -1f, -0.9238f, -0.7071f, -0.3827f,
						 0, 0.3827f, 0.7071f, 0.9238f, 1f};
 static float[] sint = { 0f, 0.3827f, 0.7071f, 0.9238f, 1f, 0.9238f, 0.7071f, 0.3827f, 0f, -0.3827f, -0.7071f, -0.9238f,
						 -1f, -0.9238f, -0.7071f, -0.3827f, 0f }; */

static int map[] = new int[2060];
/* { 
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
1,2,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,2,1,
1,2,1,1,1,1,2,1,1,1,1,1,2,1,1,2,1,1,1,1,1,2,1,1,1,1,2,1,
1,3,1,1,1,1,2,1,1,1,1,1,2,1,1,2,1,1,1,1,1,2,1,1,1,1,3,1,
1,2,1,1,1,1,2,1,1,1,1,1,2,1,1,2,1,1,1,1,1,2,1,1,1,1,2,1,
1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,
1,2,1,1,1,1,2,1,1,2,1,1,1,1,1,1,1,1,2,1,1,2,1,1,1,1,2,1,
1,2,1,1,1,1,2,1,1,2,1,1,1,1,1,1,1,1,2,1,1,2,1,1,1,1,2,1,
1,2,2,2,2,2,2,1,1,2,2,2,2,1,1,2,2,2,2,1,1,2,2,2,2,2,2,1,
1,1,1,1,1,1,2,1,1,1,1,1,0,1,1,0,1,1,1,1,1,2,1,1,1,1,1,1,
1,1,1,1,1,1,2,1,1,1,1,1,0,1,1,0,1,1,1,1,1,2,1,1,1,1,1,1,
0,0,0,0,1,1,2,1,1,0,0,0,0,0,0,0,0,0,0,1,1,2,1,1,0,0,0,0,
1,1,1,1,1,1,2,1,1,0,1,1,1,1,1,1,1,1,0,1,1,2,1,1,1,1,1,1,
1,1,1,1,1,1,2,1,1,0,1,1,0,0,0,0,1,1,0,1,1,2,1,1,1,1,1,1,
0,0,0,0,0,0,2,0,0,0,1,1,0,0,0,0,1,1,0,0,0,2,0,0,0,0,0,0,
1,1,1,1,1,1,2,1,1,0,1,1,1,1,1,1,1,1,0,1,1,2,1,1,1,1,1,1,
1,0,0,0,0,1,2,1,1,0,1,1,1,1,1,1,1,1,0,1,1,2,1,0,0,0,0,1,
0,0,0,0,0,1,2,1,1,0,0,0,0,0,0,0,0,0,0,1,1,2,1,0,0,0,0,0,
0,0,0,0,0,1,2,1,1,0,1,1,1,1,1,1,1,1,0,1,1,2,1,0,0,0,0,0,
1,1,1,1,1,1,2,1,1,0,1,1,1,1,1,1,1,1,0,1,1,2,1,1,1,1,1,1,
1,2,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,2,1,
1,2,1,1,1,1,2,1,1,1,1,1,2,1,1,2,1,1,1,1,1,2,1,1,1,1,2,1,
1,2,1,1,1,1,2,1,1,1,1,1,2,1,1,2,1,1,1,1,1,2,1,1,1,1,2,1,
1,3,2,2,1,1,2,2,2,2,2,2,2,0,0,2,2,2,2,2,2,2,1,1,2,2,3,1,
1,1,1,2,1,1,2,1,1,2,1,1,1,1,1,1,1,1,2,1,1,2,1,1,2,1,1,1,
1,1,1,2,1,1,2,1,1,2,1,1,1,1,1,1,1,1,2,1,1,2,1,1,2,1,1,1,
1,2,2,2,2,2,2,1,1,2,2,2,2,1,1,2,2,2,2,1,1,2,2,2,2,2,2,1,
1,2,1,1,1,1,1,1,1,1,1,1,2,1,1,2,1,1,1,1,1,1,1,1,1,1,2,1,
1,2,1,1,1,1,1,1,1,1,1,1,2,1,1,2,1,1,1,1,1,1,1,1,1,1,2,1,
1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
}; */

/////////////


static byte[] pacmand =  {
//pos0
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,

(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,

(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xF6,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0x6F,(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,

(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0x6F,(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xF6,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,

(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x66,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x66,(byte) 0x6F,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF


};

static byte[] gostdt =  {
//pos0
 (byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
 (byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
 (byte) 0xFF,(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0xFF,(byte) 0xFF,
 (byte) 0xFF,(byte) 0xF4,(byte) 0x47,(byte) 0x74,(byte) 0x44,(byte) 0x77,(byte) 0xFF,(byte) 0xFF,
 (byte) 0xFF,(byte) 0xF4,(byte) 0x77,(byte) 0x77,(byte) 0x47,(byte) 0x77,(byte) 0x7F,(byte) 0xFF,
 (byte) 0xFF,(byte) 0xF4,(byte) 0x77,(byte) 0x99,(byte) 0x47,(byte) 0x79,(byte) 0x9F,(byte) 0xFF,
 (byte) 0xFF,(byte) 0xF4,(byte) 0x77,(byte) 0x99,(byte) 0x47,(byte) 0x79,(byte) 0x9F,(byte) 0xFF,
 (byte) 0xFF,(byte) 0x44,(byte) 0x47,(byte) 0x74,(byte) 0x44,(byte) 0x47,(byte) 0x74,(byte) 0xFF,
 (byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0xFF,
 (byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0xFF,
 (byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0xFF,
 (byte) 0xFF,(byte) 0x4F,(byte) 0x44,(byte) 0x4F,(byte) 0xF4,(byte) 0x4F,(byte) 0xF4,(byte) 0xFF,
 (byte) 0xFF,(byte) 0x4F,(byte) 0xF4,(byte) 0x4F,(byte) 0xF4,(byte) 0x4F,(byte) 0xF4,(byte) 0xFF,
 (byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
 (byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
 (byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
// 
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF4,(byte) 0x47,(byte) 0x74,(byte) 0x44,(byte) 0x77,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF4,(byte) 0x77,(byte) 0x77,(byte) 0x47,(byte) 0x77,(byte) 0x7F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF4,(byte) 0x77,(byte) 0x99,(byte) 0x47,(byte) 0x79,(byte) 0x9F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF4,(byte) 0x77,(byte) 0x99,(byte) 0x47,(byte) 0x79,(byte) 0x9F,(byte) 0xFF,
(byte) 0xFF,(byte) 0x44,(byte) 0x47,(byte) 0x74,(byte) 0x44,(byte) 0x47,(byte) 0x74,(byte) 0xFF,
(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0xFF,
(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0xFF,
(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0xFF,
(byte) 0xFF,(byte) 0x4F,(byte) 0xF4,(byte) 0x44,(byte) 0xFF,(byte) 0x44,(byte) 0xF4,(byte) 0xFF,
(byte) 0xFF,(byte) 0x4F,(byte) 0xFF,(byte) 0x4F,(byte) 0xFF,(byte) 0x4F,(byte) 0xF4,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
//;sprite 2
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0x77,(byte) 0x44,(byte) 0x47,(byte) 0x74,(byte) 0x4F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF7,(byte) 0x77,(byte) 0x74,(byte) 0x77,(byte) 0x77,(byte) 0x4F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF9,(byte) 0x97,(byte) 0x74,(byte) 0x99,(byte) 0x77,(byte) 0x4F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF9,(byte) 0x97,(byte) 0x74,(byte) 0x99,(byte) 0x77,(byte) 0x4F,(byte) 0xFF,
(byte) 0xFF,(byte) 0x47,(byte) 0x74,(byte) 0x44,(byte) 0x47,(byte) 0x74,(byte) 0x44,(byte) 0xFF,
(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0xFF,
(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0xFF,
(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0xFF,
(byte) 0xFF,(byte) 0x4F,(byte) 0xF4,(byte) 0x4F,(byte) 0xF4,(byte) 0x44,(byte) 0xF4,(byte) 0xFF,
(byte) 0xFF,(byte) 0x4F,(byte) 0xF4,(byte) 0x4F,(byte) 0xF4,(byte) 0x4F,(byte) 0xF4,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
//;sprite 3
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0x77,(byte) 0x44,(byte) 0x47,(byte) 0x74,(byte) 0x4F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF7,(byte) 0x77,(byte) 0x74,(byte) 0x77,(byte) 0x77,(byte) 0x4F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF9,(byte) 0x97,(byte) 0x74,(byte) 0x99,(byte) 0x77,(byte) 0x4F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF9,(byte) 0x97,(byte) 0x74,(byte) 0x99,(byte) 0x77,(byte) 0x4F,(byte) 0xFF,
(byte) 0xFF,(byte) 0x47,(byte) 0x74,(byte) 0x44,(byte) 0x47,(byte) 0x74,(byte) 0x44,(byte) 0xFF,
(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0xFF,
(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0xFF,
(byte) 0xFF,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0x44,(byte) 0xFF,
(byte) 0xFF,(byte) 0x4F,(byte) 0x44,(byte) 0xFF,(byte) 0x44,(byte) 0x4F,(byte) 0xF4,(byte) 0xFF,
(byte) 0xFF,(byte) 0x4F,(byte) 0xF4,(byte) 0xFF,(byte) 0xF4,(byte) 0xFF,(byte) 0xF4,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,

(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x99,(byte) 0x99,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0x99,(byte) 0x99,(byte) 0x99,(byte) 0x99,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF9,(byte) 0x97,(byte) 0x79,(byte) 0x99,(byte) 0x77,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF9,(byte) 0x77,(byte) 0x77,(byte) 0x97,(byte) 0x77,(byte) 0x7F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF9,(byte) 0x79,(byte) 0x97,(byte) 0x97,(byte) 0x99,(byte) 0x7F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF9,(byte) 0x77,(byte) 0x77,(byte) 0x97,(byte) 0x77,(byte) 0x7F,(byte) 0xFF,
(byte) 0xFF,(byte) 0x99,(byte) 0x99,(byte) 0x99,(byte) 0x99,(byte) 0x99,(byte) 0x99,(byte) 0xFF,
(byte) 0xFF,(byte) 0x97,(byte) 0x79,(byte) 0x97,(byte) 0x79,(byte) 0x97,(byte) 0x79,(byte) 0xFF,
(byte) 0xFF,(byte) 0x79,(byte) 0x97,(byte) 0x79,(byte) 0x97,(byte) 0x79,(byte) 0x97,(byte) 0xFF,
(byte) 0xFF,(byte) 0x99,(byte) 0x99,(byte) 0x99,(byte) 0x99,(byte) 0x99,(byte) 0x99,(byte) 0xFF,
(byte) 0xFF,(byte) 0x99,(byte) 0xF9,(byte) 0x9F,(byte) 0xF9,(byte) 0x9F,(byte) 0x99,(byte) 0xFF,
(byte) 0xFF,(byte) 0x9F,(byte) 0xF9,(byte) 0x9F,(byte) 0xF9,(byte) 0x9F,(byte) 0xF9,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,

(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0x77,(byte) 0xFF,(byte) 0xFF,(byte) 0x77,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF7,(byte) 0x77,(byte) 0x7F,(byte) 0xF7,(byte) 0x77,(byte) 0x7F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF7,(byte) 0x99,(byte) 0x7F,(byte) 0xF7,(byte) 0x99,(byte) 0x7F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF7,(byte) 0x77,(byte) 0x7F,(byte) 0xF7,(byte) 0x77,(byte) 0x7F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0x77,(byte) 0xFF,(byte) 0xFF,(byte) 0x77,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF
};

static byte[] fruit =  {
//;sprite 8
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x44,(byte) 0x4F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xF4,(byte) 0x44,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xF4,(byte) 0x4F,(byte) 0x4F,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x4F,(byte) 0xFF,(byte) 0x4F,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xF4,(byte) 0xFF,(byte) 0xFF,(byte) 0x4F,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFC,(byte) 0x4C,(byte) 0xCF,(byte) 0xF4,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xCC,(byte) 0xCC,(byte) 0xFF,(byte) 0xC4,(byte) 0xCC,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xC7,(byte) 0xCC,(byte) 0xFC,(byte) 0xCC,(byte) 0xCC,(byte) 0xCF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xCC,(byte) 0x7C,(byte) 0xFC,(byte) 0x7C,(byte) 0xCC,(byte) 0xCF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFC,(byte) 0xCC,(byte) 0xFC,(byte) 0xC7,(byte) 0xCC,(byte) 0xCF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xCC,(byte) 0xCC,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
//;sprite 9
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xF7,(byte) 0x7F,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFA,(byte) 0xA7,(byte) 0x7A,(byte) 0xAF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xCC,(byte) 0xAA,(byte) 0xAA,(byte) 0xCC,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFC,(byte) 0x7C,(byte) 0xCC,(byte) 0xCC,(byte) 0x7C,(byte) 0xCF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFC,(byte) 0xCC,(byte) 0x7C,(byte) 0x7C,(byte) 0xCC,(byte) 0xCF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFC,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0x7C,(byte) 0xCF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xC7,(byte) 0xC7,(byte) 0xCC,(byte) 0xCC,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFC,(byte) 0x7C,(byte) 0xC7,(byte) 0xCF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xCC,(byte) 0xCC,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFC,(byte) 0xCF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
//;sprite 10
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xF4,(byte) 0xF2,(byte) 0x2F,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xF4,(byte) 0x22,(byte) 0x22,(byte) 0x22,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x44,(byte) 0x4F,(byte) 0x22,(byte) 0x2F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFA,(byte) 0x64,(byte) 0x6A,(byte) 0x6F,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xA6,(byte) 0xA6,(byte) 0xA6,(byte) 0xA6,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFA,(byte) 0x6A,(byte) 0x6A,(byte) 0x6A,(byte) 0x6A,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF6,(byte) 0xA6,(byte) 0xA6,(byte) 0xA6,(byte) 0xA6,(byte) 0xAF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFA,(byte) 0x6A,(byte) 0x6A,(byte) 0x6A,(byte) 0x6A,(byte) 0x6F,(byte) 0xFF,
(byte) 0xFF,(byte) 0xF8,(byte) 0xA6,(byte) 0xA6,(byte) 0xA6,(byte) 0xA6,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFA,(byte) 0x6A,(byte) 0x6A,(byte) 0x6F,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x86,(byte) 0xA8,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
//;sprite 11
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0x4F,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xCC,(byte) 0xF4,(byte) 0xFC,(byte) 0xCC,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFC,(byte) 0xCC,(byte) 0xC4,(byte) 0xCC,(byte) 0xCC,(byte) 0xCF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xFF,
(byte) 0xFF,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xFF,
(byte) 0xFF,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xFF,
(byte) 0xFF,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xC7,(byte) 0xCC,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFC,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xC7,(byte) 0xCC,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFC,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0x7C,(byte) 0xCF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xCC,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFC,(byte) 0xCF,(byte) 0xCC,(byte) 0xCF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,
(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF,(byte) 0xFF
};

final static int boundary=5;
final static int cornering=2;


final static int GHOST_X=0;
final static int GHOST_Y=1;
final static int GHOST_DIR=2;
final static int GHOST_MODE=3;
final static int GHOST_SCARED=4;
final static int GHOST_SPEED=5;

final static int NORMAL=0;
final static int DEAD   =1;
final static int RELEASED=2;
final static int TRAPPED =3;  // or greater


final static int RIGHT =0;
final static int LEFT  =1;
final static int UP    =2;
final static int DOWN  =3;


static int MODELENGTH=1000;
static int ENERGYLENGTH=500;
/////////////
static int doubleSpeed=1, speed=9;
static int PacX = 112;
static int PacY = 190;
static int PacDir=UP;
static int PacFrame=0;
static  int FoodEaten=0;
static  int PacDead=0;
static int PacEatGhost=0;
static int PacGhostCounter=0;
static int GlobalMode = 1; // 1=chase, 0=scatter
static int cherry=0;

static int EnergizerTimer=0;
static int ModeTimer=1;
static int temp;
static long score,hiscore,lastscore;
static int GhostFrame=0;
final static int OFFSET_X=66;
final static int OFFSET_Y=-4;


static int ghostd[]={112,88,0,0,0,0,
					112,96,0,15,0,0,
					112,96,0,45,0,0,
					112,96,0,65,0,0};
					
static int orcolor[]={0,0x11,0x22,0x99};

final static int blinky=0;
final static int pinky=1;
final static int inky=2;
final static int clyde=3;

	static void set_sprite( int s, int buf, int en, int x, int y)
	{
		int bank=s/15; int ss=s%15;
		Lionsys.out(16384+bank*4096+256*buf+ss*8,x); //Lionsys.outb(16384+bank*4096+1+256*buf+s*8,x%256);
		Lionsys.out(16384+bank*4096+2+256*buf+ss*8,y); //Lionsys.outb(16384+bank*4096+3+256*buf+s*8,y);
		Lionsys.out(16384+bank*4096+6+256*buf+ss*8,en); //Lionsys.outb(16384+bank*4096+7+256*buf+s*8,en);
	}
	
	static void kill_sprite( int s)
	{
		int bank=s/15; int ss=s%15;
		Lionsys.out(16384+bank*4096+6+256+ss*8,0);
		Lionsys.out(16384+bank*4096+6+ss*8,0);
	}
	
	static void set_sprite_data( int s, int buf, byte d[], int frame, int colOR)
	{
		int bank=s/15; int ss=s%15; int foff;
		foff=frame*128;
		for (int j=0; j<128; j++)  {
				Lionsys.outb(16896+bank*4096+1792*buf+ss*128+j,d[j+foff] | (byte) colOR);
		}
	}
	
    static void blit(int x, int y, byte d[], int frame)
	{
		int adr=0,i,j,foff,dat;
		foff=frame*128;
		for (j=0; j<16; j++) {
			adr=32768+(y+j)*160;
			for (i=0; i<8; i++) { 
				dat=d[foff+(j<<3)+i];
				if ((dat & 0xFF)!=0xFF) Lionsys.outb(adr+x+i,dat);
				}
		}
	}
	
	    static void dot(int x, int y, int col, int big)
	{
		int adr=0,j,dat;
		for (j=0; j<2+big*2+big; j++) {
			adr=32768+(y+j)*160;
			Lionsys.outb(adr+x,col);
			if (big!=0) Lionsys.outb(adr+x+1,col);
		}
	}
		
	

static long tempx,tempy;
//static int tunnel=0;

static void draw(int pkey)
{
  
  if (PacDead>0) {
    //ctx.drawImage(img,0,0);
    //Lionsys.print_num(3,1,PacDead);
    if (PacDead>15){
		Lionsys.out(11,0);
		Lionsys.sound(0,PacDead*5,1);
    } else {
      PacX = 112;
      PacY = 190;
      PacDir=UP;
      cherry=0;
    }
    PacDead--;
    //requestAnimationFrame(draw);
    return;
  }
  if (PacEatGhost>0) {
    //ctx.drawImage(img,229-16+PacGhostCounter*16,133,16,7,PacX-8,PacY-4,16,7);
    PacEatGhost--;
	Lionsys.out(11,0);
	Lionsys.sound(0,10000/(1+PacEatGhost)*2,2);
    //requestAnimationFrame(draw);
	//Lionsys.print_num(3,1,PacEatGhost);
    return;
  }

  temp=map[(PacY>>3)*28+(PacX>>3)];
  if (temp==2) {  // Eat Food
    map[(PacY>>3)*28+(PacX>>3)]=0;
    lastscore=score; score=score+10L; 
	if (score>=10000L && lastscore<10000L) {lives++; Lionsys.print_num(4,7,lives); }
	Lionsys.print_long(2,2,score);
    eatFood(2);
  } else if (temp==3) {  // Eat Energizer
      map[(PacY>>3)*28+(PacX>>3)]=0;
	  lastscore=score;
      score=score+50; if (score>=10000L && lastscore<10000L) {lives++; Lionsys.print_num(4,7,lives); }
      Lionsys.print_long(2,2,score);
      frighten(blinky);
      frighten(  inky);
      frighten( pinky);
      frighten( clyde);
     
      reverseDirection(blinky);
      reverseDirection(  inky);
      reverseDirection( pinky);
      reverseDirection( clyde);
      
    EnergizerTimer=ENERGYLENGTH;
    eatFood(3);
  } else if ((cherry==1)&&PacX==112&&PacY==140){
    lastscore=score; score=score + (level+1)*100;
	if (score>=10000L && lastscore<10000L) { lives++; Lionsys.print_num(4,7,lives); }
	Lionsys.print_long(2,2,score);
    cherry=0;
	 set_sprite( 6, 0, 0, 0, 0);
  } else 
	{  //Do not move while eatingx<44 || x>180

	if ((PacY<126) && (PacY>105) && (PacX<44 ||PacX>180)) tunnel=1; else tunnel=0;
    temp=(PacY+4) % 8;
	int joy1=Lionsys.joy1();
    if (((pkey=='D' || pkey=='d' || (joy1 & 16)!=0) && (temp<cornering||temp>(8-cornering))) || PacDir==RIGHT) {
      if (map[(PacY>>3)*28+((PacX+boundary)>>3)]!=1) {
      PacX++;
      PacDir=RIGHT;
      PacFrame++;
      snapY(RIGHT);
	  set_sprite_data( 0, 0, pacmand, 0, 0);
	  //Lionsys.print_num(7,1,pkey);
      }
    } 
    if (((pkey=='S' || pkey=='s' || (joy1 & 8) !=0) && (temp<cornering||temp>(8-cornering))) || PacDir==LEFT) {
      if (map[(PacY>>3)*28+((PacX-boundary)>>3)]!=1) {
      PacX--;
      PacDir=LEFT;
      PacFrame++;
      snapY(LEFT);
	  set_sprite_data( 0, 0, pacmand, 1, 0);
	  //Lionsys.print_num(7,1,pkey);
      }
    } 
    temp=(PacX+4)%8;
    if ((((pkey=='X' || pkey=='x' ||  (joy1 & 2)!=0) && (temp<cornering||temp>(8-cornering))) && (tunnel==0)) || PacDir==DOWN) {
      if (map[((PacY+boundary)>>3)*28+(PacX>>3)]!=1) {
      PacY++;
      PacDir=3;
      PacFrame++;
	  set_sprite_data( 0, 0, pacmand, 3, 0);
	  //Lionsys.print_num(7,1,pkey);
      snapX(3);
      }
    } 
    if ((((pkey=='E' || pkey=='e' || (joy1 & 4)!=0) && (temp<cornering||temp>(8-cornering))) && (tunnel==0)) || PacDir==UP) {
      if (map[((PacY-boundary)>>3)*28+(PacX>>3)]!=1) {
      PacY--;
      PacDir=2;
      PacFrame++;
	  set_sprite_data( 0, 0, pacmand, 2, 0);
	  //Lionsys.print_num(7,1,pkey);
      snapX(2);
      }
    }

    //PacX=wrap(PacX);
	if (PacX<8) {PacX=218;} else  if (PacX>218) {PacX=8;}
  }
  
  
  if (EnergizerTimer==0) {
    PacGhostCounter=0;
    if (ModeTimer==0) {
      if (GlobalMode==1) {GlobalMode=0; ModeTimer=MODELENGTH>>2; }
	  else {GlobalMode=1; ModeTimer=MODELENGTH; }
	  
      reverseDirection(blinky);
      reverseDirection(inky);
      reverseDirection(pinky);
      reverseDirection(clyde);
    }
  } else {
    EnergizerTimer--;
  }
  
  processGhost(blinky);
  processGhost(inky);
  processGhost(pinky);
  processGhost(clyde);


  if (cherry==0) { set_sprite( 6, 0, 0, 0, 0);}
  
  drawGhost(blinky,0);
  drawGhost(pinky,1);
  drawGhost(inky,2);
  drawGhost(clyde,3);
  
  //GhostFrame=(GhostFrame+1)%(8*2);
  PacFrame=PacFrame%(3*3);

  tempx=(200L*(long)PacX)/248L;  tempy=(200L*(long)PacY)/248L;
  set_sprite(0,0,1,OFFSET_X-3+(int) (tempx),OFFSET_Y-2+(int)(tempy));
}



static void drawGhost(int ghost, int offset){
  /* x=230+ghostd[ghost*6 + GHOST_DIR]*32+(int) ((GhostFrame/8)*16);
     y=65+offset*16;*/
  int et=0;
  if (EnergizerTimer<128 && (EnergizerTimer%32)<16) et=0x22;
  if (ghostd[ghost*6 + GHOST_SCARED]==1) {
		set_sprite_data( 1+ghost, 0, gostdt, 4, 0);
		set_sprite_data( 1+ghost, 1, gostdt, 4, et);
		} 
  if (ghostd[ghost*6 + GHOST_MODE]==DEAD) {
		set_sprite_data( 1+ghost, 0, gostdt, 5, 0);
		set_sprite_data( 1+ghost, 1, gostdt, 5, 0);
		} 
  tempx=((200L*(long) ghostd[ghost*6+GHOST_X])/248L); 
  tempy=((200L*(long)ghostd[ghost*6+GHOST_Y])/248L);
  set_sprite(1+ghost,0,1,OFFSET_X+(int) tempx,OFFSET_Y+(int) tempy);
}

static void snapY(int n){
  if (map[((PacY+3)>>3)*28+(PacX>>3)]==1) {
    PacY--;
  }
  if (map[((PacY-4)>>3)*28+(PacX>>3)]==1) {
    PacY++;
  }
}
static void snapX(int n){
  if (map[(PacY>>3)*28+((PacX+3)>>3)]==1) {
    PacX--;
  }
  if (map[(PacY>>3)*28+((PacX-4)>>3)]==1) {
    PacX++;
  }
}


static void eatFood(int dummy){
  FoodEaten++;
  Lionsys.out(31,14); Lionsys.out(32,0); Lionsys.out(11,2);
  Lionsys.sound(0,110,2); 
  Lionsys.sound(1,440,1);
  //Lionsys.sound(2,360,1);
  // at 70 and at 170, make cherry appear
  if (FoodEaten==70 || FoodEaten==170) {cherry=1;  set_sprite( 6, 0, 1, 152, 106);}
  //if (FoodEaten==30) ghostd[inky*6 + GHOST_MODE]=RELEASED;
  //if (FoodEaten==82) ghostd[clyde*6 + GHOST_MODE]=RELEASED;
  tempx=(200L*(long) (PacX>>3)*4L)/248L;  
  tempy=(200L*(long) (PacY>>3)*8L)/248L;
  dot(OFFSET_X/2+3+(int)tempx,OFFSET_Y+7+(int)tempy,0x00,1);
  //if (FoodEaten==244) alert("over");
}

/* static int wrap(int x){
  if (x<8) {x=218;} else  if (x>218) {x=8;}
  return x;
} */
/* static int  xDir(int a){
  if (a==RIGHT) return 1;
  if (a==LEFT) return -1;
  return 0;
}
static int  yDir(int a){
  if (a==DOWN) return 1;
  if (a==UP) return -1;
  return 0;
} */
/* static int  inTunnel(int x,int y){
if ((y<126) && (y>105) && (x<44 || x>180)) return 1; 
else return 0;
} */

static void  reverseDirection(int ghost){
  if (ghostd[ghost*6 + GHOST_DIR]==RIGHT) ghostd[ghost*6 + GHOST_DIR]=LEFT;
  else if (ghostd[ghost*6 + GHOST_DIR]==LEFT) ghostd[ghost*6 + GHOST_DIR]=RIGHT;
  else if (ghostd[ghost*6 + GHOST_DIR]==UP) ghostd[ghost*6 + GHOST_DIR]=DOWN;
  else ghostd[ghost*6 + GHOST_DIR]=UP;
}

static void  frighten(int ghost){
  ghostd[ghost*6 + GHOST_SCARED]=1;
}

static void  resetGhost(int ghost,int time){
  if(ghostd[ghost*6 + GHOST_MODE]<TRAPPED) {
     ghostd[ghost*6 + GHOST_MODE]=4+time;
     ghostd[ghost*6 + GHOST_X]=112;
     ghostd[ghost*6 + GHOST_Y]=96;
  }
}

static void  initGhost(int ghost,int time){
 
  ghostd[ghost*6 + GHOST_MODE]=4+time;
  ghostd[ghost*6 + GHOST_X]=112;
  ghostd[ghost*6 + GHOST_Y]=96;
}

static   int distanceRight=10000;
static   int distanceLeft=10000;
static   int distanceUp =10000;
static   int distanceDown = 10000;
static   int minimum=10000;
static   int ltemp=0;
static   int targetX=0; 
static   int targetY=0;
static   int tunnel=0; 
static   int mapdx,mapdy,distance,xd,yd;
static  int giy; 
static  int gix;
static  int scared;
static  int mode; 
static  int ghostdir;
static  int spd;

static void  processGhost(int ghost){
 
  giy=ghost*6 + GHOST_Y; 
  gix=ghost*6 + GHOST_X;
  scared=ghost*6 + GHOST_SCARED;
  mode=ghost*6 + GHOST_MODE; 
  ghostdir=ghost*6 + GHOST_DIR;
  spd=ghost*6 + GHOST_SPEED;
  if ((ghostd[giy]<126) && (ghostd[giy]>105) && (ghostd[gix]<44 ||ghostd[gix]>180)) tunnel=1; else tunnel=0;
  
  if (EnergizerTimer==0 && ghostd[scared]==1) ghostd[scared]=0;
  
  if (PacX>>3==(ghostd[gix]+4)>>3 && PacY>>3==(ghostd[giy]+4)>>3) {
    if (ghostd[scared]==1) {
      ghostd[mode]=DEAD;
      ghostd[scared]=0;
      ghostd[gix]=ghostd[gix] & 0xFFFE;  //Clear LSB
      ghostd[giy]=ghostd[giy] & 0xFFFE;
      
      PacGhostCounter++;
	  lastscore=score;
      score=score + (long) (100<<PacGhostCounter);
	  if (score>=10000L && lastscore<10000L) { lives++;  Lionsys.print_num(4,7,lives); }
	  
      PacEatGhost=40;
    } else if (ghostd[mode]!=DEAD) {
      PacDead=15*5;
      resetGhost(blinky,0);
      resetGhost(pinky,60);
      resetGhost(inky,120);
      resetGhost(clyde,180);
	  lives--;
	  Lionsys.screen( 0, 1);
	  Lionsys.print_num(4,7,lives);
	  Lionsys.screen( 0, 6);
    }
  }
  
  //newDir:
  if ((ghostd[gix]%8==0) && (ghostd[giy]%8==0) &&(tunnel==0)) {

    if (ghostd[scared]==1){
		if (Lionsys.rnd(10)<6) targetX = 27; else targetX=1;
        if (Lionsys.rnd(10)<6) targetY = 30; else targetY=1;
    } else	
	if (ghostd[mode]==NORMAL) {
      if (GlobalMode==0) { //Scatter
        if (ghost==pinky)  {targetX=3;  targetY=1;}
        if (ghost==blinky) {targetX=25; targetY=1;}
        if (ghost==inky)   {targetX=27; targetY=30;}
        if (ghost==clyde)  {targetX=1;  targetY=30;}
      } else {  // Chase
        targetX=PacX>>3; 
        targetY=PacY>>3;
        if (ghost==pinky) {
			if (PacDir==RIGHT)  targetX+=4; else if (PacDir==LEFT) targetX+=-4;
			if (PacDir==DOWN)   targetY+=4; else if (PacDir==UP) targetY+=-4;
        }
        if (ghost==clyde) {
		  temp=((ghostd[giy]>>3)-(PacY>>3)); 
		  distance = temp*temp;
		  temp = ((ghostd[gix]>>3)-1-(PacX>>3));
          distance+= temp*temp;
          if (distance<64) {targetX=1; targetY=30;}
        }
        if (ghost==inky) {
                   
          if (PacDir==RIGHT)  targetX+=2; else if (PacDir==LEFT) targetX+=-2;
		  if (PacDir==DOWN)   targetY+=2; else if (PacDir==UP) targetY+=-2;
          
          xd = ghostd[gix]>>3;
          yd = ghostd[giy]>>3;
          xd -= targetX;
          yd -= targetY;
          xd=xd<<1;
          yd=yd<<1;
          
          targetX-=xd;
          targetY-=yd;
        }
      }
    }

	
    if (ghostd[mode]==DEAD){
        targetX = 14;
		targetY = 11;
		}
    if (ghostd[mode]==DEAD && (ghostd[gix]>>3)==13 && (ghostd[giy]>>3)==11) {
	  ghostd[mode]=TRAPPED+30;
	  ghostd[giy]++;
	  ghostd[ghostdir]=DOWN;
	  //break newDir;
	  ///return;
    }
    else
	{
		if (ghostd[mode]==RELEASED){
			targetX = 13;
			targetY = 11;
			if ((ghostd[giy]>>3)==13 && (ghostd[gix]>>3)==13) {
			  ghostd[mode]=NORMAL;
			  ghostd[ghostdir]=UP;
			  ghostd[giy]--;
			}
		}
		if (ghostd[mode]>=TRAPPED){
			if (ghostd[mode]<255) ghostd[mode]--;
			targetY = 14;
			targetX = 13;
			if (ghost==inky) targetX = 11;
			if (ghost==clyde) targetX = 15;
		}
		//Find paths
		distanceRight=10000;
		distanceLeft=10000;
		distanceUp =10000;
		distanceDown = 10000;
		minimum=10000;
		
		mapdx=(ghostd[gix]>>3); mapdy=(ghostd[giy]>>3); 
		//If tile is not the one we came from, and is not a wall...
		if ((ghostd[ghostdir]!=LEFT) && (map[(mapdy)*28+mapdx+1]!=1)) {
	      ltemp=(ghostd[giy]/8-targetY); distanceRight=ltemp*ltemp;
		  ltemp=(ghostd[gix]/8+1-targetX);  distanceRight+=ltemp*ltemp; 
		 if (distanceRight<minimum) minimum=distanceRight;
		} else distanceRight=10001;
		if ((ghostd[ghostdir]!=RIGHT) && (map[(mapdy)*28+mapdx-1]!=1)) {
		  ltemp=(ghostd[giy]/8-targetY); distanceLeft=ltemp*ltemp;
		  ltemp=(ghostd[gix]/8-1-targetX); distanceLeft+=ltemp*ltemp;
		  if (distanceLeft<minimum) minimum=distanceLeft;
		} else distanceLeft=10001;
		if ((ghostd[ghostdir]!=DOWN) && (map[(mapdy-1)*28+(mapdx)]!=1)) {
			ltemp=(ghostd[giy]/8-1-targetY); distanceUp=ltemp*ltemp;
		   ltemp=(ghostd[gix]/8-targetX); distanceUp+=ltemp*ltemp;
		  if (distanceUp<minimum) minimum=distanceUp;
		} else distanceUp=10001;
		if ((ghostd[ghostdir]!=UP) && (map[(mapdy +1)*28+(mapdx)]!=1)) {
		  ltemp=(ghostd[giy]/8+1-targetY); distanceDown=ltemp*ltemp;
		  ltemp=(ghostd[gix]/8-targetX); distanceDown+= ltemp*ltemp;
		  if (distanceDown<minimum) minimum=distanceDown;
		} else distanceDown=10001;
		if (distanceUp<=minimum) ghostd[ghostdir]=UP;
		else if (distanceRight<=minimum) { 
			ghostd[ghostdir]=RIGHT; 
			set_sprite_data( 1+ghost, 0, gostdt, 0, orcolor[ghost]);
			set_sprite_data( 1+ghost, 1, gostdt, 1, orcolor[ghost]);
			}
		else if (distanceDown<=minimum) ghostd[ghostdir]=DOWN; 
		else if (distanceLeft<=minimum) {
			ghostd[ghostdir]=LEFT; 
			set_sprite_data( 1+ghost, 0, gostdt, 2, orcolor[ghost]);
			set_sprite_data( 1+ghost, 1, gostdt, 3, orcolor[ghost]);
			}
		}
  }
  
  
  doubleSpeed=1; speed=9;
  if (tunnel==1) speed=5;
  if (ghostd[scared]==1) speed=6; 
  if (ghostd[gix]%8==0 && ghostd[giy]%8==0) speed=10;
  if (ghostd[mode]==DEAD) {doubleSpeed=2; speed=10;}
  
  while ((doubleSpeed)!=0){
    ghostd[spd]+=speed;
    if (ghostd[spd]>9) {
      if (ghostd[ghostdir]==RIGHT) ghostd[gix]++;
      if (ghostd[ghostdir]==LEFT) ghostd[gix]--;
      if (ghostd[ghostdir]==UP) ghostd[giy]--;
      if (ghostd[ghostdir]==DOWN) ghostd[giy]++;
      ghostd[spd]-=10;
    }
	if (ghostd[gix]<8) {ghostd[gix]=218;} else  if (ghostd[gix]>218) {ghostd[gix]=8;}
	/* temp=wrap(ghostd[gix]);
    ghostd[gix]=temp; */
	doubleSpeed--;
  }
}

static int stune[]= { 
  0x00,0x00,0x00,0x3C,0x00,0x51,0x00,0x60,
  0x00,0x3C,0x51,0x00,0x00,0x60,0x60,0x00,
  0x00,0x00,0x00,0x39,0x00,0x4C,0x00,0x5B,
  0x00,0x39,0x4C,0x00,0x00,0x5B,0x5B,0x00,
  0x00,0x00,0x00,0x3C,0x00,0x51,0x00,0x60,
  0x00,0x3C,0x51,0x00,0x00,0x60,0x60,0x00,
  0x00,0x60,0x5B,0x55,0x00,0x55,0x51,0x4C,
  0x00,0x4C,0x48,0x44,0x00,0x3C,0x3C,0x00,
  
  0xA2,0xF3,0xF3,0xF3,0x00,0x00,0x00,0x00,
  0xA2,0xF3,0xF3,0xF3,0x00,0x00,0x00,0x00,
  0x99,0xE6,0xE6,0xE6,0x00,0x00,0x00,0x00,
  0x99,0xE6,0xE6,0xE6,0x00,0x00,0x00,0x00,
  0xA2,0xF3,0xF3,0xF3,0x00,0x00,0x00,0x00,
  0xA2,0xF3,0xF3,0xF3,0x00,0x00,0x00,0x00,
  0xA2,0xC1,0x00,0x00,0x00,0xAD,0x00,0x00,
  0x00,0x99,0x00,0x00,0x00,0x79,0x79,0x00
};
static int snd;

static void init(int l)
{
	PacX = 112;
	PacY = 190;
	PacDir=UP;
	PacFrame=0;
	FoodEaten=0;
	PacDead=0;
	PacEatGhost=0;
	PacGhostCounter=0;
	GlobalMode = 1; // 1=chase, 0=scatter
	cherry=0;
	initGhost(blinky,10);
	initGhost(pinky,70);
	initGhost(inky,140);
	initGhost(clyde,210);
	EnergizerTimer=0;
	ModeTimer=1;
	temp=0;  GhostFrame=0;
	int size=Lionsys.loadbini("PACMAP  DAT",map);
    for (j=1;j<30;j++)
	  for (i=0;i<27;i++) {
		tempx=(200L*(long) i*4L)/248L;  tempy=(200L*(long) j*8L)/248L;
		if (map[j*28+i]==2) dot(OFFSET_X/2+4+(int)tempx,OFFSET_Y+8+(int)tempy,0x77,0);    // Dots
		if (map[j*28+i]==3) dot(OFFSET_X/2+3+(int)tempx,OFFSET_Y+7+(int)tempy,0x66,1);  // Energizers
	  }
	snd=0;
	Lionsys.out(31,0); Lionsys.out(32,1); Lionsys.out(11,0);
	while (snd<64) if (Lionsys.isplaying(2)==0 && Lionsys.isplaying(1)==0) {
		Lionsys.sound(1,32500/stune[snd],2);
		Lionsys.sound(2,32500/stune[snd+64],2);
		snd++;
	}
	if (l==0) {
		score=0L; lives=3; gspeed=14; lastscore=0L;
	}
}

	static int lives=3,level=0,t1,t2,i,j,buffer0=0,bcount=0,gspeed;
	static void main()
	{
		t1=0; hiscore=1000L;
		//Lionsys.out(24,1);
		Lionsys.screen( 0, 6);
		//blit(10,120,pacmand,3);
		for (i=0; i<45; i++) { set_sprite( i, 0, 0, 0, 0); set_sprite( i, 1, 0, 0, 0);}
			
		set_sprite_data( 0, 0, pacmand, 0, 0);
		set_sprite_data( 0, 1, pacmand, 4, 0);
		set_sprite_data( 1+clyde, 0, gostdt, 0, 0x22);
		set_sprite_data( 1+clyde, 1, gostdt, 1, 0x22);
		set_sprite_data( 1+pinky, 0, gostdt, 0, 0x11);
		set_sprite_data( 1+pinky, 1, gostdt, 1, 0x11);
		set_sprite_data( 1+blinky, 0, gostdt, 0, 0);
		set_sprite_data( 1+blinky, 1, gostdt, 1, 0);
		set_sprite_data( 1+inky, 0, gostdt, 0, 0x99);
		set_sprite_data( 1+inky, 1, gostdt, 1, 0x99);
		set_sprite_data( 6, 0, fruit, 0, 0);
		set_sprite_data( 6, 1, fruit, 0, 0);
		 set_sprite( 6, 0, 0, 0, 0);
		/* for (j=0;j<30;j++) for (i=0;i<28;i++) Lionsys.print_num(j,i+10,map[j*28+i]);  */
		t1=Lionsys.timer();
		key=0;
		//set_sprite( 0, 0, 1, PacX, PacY);
		Lionsys.screen( 0, 6);
		Lionsys.print_str(0,1,"SCORE");
		Lionsys.print_num(2,2,0);
		Lionsys.screen( 0, 1);
		Lionsys.print_str(4,1,"LIVES:"); Lionsys.print_num(4,7,lives);
		Lionsys.print_str(4,43,"LEVEL:"); Lionsys.print_num(4,49,level+1);
		Lionsys.screen( 0, 6);
		//set_sprite( 1, 0, 1, ghostd[0], ghostd[1]);
		while (key!='Q' && key!='q') {                      //Outer loop
			init(level);
			for (i=6; i<14; i++) Lionsys.print_str(i,1,"          ");
				Lionsys.screen( 0, 1); 
				Lionsys.print_str(2,1,"         ");
				Lionsys.print_num(4,49,level+1);
				if (level<6) gspeed=14-level; else gspeed=8; 
				Lionsys.screen( 0, 6);
			while (key!='Q' && key!='q' && lives>0) {		// Main loop
				t2=Lionsys.timer();
				
				if (Lionsys.abs(t2-t1)>(gspeed)) {
					key=Lionsys.inkey();
					draw(key);
					//t1=Lionsys.timer();
					if (FoodEaten==244) {
						level++;
						set_sprite_data( 6, 0, fruit, level % 4, 0);
						set_sprite_data( 6, 1, fruit, level % 4, 0);
						Lionsys.screen( 0, 1);
						Lionsys.print_num(4,49,level+1);
						Lionsys.screen( 0, 6);
						init(level);
					}
					t1=t2;
					bcount++;
					if (bcount==8) {if (buffer0==0) buffer0=1; else buffer0=0;	Lionsys.out(20,buffer0*8); bcount=0; }
				}
			}
			key=0;
			Lionsys.screen( 0, 4);
			Lionsys.print_str(7,1,"GAME OVER!");
			Lionsys.print_str(9,1,"ENTER TO");
			Lionsys.print_str(10,1,"PLAY AGAIN");
			Lionsys.screen( 0, 2);
			level=0;
			set_sprite_data( 6, 0, fruit, 0, 0);
			set_sprite_data( 6, 1, fruit, 0, 0);
			if (score>=hiscore) {
				Lionsys.print_str(12,1,"!NEW HIGH!");
				hiscore=score;
			}
			
			Lionsys.screen( 0, 6);
			Lionsys.print_str(0,43,"HI SCORE"); Lionsys.print_long(2,44,hiscore);
			while ((key!='Q') && (key!='q') && (key!=13))
			{
				key=Lionsys.inkey();  
			}		
		}
		//Lionsys.print_long(10,40,minimum);
	}

//{keys[37]=0; keys[38]=0; keys[39]=0; keys[40]=0;}
//document.onkeydown=function(e){keys[e.keyCode]=true; if (!paused) {e.preventDefault(); e.stopPropagation(); return false;}}
//document.onkeyup=function(e){keys[e.keyCode]=false;  if (!paused) {e.preventDefault(); e.stopPropagation(); return false;}};

//(img=new Image()).onload=function(){
  //draw();
//}
//img.src="PacManSprites.png";
}