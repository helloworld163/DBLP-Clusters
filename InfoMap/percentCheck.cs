using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

/** checks for all or nothing for author research assignments**/

namespace percentCheck
{
    class Program
    {
        static void Main(string[] args)
        {
            Program p = new Program();
            p.start();
            p.seeMatching();

        }



        public class author
        {
            public string id;
           public  string area;
           public  string percent;
            public int[] v;
            public author(string i, string a, string p, int[] vector)
            {
                id = i;
                area = a;
                percent = p;
                v = vector;
                vectorAdd(a);
            }

            public void vectorAdd(string area)
            {
                
                switch(area)
                {
                    case "AI": v[0] = 1; break;
                    case "DB": v[1] = 1; break;
                    case "GV": v[2] = 1; break;
                    case "HA": v[3] = 1; break;
                    case "HCI": v[4] = 1; break;
                    case "ML": v[5] = 1; break;
                    case "NC": v[6] = 1; break;
                    case "PL": v[7] = 1; break;
                    case "TH": v[8] = 1; break;
                }
                    
            }


            public string printAreas()
            {
                return null;
            }
        }

        List<author> truthList = new List<author>();
        List<author> m = new List<author>();
        public void start()
        {
            StreamReader truth = new StreamReader(@"C:\Users\jortiz16\SkyDrive\MLProject\truth.csv");
            StreamReader mine = new StreamReader(@"C:\Users\jortiz16\SkyDrive\MLProject\mineIDF3MOREAUTHORSMOREPUB.csv");

       
           
          
             string s = string.Empty;
            while ((s = mine.ReadLine()) != null)
            {
                string[] split = s.Split(',');
               // string area = split[1].Remove('/');
                //has it
                if (m.Where(l => l.id == split[0]).Count() > 0)
                {
                    author auth = m.Where(l => l.id == split[0]).First();
                    auth.vectorAdd(split[1]);
                }
                else
                {
                    int[] v = new int[9];
                    author a = new author(split[0], split[1], split[3], v);
                    m.Add(a);
                }
            }
            Console.WriteLine("done");


             s = string.Empty;
             int count = 0;
            while ((s = truth.ReadLine()) != null)
            {
                string[] split = s.Split(',');

                if (m.Select(l => l.id).Contains(split[0]))
                {
                    //has it
                    if (truthList.Where(l => l.id == split[0]).Count() > 0)
                    {
                        author auth = truthList.Where(l => l.id == split[0]).First();
                        auth.vectorAdd(split[2]);
                    }
                    else
                    {
                        int[] v = new int[9];
                        author a = new author(split[0], split[2], split[4], v);
                        truthList.Add(a);
                    }
                }
                Console.WriteLine(count++);
            }
            Console.WriteLine("done");

        }

        public void seeMatching()
        {
            int totalRIGHT = 0;
            int totalWrong = 0;
            int countMatchLoop = 0;
            List<author> right = new List<author>();

            foreach (var t in truthList)
            {

                if (m.Where(l => l.id == t.id).Count() > 0)
                {
                    var getOther = m.Where(l => l.id == t.id).Select(l => l).Single();
                    if (getOther != null)
                    {
                      //  if (Array.Equals(t.v, getOther.v))
                      //  {
                      //      totalRIGHT++;
                      //  }
                      //  else
                      //  {
                      //      totalWrong++;
                      //  }
                      
                      
                        //SILLY WAY, BUT DOING SANITY CHECK
                        if (t.v[0] == getOther.v[0] && t.v[1] == getOther.v[1] && t.v[2] == getOther.v[2] &&
                            t.v[3] == getOther.v[3] && t.v[4] == getOther.v[4] && t.v[5] == getOther.v[5] &&
                            t.v[6] == getOther.v[6] && t.v[7] == getOther.v[7] && t.v[8] == getOther.v[8]
                        )
                        {
                            totalRIGHT++;
                            right.Add(t);
                        }
                        else
                        {
                            totalWrong++;
                        }


                    }
                    countMatchLoop++;
                }

              
            }

            Console.WriteLine("RIGHT : " + totalRIGHT);
            Console.WriteLine("WRONG : " + totalWrong);
            foreach (var r in right)
            {
               // Console.WriteLine(
            }
            Console.ReadLine();
        }



    }
}
