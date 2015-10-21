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
	public class NatPolicy : PowerAltoBaseObject {
		public int Number;
		public string Name { get; set; }
		public string Description { get; set; }
		public string NatType { get; set; }
		public List<string> Tags { get; set; }
		
		public List<string> SourceZone { get; set; }
		public string DestinationZone { get; set; }
		public string DestinationInterface { get; set; }
		public string Service { get; set; }
		public List<string> SourceAddress { get; set; }
		public List<string> DestinationAddress { get; set; }
		
		public string SourceTranslationType { get; set; }
		public string SourceTranslatedAddressType { get; set; }
		
		public List<string> SourceTranslatedAddress { get; set; }
		public bool IsBidirectional { get; set; }
		
		public string SourceTranslatedInterface { get; set; }
		
		public string DestinationAddressTranslation { get; set; }
		public string DestinationTranslatedPort { get; set; }
		
		public bool Disabled { get; set; }
		
		public string BaseXPath {
			get {
				return "/config/devices/entry/vsys/entry/rulebase/nat/rules";
			}
		}
		
		public string XPath {
		  get {
			return this.BaseXPath + "/entry[@name='" + this.Name + "']";
		  }
		}
		
		public NatPolicy () {
			this.NatType = "ipv4";
			this.DestinationInterface = "any";
			this.Service = "any";
			this.SourceAddress = new List<string> {"any"};
			this.DestinationAddress = new List<string> {"any"};
			this.SourceTranslationType = "none";
			this.Disabled = false;
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