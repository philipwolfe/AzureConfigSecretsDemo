using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DemoConsole.Properties;

namespace DemoConsole
{
	class Program
	{
		static void Main(string[] args)
		{
			Console.WriteLine("My Setting is: " + Settings.Default.MySetting);
			Console.WriteLine("My Secret is: " + Settings.Default.MySecret);
			Console.ReadKey();
		}
	}
}
