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
	public class QosPolicy : PowerAltoBaseObject {
		public string Name { get; set; }
		public string Description { get; set; }
		public List<string> Tags { get; set; }
		
		public List<string> SourceZone { get; set; }
		public List<string> SourceAddress { get; set; }
		public bool SourceNegate { get; set; }
		public List<string> SourceUser { get; set; }
		
		public string DestinationZone { get; set; }
		public List<string> DestinationAddress { get; set; }
		public bool DestinationNegate { get; set; }
		
		public List<string> Application { get; set; }
		
		public List<string> Service { get; set; }
		public List<string> UrlCategory { get; set; }
		
		public int Class { get; set; }
		public string Schedule { get; set; }
		
		public string BaseXPath {
			get {
				return "/config/devices/entry/vsys/entry/rulebase/qos/rules";
			}
		}
		
		public string XPath {
		  get {
			return this.BaseXPath + "/entry[@name='" + this.Name + "']";
		  }
		}
		
		public QosPolicy () {
			this.SourceAddress = new List<string> {"any"};
			this.SourceUser = new List<string> {"any"};
			this.DestinationAddress = new List<string> {"any"};
			this.Application = new List<string> {"any"};
			this.Service = new List<string> {"any"};
			this.UrlCategory = new List<string> {"any"};
			this.Class = 1;
			this.Schedule = "none";
		}
		
		
		
		public override XElement Xml () {
                    
			// Create root
			XDocument XmlObject = new XDocument();
			
			// create entry nod and define name attribute
			XElement xmlEntry = new XElement("entry");
			xmlEntry.SetAttributeValue("name",this.Name);
			XmlObject.Add(xmlEntry);

			//XmlObject.Element("entry").Add( createXmlWithoutMembers( this.addressType, this.address));	// Address
			//XmlObject.Element("entry").Add( createXmlWithMembers( "tag", this.Tags, false ));			      // Tags
			//XmlObject.Element("entry").Add( createXmlWithoutMembers( "description", this.Description));	// Description
			

			return XmlObject.Element("entry");
		}
	}
}