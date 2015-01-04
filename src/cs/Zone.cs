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
  public class Zone : PowerAltoBaseObject{
    private string name;
    public string Name { get { return this.name; }
                         set { this.name = nameAlphaNumDashDotUnder( value, 15 ); } }
    
    public string ZoneType { get; set; } // validatset: tap, virtual wire layer2, layer3

    public List<string> Interfaces { get; set; } //changing an interface zone will be done from the interface object

    public string ZoneProtectionProfile { get; set; } //change to object once it's made
    public string LogSetting { get; set; } //change to object once it's made
    public bool EnableUserId { get; set; }

    private List<string> userIdAclInclude;
    public List<string> UserIdAclInclude { 
      get {
        return this.userIdAclInclude;
      }
      set {
        this.userIdAclInclude = value;
        this.EnableUserId = true;
      }
    } //object or ip/net-mask, need to handle net-mask seperately from object verification

    public List<string> UserIdAclExclude { get; set; } //object or ip/net-mask, need to handle net-mask seperately from object verification
    
    public string XPath {
      get {
        string baseXPath = "/config/devices/entry/vsys/entry/zone";
        return baseXPath + "/entry[@name='" + this.Name + "']";
      }
    }
    
    public XElement Xml () {
                    
			// Create root
			XDocument XmlObject = new XDocument();
			
			// create entry nod and define name attribute
			XElement xmlEntry = new XElement("entry");
			xmlEntry.SetAttributeValue("name",this.Name);
			XmlObject.Add(xmlEntry);
      
      XElement xmlNetwork = new XElement("network");
      xmlEntry.Add(xmlNetwork);
      xmlNetwork.Add( createXmlWithMembers( this.ZoneType, this.Interfaces, false ));      

			xmlEntry.Add( createXmlBool( "enable-user-identification", this.EnableUserId));
      
      XElement xmlUserAcl = new XElement("user-acl");
      xmlEntry.Add(xmlUserAcl);
      
      xmlUserAcl.Add( createXmlWithMembers( "include-list", this.UserIdAclInclude, false ));
      xmlUserAcl.Add( createXmlWithMembers( "exclude-list", this.UserIdAclExclude, false ));

			return XmlObject.Element("entry");
	  }
    
    
		public string PrintPrettyXml() {
			return Xml().ToString();
		}

		public string PrintPlainXml() {
			return this.Xml().ToString(SaveOptions.DisableFormatting);
		}
  }
}