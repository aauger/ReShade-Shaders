using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Drawing;

namespace MaskGenerator
{
    struct VoronoiNode {
        public int x;
        public int y;

        public VoronoiNode(int x, int y)
        {
            this.x = x;
            this.y = y;
        }
    }

    class Program
    {
        static float Distance(VoronoiNode a, VoronoiNode b)
        {
            return (float)Math.Sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
        }

        static float map(float x, float in_min, float in_max, float out_min, float out_max)
        {
            return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
        }

        static void Main(string[] args)
        {
            const int NUM_NODES = 65_000;
            const int WIDTH = 1920;
            const int HEIGHT = 1080;

            Random rnd = new Random();
            Bitmap bmp = new Bitmap(WIDTH, HEIGHT);
            List<VoronoiNode> vnodes = new List<VoronoiNode>(NUM_NODES);
            for (int i = 0; i < NUM_NODES; i++)
            {
                vnodes.Add(new VoronoiNode(rnd.Next(0, 1920), rnd.Next(0, 1080)));
            }

            for (int x = 0; x < WIDTH; x++)
            {
                for (int y = 0; y < HEIGHT; y++)
                {
                    VoronoiNode psuedoNode = new VoronoiNode(x, y);
                    VoronoiNode closest = vnodes[0];

                    for (int i = 1; i < NUM_NODES; i++)
                    {
                        if (Distance(psuedoNode, vnodes[i]) < Distance(psuedoNode, closest))
                            closest = vnodes[i];
                    }

                    float rcol = (closest.x - psuedoNode.x) + 128;
                    float gcol = (closest.y - psuedoNode.y) + 128;
                    float bcol = map(Distance(psuedoNode, closest), 0, 182, 0, 255);

                    bmp.SetPixel(x, y, Color.FromArgb((int)rcol, (int)gcol, (int)bcol));
                }
                Console.WriteLine("COL {0}", x);
            }

            bmp.Save("mask.png", System.Drawing.Imaging.ImageFormat.Png);
        }
    }
}
