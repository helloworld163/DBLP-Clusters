using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

/**
This program fixes the co-author list in order from ID #1 since INFOMAP wants the nodes to start from #1. Also includes a parser for the MAP file
to associate each author to the module it is assigned to
**/

namespace GRAPHFIX
{
    class Program
    {
        static void Main(string[] args)
        {
            Program p = new Program();
            p.readAndTranslate();
        }

        class Pair
        {
            int v1;
            int v2;
            public Pair(int newID, int newID2)
            {
                v1 = newID;
                v2 = newID2;
            }

            public string getString()
            {
                return v1 + " " + v2;
            }
        }

        class Node
        {
            int nodeGraphID;
            int id;
            public Node(int iden)
            {
                id = iden;
                nodeGraphID = 0;
            }
            public int getGraphID()
            {
                return nodeGraphID;
            }
            public int getNormalID()
            {
                return id;
            }
            public void setGraphID(int i)
            {
                nodeGraphID = i;
            }
        }
        public int graphID = 1;
        List<Node> listOfNodes = new List<Node>();
        List<Pair> listOfResultingPairs = new List<Pair>();
        public void readAndTranslate()
        {
            StreamReader r = new StreamReader(@"C:\Users\Jenny\Downloads\coauthors.txt");
            StreamWriter s = new StreamWriter(@"C:\Users\Jenny\SkyDrive\translatedGraph.txt");
            StreamWriter k = new StreamWriter(@"C:\Users\Jenny\SkyDrive\translatedGraphKEY.txt");

            string line = String.Empty;
            int iter = 0;
            while ((line = r.ReadLine()) != null)
            {
                string[] split = line.Split(' ');

                int pair1ID = 0;
                int pair2ID = 0;

                //check both
                if (!listOfNodes.Select(l => l.getNormalID()).ToList().Contains(int.Parse(split[0])))
                {
                    Node n = new Node(int.Parse(split[0]));
                    n.setGraphID(graphID++);
                    listOfNodes.Add(n);
                    pair1ID = n.getGraphID();
                }
                else
                {
                    var current = listOfNodes.Where(l => l.getNormalID() == int.Parse(split[0])).First();
                    pair1ID = current.getGraphID();

                }
                if (!listOfNodes.Select(l => l.getNormalID()).ToList().Contains(int.Parse(split[1])))
                {
                    Node n = new Node(int.Parse(split[1]));
                    n.setGraphID(graphID++);
                    listOfNodes.Add(n);
                    pair2ID = n.getGraphID();
                }
                else
                {
                    var current = listOfNodes.Where(l => l.getNormalID() == int.Parse(split[1])).First();
                    pair2ID = current.getGraphID();
                }

                if (pair1ID == 0 || pair2ID == 0)
                {
                    Console.WriteLine("Wrong");
                }

                listOfResultingPairs.Add(new Pair(pair1ID, pair2ID));
                Console.WriteLine(iter++);

            }

            foreach (var p in listOfResultingPairs)
            {
                s.WriteLine(p.getString());
            }

            foreach (var n in listOfNodes)
            {
                k.WriteLine(n.getGraphID() + ", " + n.getNormalID());
            }

            s.Flush();


            k.Flush();

        }
    }
    
     class Parser
    {
        static void Main(string[] args)
        {
            Program p = new Program();
            p.startParse();
        }

        class Pair
        {
            public string m;
            public string n;
            public string s;
            public Pair(string mod, string name, string score)
            {
                m = mod;
                n = name;
                s = score;
            }

            public string toStr()
            {
                return m + "," + n;
            }
        }

        List<string> names = new List<string>();

        public void startParse()
        {
            StreamReader s = new StreamReader(@"C:\Users\jortiz16\SkyDrive\MLProject\graphPAJEKWEIGHTS.map");
            String line = String.Empty;
            bool readThis = false;
            StreamWriter w = new StreamWriter(@"C:\Users\jortiz16\SkyDrive\MLProject\outputMAP.txt");

            List<Pair> list = new List<Pair>();
            while ((line = s.ReadLine()) != null)
            {
                if (line.Contains("*Nodes") || readThis)
                {
                    if (readThis == false)
                    {
                        readThis = true;
                    }
                    else if (line.Contains("*Link"))
                    {
                        readThis = false;
                    }
                    else 
                    {
                       
                        line = line.Replace("\"","");
                        string[] parts = line.Split(' ');
                        string[] mod = parts[0].Split(':');

                      //  if (!names.Contains(parts[1]))
                      //  {
                            Pair p = new Pair(mod[0], parts[1], parts[2]);
                            list.Add(p);
                           // names.Add(parts[1]);
                            w.WriteLine(p.toStr());
                      //  }
                        
                    }
                }
            }

            var dups = list.GroupBy(i => i.n).Where(g => g.Count() > 1).Select(g => g.Key);

            var c = list.Select(l => l.n).Distinct().Count();


            foreach (var d in dups)
            {
                Console.WriteLine(d);
            }

            Console.WriteLine(dups.Count());
            Console.ReadLine();



            var count = list.Select(l => l.n).Distinct().Count();


            w.Flush();
        }
    
    
}
