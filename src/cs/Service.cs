using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Web;
using System.Xml;
using System.Xml.Linq;
using System.Text.RegularExpressions;

namespace PowerAlto {
	public class Service {

		private string paNameMatch (string Name) {
			string namePattern =  @"^[a-zA-Z0-9\-_\.\ ]+$";
			Regex nameRx = new Regex(namePattern);
			Match nameMatch = nameRx.Match(Name);
			if (nameMatch.Success) {
				return Name;
			} else {
				throw new System.ArgumentException("Value can only contain alphanumeric, hyphens, underscores, or periods.");
			}
		}

		private string name;
		public string Name { get { return this.name; }
												 set { this.name = paNameMatch( value ); } }

		public string Description { get; set; }

		private string protocol;
		public string Protocol { get { return this.protocol; }
														 set { string protocolPattern = @"^(udp|tcp)$";
														 			 //Regex protocolRx = new Regex(protocolPattern);
														 			 Match protocolMatch = Regex.Match( value, protocolPattern, RegexOptions.IgnoreCase);
														 			 if (protocolMatch.Success) {
														 			 	 this.protocol = value.ToLower();
														 			 } else {
														 			 	 throw new System.ArgumentException("Protocol must be udp or tcp.");
														 			 } } }

		//Should probably add some more valiation for port ranges, ie: the second number in a range should be higher than the first.
		private string paPortMatch (string Port) {
			string portPattern = @"^(\d+(\-|\,)\d+|\d+)+$";
			Regex portRx = new Regex(portPattern);
			Match portMatch = portRx.Match(Port);
			if (portMatch.Success) {
				return Port;
			} else {
				throw new System.ArgumentException("Port can be a single port #, range (1-65535), comma separated (80,8080,443), or a combination of the three.");
			}
		}

		private string destinationPort;
		public string DestinationPort { get { return this.destinationPort; }
																		set { this.destinationPort = paPortMatch( value ); } }

		private string sourcePort;
		public string SourcePort { get { return this.sourcePort; }
															 set { this.sourcePort = paPortMatch( value ); } }

		public string Tags { get; set; }
	}
}