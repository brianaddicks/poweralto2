namespace PowerAlto {
		public class ActiveRoute {
				public string VirtualRouter { get; set; }
				public string Destination { get; set; }
				public string NextHop { get; set; }
				public string Metric { get; set; }
				public string Age { get; set; }
				public string Interface { get; set; }
				public List<string> Flags { get; set; }
  	}
}